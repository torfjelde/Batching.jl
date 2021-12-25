using Batching
using Documenter

DocMeta.setdocmeta!(Batching, :DocTestSetup, :(using Batching); recursive=true)

makedocs(;
    modules=[Batching],
    authors="Tor Erlend Fjelde <tor.erlend95@gmail.com> and contributors",
    repo="https://github.com/torfjelde/Batching.jl/blob/{commit}{path}#{line}",
    sitename="Batching.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://torfjelde.github.io/Batching.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/torfjelde/Batching.jl",
    devbranch="main",
)
