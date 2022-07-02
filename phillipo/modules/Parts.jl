
# PHILLIPO
# Módulo: definição dos objetos de estrutura e elementos, chamados partes

module Parts

    import LinearAlgebra

    function triangle_linear_local_stiffness_matrix(element::Array{Int32, 1}, nodes::Array{Float64, 2}, D::Array{Float64, 2})::Array{Float64, 2}
        index     = element[1] 
        material  = element[2]
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
            c_i b_i c_j b_m c_m b_m
         ]
         
        B' * D * B
    end

    function generate_D_matrix(problem_type::String, material::Vector{Any})::Array{Float64, 2}
        E::Float64 = material[2] # Módulo de young
        ν::Float64 = material[3] # Coeficiente de Poisson
        if problem_type == "plane_strain"
            return E / ((1 + ν) * (1 - 2ν)) * [
                1 - ν ν     0           ;
                ν     1 - ν 0           ;
                0     0     (1 - 2ν) / 2
            ]
        elseif problem_type == "plane_stress"
            
        end 
    end

end