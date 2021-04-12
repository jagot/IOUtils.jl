using Documenter, IOUtils

makedocs(;
    modules=[IOUtils],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/jagot/IOUtils.jl/blob/{commit}{path}#L{line}",
    sitename="IOUtils.jl",
    authors="Stefanos Carlström <stefanos.carlstrom@gmail.com>",
    doctest=false
)

deploydocs(;
    repo="github.com/jagot/IOUtils.jl",
)
