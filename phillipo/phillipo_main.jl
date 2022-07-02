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
    import .Parts
    import .Converters

    # PONTO DE PARTIDA
    function main()

        IOStream.header_prompt()
        (nodes, elements_triangles_linear, constraints_forces, constraints_displacements, materials, type_problem) = "input.dat" |> IOStream.open_parse_input_file |> Converters.convert_input
        
        elements_triangles_linear_length = size(elements_triangles_linear)[1]
        if(elements_triangles_linear_length > 0)
            for j = 1:elements_triangles_linear_length
                D::Array{Float64, 2} = Parts.generate_D_matrix(type_problem, materials[elements_triangles_linear[j, 2], :])
                Parts.triangle_linear_local_stiffness_matrix(elements_triangles_linear[j, :], nodes, D)
                println(D)
            end
        end

    end

end

import .PHILLIPO
PHILLIPO.main()