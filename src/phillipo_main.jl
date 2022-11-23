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
    import DataStructures

    # MÓDULOS INTERNOS
    import .IOfiles
    import .Elements
    import .Matrices
    
    # PONTO DE PARTIDA
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
        F_global_force_vector = zeros(Float64, dimensions * nodes_length)
        U_displacement_vector = zeros(Float64, dimensions * nodes_length)
        K_global_stiffness_matrix_vector = [Matrices.SparseMatrixCOO() for i = 1:Threads.nthreads()]

        if problem_type == "3D"
            # GRAUS DE LIBERDADE, livres e restritos
            constraints_degrees = reduce(vcat, map((x) -> [3 * x[1] - 2, 3 * x[1] - 1, 3 * x[1]], constraints_displacments))
            free_degrees = filter(x -> x ∉ constraints_degrees, 1:dimensions*nodes_length)
            # RESTRIÇÕES DE FORÇA
            forces_degrees = reduce(vcat, map((x) -> [3 * x[1] - 2, 3 * x[1] - 1, 3 * x[1]], constraints_forces))
            F_global_force_vector[forces_degrees] = reduce(vcat, map((x) -> [x[2], x[3], x[4]], constraints_forces))

        else
            # GRAUS DE LIBERDADE, livres e restritos
            constraints_degrees = reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_displacments))
            free_degrees = filter(x -> x ∉ constraints_degrees, 1:dimensions*nodes_length)
            #RESTRIÇÕES DE FORÇA
            forces_degrees = reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_forces))
            F_global_force_vector[forces_degrees] = reduce(vcat, map((x) -> [x[2], x[3]], constraints_forces))
        end

        println("Número de threads: $(Threads.nthreads())")
        
        # CONSTRUÇÃO DOS ELEMENTOS
        print("Construindo os elementos e a matrix de rigidez global paralelamente... ")
        @time if problem_type == "3D"
            pop!(input_dict["elements"]["linear"]["tetrahedrons"])
            elements_length = length(input_dict["elements"]["linear"]["tetrahedrons"])
            elements = Vector{Elements.Element}(undef, elements_length)
            if "tetrahedrons" in keys(input_dict["elements"]["linear"])
                Threads.@threads for j in 1:elements_length
                    elements[j] = Elements.TetrahedronLinear(input_dict["elements"]["linear"]["tetrahedrons"][j], materials, nodes)
                    Matrices.add!(
                        K_global_stiffness_matrix_vector[Threads.threadid()],
                        elements[j].degrees_freedom, 
                        elements[j].K
                    )
                end
            end
        else
            pop!(input_dict["elements"]["linear"]["triangles"])
            elements_length = length(input_dict["elements"]["linear"]["triangles"])
            elements = Vector{Elements.Element}(undef, elements_length)
            pop!(input_dict["elements"]["linear"]["triangles"])
            if "triangles" in keys(input_dict["elements"]["linear"])
                Threads.@threads for j in 1:elements_length
                    elements[j] = Elements.TriangleLinear(triangle, materials, nodes, problem_type)
                    Matrices.add!(
                        K_global_stiffness_matrix_vector[Threads.threadid()],
                        elements[j].degrees_freedom, 
                        elements[j].K
                    )
                end
            end
        end
        
        print("Montando a matrix global de rigidez...")
        @time K_global_stiffness_matrix = Matrices.sum(K_global_stiffness_matrix_vector)
        
        print("Resolvendo o sistema...               ")
        @time U_displacement_vector = Elements.generate_U(K_global_stiffness_matrix,F_global_force_vector,free_degrees)

        print("Imprimindo o arquivo de saída...      ")
        output_file = open(string(@__DIR__,"/output.flavia.res"), "w")
        @time IOfiles.write_vector_on_output_file(output_file, U_displacement_vector, ("displacements"," 2  1  2  1  0"), dimensions)
        close(output_file)
    end
end
using BenchmarkTools
import .PHILLIPO
@time PHILLIPO.main()


