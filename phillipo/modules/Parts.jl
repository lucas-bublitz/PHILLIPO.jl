
# PHILLIPO
# Módulo: definição dos objetos de estrutura e elementos, chamados partes

module Parts

    import LinearAlgebra

    function generate_K_triangle_linear_matrix(element::Array{Int32, 1}, nodes::Array{Float64, 2}, D::Array{Float64, 2})::Array{Float64, 2}
        index     = element[1] 
        i_index   = element[3]
        j_index   = element[4]
        m_index   = element[5]

        i::Vector{Float64} = nodes[i_index, :]
        j::Vector{Float64} = nodes[j_index, :]
        m::Vector{Float64} = nodes[m_index, :]

        Δ::Float64 = 1/2 * LinearAlgebra.det([
            1  i[1]  i[2];
            1  j[1]  j[2];
            1  m[1]  m[2]
        ])
        
        a_i::Float64 = j[1] * m[2] - m[1] * j[2]
        b_i::Float64 = j[2] - m[2]
        c_i::Float64 = m[1] - j[1]

        a_j::Float64 = m[1] * i[2] - i[1] * m[2]
        b_j::Float64 = m[2] - i[2]
        c_j::Float64 = i[1] - m[1]

        a_m::Float64 = i[1] * j[2] - j[1] * i[2]
        b_m::Float64 = i[2] - j[2]
        c_m::Float64 = j[1] - i[1]

        interpolation_function_coeff::Array{Float64, 2} = [
            a_i b_i c_i;
            a_j b_j c_j;
            a_m b_m c_m
        ]

        B::Array{Float64, 2} = 1/(2Δ) * [
            b_i 0   b_j 0   b_m 0  ;
            0   c_i 0   c_j 0   c_m;
            c_i b_i c_j b_j c_m b_m
         ]
         
        B' * D * B
    end

    function generate_D_matrix(problem_type::String, material::Vector{Any})::Array{Float64, 2}
        E::Float64 = material[2] # Módulo de young
        ν::Float64 = material[3] # Coeficiente de Poisson
        if problem_type == "plane_strain"
            return E / ((1 + ν) * (1 - 2ν)) * [
                (1 - ν) ν       0           ;
                ν       (1 - ν) 0           ;
                0       0       (1 - 2ν) / 2
            ]
        elseif problem_type == "3D"
            
        else
            error("PHILLIPO: Tipo de problema desconhecido!")
        end
    end

    function assemble_stiffness_matrix!(K_global_matrix::Array{Float64, 2}, nodes::Vector{Int32}, K_element_matrix::Array{Float64, 2})
        nodes_length = length(nodes)
        degrees_vector = Vector{Int32}(undef, 2 * nodes_length)
        for j = 1:nodes_length
            degrees_vector[2 * j - 1: 2* j] = [2 * nodes[j] - 1, 2 * nodes[j]]
        end 
        K_global_matrix[degrees_vector, degrees_vector] += K_element_matrix
    end

    function generate_U_displacement_vector(K_global_stiffness_matrix::Matrix{Float64},F_global_force_vector::Vector{Float64},free_displacements_vector::Vector{Int64})
        U_displacement_vector = zeros(Float64, length(F_global_force_vector))
        K_free_displacements = K_global_stiffness_matrix[free_displacements_vector,free_displacements_vector]

        U_displacement_vector[free_displacements_vector] = K_free_displacements \ F_global_force_vector[free_displacements_vector]
        U_displacement_vector
    end
        
end