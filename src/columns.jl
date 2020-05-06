"""
    column_widths(io, args...)

Compute a set of integer widths that will add to the total amount of
columns of `io`. `Integer` `args` will be taken as-is, `Rational`
`args` (should add to ≤ 1) will result in integers that roughly
correspond to the fraction of the total amount of columns, minus the
`Integer` `args...`.

# Example

The default amount of columns is 80:

```jldoctest
julia> IOUtils.column_widths(open("/tmp/test.txt", "w"), 1//3, 2, 2//3)
3-element Array{Int64,1}:
 26
  2
 52
```
"""
function column_widths(io::IO, args...)
    column_budget(i::Integer) = max(i,0)
    column_budget(::Real) = 0

    widths = [column_budget(a) for a in args]

    budget = displaysize(io)[2] - sum(column_budget, widths)

    i = findall(a -> !(a isa Integer), args)
    isempty(i) && return widths

    sum(args[i]) ≤ 1 || @warn("Cumulative column widths exceed unity")

    # https://math.stackexchange.com/a/1791823/45104
    cs = trunc.(Int, cumsum(budget*[args[i]...]))
    widths[i] .= vcat(cs[1], diff(cs))
    widths
end

"""
    columns(fun::Function, io::IO, args...; trim=false)

Print things to `io` in columns, where `args...` is handled by
[`column_widths`](@ref). If `trim`, then the columns will be narrowed
to the maximum line of each column.

```jldoctest
julia> columns(stdout, 6, 10) do ios
           println(ios[1], "H")
           println(ios[1], " el")
           println(ios[1], " lo")

           println(ios[2], "ello")
           println(ios[2], "H")
       end
H     ello
 el   H
 lo


julia> columns(stdout, 6, 10, trim=true) do ios
           println(ios[1], "H")
           println(ios[1], " el")
           println(ios[1], " lo")

           println(ios[2], "ello")
           println(ios[2], "H")
       end
H  ello
 elH
 lo

julia> n = 10; o = ones(n);

julia> T = Tridiagonal(o[2:end], -2o, o[2:end]);

julia> columns(stdout, 1//2, 2, 1//2, trim=true) do ios
           display_matrix(ios[1], T)

           println(ios[2])
           println(ios[2], "-1")

           display_matrix(ios[3], T)
       end
 10×10 Tridiagonal{Float64,Array{Float64,1}}:                   10×10 Tridiagonal{Float64,Array{Float64,1}}:
⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎤-1⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎤
⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎢  ⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎢  ⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅ ⎢  ⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎢  ⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢  ⎢   ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢  ⎢   ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢  ⎢   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢
⎢   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢  ⎢   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢
⎣   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦  ⎣   ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦
```
"""
function columns(fun::Function, io::IO, args...; trim=false)
    widths = column_widths(io, args...)
    height = displaysize(io)[1]

    buffers = [IOBuffer() for w in widths]
    ios = map(enumerate(widths)) do (i,w)
        IOContext(buffers[i], :color => true, :limit => true, :displaysize => (height, w))
    end
    fun(ios)

    strs = [split(String(take!(buf)), "\n")
            for buf in buffers]

    new_widths = if !trim
        widths
    else
        map(lines -> maximum(length, lines), strs)
    end

    # Make all columns equal length; rewrite with zip and lazy vectors
    # of empty strings?
    maxlines = maximum(length, strs)
    for i in eachindex(strs)
        ls = length(strs[i])
        if ls < maxlines
            strs[i] = vcat(strs[i], repeat([""], maxlines-ls))
        end
    end

    # Drop last line if each column ends with an emptry string
    if all(isempty, last.(strs))
        for i in eachindex(strs)
            pop!(strs[i])
        end
        maxlines -= 1
    end

    for i = 1:maxlines
        for (j,lines) = enumerate(strs)
            print(io, rpad(lines[i], new_widths[j]))
        end
        println(io)
    end
end
