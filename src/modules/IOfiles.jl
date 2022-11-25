
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

    function write_header(file::IOStream)
        write(file, "GiD Post Results File 1.0", "\n")
    end

    function write_result(
            file::IOStream,
            header::Tuple, 
            d::Integer,
            vector::Vector{<:Real}
        )
        write(file, join(header, "\n"), "\n")
        vector_length = length(vector) ÷ d

        write(file, "Values", "\n")
        for i = 1:vector_length
            write(file, "$(i)", " ",
                join((vector[d * i - j] for j = (d - 1):-1:0), " "),
                "\n"
            )
        end
        write(file, "End Values", "\n")
        # if dimensions == 2
        #     for j = 1:vector_length
        #         write(file, join((j,vector[2*j-1],vector[2*j])," "), "\n")
        #     end
        # elseif  dimensions == 3
        #     for j = 1:vector_length
        #         write(file, join((j,vector[3*j-2],vector[3*j-1],vector[3*j])," "), "\n")
        #     end
        # end

    end
end 