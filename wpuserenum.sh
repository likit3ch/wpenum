#!/bin/bash
#Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Comprueba si toilet está instalado si no usa figlet
if command -v toilet >/dev/null 2>&1; then
  toilet -f mono12 -F metal "LIKIT3CH"
elif command -v figlet >/dev/null 2>&1; then
  figlet "LIKIT3CH" | while IFS= read -r line; do
    echo -e "\e[32m${line}\e[0m"  
  done
else
  echo -e "\e[32mLIKIT3CH\e[0m"
fi

echo -e "\n${greenColour}[+] Bienvenido a WPENUM. Use la herramienta bajo su responsabilidad!${endColour}\n"
function ctrl_c(){
echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
exit 1 
}

#ctrl+c
trap ctrl_c INT

function helpPanel(){
 echo -e "\n${purpleColour}[+] Bienvenido al panel de ayuda${endColour}\n "
 echo -e "\t${yellowColour}(-u)${endColour}${blueColour}Añade la URL de la web de la cual quieras listar usuarios.El formato debe ser https://www.example.com${endColour}"
 echo -e "\t${yellowColour}(-e)${endColour}${blueColour}Muestra y descarga todos los endpoints del wp-json.${endColour}"
 echo -e "\t${yellowColour}(-h)${endColour}${blueColour}Abre este panel de ayuda.${endColour}" 
}

function urlVictima(){
 urlName=$1
 
}

#Indicadores
declare -i parameter_counter=0

while getopts "u:e:h" arg; do
   case $arg in
    u) urlName=$OPTARG; let parameter_counter+=1;;
    e) urlName=$OPTARG; let parameter_counter+=2;;
    h) ;;   
   
   esac
done

if [ $parameter_counter -eq 1 ]; then
 urlVictima "$urlName"; curl -sS -X GET "${urlName%/}/wp-json/wp/v2/users" | js-beautify | grep '"slug"' | awk -F: '{gsub(/[", ]/,"",$2); print $2}' | tee usersfound.txt 
 echo -e "\n${turquoiseColour}[*] Se ha descargado un archivo con los usuarios encontrados llamado usersfound.txt en el directorio actual de trabajo${endColour}\n"
elif [ $parameter_counter -eq 2 ]; then
 urlVictima "$urlName"; curl -sS -X GET "${urlName%/}/wp-json" | js-beautify | grep "href" | tr -d '\\"' 2>/dev/null | awk '{print $2}' | tee endpoints.txt 
 echo -e "\n${redColour}[*] Se ha descargado un archivo llamado endpoints.txt${endColours}\n"
else
  helpPanel
fi
