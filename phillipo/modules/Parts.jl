
# PHILLIPO
# Módulo: definição dos objetos de estrutura e elementos, chamados partes

module Parts

    # DEFINIÇÃO DOS OBJETOS DAS ESTRUTURAS
    
    struct type Structure
        # Objeto de estrutura. Basicamente, comporta todos os dados do programa
        elements::AbstractVector{Element}
        constraints::AbstractVector{Constraint}
        global_stiffness_matrix::AbstractMatrix{Float64}
        global_displacement_vector::Vector{Float64}
    end

    # DEFINIÇÃO DOS OBJETOS DOS NÓS
    
    struct Node
        # Objeto de nó
        index::Integer
        position::Array{Float64}
    end

    # DEFINIÇÃO DOS OBJETOS DOS ELEMENTOS

    abstract type Element end
    abstract type Linear end


    # DEFINIÇÃO DOS OBJETOS DAS RESTRIÇÕES
    
    abstract type Constraint end

    struct Force_fixed <: Constraint
        componenst::Vector{Float64}
    end

    struct Deformation_fixed <: Constraint 
        componenst::Vector{Float64}
    end

    abstract type Element end
end