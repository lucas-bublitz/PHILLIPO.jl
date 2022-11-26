#       ___           ___                       ___       ___                   ___           ___      #
#      /\  \         /\__\          ___        /\__\     /\__\      ___        /\  \         /\  \     #
#     /  \  \       / /  /         /\  \      / /  /    / /  /     /\  \      /  \  \       /  \  \    #
#    / /\ \  \     / /__/          \ \  \    / /  /    / /  /      \ \  \    / /\ \  \     / /\ \  \   #
#   /  \~\ \  \   /  \  \ ___      /  \__\  / /  /    / /  /       /  \__\  /  \~\ \  \   / /  \ \  \  #
#  / /\ \ \ \__\ / /\ \  /\__\  __/ /\/__/ / /__/    / /__/     __/ /\/__/ / /\ \ \ \__\ / /__/ \ \__\ #
#  \/__\ \/ /  / \/__\ \/ /  / /\/ /  /    \ \  \    \ \  \    /\/ /  /    \/__\ \/ /  / \ \  \ / /  / #
#       \  /  /       \  /  /  \  /__/      \ \  \    \ \  \   \  /__/          \  /  /   \ \  / /  /  #
#        \/__/        / /  /    \ \__\       \ \  \    \ \  \   \ \__\           \/__/     \ \/ /  /   #  
#                    / /  /      \/__/        \ \__\    \ \__\   \/__/                      \  /  /    #
#                    \/__/                     \/__/     \/__/                               \/__/     #
#                                                                                                      #
# PHILLIPO é um solver para problemas de elementos finitos                                             #
# Autor: Lucas Bublitz                                                                                 #


