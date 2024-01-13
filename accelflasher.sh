#!/bin/bash

# ANSI escape codes for text styles and colors
BOLD='\033[1m'
UNDERLINE='\033[4m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ASCII art for section headers
echo -e "${BOLD}${YELLOW}"
cat << "EOF"
   _                _   ___ _           _               
  /_\   ___ ___ ___| | / __\ | __ _ ___| |__   ___ _ __ 
 //_\\ / __/ __/ _ \ |/ _\ | |/ _` / __| '_ \ / _ \ '__|
/  _  \ (_| (_|  __/ / /   | | (_| \__ \ | | |  __/ |   
\_/ \_/\___\___\___|_\/    |_|\__,_|___/_| |_|\___|_|   
                                                        
EOF
echo -e "${NC}"

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}${BOLD}Error executing the last command. Exiting.${NC}"
        exit 1
    fi
}

# Function to find the device ID
find_device_id() {
    local device_id=$(lsusb | grep -i "Raspberry Pi RP2 BOOT" | awk '{print $6}')
    echo "$device_id"
}

# Function to print user prompts
prompt_user() {
    echo -e "\n${BOLD}${YELLOW}$1${NC}"
}

# Function to create configuration file
create_config_file() {
    local config_file=$1
    local serial=$2
    local accel_chip=$3

    cat <<EOF > "$config_file"
# This file contains common pin mappings for the bigtreetech $accel_chip
# To use this config, the firmware should be compiled for the
# RP2040 with "USB"
# The micro-controller will be used to control the components.


[mcu btt_$accel_chip]
serial: $serial

[$accel_chip]
cs_pin: btt_$accel_chip:gpio9
#spi_bus: spi1a
spi_software_sclk_pin: btt_$accel_chip:gpio10
spi_software_mosi_pin: btt_$accel_chip:gpio11
spi_software_miso_pin: btt_$accel_chip:gpio8
axes_map: -y,x,-z

[resonance_tester]
probe_points: 100, 100, 20
accel_chip: $accel_chip
EOF
}

# Update the printer.cfg file
update_printer_cfg() {
    local accel_chip=$1
    local printer_cfg_file=~/printer_data/config/printer.cfg

    sed -i "1i ### Input Shaper ###" "$printer_cfg_file"
    sed -i "3i # Make sure to run SHAPER_CALIBRATE for your machine to update the following placeholder values." "$printer_cfg_file"
    # Add the include header for the new accelerometer file
    sed -i "2i [include $accel_chip.cfg]" "$printer_cfg_file"
    # Add the input shaper section
    sed -i "/\[include $accel_chip.cfg\]/a [input_shaper]" "$printer_cfg_file"
    sed -i "/input_shaper/a shaper_type_x = mzv" "$printer_cfg_file"
    sed -i "/shaper_type_x/a shaper_freq_x = 57.0" "$printer_cfg_file"
    sed -i "/shaper_freq_x/a shaper_type_y = mzv" "$printer_cfg_file"
    sed -i "/shaper_type_y/a shaper_freq_y = 32.8" "$printer_cfg_file"
    sed -i "/shaper_freq_y/a ################" "$printer_cfg_file"
    echo -e "	${GREEN}${BOLD}printer.cfg file updated successfully.${NC}"
}

# WARNING Message
prompt_user "		Warning make a backup of your printer.cfg and all other files before continuing!!"
prompt_user "		This script is working as expected, but you never know and it's best to have a backup just in case."
prompt_user "					You have been warned."
read -p "	Press Enter to confirm you understand, made a backup, and wish to continue. Pres ctrl+C if you wish to cancel at any time"
# Step 1: Checking for and installing dependencies
prompt_user "	Installing Dependencies..."
sudo apt update
check_command
sudo apt install -y python3-numpy python3-matplotlib libatlas-base-dev
check_command
echo -e "	${GREEN}${BOLD}Dependencies installed successfully.${NC}"

# Show progress and install numpy
prompt_user "	Installing numpy..."
~/klippy-env/bin/pip install -v numpy
check_command
echo -e "	${GREEN}${BOLD}numpy installed successfully.${NC}"

# Step 2: Set up firmware for your device
prompt_user "	Now let's set up the firmware..."
prompt_user "	In the next step, I will take you to the menu config. Enter the info for your board. Press Q then Y and enter when done."
read -p "	Press Enter when ready..."
cd ~/klipper
make menuconfig
echo -e ""
prompt_user "	Menuconfig setup completed."
echo -e ""
prompt_user "	Compiling firmware..."
#Make the firmware
make clean
make
check_command
echo -e "	${GREEN}${BOLD}Firmware compile completed.${NC}"

# Step 3: Attach device
retry_count=0
device_id=""
while [ -z "$device_id" ] && [ "$retry_count" -lt 3 ]; do
    prompt_user "	Now attach the device in Boot mode. This is done by holding the boot button in while plugging in the USB."
    read -p "	Press Enter when you're ready to check for the device..."
    
    # Check for device in boot mode
    device_id=$(find_device_id)
    if [ -n "$device_id" ]; then
	echo -e ""
        echo -e "	${GREEN}${BOLD}Device found: $(lsusb | grep -i "Raspberry Pi RP2 BOOT")${NC}"

    else
	echo -e ""
        prompt_user "	Device not found. Try reconnecting in boot mode, making sure to hold the boot button while connecting USB."
	echo -e ""
        ((retry_count++))
        if [ "$retry_count" -lt 3 ]; then
            read -p "	Do you want to try again? (y/n): " try_again_response
            if [ "$try_again_response" == "n" ]; then
                echo "	Exiting."
                exit 0
            fi
        else
            echo -e "	${RED}${BOLD}Maximum retries reached. Exiting.${NC}"
            exit 1
        fi
    fi
done

# Step 4: Flash
read -p "	Are you ready to flash the firmware? (y/n): " flash_response
if [ "$flash_response" == "n" ]; then
    prompt_user "	OK, I'm here if you need me. Have a good day."
    exit
elif [ "$flash_response" == "y" ]; then
    echo -e ""
    echo -e "	${GREEN}${BOLD}Firmware flash started...${NC}"
    cd ~/klipper
    make flash FLASH_DEVICE="$device_id"
    check_command
    echo -e ""
    echo -e "	${GREEN}${BOLD}Firmware flash completed successfully.${NC}"
    echo -e ""
else
    echo -e "	\n${RED}${BOLD}Invalid response. Exiting.${NC}"
    exit 1
fi

# Step 5: Confirm flash was successful
retry_count=0
new_device_serial=""
while [ -z "$new_device_serial" ] && [ "$retry_count" -lt 3 ]; do
    echo -e ""
    prompt_user "	Now let's check for a new device serial..."
    prompt_user "	First, I need you to unplug the device you just flashed. This step is important."
    read -p "	Please unplug the USB device and press Enter when done."
    connected_boards_before=$(ls /dev/serial/by-id/*)
    echo -e ""
    read -p "	Perfect! Now please reconnect the USB without holding the boot button and press Enter when done."
    connected_boards_after=$(ls /dev/serial/by-id/*)

    if [ "$connected_boards_before" != "$connected_boards_after" ]; then
        new_device_serial=$(comm -23 <(echo "$connected_boards_after") <(echo "$connected_boards_before"))
	echo -e ""
	prompt_user "	Serial was found!"
        prompt_user "	This is the new device serial: $new_device_serial"
        prompt_user "	Copy this to a safe place to later put into your printer.cfg during setup."

        # Ask the user to create a config file
        read -p "	Do you want to create a new configuration file? (y/n): " create_config_response
        if [ "$create_config_response" == "y" ]; then
            # Ask the user to select the config file option
            read -p "	Select an option (1 for lis2dw, 2 for adxl345): " config_option
            case $config_option in
                1)
                    accel_chip="lis2dw"
                    config_file=~/printer_data/config/lis2dw.cfg
                    ;;
                2)
                    accel_chip="adxl345"
                    config_file=~/printer_data/config/adxl345.cfg
                    ;;
                *)
                    echo -e "	${RED}${BOLD}Invalid option. Exiting.${NC}"
                    exit 1
                    ;;
            esac

            # Create the config file
            create_config_file "$config_file" "$new_device_serial" "$accel_chip"
            echo -e "	${GREEN}${BOLD}Configuration file created successfully: $config_file${NC}"

            # Update printer.cfg file
	    sudo systemctl stop klipper.service
            update_printer_cfg "$accel_chip"
        fi
    else
	echo -e ""
        prompt_user "	No new device found."
        ((retry_count++))
        if [ "$retry_count" -lt 3 ]; then
            read -p "	Do you want to try again? (y/n): " try_again_response
            if [ "$try_again_response" == "n" ]; then
                echo "	Exiting."
                exit 0
            fi
        else
            echo -e "	${RED}${BOLD}Maximum retries reached. Exiting.${NC}"
            exit 1
        fi
    fi
done
sudo systemctl restart klipper.service
echo -e ""
echo -e "	${GREEN}${BOLD}Everything seems to have completed successfully! Make sure to check that the .cfg files were created correctly and reboot klipper if you selected that option, otherwise continue with the .cfg setup.${NC}"
