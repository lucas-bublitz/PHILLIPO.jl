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

    include("./modules/includes.jl") # Chamando todos os módulos locais

    # MÓDULOS INTERNOS
    import .IOStream
    import .Elements
    import .Converters
    import LinearAlgebra
    # PONTO DE PARTIDA
    function main()
        IOStream.header_prompt()
        (nodes, elements_triangles_linear, constraints_forces, constraints_displacements, materials, type_problem) = string(@__DIR__ ,"/input.dat") |> IOStream.open_parse_input_file |> Converters.convert_input
        
        nodes_length = size(nodes)[1]
        F_global_force_vector = zeros(Float64, 2 * nodes_length)
        K_global_stiffness_matrix = zeros(Float64, 2 * nodes_length, 2 * nodes_length)

        # VETOR DE GRAUS DE LIBERADE
        # Fixos
        constraints_displacements_length = size(constraints_displacements)[1]
        constraints_displacements_vector = zeros(Int32, 2 * constraints_displacements_length)
        for j = 1:constraints_displacements_length
            constraints_displacements_vector[2*j-1:2*j] = [2 * constraints_displacements[j,1] - 1, 2 * constraints_displacements[j,1]]
        end

        # Livres
        free_displacements_vector = filter(x -> x ∉ constraints_displacements_vector, 1:2*nodes_length)

        # ELEMENTOS TRIANGULARES LINEARES, cálculo da matriz de rigidez
        elements_triangles_linear_length = size(elements_triangles_linear)[1]
        if(elements_triangles_linear_length > 0)
            @time for j = 1:elements_triangles_linear_length
                D::Array{Float64, 2}                        = Elements.generate_D_matrix(type_problem, materials[elements_triangles_linear[j, 2], :])
                K_triangle_linear_matrix::Array{Float64, 2} = Elements.generate_K_triangle_linear_matrix(elements_triangles_linear[j, :], nodes, D)
                Elements.assemble_stiffness_matrix!(K_global_stiffness_matrix, elements_triangles_linear[j,3:5], K_triangle_linear_matrix)
            end
        end

        # CONDIÇÕES DE CONTORNO
        # Forças
        constraints_forces_length = size(constraints_forces)[1]
        for j = 1:constraints_forces_length
            F_global_force_vector[2 * constraints_forces[j,1] - 1:2 * constraints_forces[j,1]] = constraints_forces[2:3]
        end

        U_displacement_vector = Elements.generate_U_displacement_vector(K_global_stiffness_matrix,F_global_force_vector,free_displacements_vector)

        F_global_force_vector[constraints_displacements_vector] = K_global_stiffness_matrix[free_displacements_vector, constraints_displacements_vector]' * U_displacement_vector[free_displacements_vector]
        output_file = open(string(@__DIR__,"/output.favia.res"), "w")

        IOStream.write_vector_on_output_file(output_file, U_displacement_vector, ("displacements"," 2  1  2  1  0"))
        close(output_file)  
    end
end

import .PHILLIPO
@time PHILLIPO.main()
exit()