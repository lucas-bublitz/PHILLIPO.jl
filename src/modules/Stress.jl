# PHILLIPO
# Módulo: recuperação de tensão

module Stress

    import ..Elements
    using SparseArrays

    function recovery(input_elements, Ug::Vector{<:Real}, materials::Vector{Any}, nodes::Vector{Any}, problem_type)
        map_function = e -> nothing
        if problem_type == "3D"
            if "tetrahedrons" in keys(input_elements)
                type = "tetrahedrons"
                map_function = e -> begin
                    el = Elements.TetrahedronLinear(e, materials, nodes)
                    el.D * el.B * Ug[el.degrees_freedom]
                end
            end
        else
            if "triangles" in keys(input_elements)
                type = "triangles"
                map_function = e -> begin
                    el = Elements.TriangleLinear(e, materials, nodes, problem_type)
                    el.D * el.B * Ug[el.degrees_freedom]
                end
            end
        end

        σ   = Vector{Vector{Float64}}(map(
            map_function, 
            input_elements[type]
        ))
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

    function reactions(Kg::SparseMatrixCSC, Ug::Vector{<:Real}, d::Integer)
        nodes_length = length(Ug)
        Re = Kg * Ug
        Re_sum = sum.([Re[i:d:nodes_length] for i in 1:d])
        return Re, Re_sum
    end

end