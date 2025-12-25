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


echo 'X5O!P%@AP\[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H\*' > test.txt
clamscan test.txt
echo "this is a test file to see if it works"
run_scan \
  "clamscan -r / --infected --bell --exclude-dir='^/sys|^/proc|^/dev'" \
  "Weekly full system scan"
