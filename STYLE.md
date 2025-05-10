# Style

A mirror of this file is available on [The Documentation Site](http://light.ardi.gg/contributing/)

Rule number 1 is to follow your own discretion when choosing how to style code and documentation. You generally
shouldn't need to think about these rules too much, and they shouldn't become a burden. If you think something about
this guide should be changed, or if you have a reason for breaking these rules, make a PR or leave a comment on one
respectively. Styling change PRs are also welcome.

## Inline Documentation Rules

- Light is not designed for moonwave or other docgen in mind.

- Comments should be placed on the lines preceding line(s) of code, not on the same line.

- Do not write explanations that would not make sense without prior context. Comments should be "self-contained" in a
way that anyone can understand as long as they're familiar with a high-level representation of the problem being solved.

- To avoid comments that might not make sense after future changes, do not describe any action inside of a "data"
comment. Any data structure's explanation should be immediate, and independant of that data structure's consumer. I.e.,
a set data structure should not have a comment telling you what happens "when" that data is accessed somewhere else in
the code.

- Function docs should always use `--[=[` comments.

- Explanations for multiple lines of code must be enclosed in a multiline comment --[[ or --[=[ even if the explanation
is only a single line.

- In contrast, all lines explaining a single control flow or line of code should use multiple comments:

    ```none
    --- foo
    --- bar
    --- baz
    print("Hello, World!")
    ```

- For blocks / multilines of variables and types, prefer multiple fields or variables being explained in one "list"
comment block, as opposed to comments interleaved with each variable. This makes it easy to collapse large explanations
when not reading.

- Descriptions of item(s) in a block should begin with an indented line of some kind
(hyphens / regular comment or tab acceptable), followed by unindented lines.

- Inline Documentation should always be no more than 120 columns wide. Wrapping should always and only happen at the
furthest applicable boundary that does not harm readability.

- To make collapsing block comments more convenient, it is recommended that blocks have a title which is on the same
line that the block begins.

- Item/description lists in documentation blocks should always be followed by a newline, even at the end of a list.

- Boundaries in inline documentation topics should always be separated by a new multiline comment.

## API Documentation Rules

There are three forms of "API Documentation" for light. The markdown site, the luau documentation, and the typescript
documentation. It's a bit of a mess, but generally:

- User-Facing API documentation should only be present in `.h.luau` or typescript definition files. Otherwise, refer to
inline doc style guide.

- Simple descriptions for a function or property should come before a code block describing the function or property's
type.

- In markdown files, links to pages that are not part of the markdown site should open in a new tab. You can find
examples of this in the README.md links.
