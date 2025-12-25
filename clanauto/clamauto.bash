#!/bin/bash


run_scan() {
    local SCAN_CMD="$1"
    local TARGET_DESC="$2"

    LOG_DIR="/var/log/clanauto"
    mkdir -p "$LOG_DIR"

    LOG_FILE="$LOG_DIR/scan-$(date '+%Y-%m-%d_%H-%M-%S').log"

    echo " $TARGET_DESC"
    echo "Log: $LOG_FILE"
    echo

    # Run scan, capture output
    eval "$SCAN_CMD" | tee "$LOG_FILE"

    # Extract infected count
    INFECTED=$(grep "Infected files:" "$LOG_FILE" | awk '{print $3}')

    if [[ "${INFECTED:-0}" -gt 0 ]]; then
        echo " Malware detected!"

        if [[ "$NOTIFY" == true ]]; then
            notify-send \
                -u critical \
                "Clanauto Alert" \
                " Malware detected!\nLog: $LOG_FILE"
        fi

        less "$LOG_FILE"
    else
        echo "Scan clean."
    fi
}

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
    echo "  -l           give the log file "
}

[[ $# -eq 0 ]] && usage && exit 1

while getopts "huf:r:st:i:b:l" opt; do
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
            run_scan \
            "clamscan --move=/quarantine --infected --bell \"$OPTARG\"" \
            "Scanning file: $OPTARG"
            ;;

        r)
            echo "Scanning folder: $OPTARG"
            echo 'X5O!P%@AP\[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H\*' > test.txt
            clamscan test.txt
            echo "this is a test file to see if it works"
            run_scan \
            "clamscan -r --move=/quarantine --infected --bell \"$OPTARG\"" \
            "Scanning folder: $OPTARG"
            ;;

        s)
            echo "Scanning entire system..."

            if [[ "$EUID" -ne 0 ]]; then
                echo "System scan must be run as root."
                echo "Run: sudo clanauto -s"
                exit 1
            fi

            run_scan \
                "clamscan -r / --infected --bell --exclude-dir='^/sys|^/proc|^/dev'" \
                "Scanning entire system"
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
            sigtool --info "$OPTARG" \
            ;;

        b)
            echo "Inspecting bytecode in: $OPTARG"
            sigtool --list-sigs "$OPTARG" \
            ;;
        
        l)
            if [[ ! -d "$LOG_DIR" ]]; then
                echo "No logs found."
                exit 0
            fi

            echo "Available scan logs:"
            ls -lh "$LOG_DIR"

            echo
            read -p "Open latest log? (y/N): " ans
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                latest=$(ls -t "$LOG_DIR"/scan-*.log | head -n 1)
                less "$latest"
            fi
            ;;
        *)
            echo "Unknown option"
            usage
            exit 1
            ;;
    esac
done

