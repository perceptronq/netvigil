#!/bin/bash

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

select_interface() {
    clear
    echo "Available network interfaces:"
    readarray -t interfaces < <(get_network_interfaces)
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        echo "No network interfaces found."
        exit 1
    fi
    
    for i in "${!interfaces[@]}"; do
        printf "%3d. %s\n" $((i+1)) "${interfaces[$i]}"
    done
    echo ""
    
    read -p "Enter the number of the interface you want to monitor: " choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#interfaces[@]}" ]; then
        echo "Invalid choice. Please try again."
        select_interface
    fi
    
    INTERFACE="${interfaces[$((choice-1))]}"
    echo "Selected interface: $INTERFACE"
}

select_interface

if [ -n "$INTERFACE" ]; then
    echo "Monitoring network traffic on interface $INTERFACE. Press Ctrl+C to stop."
    sudo tcpdump -i "$INTERFACE"
else
    echo "No interface selected."
    exit 1
fi