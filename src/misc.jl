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