module PHILLIPO
    # Módulo do escopo principal

    include("./modules/includes.jl") # Módulos internos

    # MÓDUgLOS EXTERNOS
    import LinearAlgebra
    import SparseArrays

    # MÓDUgLOS INTERNOS
    import .IOfiles
    import .Elements
    import .Solver
    import .Matrices
    import .Stress
    
    # PONTO DE PARTIDA (aqui inicia a execução)
    function main()
        IOfiles.header_prompt()
        print("Lendo arquivo JSON...                 ")
        input_dict = string(@__DIR__ ,"/input.json") |> IOfiles.open_parse_input_file

        problem_type = input_dict["type"]
        nodes = input_dict["nodes"]
        materials = input_dict["materials"]
        constraints_forces = input_dict["constraints"]["forces"]
        constraints_displacments = input_dict["constraints"]["displacements"]
        
        pop!(nodes)
        pop!(materials)
        pop!(constraints_forces)
        pop!(constraints_displacments)

        # VARIÁVEIS do PROBLEMA
        dimensions = input_dict["type"] == "3D" ? 3 : 2
        nodes_length = length(nodes)
        elements = Vector{Elements.Element}()
        Fg = zeros(Float64, dimensions * nodes_length)
        Ug = zeros(Float64, dimensions * nodes_length)
        Kg_vector = [Matrices.SparseMatrixCOO() for i = 1:Threads.nthreads()]

        # GRAUS DE LIBERDADE: LIVRES E PRESCRITOS 
        if problem_type == "3D"
            dof_prescribe = reduce(vcat, map((x) -> [3 * x[1] - 2, 3 * x[1] - 1, 3 * x[1]], constraints_displacments))
            dof_free = filter(x -> x ∉ dof_prescribe, 1:dimensions*nodes_length)
            # RESTRIÇÃO DE DESLOCAMENTO
            Ug[dof_prescribe] = reduce(vcat, map((x) -> [x[2], x[3], x[4]], constraints_displacments))
            # RESTRIÇÕES DE FORÇA
            if !isempty(constraints_forces)
                dof_constraints_forces = reduce(vcat, map((x) -> [3 * x[1] - 2, 3 * x[1] - 1, 3 * x[1]], constraints_forces))
                Fg[dof_constraints_forces] = reduce(vcat, map((x) -> [x[2], x[3], x[4]], constraints_forces))
            end 
        else
            dof_prescribe = reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_displacments))
            dof_free = filter(x -> x ∉ dof_prescribe, 1:dimensions*nodes_length)
            # RESTRIÇÃO DE DESLOCAMENTO
            Ug[dof_prescribe] = reduce(vcat, map((x) -> [x[2], x[3]], constraints_displacments))
            # RESTRIÇÕES DE FORÇA
            if !isempty(constraints_forces)
                dof_constraints_forces = reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_forces))
                Fg[dof_constraints_forces] = reduce(vcat, map((x) -> [x[2], x[3]], constraints_forces))
            end 
        end

        println("Número de threads: $(Threads.nthreads())")
        
        # CONSTRUgÇÃO DOS ELEMENTOS
        print("Construindo os elementos e a matrix de rigidez global paralelamente... ")
        @time if problem_type == "3D"
            pop!(input_dict["elements"]["linear"]["tetrahedrons"])
            elements_length = length(input_dict["elements"]["linear"]["tetrahedrons"])
            elements = Vector{Elements.Element}(undef, elements_length)
            if "tetrahedrons" in keys(input_dict["elements"]["linear"])
                Threads.@threads for j in 1:elements_length
                    elements[j] = Elements.TetrahedronLinear(input_dict["elements"]["linear"]["tetrahedrons"][j], materials, nodes)
                    Matrices.add!(
                        Kg_vector[Threads.threadid()],
                        elements[j].degrees_freedom, 
                        elements[j].K
                    )
                end
            end
        else
            pop!(input_dict["elements"]["linear"]["triangles"])
            elements_length = length(input_dict["elements"]["linear"]["triangles"])
            elements = Vector{Elements.Element}(undef, elements_length)
            if "triangles" in keys(input_dict["elements"]["linear"])
                Threads.@threads for j in 1:elements_length
                    elements[j] = Elements.TriangleLinear(triangle, materials, nodes, problem_type)
                    Matrices.add!(
                        Kg_vector[Threads.threadid()],
                        elements[j].degrees_freedom, 
                        elements[j].K
                    )
                end
            end
        end
        
        print("Montando a matrix global de rigidez...")
        @time Kg = Matrices.sum(Kg_vector)
        print("Resolvendo o sistema...               ")
        @time Solver.direct_solve!(Kg, Ug, Fg, dof_free, dof_prescribe)

        println("Recuperando as tensões...")
        σ, σvm = Stress.recovery(elements, Ug)

        print("Imprimindo o arquivo de saída...      ")
        output_file = open(string(@__DIR__,"/output.post.res"), "w")
        IOfiles.write_header(output_file)

        # Pontos gaussianos
        if "tetrahedrons" in keys(input_dict["elements"]["linear"])
            write(output_file,
                "GaussPoints \"gpoints\" ElemType Tetrahedra \n",
                " Number Of Gauss Points: 1 \n",
                " Natural Coordinates: internal \n",
                "end gausspoints \n",
            )
        end
        if "triangles" in keys(input_dict["elements"]["linear"])
            write(output_file,
                "GaussPoints \"gpoints\" ElemType Triangle \n",
                " Number Of Gauss Points: 1 \n",
                " Natural Coordinates: internal \n",
                "end gausspoints \n",
            )
        end

        # DESLOCAMENTOS
        IOfiles.write_result_nodes(output_file,
            "Result \"Displacements\" \"Load Analysis\" 0 Vector OnNodes",
            dimensions, Ug
        )

        # ESTADO TENSÃO
        IOfiles.write_result_gauss(output_file,
            "Result \"Stress\" \"Load Analysis\" 0 matrix$( problem_type == "3d" ? ":3" : ":6") OnGaussPoints \"gpoints\"", 
            σ
        )

        # VON MISSES
        IOfiles.write_result_gauss(output_file,
            "Result \"Von Misses\" \"Load Analysis\" 0 scalar OnGaussPoints \"gpoints\"",
            σvm
        )
        close(output_file)
    end
end
using BenchmarkTools
import .PHILLIPO
@time PHILLIPO.main()
exit(0)


