#!/bin/sh
echo "--------------------OS info--------------------------"
uname -a
echo "--------------------CPU info-------------------------"
cat /proc/cpuinfo
echo "--------------------Memory info----------------------"
cat /proc/meminfo
echo "--------------------Size&partiton--------------------"
cat /proc/partitions
echo "--------------------Pi version-----------------------"
cat /proc/version
echo "--------------------Tempature------------------------"
vcgencmd measure_temp
echo "--------------------Memory split CPU&GPU-------------"
vcgencmd get_mem arm && vcgencmd get_mem gpu
echo "-------------------System memory---------------------"
free -m -h
echo "-------------------Storage in details---------------------"
df -h
