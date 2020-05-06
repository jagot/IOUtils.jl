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
    display_matrix(io, A)

Display the matrix `A` on `io` wrapped in square brackets. Quite
simple implementation that assumes the first line contains type
information and the rest of the lines are the matrix elements.

# Examples

```jldoctest
julia> n = 10; o = ones(n);

julia> T = Tridiagonal(o[2:end], -2o, o[2:end]);

julia> display_matrix(stdout, T)
 10×10 Tridiagonal{Float64,Array{Float64,1}}:
⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎤
⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢
⎣   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦
```

"""
function display_matrix(io::IO, A::AbstractMatrix)
    buf = IOBuffer()
    (height, width) = displaysize(io)
    show(IOContext(buf, :limit => true, :displaysize => (height, width-2)),
         MIME"text/plain"(), A)

    lines = split(String(take!(buf)), "\n")
    println(io, " ", lines[1])
    body = lines[2:end]
    if length(body) == 1
        println(io, "[", body[1], "]")
    else
        println(io, "⎡", body[1], "⎤")
        for l in body[2:end-1]
            println(io, "⎢", l, "⎢")
        end
        println(io, "⎣", body[end], "⎦")
    end
end
