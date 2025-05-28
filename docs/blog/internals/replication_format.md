# Light's Replication Format

## Notation

Some shorthand should be established before reading:

- `<D>:size(<Value?>)`
    The size of a datatype given a value.

- `<D>[<L>]`:
    An array containing items represented by `D` datatype, with the number of items represented as datatype `L`.

- `{<K>:<V>}`:
    A map of keys which are represented by `K` datatype, and values represented by `V` datatype.

- `vlq<N>`:
    A variable length quantity of `N` maximum bytes. Ex. vlq2, vlq3, etc.

## General Encoding

### Bitpack

To optimize bandwidth, sometimes light needs to [bitpack](./bitpacks.md) multiple booleans into a single byte. The
implementation for a bitpack is generally outside of the scope of this document, but it's important to understand that
they are encoded as any number of bytes, notated as `byte[<L>]` or `byte`. Technically, `byte` is the same as `u8`, but
`byte` and `byte[<L>]` will be reserved specifically for bitpacks to avoid confusion. Bitpacked booleans are annotated
as `bit`, and an optional value as `opt(T)`.

### Boundary Array

An array of u8s signifying a number of identical booleans in sequence notated as `bbyte` or `bbyte[<L>]`. Light streams
encode a "state" for `bbyte`s, defaulting to false. When encountering a boolean that does not match the current state of
the `bbyte`, the state will "flip", and write the number of items from the previous state into the `bbyte`. I.e., take
the following list of booleans:

```lua
{
    -- default false
    -- encode 0 (now true)
    true,
    -- encode 1 (now false)
    false, -- 1
    false, -- 2
    false, -- 3,
    -- encode 3 (now true)
    true, -- 1
    -- encode 1 (now false)
    false, -- 1
    -- encode 1 (now true)
    true, -- 1
    true, -- 2
    true, -- 3
    -- replication step
    -- because no "flip" in state has ocurred, the encoder does not need to write a number at the end
}
-- output: {0, 1, 3, 1, 1}
```

Optional values encoded in the `bbyte` are referred to as `bopt`s, and booleans as `bbit`. Boundary arrays, `bopt`s, and
`bbit`s are currently unavailable to users directly. For now, they are only used for internal encoding.

### Message Encoding

A message can be "high" or "low". The first 256 messages you define in light are "low", and thus use a `u8` in the
replication step. Messages defined after that are encoded with a `u16`. Messages generally store multiple fires in a
"Content Array", rather than encoding the message ID for every message fire. To give users access to bitpack
optimizations, each message also has a `bopt(byte[vlq2])`
access to bitpacked `opts` in the form of message bitpacks. A message more or less looks like this in the stream:

- `u8|u16`
    The message's ID. "Low" IDs are annotated as `LoMsg`, and "High" IDs are annotated as `HiMsg`.
- `bopt(byte[vlq2])`
    To give users access to optimizations involving packed bits, each message ID has an optional `byte[vlq2]` bitpack.
    Since a message might not have any bitpack data at all, the `bopt` for this component of the message will be false
    if the message's bitpack is empty.
- `vlq4`
    The number of bytes of content.
- `Content[]`
    All of the data encoded to this message since it was last exported.

## Stream Format

Here the encoding specifications for each part of the replication step are defined in order.

### Global Bitpack (`byte`)

A single byte encoding up to 8 `opt`s or `bit`s for light's entire internal replication step encoding schema. Things
that contribute to this limit of 8 will be annotated as either `gopt`s or `gbit`s.

### Global Boundary Array (`gopt(bbyte[vlq2])`)

Messages use a `bopt` for creating optional message-specific bitpacks, those `bopt`s are encoded here. If the boundary
array is empty (a.k.a. all `bbit`s & `bopt`s are false), the outer `gopt` will be false and no boundary array will be
encoded for this stream.

### Message Arrays

Generally, there are two places you can find Messages in the replication step:

- Low (`gopt(LoMsg[vlq2])`)
- High (`gopt(HiMsg[vlq2])`)

Low and High message arrays are lists of all the `u8` messages and `u16` messages respectively. Both of these arrays are
technically optional, but if neither low nor high messages have been sent this step, no replication batch will be
created at all.

## Export Stream

Code is slightly abridged for simplicity and readability. Stream exporting can be abstracted into 3 steps:

- Initialization

    Initialize variables, values, etc. to use for encoding.

- Allocation

    Because reallocating an entire stream is expensive, all allocation for the final stream buffer is done ahead of
    time. Once allocation is done, the next step, Writing, will copy and write relevant data into the outgoing buffer.

- Writing

    Creates a buffer with the allocated size, and encodes all of the stream's data.

### Initialization

