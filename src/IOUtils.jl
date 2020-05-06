module IOUtils

include("misc.jl")
include("boxes.jl")
include("indents.jl")
include("displays.jl")
include("columns.jl")

export redirect_output, print_boxed, indent, @display,
    horizontal_line, columns, display_matrix

end # module
