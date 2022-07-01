
# PHILLIPO
# Módulo: definição dos objetos de estrutura e elementos, chamados partes

module Parts

    # RESTRIÇÕES

    abstract type Constraint end # Grupo de todas as restrições

    struct Force_node <: Constraint
        componenst::Vector{Float64}
    end

    struct Deformation_node <: Constraint 
        componenst::Vector{Float64}
     end
 
    # NÓS
    
    struct Node
        # Objeto de nó
        index::Integer
        position::Vector{Float64}
        constraints::Vector{Constraint}
    end

    # MATERIAIS

    struct Material 
        name::String
        young_module::Float64
        poisson_ratio::Float64
    end

    # ELEMENTOS

    abstract type Element end

    abstract type Linear <: Element end # Grupo dos elementos lineares

    struct Triangle_Linear <: Linear
        # Elemento triangular linear
        index::Integer
        nodes::Vector{Node}
        local_stiffness_matrix::AbstractMatrix{Float64}
        material::Material
    end

    # ESTRUTURAS
    
    struct Structure
        # Objeto de estrutura. Basicamente, comporta todos os dados principais do programa
        elements::AbstractVector{Element}
        global_stiffness_matrix::AbstractMatrix{Float64}
        global_displacement_vector::Vector{Float64}
        function Structure(input_dict::Dict)
            print("\nCOMENÇANDO")
        end
    end

end