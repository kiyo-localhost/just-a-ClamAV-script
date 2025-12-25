# ClamAuto – just a  ClamAV scrpt 

**ClamAuto** is a Bash script that makes using ClamAV faster, easier,for avarge dumb people like me  It adds:

* Easy commands for scanning files, folders, or the whole system.
* Optional weekly automated scans.
* A quarantine folder for detected malware.
* Colorful, readable terminal output.
* Optional desktop notifications for malware detection.

---

## Features

* Scan a file or folder quickly.
* Full system scans (root required).
* Fast scans of user-writable areas.
* Inspect ClamAV signature files or bytecode.
* Test scan using the safe EICAR file.
* Logs stored in `~/.local/share/clanauto` (user) or `/var/log/clanauto` (root).

---

## Requirements

* **Linux** (tested on Ubuntu/Debian)
* **Bash** (`>= 4`)
* **ClamAV** (`clamscan`, `freshclam`, `sigtool`)
* **notify-send** (optional, for desktop notifications)

---

## Installation

1. Clone then copy the script to `/usr/local/bin/clamauto`
```bash
sudo mv "the path of clone"  /usr/local/bin/
``` 
2. go to the path 
 ```bash
  cd /usr/local/bin/clamauto
```
3. Make it executable:
```bash
sudo chmod +x /usr/local/bin/clamauto
```
4. Update ClamAV database (first time):

```bash
sudo clamauto -u
```

---

## Usage

```bash
clamauto -h        # Show help
clamauto -f file   # Scan a specific file
clamauto -r folder # Scan a folder
clamauto -s        # Scan entire system (root required)
clamauto -d        # Fast scan (user areas)
clamauto -i file   # Inspect signature file
clamauto -b file   # List bytecode signatures
clamauto -l        # View latest scan log
```

### Examples

Scan a single file:

```bash
clamauto -f ~/Downloads/eicar.txt
```

Scan a folder:

```bash
clamauto -r ~/Documents
```

Enable weekly system scan (via cron):

```bash
clamauto -t true
```

---

## Logs & Quarantine

* Logs:

  * User scans → `~/.local/share/clanauto`
  * Root scans → `/var/log/clanauto`
* Quarantine folder:

  * User → `~/.local/share/clanauto/quarantine`
  * Root → `/quarantine`

---

## Notes

* EICAR test string is used for safe testing.
* Some scans require root (`sudo`) for full system access.
* Currently, the spinner is disabled during scans to preserve live output.

---

## Contributing

* ps: its my first bash project with like more then 5 lines and created from scrach so its gonna be bad 
* Open an issue for bugs or feature requests.
* or just do it yourself and send me so i can also use it
---

## License

* MIT License (or whatever you choose)
* []{https://media.tenor.com/tgs32ozGlrkAAAAi/uma-musume-anime.gif}
