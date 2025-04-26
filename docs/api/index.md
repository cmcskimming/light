# API Documentation

This part of the documentation is for all of the properties and functions you're able to access inside of light's API.
It also teaches you more about Datatypes and ways you could use them efficiently.

## Tags

### <!-- client -->

API can be accessed on the client:
<br>`#!luau require(ReplicatedStorage.light).client`

### <!-- server -->

API can be accessed on the server:
<br>`#!luau require(ReplicatedStorage.light).server`

### <!-- shared -->

API can be accessed in a shared context:
<br>`#!luau require(ReplicatedStorage.light).shared`

### <!-- sync -->

Function can run without yielding the current thread

### <!-- async -->

Function can yield the current thread

### <!-- errors -->

Function can error under specific circumstances.(1)
{.annotate}

1. This tag does not include errors from user mistakes, like trying to write a `string` into a `u8` Datatype, or calling
an API with the wrong parameters.

### <!-- experimental -->

This part of the API is considered experimental for now, and may change or be removed at any point.
