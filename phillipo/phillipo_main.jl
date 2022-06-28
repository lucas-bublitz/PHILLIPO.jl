
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
    
    include("./modules/module_include.jl") # Chamando todos os módulos locais

    # MÓDULOS LOCAIS
    import .IOStream

    # MÓDULOS EXTERNOS
    

    # PONTO DE PARTIDA
    function main()
        IOStream.header_prompt()
    end

end
import .PHILLIPO
PHILLIPO.main()

