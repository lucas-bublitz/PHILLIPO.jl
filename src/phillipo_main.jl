
# PHILLIPO
# Este arquivo serve para ser chamado pelo GiD

include("PHILLIPO.jl")

using BenchmarkTools
import .PHILLIPO
@time PHILLIPO.main()
exit(0)