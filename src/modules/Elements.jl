
# PHILLIPO
# Módulo: definição dos elementos e funções relacionadas

module Elements

    #MÓDULOS EXTERNOS
    import LinearAlgebra
    using SparseArrays
    import ..Matrices

    abstract type Element end

    struct TriangleLinear <: Element

        index::Integer
        material_index::Integer
        nodes_index::Vector{Integer}
        interpolation_function_coeff::Matrix{Real}
        D::Matrix{Real}
        B::Matrix{Real}
        K::Matrix{Real}
        degrees_freedom::Vector{Integer}

        function TriangleLinear(triangle_element_vector::Vector{Any}, materials::Vector{Any}, nodes::Vector{Any}, problem_type::String)
           
            index          = triangle_element_vector[1]
            material_index = triangle_element_vector[2]
            nodes_index    = triangle_element_vector[3:5]
            

            i::Vector{Real} = nodes[nodes_index[1]]
            j::Vector{Real} = nodes[nodes_index[2]]
            m::Vector{Real} = nodes[nodes_index[3]]
    
            Δ::Real = 1/2 * LinearAlgebra.det([
                1  i[1]  i[2];
                1  j[1]  j[2];
                1  m[1]  m[2]
            ])
            
            a_i::Real = j[1] * m[2] - m[1] * j[2]
            b_i::Real = j[2] - m[2]
            c_i::Real = m[1] - j[1]
    
            a_j::Real = m[1] * i[2] - i[1] * m[2]
            b_j::Real = m[2] - i[2]
            c_j::Real = i[1] - m[1]
    
            a_m::Real = i[1] * j[2] - j[1] * i[2]
            b_m::Real = i[2] - j[2]
            c_m::Real = j[1] - i[1]

            interpolation_function_coeff::Matrix{Real} = 1/(2Δ) * [
                a_i b_i c_i;
                a_j b_j c_j;
                a_m b_m c_m
            ]

            B::Matrix{Real} = 1/(2Δ) * [
                b_i 0   b_j 0   b_m 0  ;
                0   c_i 0   c_j 0   c_m;
                c_i b_i c_j b_j c_m b_m
            ]

            D::Matrix{Real} = generate_D(problem_type, materials[material_index])

            K::Matrix{Real} = B' * D * B * Δ * 1

            degrees_freedom = reduce(vcat, map((x) -> [2 * x - 1, 2 * x], nodes_index))

            new(index, material_index, nodes_index, interpolation_function_coeff, D, B, K, degrees_freedom)
        end 
    end

    struct TetrahedronLinear <: Element
        index::Integer
        material_index::Integer
        nodes_index::Vector{Integer}
        interpolation_function_coeff::Matrix{Real}
        D::Matrix{Real}
        B::Matrix{Real}
        K::Matrix{Real}
        degrees_freedom::Vector{Integer}
        function TetrahedronLinear(tetrahedron_element_vector::Vector{Any}, materials::Vector{Any}, nodes::Vector{Any})
            index = tetrahedron_element_vector[1]
            material_index = tetrahedron_element_vector[2]
            nodes_index = tetrahedron_element_vector[3:6]
            
            i::Vector{Real} = nodes[nodes_index[1]]
            j::Vector{Real} = nodes[nodes_index[2]]
            m::Vector{Real} = nodes[nodes_index[3]]
            p::Vector{Real} = nodes[nodes_index[4]]

            position_nodes_matrix::Matrix{Real} = [
                1 i[1] i[2] i[3];
                1 j[1] j[2] j[3];
                1 m[1] m[2] m[3];
                1 p[1] p[2] p[3]
            ]
            interpolation_function_coeff::Matrix{Real} = LinearAlgebra.inv(position_nodes_matrix)
            V::Real = 1/6 * LinearAlgebra.det(position_nodes_matrix)

            a::Vector{Real} = interpolation_function_coeff[1,:]
            b::Vector{Real} = interpolation_function_coeff[2,:]
            c::Vector{Real} = interpolation_function_coeff[3,:]
            d::Vector{Real} = interpolation_function_coeff[4,:]
            
            B::Matrix{Real} = [
                b[1]  0      0    b[2]  0      0    b[3]  0      0    b[4]  0      0   ;
                0     c[1]   0    0     c[2]   0    0     c[3]   0    0     c[4]   0   ;
                0     0      d[1] 0     0      d[2] 0     0      d[3] 0     0      d[4];
                c[1]  b[1]   0    c[2]  b[2]   0    c[3]  b[3]   0    c[4]  b[4]   0   ;
                0     d[1]   c[1] 0     d[2]   c[2] 0     d[3]   c[3] 0     d[4]   c[4];
                d[1]  0      b[1] d[2]  0      b[2] d[3]  0      b[3] d[4]  0      b[4]  
            ]

            D::Matrix{Real} = generate_D("3D", materials[material_index])

            K::Matrix{Real} =  B' * D * B * V

            degrees_freedom = reduce(vcat, map((x) -> [3 * x - 2, 3 * x - 1, 3 * x], nodes_index))

            new(index, material_index, nodes_index, interpolation_function_coeff, D, B, K, degrees_freedom)
        end
    end


    function generate_D(problem_type, material)::Matrix{Real}
        # Gera a matrix da lei de Hook
        E::Float64 = material[2] # Módulo de young
        ν::Float64 = material[3] # Coeficiente de Poisson
        if problem_type == "plane_strain"
            return E / ((1 + ν) * (1 - 2ν)) * [
                (1 - ν) ν       0           ;
                ν       (1 - ν) 0           ;
                0       0       (1 - 2ν) / 2
            ]
        elseif problem_type == "3D"
            return E / ((1 + ν) * (1 - 2ν)) * [
                (1 - ν) ν       ν         0            0            0           ;
                ν       (1 - ν) ν         0            0            0           ;
                ν       ν       (1 - ν)   0            0            0           ; 
                0       0       0         (1 - 2ν) / 2 0            0           ;
                0       0       0         0            (1 - 2ν) / 2 0           ;
                0       0       0         0            0            (1 - 2ν) / 2   
            ]   
        else
            error("PHILLIPO: Tipo de problema desconhecido!")
        end
    end

    function assemble_stiffness_matrix!(K_global_matrix::Matrix{Float64}, elements::Vector{Element})::SparseMatrixCSC
        for element in elements
            K_global_matrix[element.degrees_freedom, element.degrees_freedom] += element.K
        end
    end

end