# fetch current "feels-like" temperature
bash script that queries the [openweathermap api](https://openweathermap.org/) to fetch and display the current "feels-like" temperature for a specific location. it allows users to input a city name, and optionally a state and country code, to output the "feels-like" temperature for that location

## purpose
**what it does**: the script takes in user input (city name, and optionally state and country) and outputs the current "feels-like" temperature for that location

**why it is useful**: this script provides users with a quick way to check how the temperature feels for any location directly from the command line

## requirements
to run the script, you need the following:

1. `jq`: The script uses jq to parse JSON returned from the openweathermap api. you can check if it is already installed by running `jq --version` in your terminal.
if applicable, [see download instructions here](https://jqlang.github.io/jq/download/)

4. `openweathermap api key`: you'll need an api key from openweathermap. [see instructions here](https://openweathermap.org/appid)

## arguments
to fetch the current "feels-like" temperature for a specified location, you can run the script with the following arguments:

- `-c`: specify the city name for fetching weather data (required)
- `-s`: specify the state code (optional)
- `-C`: specify the country code (optional)
- `-l`: log the weather output to a file
- `-h`: displays help and usage instructions

> it's recommended to provide a state code and/or country code to get more accurate results

## usage
before running the script, you need to replace the placeholder api key on line 8 with your own openweathermap api key

<details>
<summary><b>get the current "feels-like" temperature by city name and state code</b></summary>
<br />
    
**input**

`./feels_like_temp.sh -c "cincinnati" -s "oh"`

**output**

```bash
location found: Cincinnati, Ohio, US (lat: 39.1014537, lon: -84.5124602)

output: it feels like 70°F in Cincinnati, Ohio, US
```
</details>

<details>
<summary><b>get the current "feels-like" temperature by city name, state code, and country code</b></summary>
<br />
    
**input**

`./feels_like_temp.sh -c "cincinnati" -s "oh" -C "us"`

**output**

```bash
location found: Cincinnati, Ohio, US (lat: 39.1014537, lon: -84.5124602)

output: it feels like 70°F in Cincinnati, Ohio, US
```
</details>

<details>
<summary><b>get the current "feels-like" temperature by city name and state code, and log the weather data to a file</b></summary>
<br />
    
**input**

`./feels_like_temp.sh -c "cincinnati" -s "oh" -l weather.log`

**output**

```bash
location found: Cincinnati, Ohio, US (lat: 39.1014537, lon: -84.5124602)

output: it feels like 58.19°F in Cincinnati, Ohio, US
output written to weather.log
```
</details>

<details>
<summary><b>display help and usage instructions</b></summary>
<br />
    
**input**

`./feels_like_temp.sh -h`

**output**

```bash
usage: ./feels_like_temp.sh [-c city_name] [-s state_code] [-C country_code] [-l log_file] [-h]

options:
    -c   specify the city name (regex: only alphabetic characters and spaces)
    -s   specify the state code (optional, regex: 2 alphabetic characters)
    -C   specify the country code (optional, regex: 2 alphabetic characters, defaults to "us" if state code is provided)
    -l   log the output to a file
    -h   display this help message
```
</details>

<hr>

### handling multiple returned locations
if there are multiple locations with the same name, the script will prompt you to choose your desired one from a list, with each option being clearly numbered. you can select the desired location by entering the corresponding number. if none apply, you can press ctrl+c to exit. if you enter an invalid number, the script will display an error message

<details>
<summary><b>example</b></summary>
<br />
    
**input**

`./feels_like_temp.sh -c "springfield"`

**output**

```bash
multiple locations found for 'springfield':

none of these? press ctrl+c to exit

1. Springfield, Illinois, US (lat: 39.7990175, lon: -89.6439575)
2. Springfield, Massachusetts, US (lat: 42.1018764, lon: -72.5886727)
3. Springfield, Missouri, US (lat: 37.1968298, lon: -93.2946576)
4. Springfield, Ohio, US (lat: 39.9234046, lon: -83.810138)
5. Springfield, Oregon, US (lat: 44.0462362, lon: -123.0220289)

enter the number corresponding to the correct location: {chosen_number}

you selected location {chosen_number}: {location_info}

output: it feels like {location_temperature}°F in {location_info}
```
</details>


## error handling
this script uses various checks and validation steps to ensure that the user's input is correct before making requests to the api. if any issues are detected, error messages are displayed, and the script exits

## build instructions
1. clone the repository and change into the directory
    ```
    git clone https://github.com/steelesh/feels-like-temp.git && cd feels-like-temp
    ```
2. install `jq`. [see instructions here](https://stedolan.github.io/jq/download/)
3. get an api key from openweathermap. [see instructions here](https://openweathermap.org/appid)
4. replace the placeholder api key on line 8 with your own openweathermap api key
5. in the repository directory, run `chmod +x feels_like_temp.sh` to make the script executable
6. run as per the [usage](#usage) instructions
