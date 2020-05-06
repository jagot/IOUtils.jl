using IOUtils
using Test
using LinearAlgebra

@testset "Output redirection" begin
    @test redirect_output(io -> print(io, "Hello")) == "Hello"
    @test redirect_output() do io
        println(io, "Hello")
        println(io, "World")
    end == "Hello\nWorld\n"
    @test redirect_output() do io
        printstyled(io, "Hello World", color=:light_red)
    end == "\e[91mHello World\e[39m"
end

@testset "Print boxed" begin
    @testset "One line" begin
        @test redirect_output() do io
            print_boxed(io, ["Hello world"])
        end == "\e[90m\e[1m[ \e[22m\e[39m Hello world\n"

        @test redirect_output() do io
            print_boxed(io, ["Hello world"], color=:light_red)
        end == "\e[91m\e[1m[ \e[22m\e[39m Hello world\n"

        @test redirect_output() do io
            print_boxed(io, ["Hello world"], "Prefix", "Suffix", color=:light_red)
        end == "\e[91m\e[1m[ \e[22m\e[39m\e[91m\e[1mPrefix \e[22m\e[39m Hello world \e[90mSuffix\e[39m\n"

        @test redirect_output() do io
            print_boxed(io, ["Hello world"], chars="(╭│╰")
        end == "\e[90m\e[1m( \e[22m\e[39m Hello world\n"
    end

    @testset "Multiple lines" begin
        @test redirect_output() do io
            print_boxed(io, ["Hello", "World"], "Prefix", "Suffix", color=:light_red)
        end == """\e[91m\e[1m┌ \e[22m\e[39m\e[91m\e[1mPrefix \e[22m\e[39m Hello
\e[91m\e[1m└ \e[22m\e[39m World \e[90mSuffix\e[39m
"""
        @test redirect_output() do io
            print_boxed(io, ["Hello", "Beautiful", "World"],
                        "Prefix", "Suffix", color=:light_red)
        end == """\e[91m\e[1m┌ \e[22m\e[39m\e[91m\e[1mPrefix \e[22m\e[39m Hello
\e[91m\e[1m│ \e[22m\e[39m Beautiful
\e[91m\e[1m└ \e[22m\e[39m World \e[90mSuffix\e[39m
"""
    end

    @testset "Block interface" begin
        @test redirect_output() do io
            print_boxed(io,
                        "Prefix", "Suffix", color=:light_red) do io
                            println(io, "Hello")
                            println(io, "Beautiful")
                            println(io, "World")
                        end
        end == """\e[91m\e[1m┌ \e[22m\e[39m\e[91m\e[1mPrefix \e[22m\e[39m Hello
\e[91m\e[1m│ \e[22m\e[39m Beautiful
\e[91m\e[1m└ \e[22m\e[39m World \e[90mSuffix\e[39m
"""

        @test redirect_output() do io
            print_boxed(io,
                        "Prefix", "Suffix", color=:light_red, chars="(╭│╰") do io
                            println(io, "Hello")
                            println(io, "Beautiful")
                            println(io, "World")
                        end
        end == """\e[91m\e[1m╭ \e[22m\e[39m\e[91m\e[1mPrefix \e[22m\e[39m Hello
\e[91m\e[1m│ \e[22m\e[39m Beautiful
\e[91m\e[1m╰ \e[22m\e[39m World \e[90mSuffix\e[39m
"""
    end
end

@testset "Indentation" begin
    @test redirect_output() do io
        indent(io, 5) do io
            println(io, "Hello")
            println(io, "World")
        end
    end == """     \e[0mHello
     \e[0mWorld
"""
    @test redirect_output() do io
        indent(io, "Important information: ") do io
            println(io, "Hello")
            println(io, "World")
        end
    end == """\e[0mImportant information: \e[0mHello
                       \e[0mWorld
"""
    @test redirect_output() do io
        indent(io, "Important information: ", color=:light_red) do io
            println(io, "Hello")
            println(io, "World")
        end
    end == """\e[91mImportant information: \e[39m\e[91mHello\e[39m
                       \e[91mWorld\e[39m
"""
end

