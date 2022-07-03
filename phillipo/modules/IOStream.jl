
# PHILLIPO
# Módulo: controle de entradas e saídas


module IOStream

    # MÓDULOS EXTERNOS
    import JSON

    function open_parse_input_file(file_name::String)::Dict
        # Carrega e interpreta o arquivo de entrada
        # Retorna um dicionário
        JSON.parsefile(file_name, dicttype=Dict, use_mmap = true)
    end

    function header_prompt()
        # Imprime o cabeçalho do prompt de execução do programa
        header_msg_file = open("./modules/header_msg.txt", "r")
        header_msg_text::String = read(header_msg_file, String)
        println(header_msg_text)
        close(header_msg_file)
    end

end 