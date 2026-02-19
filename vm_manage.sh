#!/usr/bin/env bash

# VirtualBox VM Manager
# ---------------------
# This script shows all registered VMs, lets you pick one,
# and then offers various operations (power off, restart, status, etc.).
# Press 'q' at any menu to quit.

set -euo pipefail

# Colors for readability (optional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if VBoxManage is installed
if ! command -v VBoxManage &> /dev/null; then
    echo -e "${RED}Error: VBoxManage not found. Please install VirtualBox.${NC}" >&2
    exit 1
fi

# Get the list of all VMs (names only)
get_vm_list() {
    VBoxManage list vms | awk '{print $1}' | sed 's/"//g'
}

# Show status of a VM
show_status() {
    local vm="$1"
    echo -e "${YELLOW}--- Status for VM: $vm ---${NC}"
    VBoxManage showvminfo "$vm" --machinereadable | grep -E '^(name|VMState)'
}

# Main menu loop
main() {
    while true; do
        clear
        echo -e "${GREEN}=== VirtualBox VM Manager ===${NC}"
        echo

        # Get current VM list
        mapfile -t vms < <(get_vm_list)
        if [ ${#vms[@]} -eq 0 ]; then
            echo -e "${RED}No VMs found.${NC}"
            exit 1
        fi

        # VM selection menu
        echo "Available VMs:"
        PS3="Select a VM by number (or 'q' to quit): "
        select vm in "${vms[@]}"; do
            # Check if user wants to quit
            if [[ "${REPLY,,}" == "q" ]]; then
                echo "Exiting."
                exit 0
            fi
            if [[ -n "$vm" ]]; then
                break
            else
                echo -e "${RED}Invalid choice. Please try again.${NC}"
            fi
        done

        # Operations menu for the chosen VM
        while true; do
            echo
            echo -e "${GREEN}Managing VM: $vm${NC}"
            echo "Choose an operation (or 'q' to quit):"
            select op in "Power Off (ACPI)" "Restart (Reset)" "Show Status" "Start" "Pause" "Resume" "Save State" "Force Power Off" "Back to VM list" "Exit"; do
                # Check for quit at any time
                if [[ "${REPLY,,}" == "q" ]]; then
                    echo "Exiting."
                    exit 0
                fi
                case $op in
                    "Power Off (ACPI)")
                        echo -e "${YELLOW}Sending ACPI power off to $vm...${NC}"
                        VBoxManage controlvm "$vm" acpipowerbutton
                        break
                        ;;
                    "Restart (Reset)")
                        echo -e "${YELLOW}Resetting $vm...${NC}"
                        VBoxManage controlvm "$vm" reset
                        break
                        ;;
                    "Show Status")
                        show_status "$vm"
                        break
                        ;;
                    "Start")
                        echo -e "${YELLOW}Starting $vm (headless)...${NC}"
                        VBoxManage startvm "$vm" --type headless
                        break
                        ;;
                    "Pause")
                        echo -e "${YELLOW}Pausing $vm...${NC}"
                        VBoxManage controlvm "$vm" pause
                        break
                        ;;
                    "Resume")
                        echo -e "${YELLOW}Resuming $vm...${NC}"
                        VBoxManage controlvm "$vm" resume
                        break
                        ;;
                    "Save State")
                        echo -e "${YELLOW}Saving state of $vm...${NC}"
                        VBoxManage controlvm "$vm" savestate
                        break
                        ;;
                    "Force Power Off")
                        echo -e "${RED}Force powering off $vm...${NC}"
                        VBoxManage controlvm "$vm" poweroff
                        break
                        ;;
                    "Back to VM list")
                        break 2   # break out of both menus, back to VM selection
                        ;;
                    "Exit")
                        echo "Exiting."
                        exit 0
                        ;;
                    *)
                        echo -e "${RED}Invalid option. Please choose a number.${NC}"
                        ;;
                esac
            done
        done
    done
}

# Run the main function
main