@testset "@display" begin
    filename = @__FILE__
    line = @__LINE__
    @test redirect_output() do io
        @eval @display "Hello world" $io
    end == "\e[32m\e[1m[ \e[22m\e[39m\e[32m\e[1mHello world = \e[22m\e[39m \"Hello world\" \e[90m@ $(filename):$(line+2)\e[39m\n"

    line = @__LINE__
    @test redirect_output() do io
        @eval @display identity.(1.0:10) $io
    end == """\e[32m\e[1m┌ \e[22m\e[39m\e[32m\e[1midentity.(1.0:10) = \e[22m\e[39m 10-element Array{Float64,1}:
\e[32m\e[1m│ \e[22m\e[39m   1.0
\e[32m\e[1m│ \e[22m\e[39m   2.0
\e[32m\e[1m│ \e[22m\e[39m   3.0
\e[32m\e[1m│ \e[22m\e[39m   4.0
\e[32m\e[1m│ \e[22m\e[39m   5.0
\e[32m\e[1m│ \e[22m\e[39m   6.0
\e[32m\e[1m│ \e[22m\e[39m   7.0
\e[32m\e[1m│ \e[22m\e[39m   8.0
\e[32m\e[1m│ \e[22m\e[39m   9.0
\e[32m\e[1m│ \e[22m\e[39m  10.0
\e[32m\e[1m└ \e[22m\e[39m \e[90m@ $(filename):$(line+2)\e[39m
"""
end

@testset "Horizontal lines" begin
    @test redirect_output(io -> horizontal_line(io)) ==
        "\e[90m"*repeat("━", 80)*"\e[39m\n"
    @test redirect_output(io -> horizontal_line(io,char="-")) ==
        "\e[90m"*repeat("-", 80)*"\e[39m\n"
    @test redirect_output(io -> horizontal_line(io,color=:light_red)) ==
        "\e[91m"*repeat("━", 80)*"\e[39m\n"
    @test redirect_output(io -> horizontal_line(IOContext(io, :displaysize => (10,10)))) ==
        "\e[90m"*repeat("━", 10)*"\e[39m\n"
end

@testset "Display matrices" begin
    n = 10; o = ones(n);
    T = Tridiagonal(o[2:end], -2o, o[2:end]);
    @test redirect_output() do io
        display_matrix(io, T)
    end == """ 10×10 Tridiagonal{Float64,Array{Float64,1}}:
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
"""
end

@testset "Columns" begin
    n = 6; o = ones(n);
    T = Tridiagonal(o[2:end], -2o, o[2:end]);

    @test redirect_output() do io
        io2 = IOContext(io, :displaysize => (24,93))
        columns(io2, 1//2, 2, 1//2) do ios
            display_matrix(ios[1], T)

            println(ios[2])
            println(ios[2], "-1")

            display_matrix(ios[3], T)
        end
    end == " 6×6 Tridiagonal{Float64,Array{Float64,1}}:     6×6 Tridiagonal{Float64,Array{Float64,1}}:   \n⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎤        -1⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎤         \n⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢          ⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢         \n⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢          ⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢         \n⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢          ⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢         \n⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢          ⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢         \n⎣   ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦          ⎣   ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦         \n"

    @test redirect_output() do io
        io2 = IOContext(io, :displaysize => (24,93))
        columns(io2, 1//2, 2, 1//2, trim=true) do ios
            display_matrix(ios[1], T)

            println(ios[2])
            println(ios[2], "-1")

            display_matrix(ios[3], T)
        end
    end == " 6×6 Tridiagonal{Float64,Array{Float64,1}}:   6×6 Tridiagonal{Float64,Array{Float64,1}}:\n⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎤      -1⎡ -2.0   1.0    ⋅     ⋅     ⋅     ⋅ ⎤      \n⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢        ⎢  1.0  -2.0   1.0    ⋅     ⋅     ⋅ ⎢      \n⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢        ⎢   ⋅    1.0  -2.0   1.0    ⋅     ⋅ ⎢      \n⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢        ⎢   ⋅     ⋅    1.0  -2.0   1.0    ⋅ ⎢      \n⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢        ⎢   ⋅     ⋅     ⋅    1.0  -2.0   1.0⎢      \n⎣   ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦        ⎣   ⋅     ⋅     ⋅     ⋅    1.0  -2.0⎦      \n"
end
