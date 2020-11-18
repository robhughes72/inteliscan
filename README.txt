
To Schedule a scan (TCP, UDP Host Discovery then full TCP port scan, Top 100 UDP scan or Fast Scan) run the following, editing the time and date and obviously the IP address / subnet. 

1. Check current time / date on Kali

root@kali# date

It will then print out the date and time, as follows

Fri  3 May 02:37:34 BST 2019

2. Edit the schedule scan bash script with the IP / subnet's to be scanned, ie

#!/bin/bash
echo

./inteliscan.sh ADD_IP_SUBNET_HERE

close and save


3. Schedule the scan at the date and time requested. 

root@kali# at -f schedule.sh 192.168.1.1 00.01 april 19

4. To list scheduled jobs / pending scan

at -l

5. cancel pending scan
atrm (number of scan)


When run, this will perform a host discovery over the IP or subnet added to the schedule.sh and then complete an all ports TCP syn scan and a top 100 UDP scan and output the results into the folder. Be sure to copy them down and delete the files once completed the scan. 