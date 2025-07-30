#!/bin/bash

process_name="test"
log_file="/var/log/monitoring.log"
url="https://test.com/monitoring/test/api"
state_file="/var/run/test_last_pid"

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

current_pid=$(pgrep -f "$process_name" | head -n1)

if [ -z "$current_pid" ]; then
    exit 0
fi

if [ -f "$state_file" ]; then
    old_pid=$(cat "$state_file")
else
    old_pid=""
fi

if [ "$current_pid" != "$old_pid" ]; then
    echo "$(timestamp) [info] process '$process_name' restarted. Old PID: $old_pid, New PID: $current_pid" >> "$log_file"
    echo "$current_pid" > "$state_file"
fi

http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")
if [ "$http_code" -ne 200 ]; then
    echo "$(timestamp) [error] Monitoring server unreachable: $url" >> "$log_file"
fi

if [ "$http_code" -eq 200 ]; then
    echo "$(timestamp) [ok] Server responded with 200 OK" >> "$log_file"
fi
