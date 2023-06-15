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

    # MÓDULOS EXTERNOS
    import LinearAlgebra
    import SparseArrays

    # MÓDULOS INTERNOS
    import .IOfiles
    import .Elements
    import .Solver
    import .Matrices
    import .Stress
    
    # PONTO DE PARTIDA (aqui inicia a execução)
    function main(
            input_path::String, # Arquivo de entrada (.json)
            output_path::String # Arquivo de saida (.post.res, formato do GiD)
        )
        IOfiles.header_prompt()
        println("Número de threads: $(Threads.nthreads())")
        print("Lendo arquivo JSON...                                                 ")
        
        @time input_dict = string(input_path) |> IOfiles.open_parse_input_file
        
        problem_type = input_dict["type"]
        nodes = input_dict["nodes"]
        materials = input_dict["materials"]
        constraints_forces_nodes    = input_dict["constraints"]["forces_nodes"]
        constraints_forces_lines    = input_dict["constraints"]["forces_lines"]
        constraints_forces_surfaces = input_dict["constraints"]["forces_surfaces"]
        constraints_displacments    = input_dict["constraints"]["displacements"]
        
        println("Tipo de problema: $(problem_type)")

        # REMOVENDO ELEMENTOS NÃO UTILIZADOS
        # esses elementos nulos são gerados pelo modo que o arquivo JSON é criado pelo GiD
        # É uma falha que deve ser corrigida, mas que não é urgente.
        pop!(nodes)
        pop!(materials)
        pop!(constraints_forces_nodes)
        pop!(constraints_forces_lines)
        pop!(constraints_forces_surfaces)
        pop!(constraints_displacments)

        if isempty(materials) error("Não há nenhum material definido!") end

        # VARIÁVEIS do PROBLEMA
        dimensions = input_dict["type"] == "3D" ? 3 : 2
        nodes_length = length(nodes)
        Fg = zeros(Float64, dimensions * nodes_length)
        Ug = zeros(Float64, dimensions * nodes_length)

        # GRAUS DE LIBERDADE: LIVRES E PRESCRITOS
        if problem_type == "3D"
            dof_prescribe = reduce(vcat, map((x) -> [3 * x[1] - 2, 3 * x[1] - 1, 3 * x[1]], constraints_displacments))
            dof_free = filter(x -> x ∉ dof_prescribe, 1:dimensions*nodes_length)
            # RESTRIÇÃO DE DESLOCAMENTO
            Ug[dof_prescribe] = reduce(vcat, map((x) -> [x[2], x[3], x[4]], constraints_displacments))
        else
            dof_prescribe = reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_displacments))
            dof_free = filter(x -> x ∉ dof_prescribe, 1:dimensions*nodes_length)
            # RESTRIÇÃO DE DESLOCAMENTO
            Ug[dof_prescribe] = reduce(vcat, map((x) -> [x[2], x[3]], constraints_displacments))
        end


        # CONSTRUÇÃO DOS ELEMENTOS
        print("Construindo os elementos e a matrix de rigidez global paralelamente...")
        @time Kg = Elements.assemble_stiffness_matrix(input_dict["elements"]["linear"], materials, nodes, problem_type)
        
        print("Aplicando as restrições de força...                                   ")
        @time if problem_type == "3D"
            # RESTRIÇÕES DE FORÇA SOBRE NÓS
            if !isempty(constraints_forces_nodes)
                dof_constraints_forces_nodes = reduce(vcat, map((x) -> [3 * x[1] - 2, 3 * x[1] - 1, 3 * x[1]], constraints_forces_nodes))
                Fg[dof_constraints_forces_nodes] = reduce(vcat, map((x) -> [x[2], x[3], x[4]], constraints_forces_nodes))
            end
            # RESTRIÇÃO DE FORÇAS SOBRE SUPERFÍCIES (somente TetrahedronLinear)
            if !isempty(constraints_forces_surfaces)
                Elements.assemble_force_surface!(Fg, nodes, constraints_forces_surfaces)
            end
        else
            # RESTRIÇÕES DE FORÇA SOBRE NÓS
            if !isempty(constraints_forces_nodes)
                dof_constraints_forces_nodes = reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_forces_nodes))
                Fg[dof_constraints_forces_nodes] = reduce(vcat, map((x) -> [x[2], x[3]], constraints_forces_nodes))
            end
            # RESTRIÇÃO DE FORÇAS SOBRE LINHAS (somente TriangleLinear)
            if !isempty(constraints_forces_lines)
                Elements.assemble_force_line!(Fg, nodes, constraints_forces_lines)
            end
        end


        print("Resolvendo o sistema...                                               ")
        @time Solver.direct_solve!(Kg, Ug, Fg, dof_free, dof_prescribe)

        print("Calculando as reações...                                              ")
        @time Re, Re_sum = Stress.reactions(Kg, Ug, dimensions)

        println("Somatório das reações: $(Re_sum)")

        print("Recuperando as tensões...                                             ")
        @time σ, σvm = Stress.recovery(input_dict["elements"]["linear"], Ug, materials, nodes, problem_type)

        print("Imprimindo o arquivo de saída...                                      ")
        @time begin
            output_file = open(string(output_path), "w")
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
            IOfiles.write_result_gauss_center(output_file,
                "Result \"Stress\" \"Load Analysis\" 0 $( problem_type == "3D" ? "matrix" : "PlainDeformationMatrix") OnGaussPoints \"gpoints\"", 
                σ
            )

            # REAÇÕES
            IOfiles.write_result_nodes(output_file,
                "Result \"Reactions\" \"Load Analysis\" 0 Vector OnNodes", 
                dimensions, Re
            )
            # VON MISSES
            IOfiles.write_result_gauss_center(output_file,
                "Result \"Von Misses\" \"Load Analysis\" 0 scalar OnGaussPoints \"gpoints\"",
                σvm
            )

            close(output_file)

        end
        print("Tempo total de execução: ")
    end
end
