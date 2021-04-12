# IOUtils.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://www.tipota.org/IOUtils.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://www.tipota.org/IOUtils.jl/dev)
[![Build Status](https://github.com/jagot/IOUtils.jl/workflows/CI/badge.svg)](https://github.com/jagot/IOUtils.jl/actions)
[![Coverage](https://codecov.io/gh/jagot/IOUtils.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jagot/IOUtils.jl)

A collection of simple helper functions for structured terminal
output, such as delimiters, indentations, and blocks.

```julia
print_boxed(stdout) do io
    println(io, "Hello")
    println(io, "World")
end
```

```
┌  Hello
└  World
```

See the documentation for a complete list of available functions.

Pull requests with additional functionality and improvements welcome!
