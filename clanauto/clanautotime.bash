#!/bin/bash
echo 'X5O!P%@AP\[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H\*' > test.txt
clamscan test.txt
echo "this is a test file to see if it works"
clamscan -r / \
  --infected \
  --bell \
  --exclude-dir="^/sys|^/proc|^/dev" \
  --log=/var/log/clamav/weekly.log