- `#!luau local stream_pack = new_bitpack()`

- `#!luau local boundarr = new_boundary_arr()`

    Construct the global boundary array. Wait until later to allocate.

- `#!luau local allocated = 0`

    Initialize an allocated number of bytes the stream takes up for the "Allocation" step to use.

- Split Messages

    Split up `LoMsg` and `HiMsg` data into lo_batch and hi_batch respectively.

### Allocation

- `#!luau allocated += 1 -- stream_pack`

- `u8` Messages (`gopt(LoMsg[vlq2])`)

    ```luau
    local lo_arr_exists = next(lo_batch)
    if lo_arr_exists then
        stream_pack:push(true)

        for _id, msg_content, msg_bitpack in lo_batch do
            local bitpack_has_data = msg_bitpack:has_data()
            boundarr:push(bitpack_has_data)

            -- message id
            allocated += u8:size()
            -- message bitpack
            allocated += if bitpack_has_data then byte[vlq2]:size(msg_bitpack) else 0
            -- number of content bytes
            allocated += vlq4:size(msg_content.size)
            -- message contents
            allocated += msg_content.size
        end
    else
        stream_pack:push(false)
    end
    ```

- `u16` Messages (`gopt(HiMsg[vlq2])`)

    ```luau
    local hi_arr_exists = next(hi_batch)
    if hi_arr_exists then
        stream_pack:push(true)

        for _id, msg_content, msg_bitpack in hi_batch do
            local bitpack_has_data = msg_bitpack:has_data()
            boundarr:push(bitpack_has_data)

            allocated += u16:size()
            allocated += if bitpack_has_data then byte[vlq2]:size(msg_bitpack) else 0
            allocated += vlq4:size(msg_content.size)
            allocated += msg_content.size
        end
    else
        stream_pack:push(false)
    end
    ```

- Boundary Array

    Since all pushes to the bitpack bound array have been completed, it can now be allocated:

    ```luau
    if #boundarr == 0 then
        stream_pack:push(false)
        return
    end

    stream_pack:push(true)
    allocated += bbyte[vlq2]:size(boundarr)
    ```

### Writing

- `#!luau local send_buff = buffer.create(allocated)`

- `#!luau local send_ptr = 0`

- `#!luau local assert_not_reallocated: () -> ()`

- Stream Pack

    All global bits have been compiled, now they can be written:

    ```luau
    buffer.writeu8(
        send_buff,
        send_ptr,
        stream_pack[1] * 0b1 +
        stream_pack[2] * 0b10 +
        stream_pack[3] * 0b100 +
        stream_pack[4] * 0b1000 +
        stream_pack[5] * 0b10000 +
        stream_pack[6] * 0b100000 +
        stream_pack[7] * 0b1000000 +
        stream_pack[8] * 0b10000000
    )
    send_ptr += 1
    ```

- Boundary Array

    ```luau
    local boundarr_len, boundarr_buff = boundarr:as_buff()

    buffer.writeu8(send_buff, send_ptr, boundarr_len)
    send_ptr += 1

    buffer.copy(send_buff, send_ptr, boundarr_buff, 0, boundarr_len)
    send_ptr += boundarr_len
    ```

- Low Messages

    ```luau
    local LO_MSG_OFFSET = 2 ^ 20

    for id, msg_content, msg_bitpack in lo_batch do
        buffer.writeu8(send_buff, send_ptr, id - LO_MSG_OFFSET)

        if msg_bitpack:has_data() then
            send_ptr = bitpack_export_no_realloc(send_buff, send_ptr, msg_bitpack)
        end

        local content_size = msg_content.size
        send_ptr, send_buff = ser[vlq(2)](send_buff, send_ptr, content_size)
        assert_not_reallocated()

        local content_buff = msg_content.buff
        buffer.copy(send_buff, send_ptr, content_buff, 0, content_size)
        send_ptr += content_size
    end
    ```

- High Messages

    ```luau
    local HI_MSG_OFFSET = LO_MSG_OFFSET + 2 ^ 8

    for id, msg_content, msg_bitpack in lo_batch do
        buffer.writeu16(send_buff, send_ptr, id - HI_MSG_OFFSET)

        if msg_bitpack:has_data() then
            send_ptr = bitpack_export_no_realloc(send_buff, send_ptr, msg_bitpack)
        end

        local content_size = msg_content.size
        send_ptr, send_buff = ser[vlq(2)](send_buff, send_ptr, content_size)
        assert_not_reallocated()

        local content_buff = msg_content.buff
        buffer.copy(send_buff, send_ptr, content_buff, 0, content_size)
        send_ptr += content_size
    end
    ```

## Import Stream

### TODO
