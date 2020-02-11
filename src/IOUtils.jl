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
    print_boxed(io, msglines[, prefix="", suffix=""; color=:light_black, chars="[┌│└"])

Print each line in `msglines` to `io` with an enclosing box drawn to
the left, using the specified `color`. The first and last line will
additionally print the optional parameter `prefix` and `suffix`,
respectively. The box drawing characters can be customized by setting
the string `chars` to any combination of four characters.

# Examples

```jldoctest
julia> print_boxed(stdout, ["Hello", "World"], ">>>", "<<<")
┌ >>>  Hello
└  World <<<

julia> print_boxed(stdout, ["Hello world"], chars="(╭│╰")
(  Hello world

julia> print_boxed(stdout, ["Hello", "world"], chars="(╭│╰")
╭  Hello
╰  world
```
"""
function print_boxed(io::IO, msglines, prefix="", suffix="";
                     color=:light_black, chars="[┌│└")
    # This is mostly taken from the print routine behind @info &c from Base
    a,b,c,d = chars
    for (i,msg) in enumerate(msglines)
        boxstr = length(msglines) == 1 ? "$a " :
                 i == 1                ? "$b " :
                 i < length(msglines)  ? "$c " :
                                         "$d "

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
    n = length(last(split(first_line, "\n")))
    indent(fun, io, n; indent_first=false, kwargs...)
end

"""
    @display expr

Display `expr` using [`print_boxed`](@ref) along with the location
from where the macro was called (useful for debugging); a mixture of
`@show`, `display`, and `@debug`.

# Examples

```julia-repl
julia> @display sin.(1:10)
┌ sin.(1:10) =  10-element Array{Float64,1}:
│    0.8414709848078965
│    0.9092974268256817
│    0.1411200080598672
│   -0.7568024953079282
│   -0.9589242746631385
│   -0.27941549819892586
│    0.6569865987187891
│    0.9893582466233818
│    0.4121184852417566
│   -0.5440211108893698
└  @ REPL[16]:1
```

"""
macro display(a,io=:stdout)
    aname = "$a"
    suffix = "@ "*string(__source__.file)*":"*string(__source__.line)
    quote
        buf = IOBuffer()
        show(buf, MIME"text/plain"(), $(esc(a)))
        msglines = split(String(take!(buf)), "\n")
        length(msglines) > 1 && push!(msglines, "")
        print_boxed($(esc(io)), msglines, $aname*" =", $suffix, color=:green)
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
