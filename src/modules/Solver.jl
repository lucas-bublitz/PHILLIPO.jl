# PHILLIPO
# Módulos: funções para executar o método de soluação

module Solver

    using SparseArrays

    function direct_solve!(
            Kg::SparseArrays.SparseMatrixCSC,
            Ug::Vector{<:Real},
            Fg::Vector{<:Real},
            dof_free::Vector{<:Integer}, 
            dof_prescribe::Vector{<:Integer}
        )
        # Realiza a soluação direta para o sistema
        Ug[dof_free]        = Kg[dof_free, dof_free] \ (Fg[dof_free] - Kg[dof_free, dof_prescribe] * Ug[dof_prescribe])
        Fg[dof_prescribe]   = Kg[dof_prescribe, dof_free] * Ug[dof_free] + Kg[dof_prescribe, dof_prescribe] * Ug[dof_prescribe]
    end
end