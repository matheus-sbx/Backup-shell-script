#!/usr/bin/env bash

############################################################
# Script: backup.sh                                        #
# Descrição:                                               #
#           Script para realizar backup compactado de      #
#           diretórios                                     #
#                                                          #
# Autor: Matheus Siqueira (matheus.businessc@gmail.com)    #
# Mantenedor: Matheus Siqueira                             #
#..........................................................#
# Exemplo de uso:                                          #
# ./backupV2.sh  -c zip -d $(pwd)                          #
#  Neste exemplo o programa vai compactar o diretório atual#
#  utilizando o zip e vai gerar um arquivo com o nome      #
#  padrão                                                  #
#......................................................... #
# O programa recebe como parâmetros o compactador desejado #
# e o diretório a ser compactado e então realiza a         #
# a compactação do diretório                               #
#..........................................................#
# Testado em:                                              #
#        bash 5.1.16                                       #
#..........................................................#
# Histórico:                                               #
#         16/09/2022, Matheus                              #
#           - Criação do programa                          #
#         30/09/2022, Matheus                              #
#           - Restruturação do códgio (getopt)             #
#           - Inserção do manual de uso                    #
#                                                          #
############################################################


#..............................VARIÁVEIS..............................#




VERSION="v1.1"
COMPACT=
DIR=
NAME=
MANUAL="
  $(basename $0) - [OPÇÕES]
    -n - especifica o nome da arquivo que será gerado
    -c - define o compactador que será utilizado [zip/tar]
    -d - especifica o diretório que será compactado
    -h - exibi o manual de uso
    -v - exibi a versão do programa
"
HELP="\033[31m[ERRO]\033[0m Comando não encontrado, verifique o manual com a opção -h."
UNEXPECTED_EXIT="\033[31m[ERRO]\033[0m - Saída inesperada."
DIR_NO_FOUND="\033[31m[ERRO]\033[0m - Diretório inexistente."
COMPACT_NO_FOUND="\033[31m[ERRO]\033[0m - Compactador Desconhecido."
SUCCESS="\033[32m[SUCESSO]\033[0m - Compactação realizada com sucesso."
FAILURE="\033[31m[ERRO]\033[0m - Não foi possível compactar os arquivos."


#..............................TESTES..............................#



while getopts "vhn:c:d:" OPT
do
  case "$OPT" in
    "c") COMPACT="$OPTARG"           ;;
    "d") DIR="$OPTARG"               ;;
    "h") echo "$MANUAL" && exit 0    ;;
    "n") NAME="$OPTARG"                ;;
    "v") echo "$VERSION" && exit 0   ;;
    "?") exit 1                      ;;
    *) echo -e "$HELP" && exit 1   ;;
 esac
done

#..............................EXECUÇÃO..............................#


if [[ $COMPACT = "tar" ]]; then
    [[ -z $NAME ]] && tar -czf backup-$(date +%Y-%m-%d).tar.gz $DIR || tar -czf $NAME $DIR
    [[ $? -eq 0 ]] && echo -e "$SUCCESS" || echo -e "$FAILURE"
fi

if [[ $COMPACT = "zip" ]]; then
     [[ -z $NAME ]] && zip -r backup-$(date +%Y-%m-%d).zip $DIR  || zip -r $NAME $DIR
     [[ $? -eq 0 ]] && echo -e "$SUCCESS" || echo -e "$FAILURE"
fi
