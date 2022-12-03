
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
           
            index          = Integer(triangle_element_vector[1])
            material_index = Integer(triangle_element_vector[2])
            nodes_index    = Vector{Integer}(triangle_element_vector[3:5])
            

            i = Vector{Real}(nodes[nodes_index[1]])
            j = Vector{Real}(nodes[nodes_index[2]])
            m = Vector{Real}(nodes[nodes_index[3]])
    
            position_nodes_matrix = [
                1  i[1]  i[2];
                1  j[1]  j[2];
                1  m[1]  m[2]
            ]

            interpolation_function_coeff = LinearAlgebra.inv(position_nodes_matrix)

            Δ = 1/2 *  LinearAlgebra.det(position_nodes_matrix)
            
            a = interpolation_function_coeff[1,:]
            b = interpolation_function_coeff[2,:]
            c = interpolation_function_coeff[3,:]


            B = [
                b[1] 0    b[2] 0    b[3] 0   ;
                0    c[1] 0    c[2] 0    c[3];
                c[1] b[1] c[2] b[2] c[3] b[3]
            ]

            try
                materials[material_index]
            catch
                error("Material não definido no elemento de índice: $(index)")
            end

            D = generate_D(problem_type, materials[material_index])

            K = B' * D * B * Δ * 1

            degrees_freedom = reduce(vcat, map((x) -> [2 * x - 1, 2 * x], nodes_index))

            new(index, material_index, nodes_index, interpolation_function_coeff, D, B, K, degrees_freedom)
        end 
    end

    struct TetrahedronLinear <: Element
        index::Integer
        material_index::Integer
        nodes_index::Vector{<:Integer}
        interpolation_function_coeff::Matrix{<:Real}
        D::Matrix{<:Real}
        B::Matrix{<:Real}
        K::Matrix{<:Real}
        degrees_freedom::Vector{<:Integer}
        function TetrahedronLinear(tetrahedron_element_vector::Vector{<:Any}, materials::Vector{<:Any}, nodes::Vector{<:Any})
            
            index          = Integer(tetrahedron_element_vector[1])
            material_index = Integer(tetrahedron_element_vector[2])
            nodes_index    = Vector{Integer}(tetrahedron_element_vector[3:6])
            

            i = Vector{Real}(nodes[nodes_index[1]])
            j = Vector{Real}(nodes[nodes_index[2]])
            m = Vector{Real}(nodes[nodes_index[3]])
            p = Vector{Real}(nodes[nodes_index[4]])

            position_nodes_matrix = [
                1 i[1] i[2] i[3];
                1 j[1] j[2] j[3];
                1 m[1] m[2] m[3];
                1 p[1] p[2] p[3]
            ]
            interpolation_function_coeff = LinearAlgebra.inv(position_nodes_matrix)
            V = 1/6 * LinearAlgebra.det(position_nodes_matrix)

            a = interpolation_function_coeff[1,:]
            b = interpolation_function_coeff[2,:]
            c = interpolation_function_coeff[3,:]
            d = interpolation_function_coeff[4,:]
            
            B = [
                b[1]  0      0    b[2]  0      0    b[3]  0      0    b[4]  0      0   ;
                0     c[1]   0    0     c[2]   0    0     c[3]   0    0     c[4]   0   ;
                0     0      d[1] 0     0      d[2] 0     0      d[3] 0     0      d[4];
                c[1]  b[1]   0    c[2]  b[2]   0    c[3]  b[3]   0    c[4]  b[4]   0   ;
                0     d[1]   c[1] 0     d[2]   c[2] 0     d[3]   c[3] 0     d[4]   c[4];
                d[1]  0      b[1] d[2]  0      b[2] d[3]  0      b[3] d[4]  0      b[4]  
            ]

            try
                materials[material_index]
            catch
                error("Material não definido no elemento de índice: $(index)")
            end

            D = generate_D("3D", materials[material_index])

            K =  B' * D * B * V

            degrees_freedom = Vector{Integer}(reduce(vcat, map((x) -> [3 * x - 2, 3 * x - 1, 3 * x], nodes_index)))
            
            new(index, material_index, nodes_index, interpolation_function_coeff, D, B, K, degrees_freedom)
        end
    end


    function generate_D(problem_type, material)::Matrix{<:Real}
        # Gera a matrix constitutiva
        E::Float64 = material[2] # Módulo de young
        ν::Float64 = material[3] # Coeficiente de Poisson

        if problem_type == "plane_strain"
            return E / ((1 + ν) * (1 - 2ν)) * [
                (1 - ν) ν       0           ;
                ν       (1 - ν) 0           ;
                0       0       (1 - 2ν) / 2
            ]
        end

        if problem_type == "plane_stress"
            return E / (1 - ν^2) * [
                1       ν       0           ;
                ν       1       0           ;
                0       0       (1 - ν) / 2
            ]
        end

        if problem_type == "3D"
            return E / ((1 + ν) * (1 - 2ν)) * [
                (1 - ν) ν       ν         0            0            0           ;
                ν       (1 - ν) ν         0            0            0           ;
                ν       ν       (1 - ν)   0            0            0           ; 
                0       0       0         (1 - 2ν) / 2 0            0           ;
                0       0       0         0            (1 - 2ν) / 2 0           ;
                0       0       0         0            0            (1 - 2ν) / 2   
            ]   
        end

        error("PHILLIPO: Tipo de problema desconhecido!")
        
    end

    # function assemble_stiffness_matrix!(K_global_matrix::Matrix{Float64}, elements::Vector{Element})::SparseMatrixCSC
    #     for element in elements
    #         K_global_matrix[element.degrees_freedom, element.degrees_freedom] += element.K
    #     end
    # end
    
    function assemble_force_line!(
            Fg::Vector{<:Real}, 
            nodes::Vector, 
            forces::Vector, 
        )
        # Aplica a força equivalente nos nós de linha que sofre um carregamento constante.
        # Por enquanto, só funciona para problemas com elementos do tipo TriangleLinear
        for force in forces
            elements_index = force[1]
            nodes_index    = force[2:3]
            forces_vector  = force[4:5]

            dof_i = mapreduce(el -> [2 * el - i for i in 1:-1:0], vcat, nodes_index[1])
            dof_j = mapreduce(el -> [2 * el - i for i in 1:-1:0], vcat, nodes_index[2]) 

            node_i = nodes[nodes_index[1]]
            node_j = nodes[nodes_index[2]]

            Δ =  LinearAlgebra.norm(node_i .- node_j)
            F =  1/2 * Δ .* forces_vector

            Fg[dof_i] += F
            Fg[dof_j] += F
        end 
    end

    function assemble_force_surface!(
            Fg::Vector{<:Real}, 
            nodes::Vector, 
            forces::Vector
        )
        # Aplica a força equivalente nos nós de superfícies que sofre um carregamento constante.
        # Por enquanto, só funciona para problemas com elementos do tipo TetrahedronLinear
        for force in forces
            elements_index = force[1]
            nodes_index    = force[2:4]
            forces_vector  = force[5:7]

            dof_i = mapreduce(el -> [3 * el - i for i in 2:-1:0], vcat, nodes_index[1])
            dof_j = mapreduce(el -> [3 * el - i for i in 2:-1:0], vcat, nodes_index[2]) 
            dof_k = mapreduce(el -> [3 * el - i for i in 2:-1:0], vcat, nodes_index[3])

            node_i = nodes[nodes_index[1]]
            node_j = nodes[nodes_index[2]]
            node_k = nodes[nodes_index[3]]

            vector_ij = node_j .- node_i
            vector_ik = node_k .- node_i

            Δ =  1/2 * LinearAlgebra.norm(LinearAlgebra.cross(vector_ij, vector_ik))
            F =  1/3 * Δ .* forces_vector

            Fg[dof_i] += F
            Fg[dof_j] += F
            Fg[dof_k] += F
        end 
    end

end