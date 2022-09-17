#!/usr/bin/env bash

############################################################
# Script: backup.sh                                        #
# Descrição:                                               #
#           Script para realizar backup compactado de      #
#           diretórios                                     #
#                                                          #
# Autor: Matheus Siqueira (matheus.businessc@gmail.com)    #
# Mantenedor: Matheus Siqueira                             #
# Exemplo de uso:                                          #
# ./backup.sh [compactador*] [diretório*] [nome-arquivo]   #
#......................................................... #
# O programa recebe como parâmetros o compactador desejado #
# e o diretório a ser compactado e então realiza a         #
# a compactação do diretório                               #
#..........................................................#
# Testado em:                                              #
#        bash 5.1.16                                       #
#..........................................................#
# Histórico:                                               #
#         16/09/2022                                       #
#           - Criação do programa                          #
############################################################



COMPACT=$1 #parâmetro obrigatório
DIR=$2 #parâmetro obrigatório
NAME_FILE=$3 #opcional


# logado como usuário root
# USER=$(whoami)
# if [[ $USER != "root" ]]; then
#   echo "Precisa ser usuário root para realizar backup"
#   exit 1
# fi



# programa figlet instalado?
figlet test > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Necessário instalar o programa figlet"
  read -p "Proceder [y/n]" RESP
  if [[ $RESP == 'y' || $RESP == 'Y' ]]; then
    sudo apt install figlet
    if [ $? -eq 0 ]; then
      figlet Backup.sh
    fi
  else
    echo "Saindo..."
    sleep 1
    exit 0
  fi
else
  figlet Backup.sh
fi


if [[ $COMPACT = "tar" ]]; then
  if [[ -d $DIR ]]; then
    if [[ -z $NAME_FILE ]]; then
      tar -czf backup-$(date +%Y-%m-%d).tar.gz $DIR #se name_file vazio, backup criado com nome default
      [ $? -eq 0 ] && echo "Backup realizado com sucesso" || echo "Erro no processo de backup"
    else
      tar -czf $NAME_FILE $DIR
      [ $? -eq 0 ] && echo "Backup realizado com sucesso" || echo "Erro no processo de backup"
    fi
  else
    echo "Diretório inexistente"
  fi
elif [[ $COMPACT = "zip" ]]; then
  if [[ -d $DIR ]]; then
    if [[ -z $NAME_FILE ]]; then
      zip -r backup-$(date +%Y-%m-%d).zip $DIR
      [ $? -eq 0 ] && echo "Backup realizado com sucesso" || echo "Erro no processo de backup"
    else
      zip -r $NAME_FILE $DIR
      [ $? -eq 0 ] && echo "Backup realizado com sucesso" || echo "Erro no processo de backup"
    fi
  else
    echo "Diretório inexistente"
  fi
else
  echo "Compactador não identificado"
fi
