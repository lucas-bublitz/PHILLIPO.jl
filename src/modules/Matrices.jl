
# PHILLIPO
# Módulo: construção de matrizes esparsas baseada em coordenadas
# Este arquivo é construído com fork indireto o FEMSparse.jl (módulo utilizado no JuliaFEM.jl)

module Matrices

    using SparseArrays
    import Base.sum
    export SparseMatrixCOO, spCOO, sum, add!
    using LinearAlgebra

    mutable struct SparseMatrixCOO{Tv,Ti<:Integer} <: AbstractSparseMatrix{Tv,Ti}
        I :: Vector{Ti}
        J :: Vector{Ti}
        V :: Vector{Tv}
    end

    spCOO(A::Matrix{<:Number}) = SparseMatrixCOO(A)
    SparseMatrixCOO() = SparseMatrixCOO(Int[], Int[], Float64[])
    SparseMatrixCOO(A::SparseMatrixCSC{Tv,Ti}) where {Tv, Ti<:Integer} = SparseMatrixCOO(findnz(A)...)
    SparseMatrixCOO(A::Matrix{<:Real}) = SparseMatrixCOO(sparse(A))
    SparseArrays.SparseMatrixCSC(A::SparseMatrixCOO) = sparse(A.I, A.J, A.V)
    Base.isempty(A::SparseMatrixCOO) = isempty(A.I) && isempty(A.J) && isempty(A.V)
    Base.size(A::SparseMatrixCOO) = isempty(A) ? (0, 0) : (maximum(A.I), maximum(A.J))
    Base.size(A::SparseMatrixCOO, idx::Int) = size(A)[idx]
    Base.Matrix(A::SparseMatrixCOO) = Matrix(SparseMatrixCSC(A))

    get_nonzero_rows(A::SparseMatrixCOO) = unique(A.I[findall(!iszero, A.V)])
    get_nonzero_columns(A::SparseMatrixCOO) = unique(A.J[findall(!iszero, A.V)])

    function Base.getindex(A::SparseMatrixCOO{Tv, Ti}, i::Ti, j::Ti) where {Tv, Ti}
        if length(A.V) > 1_000_000
            @warn("Performance warning: indexing of COO sparse matrix is slow.")
        end
        p = (A.I .== i) .& (A.J .== j)
        return sum(A.V[p])
    end

    """
        add!(A, i, j, v)
    Add new value to sparse matrix `A` to location (`i`,`j`).
    """
    function add!(A::SparseMatrixCOO, i, j, v)
        push!(A.I, i)
        push!(A.J, j)
        push!(A.V, v)
        return nothing
    end

    function Base.empty!(A::SparseMatrixCOO)
        empty!(A.I)
        empty!(A.J)
        empty!(A.V)
        return nothing
    end

    function assemble_local_matrix!(A::SparseMatrixCOO, dofs1::Vector{<:Integer}, dofs2::Vector{<:Integer}, data)
        n, m = length(dofs1), length(dofs2)
        @assert length(data) == n*m
        k = 1
        for j=1:m
            for i=1:n
                add!(A, dofs1[i], dofs2[j], data[k])
                k += 1
            end
        end 
        return nothing
    end

    function add!(A::SparseMatrixCOO, dof1::Vector{<:Integer}, dof2::Vector{<:Integer}, data)
        assemble_local_matrix!(A, dof1, dof2, data)
    end

    function sum(A::Vector{<:SparseMatrixCOO})::SparseMatrixCSC
        # Retorna uma matriz em CSC a partir de um vetor formado por matrizes em COO
        I = reduce(vcat, getfield.(A, :I))
        J = reduce(vcat, getfield.(A, :J))
        V = reduce(vcat, getfield.(A, :V))
        LinearAlgebra.Symmetric(sparse(I,J,V))
    end

    function add!(A::SparseMatrixCOO, dof::Vector{<:Integer}, data)
        assemble_local_matrix!(A, dof, dof, data)
    end
    
end

