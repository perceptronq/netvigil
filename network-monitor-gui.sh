#!/bin/bash

# Check if zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Installing..."
    sudo apt-get install -y zenity
fi

# get a list of available network interfaces
get_network_interfaces() {
    local interfaces=()
    while read -r line; do
        if [[ $line =~ ^[0-9]+:.* ]]; then
            interface=$(echo "$line" | awk -F ':' '{print $2}' | awk '{print $1}')
            interfaces+=("$interface")
        fi
    done < <(ip link show)
    printf '%s\n' "${interfaces[@]}"
}

# GUI interface selection
select_interface_gui() {
    local interfaces=($(get_network_interfaces))
    local options=()
    
    for interface in "${interfaces[@]}"; do
        options+=("$interface" "Network Interface")
    done
    
    INTERFACE=$(zenity --list \
        --title="Network Monitor" \
        --text="Select network interface to monitor:" \
        --column="Interface" \
        --column="Type" \
        "${options[@]}" \
        --width=400 \
        --height=300)
    
    if [ $? -ne 0 ]; then
        zenity --error --text="No interface selected. Exiting."
        exit 1
    fi
}

# Main execution
select_interface_gui

if [ -n "$INTERFACE" ]; then
    # Show monitoring notification
    zenity --info --text="Starting monitoring on $INTERFACE\nCheck terminal for output" &
    
    # Start tcpdump in terminal
    xterm -T "Network Monitor - $INTERFACE" -e "sudo tcpdump -i $INTERFACE; read -p 'Press Enter to close...'" 2>/dev/null
else
    zenity --error --text="No interface selected."
    exit 1
fi