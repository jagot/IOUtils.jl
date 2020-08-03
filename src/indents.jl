"""
    indent(fun, io, n[; indent_first=true, kwargs...])

Print all the output of `fun` to `io` indented by `n` spaces. If
`!indent_first`, the first line is _not_ indented. `kwargs...` are
passed on to `printstyled`.

# Examples

```jldoctest
julia> indent(stdout, 6) do io
           println(io, "Hello")
           println(io, "World")
       end
      Hello
      World
```
"""
function indent(fun::Function, io::IO, n::Int; indent_first=true, kwargs...)
    indentation = repeat(" ", n)
    for (i,l) in enumerate(split(rstrip(redirect_output(fun)), "\n"))
        (indent_first || i > 1) && write(io, indentation)
        printstyled(io, l; kwargs...)
        println(io)
    end
end

"""
    indent(fun, io, first_line::String[; kwargs...])

Variant of [`indent`](@ref) that will first print `first_line` and
then print all the output from `fun` indented by the length of
`first_line`. `kwargs` are passed on to `printstyled`.

# Examples

```jldoctest
julia> indent(stdout, "Important information: ") do io
           println(io, "Hello")
           println(io, "World")
       end
Important information: Hello
                       World


julia> indent(stdout, "Important information: ") do io
           print_boxed(io) do io
               println(io, "Hello")
               println(io, "World")
           end
       end

Important information: ┌  Hello
                       └  World
```
"""
function indent(fun::Function, io::IO, first_line::String; kwargs...)
    printstyled(io, first_line; kwargs...)
    n = textwidth(last(split(first_line, "\n")))
    indent(fun, io, n; indent_first=false, kwargs...)
end
