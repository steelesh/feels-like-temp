#!/bin/bash

# default values
city_name=""
state_code=""
country_code=""
log_file=""
api_key="" # insert your api key here



# display help and usage instructions
function help {
    echo
    echo "usage: $0 [-c city_name] [-s state_code] [-C country_code] [-l log_file] [-h]"
    echo
    echo "options:"
    echo "    -c$   specify the city name (regex: only alphabetic characters and spaces)"
    echo "    -s$   specify the state code (optional, regex: 2 alphabetic characters)"
    echo "    -C$   specify the country code (optional, regex: 2 alphabetic characters, defaults to \"us\" if state code is provided)"
    echo "    -l$   log the output to a file"
    echo "    -h$   display this help message"
    echo
    exit 1
}



# parse arguments
while getopts "c:s:C:l:h" opt; do
    case $opt in
        c) city_name="$OPTARG" ;;
        s) state_code="$OPTARG" ;;
        C) country_code="$OPTARG" ;;
        l) log_file="$OPTARG" ;;
        h) help ;;
        *) help ;;
    esac
done



# early exit if required input is null OR input does not match regex
if [[ -z "$city_name" ]]; then
    echo
    echo "error: city name is required"
    echo
    help
fi
if [[ ! "$city_name" =~ ^[a-zA-Z\ ]+$ ]]; then
    echo
    echo "error: invalid city name, it should contain only alphabetic characters and spaces"
    echo
    exit 1
fi
if [[ -n "$state_code" ]] && [[ ! "$state_code" =~ ^[a-zA-Z]{2}$ ]]; then
    echo
    echo "error: invalid state code, it should be exactly 2 alphabetic characters"
    echo
    exit 1
fi
if [[ -n "$country_code" ]] && [[ ! "$country_code" =~ ^[a-zA-Z]{2}$ ]]; then
    echo
    echo "error: invalid country code, it should be exactly 2 alphabetic characters"
    echo
    exit 1
fi



# default to "us" if state is provided and no country code is given
if [[ -n "$state_code" ]] && [[ -z "$country_code" ]]; then
    country_code="us"
fi



# build query from input
q="${city_name}"
if [ -n "$state_code" ]; then
    q="${q},${state_code}"
fi
if [ -n "$country_code" ]; then
    q="${q},${country_code}"
fi



# send request to openweathermap geocoding api, store response in variable
geo_res=$(curl -s "http://api.openweathermap.org/geo/1.0/direct?q=${q}&limit=5&appid=${api_key}")



# exit if empty or invalid response
if [ -z "$geo_res" ]; then
    echo
    echo "error: couldn't find location data for ${q}"
    echo
    exit 1
fi



# handle edge case where multiple locations are returned, prompt user to select one
location_count=$(echo "$geo_res" | jq '. | length')
if [ "$location_count" -gt 1 ]; then

    echo
    echo "multiple locations found for '${city_name}':"
    echo
    echo "none of these? press ctrl+c to exit"
    echo
    echo

    for i in $(seq 0 $((location_count - 1))); do
        city=$(echo "$geo_res" | jq -r ".[$i].name")
        state=$(echo "$geo_res" | jq -r ".[$i].state")
        country=$(echo "$geo_res" | jq -r ".[$i].country")
        lat=$(echo "$geo_res" | jq -r ".[$i].lat")
        lon=$(echo "$geo_res" | jq -r ".[$i].lon")

        echo "$((i+1)). ${city}, ${state}, ${country} (lat: $lat, lon: $lon)"
    done
    
    echo
    echo
    echo -n "enter the number corresponding to the correct location: "
    read location_choice

    if [[ ! "$location_choice" =~ ^[0-9]+$ ]]; then
        echo
        echo "error: invalid location choice, it should be a number"
        echo
        exit 1
    fi
    if [[ "$location_choice" -lt 1 ]] || [[ "$location_choice" -gt "$location_count" ]]; then
        echo
        echo "error: invalid location choice, it should be between 1 and ${location_count}"
        echo
        exit 1
    fi

    lat=$(echo "$geo_res" | jq -r ".[$((location_choice - 1))].lat")
    lon=$(echo "$geo_res" | jq -r ".[$((location_choice - 1))].lon")
    city=$(echo "$geo_res" | jq -r ".[$((location_choice - 1))].name")
    state=$(echo "$geo_res" | jq -r ".[$((location_choice - 1))].state")
    country=$(echo "$geo_res" | jq -r ".[$((location_choice - 1))].country")

    echo
    echo
    echo "you selected location ${location_choice}: ${city}, ${state}, ${country} (lat: $lat, lon: $lon)"

elif [ "$location_count" -eq 1 ]; then
    lat=$(echo "$geo_res" | jq -r '.[0].lat')
    lon=$(echo "$geo_res" | jq -r '.[0].lon')
    city=$(echo "$geo_res" | jq -r '.[0].name')
    state=$(echo "$geo_res" | jq -r '.[0].state')
    country=$(echo "$geo_res" | jq -r '.[0].country')

    echo
    echo
    echo "location found: ${city}, ${state}, ${country} (lat: $lat, lon: $lon)"

else
    echo
    echo "error: couldn't find any location data for '${q}'"
    echo
    exit 1
fi



# early exit if lat or lon is null
if [ "$lat" == "null" ] || [ "$lon" == "null" ]; then
    echo
    echo "error: couldn't find latitude and/or longitude for ${q}"
    echo
    exit 1
fi



# send request to openweathermap current weather api, store response in variable
weather_res=$(curl -s "http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$api_key&units=imperial")



# extract feels-like temperature from weather data response
feels_like=$(echo "$weather_res" | jq -r '.main.feels_like')



# build output string
if [ -z "$state" ]; then
    output="it feels like ${feels_like}°F in ${city}, ${country}"
else
    output="it feels like ${feels_like}°F in ${city}, ${state}, ${country}"
fi



# print the output to the command line
echo
echo
echo "output: $output"



# log to file if -l option is used
if [ -n "$log_file" ]; then
    current_time=$(date +"%B %-d, %Y at %-I:%M%p %Z")
    if ! touch "$log_file" &> /dev/null; then
        echo -e "error: can't write to file ${log_file}"
        exit 1
    fi
    echo "[$current_time] $output" >> "$log_file"
    echo "output written to ${log_file}"
fi
