
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
    
            interpolation_function_coeff::Matrix{Real} = LinearAlgebra.inv([
                1  i[1]  i[2];
                1  j[1]  j[2];
                1  m[1]  m[2]
            ])
            
            a::Vector{Real} = interpolation_function_coeff[1,:]
            b::Vector{Real} = interpolation_function_coeff[2,:]
            c::Vector{Real} = interpolation_function_coeff[3,:]

            Δ::Real = 1/2 *  LinearAlgebra.det(interpolation_function_coeff)

            B::Matrix{Real} = 1/(2Δ) * [
                b[1] 0    b[2] 0    b[3] 0   ;
                0    c[1] 0    c[2] 0    c[3];
                c[1] b[1] c[2] b[2] c[3] b[3]
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
    
    function assemble_force_line!(
            Fg::Vector{<:Real}, 
            nodes::Vector, 
            forces::Vector, 
            d::Integer
        )

        elements_index = [i[1] for i in forces]
        nodes_index    = [i[2:3] for i in forces]
        forces_vector  = [i[4:(3 + d)] for i in forces]

        dof_i = mapreduce(el -> [d * el[1] - i for i in d-1:-1:0], vcat , nodes_index)
        dof_j = mapreduce(el -> [d * el[2] - i for i in d-1:-1:0], vcat, nodes_index) 

        nodes_i = nodes[[i[1] for i in nodes_index]]
        nodes_j = nodes[[i[2] for i in nodes_index]]


        L = LinearAlgebra.norm(nodes_i .- nodes_j)
        F = 1/2 * L .* forces_vector
        
        Fe = reduce(vcat, F)

        Fg[dof_i] = Fe
        Fg[dof_j] = Fe

    end

    function assemble_force_surface!(
            Fg::Vector{<:Real}, 
            nodes::Vector, 
            forces::Vector, 
            d::Integer
        )
        elements_index = [i[1] for i in forces]
        nodes_index    = [i[2:4] for i in forces]
        forces_vector  = [i[5:(4 + d)] for i in forces]

        dof_i = mapreduce(el -> [d * el[1] - i for i in d-1:-1:0], vcat , nodes_index)
        dof_j = mapreduce(el -> [d * el[2] - i for i in d-1:-1:0], vcat, nodes_index) 
        dof_k = mapreduce(el -> [d * el[3] - i for i in d-1:-1:0], vcat, nodes_index)

        nodes_i = nodes[[i[1] for i in nodes_index]]
        nodes_j = nodes[[i[2] for i in nodes_index]]
        nodes_k = nodes[[i[3] for i in nodes_index]]

        vector_ij = nodes_j .- nodes_i
        vector_ik = nodes_k .- nodes_i
        
        Δ =  1/2 * LinearAlgebra.norm(LinearAlgebra.cross.(vector_ij, vector_ik))

        F =  1/3 * Δ .* forces_vector
        
        

        Fe = reduce(vcat, F)

        Fg[dof_i] = Fe
        Fg[dof_j] = Fe
        Fg[dof_k] = Fe
    
    end

end