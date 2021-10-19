#!/bin/bash
# AWS web server monitoring script

# web server responce timeout 
curl_timeout=2

# how often to do server check in seconds
monitoring_interval=2

# Curl error codes url
error_codes_url="https://curl.se/libcurl/c/libcurl-errors.html"

# web server name to monitor
monitor_url=$(terraform state pull | jq -r '.resources[2].instances[0].attributes.public_dns')

if_error()
{
# check if command executed with error
if [ $? -ne 0 ]; then
   echo $*
   echo -e "\nYou can find the exact reason for this error following this documentation URL:" 
   echo "$error_codes_url"
   exit 1
fi
}

echo "Monitoring web server: $monitor_url"

while true; do
  curl --silent --output /dev/null --max-time $curl_timeout http://${monitor_url}
  if_error "Alarm: Webserver is not available. Alarm (exit) code is $?"
  echo "Webserver is running."
  sleep $monitoring_interval
done 
