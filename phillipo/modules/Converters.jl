
# PHILLIPO

module Converters
    function convert_input(input_dict::Dict)
        # CONVERTENDO OS TIPOS DOS VALORES DOS NÓS PARA FLOAT64
        nodes_length = length(input_dict["nodes"])
        nodes = Array{Float64, 2}(undef, nodes_length, 2)
        for j = 1:nodes_length - 1 # -1 porque toda a lista do JSON termina com o tipo nothing
           nodes[j, 1:2] = convert(Array{Float64, 1}, input_dict["nodes"][j])
        end
        # CONVERTENDO OS TIPOS DOS VALORES DOS ELEMENTOS PARA INT32
        # ELEMENTO TRIANGULAR LINEAR
        elements_triangular_length = length(input_dict["elements"]["linear"]["triangles"])
        elements_triangular = Array{Any, 2}(undef, elements_triangular_length, 5)
        for j = 1:elements_triangular_length - 1 # -1 porque toda a lista do JSON termina com o tipo nothing
            println(convert(Array{Any, 1}, input_dict["elements"]["linear"]["triangles"][j]))
        end
    end
end