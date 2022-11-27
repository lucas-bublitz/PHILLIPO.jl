# PHILLIPO
# Módulo: recuperação de tensão

module Stress

    import ..Elements

    function recovery(elements::Vector{<:Elements.Element}, Ug::Vector{<:Real})
        σ   = Vector{Vector{Float64}}(map(e ->  e.D * e.B * Ug[e.degrees_freedom], elements))
        σvm = von_misses.(σ)
        σ, σvm 
    end

    von_misses(σ::Vector{<:Real}) = length(σ) == 3 ? von_misses_2D(σ) : von_misses_3D(σ)

    function von_misses_2D(σ::Vector{<:Real})
        √(σ[1]^2 - σ[1] * σ[2] + σ[2]^2 + 3 * σ[3]^2)
    end

    function von_misses_3D(σ::Vector{<:Real})
        √(((σ[1] - σ[2])^2 + (σ[2] - σ[3])^2 + (σ[3] - σ[1])^2 + 6 * (σ[4]^2 + σ[5]^2 + σ[6]^2)) / 2)
    end
end