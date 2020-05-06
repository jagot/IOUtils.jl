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
