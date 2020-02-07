module IOUtils

"""
    redirect_output(fun)

Create an `IOBuffer`, pass it to `fun`, and return the captured output
as a string.

# Examples

```jldoctest
julia> redirect_output() do io
           println(io, "Hello")
           println(io, "World")
       end
"Hello\\nWorld\\n"
```
"""
function redirect_output(fun::Function)
    buf = IOBuffer()
    fun(IOContext(buf, :color => true))
    String(take!(buf))
end

"""
    print_boxed(io, msglines[, prefix="", suffix=""; color=:light_black])

Print each line in `msglines` to `io` with an enclosing box drawn to
the left, using the specified `color`. The first and last line will
additionally print the optional parameter `prefix` and `suffix`,
respectively.

# Examples

```jldoctest
julia> print_boxed(stdout, ["Hello", "World"], ">>>", "<<<")
┌ >>>  Hello
└  World <<<
```
"""
function print_boxed(io::IO, msglines, prefix="", suffix=""; color=:light_black)
    for (i,msg) in enumerate(msglines)
        boxstr = length(msglines) == 1 ? "[ " :
                 i == 1                ? "┌ " :
                 i < length(msglines)  ? "│ " :
                                         "└ "

        printstyled(io, boxstr, bold=true, color=color)
        if i == 1 && !isempty(prefix)
            printstyled(io, prefix, " ", bold=true, color=color)
        end
        print(io, " ", msg)
        if i == length(msglines) && !isempty(suffix)
            !isempty(msg) && print(io, " ")
            printstyled(io, suffix, color=:light_black)
        end
        println(io)
    end
end

"""
    print_boxed(fun::Function, io, args...; kwargs...)

Block-version of [`print_boxed`](@ref) that via
[`redirect_output`](@ref) captures the output of `fun`, and prints
them in a block.

# Examples

```jldoctest
julia> print_boxed(stdout) do io
           println(io, "Hello")
           println(io, "World")
       end
┌  Hello
└  World
```
"""
print_boxed(fun::Function, io::IO, args...; kwargs...) =
    print_boxed(io, split(rstrip(redirect_output(fun)), "\n"), args...; kwargs...)

"""
    indent(fun, io, n[; indent_first=true])

Print all the output of `fun` to `io` indented by `n` spaces. If
`!indent_first`, the first line is _not_ indented.

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
function indent(fun::Function, io::IO, n::Int; indent_first=true)
    indentation = repeat(" ", n)
    for (i,l) in enumerate(split(redirect_output(fun), "\n"))
        (indent_first || i > 1) && write(io, indentation)
        println(io, l)
    end
end

"""
    indent(fun, io, first_line::String)

Variant of [`indent`](@ref) that will first print `first_line` and
then print all the output from `fun` indented by the length of
`first_line`.

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
function indent(fun::Function, io::IO, first_line::String)
    write(io, first_line)
    n = length(last(split(first_line, "\n")))
    indent(fun, io, n, indent_first=false)
end

macro display(a)
    aname = "$a"
    suffix = "@ "*string(__source__.file)*":"*string(__source__.line)
    quote
        buf = IOBuffer()
        show(buf, MIME"text/plain"(), $(esc(a)))
        msglines = split(String(take!(buf)), "\n")
        length(msglines) > 1 && push!(msglines, "")
        print_boxed(stdout, msglines, $aname*" =", $suffix, color=:green)
        println()
    end
end

"""
    horizontal_line([io=stdout; char="━", color=:light_black])

Draw a `color`ed horizontal line of `char`s across the whole screen.

# Example

```jldoctest
julia> horizontal_line()
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

julia> horizontal_line(char="─")
────────────────────────────────────────────────────────────────────────────────

```
"""
function horizontal_line(io::IO=stdout; char="━", color=:light_black)
    ncol = displaysize(io)[2]
    printstyled(io, repeat(char, ncol), color=color)
    println(io)
end

export redirect_output, print_boxed, indent, @display, horizontal_line

end # module