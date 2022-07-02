
# PHILLIPO

module Converters

    function convert_input(input_dict::Dict)
        # Separa os dados do dicionário de entrada em 
        type_problem              = input_dict["type"]
        nodes                     = json_vectors_into_matrix(input_dict["nodes"], Float64, 2)
        elements_triangles_linear = json_vectors_into_matrix(input_dict["elements"]["linear"]["triangles"], Int32, 5)
        constraints_forces        = json_vectors_into_matrix(input_dict["constraints"]["forces"], Any, 3)
        constraints_displacements = json_vectors_into_matrix(input_dict["constraints"]["displacements"], Any, 3)
        materials                 = json_vectors_into_matrix(input_dict["materials"], Any, 3)
        (nodes, elements_triangles_linear, constraints_forces, constraints_displacements, materials, type_problem)
    end

    function json_vectors_into_matrix(vectors::Vector{Any}, type::Any, size::Int)
        # Converte um vector de vetores em uma matriz
        vectors_length = length(vectors) - 1 # -1 porque toda a lista do JSON termina com o tipo nothing
        matrix  = Array{type, 2}(undef, vectors_length, size)
        for j = 1:vectors_length
            matrix[j, 1:size] = convert(Array{type, 1}, vectors[j])
        end
        matrix
    end

end 