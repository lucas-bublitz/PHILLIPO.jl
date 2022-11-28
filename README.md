# PHILLIPO: desenvolvimento de uma aplicação de elementos finitos

Desenvolvido por Lucas Bublitz, com a orientação de Pablo Muñoz

## Sobre este projeto

O presente projeto corresponde ao meu TCC, requisito para obtebção do grau de bacharel em Engenharia Mecânica, e tem por objetivo desenvolver uma programa para aplicar os métodos de elementos finitos, mais especificamente, solucionar problemas de tensão-deformação, estáticos e lineares.

## Sobre este repositório

Aqui estão ambos, o resultado e o histórico do meu trabalho, que consiste no próprio documento para avaliação (a monografia em `\documentation`) e o software (PHILLIPO em `\src`), e a integração com o GiD (os dois problem types em `\GiD connection`). Também estão disponíveis alguns exemplos em `\examples`.

## Instalação 

Para se utilizar PHILLIPO plenamente, é preciso ter a linguagem Julia instalada (Recomenda-se a LTS v1.6.7), que pode ser obtida pelo  site oficial: https://julialang.org/downloads/. (Durante a instalação, lembre-se de marcar a opção de adicionar Julia nas variáveis de ambiente!) Também é preciso possuir o GiD, a fim de facilitar a geração dos os arquivos de entrada para o módulo e a visualização dos resultados. Seu instalador pode ser obtido pelo site oficial (em sua versão gratuita e limitada): https://www.gidsimulation.com/gid-for-science/downloads/. Por questões de compatibilidade, recomenda-se a utilização da versão 16.0.)

PHILLIPO possui as seguintes dependências diretas:

- LinearAlgebra
- SparseArrays
- JSON

Os dois primeiros módulos são instalados junto com a própria linguagem Julia, portanto não há a necessidade de instalação. JSON (parser de arquivos `.json`), entretanto, deve ser requerido por meio do gerenciador de pacotes de Julia: o Pkg.jl. Para tanto, deve-se inicial uma sessão, iniciando o aplicativo `julia`, e pressionar `]`, para entrar no modo de comando Pkg. Depois, basta executar o comando `add JSON`. Após a execução, o módulo estará devidamente instalado e pronto para ser chamado por qualquer terminal Julia.

Os arquivos do projeto podem ser baixado em `.zip`, por meio do botão verde sobre a parte direita da árvore de aquivos deste repositório. Ou, por meio de um requisição Git. Após o download, deve-se descompactar o `.zip` em uma pasta conhecida.

### Configurando o GiD

Os arquivos `.bat`, dentro de `\GiD connection`, devem ser alterados em dois locais. Na linha `1`, a variável `path` deve ser modificada para apontar a pasta que contém o arquivo `phillipo_main.jl`, similar ao que já consta no repositório. E na linha `8`, caso ocorra um erro quando no GiD se requisitar o cálculo da estrutura, o comando `julia` precisa ser substituído pelo próprio caminho para o arquivo `julia.exe`. 

Esses duas pastas, `PHILLIPO.gid` e `PHILLIPO3D.gid`, modificadas agora, precisam ser adicionadas no próprio GiD, o que é realizado, abrindo o GiD, por meio do comando `Load...`, localizado em `Data -> Problem Type -> Load...`.
