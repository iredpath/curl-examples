#!/bin/bash

ping_url="https://api.rosette.com/rest/v1"
retcode=0
errors=( "Exception" "processingFailure" "badRequest" )

#------------ Start Functions --------------------------

#Gets called when the user doesn't provide any args
function usage {
    echo -e "\n${0} -a API_KEY -f [FILENAME] -u [ALT_URL]"
    echo "  API_KEY      - Rosette API key (required)"
    echo "  FILENAME     - Shell script file (optional)"
    echo "  ALT_URL      - Alternate URL (optional)"
    exit 1
}

#Checks if Rosette API key is valid
function checkAPI {
    match=$(curl "${ping_url}/ping" -H "X-RosetteAPI-Key: ${API_KEY}" |  grep -o "forbidden")
    if [ ! -z $match ]; then
        echo -e "\nInvalid Rosette API Key"
        exit 1
    fi  
}

# strip the trailing slash off of the alt_url if necessary
function cleanURL() {
    if [ ! -z "${ALT_URL}" ]; then
        case ${ALT_URL} in
            */) ALT_URL=${ALT_URL::-1}
                echo "Slash detected"
                ;;
        esac
        ping_url=${ALT_URL}
    fi
}

#Checks for valid url
function validateURL() {
    match=$(curl "${ping_url}/ping" -H "X-RosetteAPI-Key: ${API_KEY}" |  grep -o "Rosette API")
    if [ "${match}" = "" ]; then
        echo -e "\n${ping_url} server not responding\n"
        exit 1
    fi  
}

function runExample() {
    echo -e "\n---------- ${1} start -------------"
    result=""
    script="$(sed s/your_api_key/${API_KEY}/ < ./${1})" #replacing your_api_key with actual key
    if [ ! -z ${ALT_URL} ]; then
        script=$(echo "${script}" | sed "s#https://api.rosette.com/rest/v1#${ping_url}#") #replacing api url with alt URL if provided
    fi
    script=$(echo "${script}" | sed 's~\\~~g' )
    echo $script #curl -x etc etc
    result="$(echo ${script} | bash 2>&1)" #run api operation
    echo "${result}"
    echo -e "\n---------- ${1} end -------------"
    for err in "${errors[@]}"; do 
        if [[ ${result} == *"${err}"* ]]; then
            retcode=1
        fi
    done
}

#------------ End Functions ----------------------------

#Gets API_KEY, FILENAME
while getopts ":a:f:u:" arg; do
    case "${arg}" in
        a)
            API_KEY=${OPTARG}
            ;;
        f)
            FILENAME=${OPTARG}
            ;;
        u)
            ALT_URL=${OPTARG}
            echo "Using alternate URL: ${ALT_URL}"
            ;;
        :)
            echo "Option -${OPTARG} requires an argument"
            usage
            ;;
    esac
done

if [ -z ${API_KEY} ]; then
    echo "-a API_KEY required"
    usage
fi

cleanURL

validateURL

#Run the examples
if [ ! -z ${API_KEY} ]; then
    checkAPI
    pushd examples
    if [ ! -z ${FILENAME} ]; then
        runExample ${FILENAME}
    else
        for file in *.curl; do
            runExample ${file}
        done
    fi
else 
    HELP
fi

exit ${retcode}
