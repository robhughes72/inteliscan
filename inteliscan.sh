#!/bin/sh
# $Id: mapping-script.sh v0.2 - 22/03/13 - Jim Taylor = updated by Rob Hughes

# USE type - sudo mapping-script.sh -i filename.txt    or    sudo mapping-script.sh 192.168.1.1 etc.....


# Runs the find-hosts-up.sh (initially written by Dave Armstrong), outputs the targets found alive to the live.hosts file.
# Next a menu appears giving options to differing nmap scans against the alive hosts saved in the live.hosts file.
# All output is then saved in 3 formats as tcpscan and udpscan etc.

echo ""
echo ""
echo "Initiating scan to find alive hosts ........"
echo ""
echo ""

# $Id: hostup,v 1.1.1.1 2007/10/02 14:45:49 dave Exp $ ## Maximum of 10 ports per protocol!  NMap b0rks if we try any more... :( ## If you want to increase the number of ports available, change ## the value of MAX_PROBE_PORTS in nmap.h and recompile nmap.
##
TCP_PORTS=22,25,53,80,110,143,256,258,443,8080

UDP_PORTS=19,500,49,123,161

IP=$1

##
## ICMP Probes: PE=Echo, PP=Timestamp, PM=Netmask ## ICMP="-PE -PP -PM"

##
## Fast options are used when the "-f" flag is specified ##
FAST_OPTS="-T4 --max-rtt-timeout 1000ms"

##
## Build our base nmap command
##
nmap -r -v -sP $1 $ICMP -PS$TCP_PORTS -PU$UDP_PORTS 0 -oA hostup

##
## Process command line options
##
args=`getopt hdfi: $*`
if [ $? != 0 ]; then
                echo Try \'`basename $0` -h\' for more information.
                exit 2
fi

set -- $args

for i; do
                case "$i" in
                -h)
                                echo "Usage: `basename $0` [-hdf] [-i file] [target [...]]"
                                echo "  -h  Display usage information"
                                echo "  -d  Dump previous results"
                                echo "  -f  Enable fast scanning"
                                echo "  -i  Specify a targets file"
                                exit;;
                -d)
                                if [ ! -f "hostup.gnmap" ]; then
                                                echo "ERROR: No hostup results to dump!"
                                                exit 2
                                fi
                                egrep "Host:.+(\(.+\)|Up)" hostup.gnmap | cut -d ' ' -f 2
                                exit;;
                -f)
                                NMAP="$NMAP $FAST_OPTS"
                                shift;;
                -i)
                                if [ ! -f "$2" ]; then
                                                echo "ERROR: Input file does not exist!";
                                                exit 2
                                fi
                                INPUT_FILE="$2"
                                shift;
                                shift;;
                --)
                                shift;
                                break;;
                esac
done


## If an targets file has been specified ## if [ -n "$INPUT_FILE" ]; then
                ##
                ## Blast away at the specified input file
                ##
                $NMAP -iL $INPUT_FILE
                ## Otherwise...
                ##
                ## Ensure at least one target has been specified
                ##
                if [ -z "$1" ]; then
                                echo "ERROR: No targets specified!"
                                exit 2
                fi

                ##
                ## Tell nmap to append output files and remove any old output files
                ## so we don't append to old results/
                ##
                NMAP="$NMAP --append_output"
                #rm -f hostup.nmap hostup.gnmap hostup.xml

                ##
                ## Do the deed to every target specified on the command line...
                ##
                while [ -n "$1" ]; do
                                $NMAP $1
                                shift;
                done


##
## This part of the script extract the targets found up, to file called live.hosts ## 

cat hostup.gnmap | grep "Status: Up" | cut -d" " -f2 | grep ^[0-9] > live.hosts


clear
echo ""
echo "The following hosts were found to be alive:"
more live.hosts
echo ""
echo ""
echo "The following nmap scripts will now run against the targets listed above:"
echo ""
echo "1. A UDP Scan against common ports (Fast Scan) and a version detection."
echo "2. A full TCP Scan Incl. Version Detection and OS Guess."
echo "3. A UDP Scan against 1000 ports."
echo ""
echo "Please wait for scans to start............."


nmap -vv -Pn -sUV -F -oA UDP -iL live.hosts --version-intensity 0;nmap -v -n -Pn -sS -sV -O -iL live.hosts -p- -oA tcp-osscan-versiondet_nmap_results


wait

clear
echo ""
echo "All Nmap scans have been completed and saved..."
echo "Review results in the scripted-nmap-scan-results folder."

##
## Tell nmap to append output files and remove any old output files ## so we don't append to old results/ ## 

rm -f hostup.nmap hostup.gnmap hostup.xml

