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

    # MÓDULOS EXTERNOS
    import LinearAlgebra
    
    # PONTO DE PARTIDA
    function main()
        IOStream.header_prompt()
        input_dict = string(@__DIR__ ,"/input.dat") |> IOStream.open_parse_input_file
    

        problem_type = input_dict["type"]
        nodes = input_dict["nodes"]
        materials = input_dict["materials"]
        constraints_forces = input_dict["constraints"]["forces"]
        constraints_displacments = input_dict["constraints"]["displacements"]
        pop!(nodes)
        pop!(materials)
        pop!(constraints_forces)
        pop!(constraints_displacments)
        
        # VARIÁVEIS GLOBAIS
        dimensions = input_dict["type"] == "3D" ? 3 : 2
        nodes_length = length(nodes)
        elements = Vector{Elements.Element}()
        F_global_force_vector = zeros(Float64, dimensions * nodes_length)
        K_global_stiffness_matrix = zeros(Float64, dimensions * nodes_length, dimensions * nodes_length)
        U_displacement_vector = zeros(Float64, dimensions * nodes_length)
        
        # GRAUS DE LIBERDADE, livres e restritos
        constraints_degrees = begin
            if problem_type == "3D"

            else
                reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_displacments))
            end
        end
        free_degrees = filter(x -> x ∉ constraints_degrees, 1:dimensions*nodes_length)
        
        # RESTRIÇÕES DE FORÇA
        forces_degrees = begin
            if problem_type == "3D"

            else
                reduce(vcat, map((x) -> [2 * x[1] - 1, 2 * x[1]], constraints_forces))
            end
        end
        F_global_force_vector[forces_degrees] = begin
            if problem_type == "3D"

            else
                reduce(vcat, map((x) -> [x[2], x[3]], constraints_forces))
            end
        end

        # CONSTRUÇÃO DOS ELEMENTOS
        if "triangles" in keys(input_dict["elements"]["linear"])
            pop!(input_dict["elements"]["linear"]["triangles"])
            for triangle in input_dict["elements"]["linear"]["triangles"]
                push!(elements, Elements.TriangleLinear(triangle, materials, nodes, problem_type))
            end
        end

        Elements.assemble_stiffness_matrix!(K_global_stiffness_matrix, elements)

        U_displacement_vector = Elements.generate_U_displacement_vector(K_global_stiffness_matrix,F_global_force_vector,free_degrees)

        # F_global_force_vector[constraints_displacements_vector] = K_global_stiffness_matrix[free_displacements_vector, constraints_displacements_vector]' * U_displacement_vector[free_displacements_vector]
        
        output_file = open(string(@__DIR__,"/output.favia.res"), "w")
        IOStream.write_vector_on_output_file(output_file, U_displacement_vector, ("displacements"," 2  1  2  1  0"))
        close(output_file)  
    end
end

import .PHILLIPO
@time PHILLIPO.main()
exit()