# TRACE Request Script

This Bash script performs TRACE requests on specified targets and provides feedback based on the HTTP status codes received.

## Usage

```bash
./trace_script.sh <mode> <target or target_list>
```
## Modes
./trace_script.sh single <target><br>
./trace_script.sh list <target_list>

## Results Folder
The script creates a "results" folder and saves valid targets in the "valid.txt" file.
