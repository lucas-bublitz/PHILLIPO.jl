# Desenvolvimento de uma aplicação de elementos finitos

Por Lucas Bublitz

Orientado por Pablo Muñoz

## Sobre este projeto

O presente projeto corresponde ao meu TCC, requisito para obteção do grau de bacharel em Engenharia Mecânica, e tem por objetivo desenvolver uma programa para aplicar os métodos de elementos finitos, mais especificamente, solucionar problemas de tensão-deformação plana.

## Sobre este repositório

Aqui estão ambos, o resultado e o histórico do meu trabalho, que consitem no próprio documento para avaliação, a dissertação, e o software, meio e objetivo do TCC.

## Instalação 

Para se utilizar PHILLIPO plenamente, é preciso ter a linguagem Julia instalada (Recomenda-se a LTS v1.6.7), que pode ser obtida pelo  site oficial: https://julialang.org/downloads/. (Durante a instalação, lembre-se de marcar a opção de adicionar Julia nas variáveis de ambiente!) Também é preciso possuir o GiD, a fim de facilitar a geração dos os arquivos de entrada para o módulo e a visualização dos resultados. Seu instalador pode ser obtido pelo site oficial (em sua versão gratuita e limitada): https://www.gidsimulation.com/gid-for-science/downloads/. Por questões de compatibilidade, recomenda-se a utilização da versão 16.0.)

PHILLIPO possui as seguintes dependências diretas:

- LinearAlgebra
- SparseArrays
- JSON

Os dois primeiros módulos são instalados junto com a própria linguagem Julia, portanto não há a necessidade de instalação. JSON, entretanto, deve ser requerido por meio do gerenciador de pacotes de Julia: o Pkg.jl. Para tanto, deve-se inicial uma sessão, chamando o comando `julia`, e pressionar `]`, para entrar no modo de comando PKG. Depois, basta executar o seguinte comando:

```
add JSON
```