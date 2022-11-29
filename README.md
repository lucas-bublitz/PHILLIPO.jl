# PHILLIPO: desenvolvimento de uma aplicação de elementos finitos

Desenvolvido por Lucas Bublitz, com a orientação de Pablo Muñoz

## Sobre este projeto

O presente projeto corresponde ao meu TCC, requisito para obtebção do grau de bacharel em Engenharia Mecânica, e tem por objetivo desenvolver uma programa para aplicar os métodos de elementos finitos, mais especificamente, solucionar problemas de tensão-deformação, estáticos e lineares.

## Sobre este repositório

Aqui estão ambos, o resultado e o histórico do meu trabalho, que consiste no próprio documento para avaliação (a monografia em `\documentation`) e o software (PHILLIPO em `\src`), e a integração com o GiD (os dois problem types em `\GiD connection`). Também estão disponíveis alguns exemplos em `\examples`.

## Instalação

### Julia & GiD
Para se utilizar PHILLIPO plenamente, é preciso ter a linguagem Julia instalada (Recomenda-se a LTS v1.6.7), que pode ser obtida pelo  site oficial: https://julialang.org/downloads/. (Durante a instalação, lembre-se de marcar a opção de adicionar Julia nas variáveis de ambiente!) Também é preciso possuir o GiD, a fim de facilitar a geração dos os arquivos de entrada para o módulo e a visualização dos resultados. Seu instalador pode ser obtido pelo site oficial (em sua versão gratuita e limitada): https://www.gidsimulation.com/gid-for-science/downloads/. Por questões de compatibilidade, recomenda-se a utilização da versão 16.0.)


### PHILLIPO

PHILLIPO é distribuído pelo gerenciador de pacotes de Julia, o Pkg.jl, porém ainda não se encontra no repositório oficial. Para instalar o módulo basta executar o seguinte comando:
```
pkg> add
```

