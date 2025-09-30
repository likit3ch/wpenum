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
 echo -e "\t${yellowColour}(-v)${endColour}${blueColour}Verifica los endpoints guardados en endpoints.txt y muestra solo los que devuelvan HTTP 200.${endColour}"
 echo -e "\t${yellowColour}(-h)${endColour}${blueColour}Abre este panel de ayuda.${endColour}" 
}

function urlVictima(){
 urlName=$1
 urlValidation="$(curl -sS -X GET "${urlName%/}/wp-json/wp/v2/users" 2>/dev/null | js-beautify 2>/dev/null | grep '"slug"' | awk -F: '{gsub(/[", ]/,"",$2); print $2}' | tee usersfound.txt)"
 if [ "$urlValidation" ]; then
 echo -e "${turquoiseColour}[*] Listando usuarios, espere...${endColour}\n"
 else
 echo -e "${redColour}[!] La web no expone usuarios, pruebe otra opción${endColour}"
 fi
}

function urlVictima2(){
 urlName=$1
 urlValidation2="$(curl -sS -X GET "${urlName%/}/wp-json" 2>/dev/null | js-beautify 2>/dev/null | grep "href" | tr -d '\\"' 2>/dev/null | awk '{print $2}' | tee endpoints.txt)"
 if [ "$urlValidation2" ]; then
  echo -e "${turquoiseColour}[*] Listando endpoints, espere...${endColour}\n"
 else
 echo -e "${redColour}[!] La web no expone endpoints, lo sentimos <3${endColour}"
 fi
}

function checkRute200(){
 local file=$1
 local line code
if [ ! -f "$file" ]; then
  echo -e "${redColour}[!] No existe el archivo ${file}${endColour}"
  return 1 
fi

  echo -e "${turquoiseColour}[*] Verificando endpoints en ${file}...${endColour}\n"
 while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    code=$(curl -sS -o /dev/null -w "%{http_code}" -I -L --max-time 10 "$line" 2>/dev/null || echo "000")
    if [ "$code" == "200" ]; then
      echo -e "${greenColour}[200]${endColour} $line"
    fi
  done < "$file"
}
#Indicadores
declare -i parameter_counter=0

while getopts "u:e:hv" arg; do
   case $arg in
    u) urlName=$OPTARG; let parameter_counter+=1;;
    e) urlName=$OPTARG; let parameter_counter+=2;;
    v) let parameter_counter+=3;;
    h) ;;   
   
   esac
done

if [ $parameter_counter -eq 1 ]; then
 
 urlVictima "$urlName"; curl -sS -X GET "${urlName%/}/wp-json/wp/v2/users" 2>/dev/null | js-beautify 2>/dev/null | grep '"slug"' | awk -F: '{gsub(/[", ]/,"",$2); print $2}' | tee usersfound.txt 
 echo -e "\n${turquoiseColour}[*] Se ha descargado un archivo con los usuarios encontrados llamado usersfound.txt en el directorio actual de trabajo${endColour}\n"

elif [ $parameter_counter -eq 2 ]; then
 urlVictima2 "$urlName"; curl -sS -X GET "${urlName%/}/wp-json" 2>/dev/null | js-beautify 2>/dev/null | grep "href" | tr -d '\\"' 2>/dev/null | awk '{print $2}' | tee endpoints.txt 
 echo -e "\n${redColour}[*] Se ha descargado un archivo llamado endpoints.txt${endColours}\n"

elif [ $parameter_counter -eq 3 ]; then
 checkRute200 endpoints.txt 
else
  helpPanel
fi

