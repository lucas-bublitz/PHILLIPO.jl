
# PHILLIPO
# Módulo: controle de entradas e saídas


module IOfiles
    # MÓDULOS EXTERNOS
    import JSON

    function open_parse_input_file(file_name::String)::Dict
        # Carrega e interpreta o arquivo de entrada
        # Retorna um dicionário
        JSON.parsefile(file_name, dicttype=Dict, use_mmap = true)
    end

    function header_prompt()
        # Imprime o cabeçalho do prompt de execução do programa
        header_msg_file = open(string(@__DIR__ ,"/header_msg.txt"), "r")
        header_msg_text::String = read(header_msg_file, String)
        println(header_msg_text)
        close(header_msg_file)
    end

    function write_vector_on_output_file(file, vector::Vector{Real}, types::Tuple, dimensions::Integer)
        write(file, join((types[1], types[2]), " "), "\n")
        vector_length = length(vector) ÷ dimensions 
        if dimensions == 2
            for j = 1:vector_length
                write(file, join((j,vector[2*j-1],vector[2*j])," "), "\n")
            end
        elseif  dimensions == 3
            for j = 1:vector_length
                write(file, join((j,vector[3*j-2],vector[3*j-1],vector[3*j])," "), "\n")
            end
        end
    end
end 