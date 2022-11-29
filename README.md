```
      ___           ___                       ___       ___                   ___           ___      
     /\  \         /\__\          ___        /\__\     /\__\      ___        /\  \         /\  \     
    /  \  \       / /  /         /\  \      / /  /    / /  /     /\  \      /  \  \       /  \  \    
   / /\ \  \     / /__/          \ \  \    / /  /    / /  /      \ \  \    / /\ \  \     / /\ \  \   
  /  \-\ \  \   /  \  \ ___      /  \__\  / /  /    / /  /       /  \__\  /  \-\ \  \   / /  \ \  \  
 / /\ \ \ \__\ / /\ \  /\__\  __/ /\/__/ / /__/    / /__/     __/ /\/__/ / /\ \ \ \__\ / /__/ \ \__\ 
 \/__\ \/ /  / \/__\ \/ /  / /\/ /  /    \ \  \    \ \  \    /\/ /  /    \/__\ \/ /  / \ \  \ / /  / 
      \  /  /       \  /  /  \  /__/      \ \  \    \ \  \   \  /__/          \  /  /   \ \  / /  /  
       \/__/        / /  /    \ \__\       \ \  \    \ \  \   \ \__\           \/__/     \ \/ /  /   
                   / /  /      \/__/        \ \__\    \ \__\   \/__/                      \  /  /    
                   \/__/                     \/__/     \/__/                               \/__/     
```
Desenvolvido por Lucas Bublitz, sob a orientação de Pablo Muñoz

# PHILLIPO: desenvolvimento de uma aplicação de elementos finitos

Desenvolvido por Lucas Bublitz, com a orientação de Pablo Muñoz

## Sobre este projeto

O presente projeto corresponde ao meu TCC, requisito para obtebção do grau de bacharel em Engenharia Mecânica, e tem por objetivo desenvolver uma programa para aplicar os métodos de elementos finitos, mais especificamente, solucionar problemas de tensão-deformação, estáticos e lineares.

## Sobre este repositório

Aqui estão ambos, o resultado e o histórico do meu trabalho, que consiste no próprio documento para avaliação (a monografia em `\documentation`), o software (PHILLIPO em `\src`), e a integração com o GiD (os dois problem types em `\GiD connection`). Também estão disponíveis alguns exemplos em `\examples`.

## Instalação

### Julia & GiD

Para se utilizar PHILLIPO, é preciso ter a linguagem Julia instalada (Recomenda-se a LTS v1.6.7), que pode ser obtida pelo site oficial: https://julialang.org/downloads/. (Durante a instalação, lembre-se de marcar a opção de adicionar Julia nas variáveis de ambiente!) Também é preciso possuir o GiD, a fim de promover a geração dos os arquivos de entrada para o módulo e a visualização dos resultados. Seu instalador pode ser obtido pelo site oficial (em sua versão gratuita e limitada): https://www.gidsimulation.com/gid-for-science/downloads/. Por questões de compatibilidade, recomenda-se a utilização da versão 16.0.

As duas pastas presentes em `\GiD connection`, `PHILLIPO.gid` e `PHILLIPO3D.gid`, precisam ser adicionadas no próprio GiD, o que é realizado, abrindo o software, por meio do comando`Load...`, localizado em `Data -> Problem Type -> Load...`.

Os arquivos do projeto podem ser baixado em `.zip`, por meio do botão verde sobre a parte direita da árvore de aquivos deste repositório. 

### PHILLIPO

PHILLIPO pode ser instalado utilizando o Pkg.jl, que é o gerenciador de pacotes da linguagem Julia. Para tanto, basta iniciar uma sessão, abrindo o aplicativo Julia, ou executando `julia` em um terminal. Se esse comando não for executado, provavelmente Julia não foi adicionada às variáveis de ambiente. Com o terminal Julia aberto, deve-se pressionar `]` para que o terminal entre no modo Pkg, e, então, executar o comando:
```
add https://github.com/lucas-bublitz/PHILLIPO.jl
```
para instalar o módulo PHILLIPO.
<pre>
  ,ggggggggggggggg     
dP""""""88"""""""     
Yb,_    88            
 `""    88            
        88            
        88  
        88 
  gg,   88  
   "Yb,,8P 
     "Y8P'    
</pre>
<pre class="y-text">
  gg     gg 
  I8     8I 
  I8,   ,8I 
 ,d8b, ,d8I 
 P""Y88P"888
       ,d8I'
     ,dP'8I           
    ,8"  8I 
    I8   8I 
    `8, ,8I 
      `Y8P"         
</pre>
<style>
    .y-text {
        color: blue;
        position: absolute;
        top: 82px;
        left: 80px;
    }
</style>