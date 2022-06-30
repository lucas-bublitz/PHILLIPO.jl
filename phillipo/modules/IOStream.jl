
# PHILLIPO
# Módulo: controle de entradas e saidas
# Autor: Lucas Bublitz

module IOStream

    

    function header_prompt()
        # Imprime o cabeçalho do prompt de execução do programa
        header_msg_file = open("./modules/header_msg.txt", "r")
        header_msg_text = read(header_msg_file, String)
        print(header_msg_text)
        close(header_msg_file)
    end

end 