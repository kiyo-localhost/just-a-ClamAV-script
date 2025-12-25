#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage:"
    echo " -command path of <file> or <folder> " 
    echo "  -u           The tool freshclam is used to download and update ClamAVs official virus signature databases."
    echo "  -f <file>    Scan a specific file"
    echo "  -r <folder>  scan a specific folder"
    echo "  -s           Scan the entire system"
    echo "  -t <true|false>  Enable weekly system scan"
    echo "  -h           Show this help message"
    echo "  -si  <file>  sigtool scans comman virus signatures"
    echo "  -bc  <file>  a bytecode language + engine used by ClamAV to run detection logic safely"

}

[[ $# -eq 0 ]] && usage && exit 1

while getopts "huf:r:st:i:b:" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
            
        u)
            echo "Updating ClamAV database..."
            sudo freshclam || {
                echo " Update failed"
                exit 1
            }
            ;;

        f)
            echo "Scanning file: $OPTARG"
            echo 'X5O!P%@AP\[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H\*' > test.txt
            clamscan test.txt
            echo "this is a test file to see if it works"
            clamscan "$OPTARG" --move=/quarantine --infected --bell
            ;;

        r)
            echo "Scanning folder: $OPTARG"
            echo 'X5O!P%@AP\[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H\*' > test.txt
            clamscan test.txt
            echo "this is a test file to see if it works"
            clamscan -r "$OPTARG" --move=/quarantine --infected --bell
            ;;

        s)
            echo "Scanning entire system..."
            echo 'X5O!P%@AP\[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H\*' > test.txt
            clamscan test.txt
            echo "this is a test file to see if it works"
            sudo clamdscan -r / \
                --infected \
                --bell \
                --exclude-dir="^/sys|^/proc|^/dev"\
                --log="/var/log/clamav/scan.log"
                
            ;;

        t)
            if [[ "$OPTARG" == "true" ]]; then
                echo "Enabling weekly scan..."
                (crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/local/bin/clamav-weekly-scan.sh") | crontab -
            elif [[ "$OPTARG" == "false" ]]; then
                echo "Disabling weekly scan..."
                crontab -l 2>/dev/null | grep -v "clamav-weekly-scan.sh" | crontab -
            else
                echo " Use true or false"
                exit 1
            fi
            ;;

        i)
            echo "Inspecting signature file: $OPTARG"
            sigtool --info "$OPTARG"
            ;;

        b)
            echo "Inspecting bytecode in: $OPTARG"
            sigtool --list-sigs "$OPTARG"
            ;;

        *)
            echo "Unknown option"
            usage
            exit 1
            ;;
    esacc
done