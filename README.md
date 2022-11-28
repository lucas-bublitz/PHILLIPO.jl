# Desenvolvimento de uma aplicação de elementos finitos

Por Lucas Bublitz

Orientado por Pablo Muñoz

## Sobre este projeto

O presente projeto corresponde ao meu TCC, requisito para obteção do grau de bacharel em Engenharia Mecânica, e tem por objetivo desenvolver uma programa para aplicar os métodos de elementos finitos, mais especificamente, solucionar problemas de tensão-deformação plana.

## Sobre este repositório

Aqui estão ambos, o resultado e o histórico do meu trabalho, que consitem no próprio documento para avaliação, a dissertação, e o software, meio e objetivo do TCC.

## Instalação 

PHILLIPO é utilziado, atualmente, para ser chamado pelo GiD (um pre e pos visualizador), e tem como dependências diretas:

- LinearAlgebra
- JSON
- SparseArrays

Todos esses módulos estão disponíveis por meio do gerenciador de pacotes Pkg.jl (o oficial da linguagem Julia).

Primeiro passo: os arquivos

A primeira coisa a se fazer para rodar PHILLIPO é baixar o seu código fonte, dispoível em https://github.com/lucas-bublitz/PHILLIPO