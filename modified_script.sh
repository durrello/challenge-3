#!/bin/bash

# Check API key is provided
if [ -z "$CF_API_KEY" ]; then
  echo "ERROR: CF_API_KEY environment variable not set" >&2
  exit 1
fi

# Call Cloudflare API to list zones
zones_json=($(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "X-Auth-Email: durrellgemuh07@gmail.com" \
  -H "X-Auth-Key: $CF_API_KEY" \
  -H "Content-Type: application/json"))

# Parse JSON response  
zones=($(echo "$zones_json" | jq -r '.result[] | .name'))

for zone in "${zones[@]}"
do
  zone_tld=$(echo "$zone" | cut -d. -f3-)
  
  # Create TLD folder 
  mkdir -p "$zone_tld"
    
  # Get records for zone  
  records=($(cf-terraforming api dns_record_list -z $zone -t $CF_API_KEY))  
        
  # Write records to zone file       
  ...

done