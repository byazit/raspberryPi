#!/bin/bash

# --- Raspberry Pi Hardware Information Script ---
# Displays key specs using Raspberry Pi-specific tools (vcgencmd)
# and standard Linux filesystems.

echo "========================================="
echo "    Raspberry Pi Hardware Info"
echo "========================================="

# --- Utility Function ---
# Check if vcgencmd is available before using it
VCMD_AVAILABLE=$(command -v vcgencmd)

# 1. CPU AND SYSTEM INFORMATION
echo "\n--- 🧠 CPU & SYSTEM INFORMATION ---"

# Get the specific model name from the device tree
RPI_MODEL=$(cat /sys/firmware/devicetree/base/model 2>/dev/null)
if [ -z "$RPI_MODEL" ]; then
 RPI_MODEL="[Model not found]"
fi
echo "Model: $RPI_MODEL"

# Get the CPU architecture and model information
CPU_INFO=$(cat /proc/cpuinfo 2>/dev/null)
CPU_MODEL_NAME=$(echo "$CPU_INFO" | grep "Hardware" | head -n 1 | awk '{$1=$1;print $3}')
CORES=$(echo "$CPU_INFO" | grep -c "^processor")

echo "Architecture: ARM"
echo "Chip Type: $CPU_MODEL_NAME"
echo "Cores (Total): $CORES"

# 2. TOTAL RAM (Unified Memory Architecture)
echo "\n--- 💾 RAM INFORMATION ---"

# A. Total Usable RAM (Kernel View)
TOTAL_USABLE_RAM=$(free -h | grep "Mem:" | awk '{print $2}')
echo "Total Installed RAM: $TOTAL_USABLE_RAM"

# B. RAM Module Details (Removed - Not applicable to Pi's soldered RAM)
echo "RAM Modules: [Pi RAM is soldered, no module information available]"

# 3. TOTAL DISK SPACE
echo "\n--- 🗄️ DISK SPACE (Aggregate) ---"
# Sum up the size of all physical block devices (excluding non-disks)
TOTAL_DISK_SPACE_GB=$(lsblk -b -n -o SIZE,TYPE,NAME 2>/dev/null | grep "disk" | awk '{SUM+=$1} END {print SUM/1024/1024/1024}')
echo "Total Disk Space: $(printf "%.1f" $TOTAL_DISK_SPACE_GB) GB"

# 4. GPU INFORMATION
echo "\n--- 🔌 GPU INFORMATION ---"

# On Raspberry Pi, the GPU memory is allocated from the total RAM (VRAM)
if [ -n "$VCMD_AVAILABLE" ]; then
 # Use vcgencmd to check current GPU memory split
 GPU_MEM=$(vcgencmd get_mem gpu | awk -F'=' '{print $2}')
 echo "GPU: Broadcom VideoCore (Integrated)"
 echo "Allocated VRAM (Shared): $GPU_MEM"
else
 # Fallback if vcgencmd is not available (e.g., on older OS or custom build)
 echo "GPU: Broadcom VideoCore (Integrated)"
 echo "Allocated VRAM (Shared): [vcgencmd not available to check split]"
fi


echo "\n========================================="
