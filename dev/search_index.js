var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Batching","category":"page"},{"location":"#Batching","page":"Home","title":"Batching","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Batching.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Batching]","category":"page"},{"location":"#Batching.batch_like-Tuple{Any, Vararg{Any}}","page":"Home","title":"Batching.batch_like","text":"batch_like(input, output)\n\nReturn output as a batch similar to input, if input is a batch.\n\nIf input is not a AbstractBatch, then output is returned.\n\nExamples\n\njulia> xs = batch(ones(2, 3))\n3-element Batching.ArrayBatch{Vector{Float64}, Matrix{Float64}, 2}:\n [1.0, 1.0]\n [1.0, 1.0]\n [1.0, 1.0]\n\njulia> # Want to specialize `f` on the case of an `ArrayBatch`.\n       function f(input::Batching.ArrayBatch)\n           # Extract the underlying array.\n           input_batch_maybe = Batching.value(input)\n           # Broadcast `exp`.\n           output_batch_maybe = exp.(input_batch_maybe)\n           # Rewrap as a `batch` similar to `input`, e.g. preserving `eventdim(input)`.\n           return batch_like(input, output_batch_maybe)\n       end\nf (generic function with 1 methods)\n\njulia> f(xs)\n3-element Batching.ArrayBatch{Vector{Float64}, Matrix{Float64}, 2}:\n [2.718281828459045, 2.718281828459045]\n [2.718281828459045, 2.718281828459045]\n [2.718281828459045, 2.718281828459045]\n\n\n\n\n\n","category":"method"},{"location":"#Batching.value-Tuple{Any}","page":"Home","title":"Batching.value","text":"value(x)\n\nReturns the underlying storage used for the entire batch.\n\nIf x is not AbstractBatch, then this is the identity function.\n\n\n\n\n\n","category":"method"}]
}