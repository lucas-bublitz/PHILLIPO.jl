
#
#       ___           ___                       ___       ___                   ___           ___     
#      /\  \         /\__\          ___        /\__\     /\__\      ___        /\  \         /\  \    
#     /::\  \       /:/  /         /\  \      /:/  /    /:/  /     /\  \      /::\  \       /::\  \   
#    /:/\:\  \     /:/__/          \:\  \    /:/  /    /:/  /      \:\  \    /:/\:\  \     /:/\:\  \  
#   /::\~\:\  \   /::\  \ ___      /::\__\  /:/  /    /:/  /       /::\__\  /::\~\:\  \   /:/  \:\  \ 
#  /:/\:\ \:\__\ /:/\:\  /\__\  __/:/\/__/ /:/__/    /:/__/     __/:/\/__/ /:/\:\ \:\__\ /:/__/ \:\__\
#  \/__\:\/:/  / \/__\:\/:/  / /\/:/  /    \:\  \    \:\  \    /\/:/  /    \/__\:\/:/  / \:\  \ /:/  /
#       \::/  /       \::/  /  \::/__/      \:\  \    \:\  \   \::/__/          \::/  /   \:\  /:/  / 
#        \/__/        /:/  /    \:\__\       \:\  \    \:\  \   \:\__\           \/__/     \:\/:/  /  
#                    /:/  /      \/__/        \:\__\    \:\__\   \/__/                      \::/  /   
#                    \/__/                     \/__/     \/__/                               \/__/    
#
# "Dividir e dominar" - Phillipo II da Macedônia
# PHILLIPO é um solver para problemas lineares, estáticos e eleásticos de arquivos no padrão ABAQUS.
# Autor: Lucas Bublitz                           


# Escopo principal
module PHILLIPO

    export main()

    include("./modules/includes.jl") # Chamando todos os módulos locais

    # MÓDULOS LOCAIS
    import .IOStream

    # PONTO DE PARTIDA
    function main()
        IOStream.header_prompt()
        IOStream.import_model_abaqus("teste.inp")
    end

end

using PHILLIPO
main()