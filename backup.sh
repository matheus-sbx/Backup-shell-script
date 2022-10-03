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
#         01/10/2022, Matheus                              #
#           - Adicionando tratamentos de erro              #
#         03/10/2022, Matheus                              #
#           - Adicionando diretório Backup                 #
############################################################

#..............................VARIÁVEIS..............................#
FILE=
FILE_CONFIG="config.cf"
DIR_BACKUP=
SAVE_DIR_BACKUP=
CONFIRMATION=0
VERSION="v1.2"
COMPACT=
DIR=
OLD_FILE=
NEW_FILE=
MANUAL="
  $(basename $0) - [OPÇÕES]
    -n - (opcional) especifica o nome do arquivo que será gerado
    -c - define o compactador que será utilizado [zip/tar]
    -d - especifica o diretório que será compactado
    -h - exibi o manual de uso
    -v - exibi a versão do programa
"
HELP="\033[31m[ERRO]\033[0m Comando não encontrado, verifique o manual com a opção -h."
UNEXPECTED_EXIT="\033[31m[ERRO]\033[0m - Saída inesperada."
COMPACT_NO_FOUND="\033[31m[ERRO]\033[0m - Compactador Desconhecido."
SUCCESS="\033[32m[SUCESSO]\033[0m - Compactação realizada com sucesso."
FAILURE="\033[31m[ERRO]\033[0m - Não foi possível compactar os arquivos."

# #..............................TESTES..............................#
while getopts "vhn:c:d:f" OPT
do
  case "$OPT" in
    "c") COMPACT="$OPTARG"           ;;
    "d") DIR="$OPTARG"               ;;
    "h") echo "$MANUAL" && exit 0    ;;
    "n") NEW_FILE="$OPTARG"          ;;
    "v") echo "$VERSION" && exit 0   ;;
    "?") exit 1                      ;;
    *) echo -e "$HELP" && exit 1   ;;
 esac
done

# o diretório/arquivo exite?
find $DIR > /dev/null 2>&1
[[ $? -ne 0 ]] && echo "Diretório/arquivo não encontrado." && exit 1

# compactador existe?
if [[ $COMPACT != "tar" && $COMPACT != "zip" ]]; then
  echo "Compactador não encontrado."
  exit 1
fi

# já existe um arquivo com este nome?
if [[ -e $NEW_FILE ]]; then
  read -p "Já existe um arquivo com este nome, deseja subistituir? [y/n]" RESP
  [[ "$RESP" != "y" && "$RESP" != "Y" ]] && exit 0 || rm $NEW_FILE
fi

[[ $COMPACT = "tar" ]] && OLD_FILE="backup-$(date +%Y-%m-%d).tar.gz" || OLD_FILE="backup-$(date +%Y-%m-%d).zip"

if [[ -e $OLD_FILE ]]; then
  read -p "Já existe um arquivo com este nome, deseja subistituir? [y/n]" RESP
  [[ $RESP = "Y" || $RESP = "y" ]] && rm $OLD_FILE || exit 0
fi

# #..............................FUNÇÕES..............................#

set_parameters (){
  local parameter="$(echo $1 | cut -d : -f 1)"
  local value="$(echo $1 | cut -d : -f 2)"

  case $parameter in
    "DIR_BACKUP")DIR_BACKUP=$value           ;;
    "SAVE_DIR_BACKUP")SAVE_DIR_BACKUP=$value ;;
  esac

}
# #..............................EXECUÇÃO..............................#

if [[ $COMPACT = "tar" ]]; then
    [[ -z $NEW_FILE ]] && FILE=backup-$(date +%Y-%m-%d).tar.gz || FILE=$NEW_FILE
    [[ -z $NEW_FILE ]] && tar -czf backup-$(date +%Y-%m-%d).tar.gz $DIR || tar -czf $NEW_FILE $DIR
    [[ $? -eq 0 ]] && echo -e "$SUCCESS" || echo -e "$FAILURE"
fi

if [[ $COMPACT = "zip" ]]; then
     [[ -z $NEW_FILE ]] && FILE=backup-$(date +%Y-%m-%d).zip || FILE=$NEW_FILE
     [[ -z $NEW_FILE ]] && zip -r backup-$(date +%Y-%m-%d).zip $DIR || zip -r $NEW_FILE $DIR
     [[ $? -eq 0 ]] && echo -e "$SUCCESS" || echo -e "$FAILURE"
fi

while read -r line
do
  [[ "$(echo $line | cut -c1)" = "#" ]] && continue
  [[ ! "$line" ]] && continue
  set_parameters "$line"
done < "$FILE_CONFIG"

if [[ "$DIR_BACKUP" = "true" ]]; then
  find /home/$(whoami)/Backup > /dev/null 2>&1
  [[ $? -ne 0 ]] && mkdir /home/$(whoami)/Backup
  CONFIRMATION=1
fi

if [[ "$SAVE_DIR_BACKUP" = "true" ]]; then
   [[ $CONFIRMATION -eq 1 ]] && mv "$FILE" /home/$(whoami)/Backup || echo "Diretório Backup/ não encontrado."
fi
