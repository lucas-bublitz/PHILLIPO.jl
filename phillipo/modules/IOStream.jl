
# PHILLIPO
# Módulo: controle de entradas e saídas


module IOStream

    import .Parts

    function open_parse_input_file(file_name::String)
        open(file_name, "r") do f

            println(readline(f))
        end
    end

    function header_prompt()
        # Imprime o cabeçalho do prompt de execução do programa
        header_msg_file = open("./modules/header_msg.txt", "r")
        header_msg_text = read(header_msg_file, String)
        print(header_msg_text)
        close(header_msg_file)
    end

end 