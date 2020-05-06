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
