#!/bin/bash
set -e

# Check if Cloudflare API Key is set
if [ -z "$CF_API_KEY" ]; then
  echo "Error: Cloudflare API Key not set. Please set the CF_API_KEY environment variable."
  exit 1
fi

# Check if cf-terraforming is installed
if ! command -v cf-terraforming &> /dev/null; then
  echo "Error: cf-terraforming is not installed. Please install cf-terraforming version 1.6.0 or later."
  exit 1
fi

# Fetch the Cloudflare resources using cf-terraforming
echo "Fetching Cloudflare resources..."
resources=$(cf-terraforming --token $CF_API_KEY)

# Check if the API request was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch Cloudflare resources. Please check the CF_API_KEY environment variable and try again."
  exit 1
fi

# Create the Terraform files
echo "Creating Terraform files..."
echo "$resources" | jq -r '.zones[] | [.name, .records[] | {"name": .name, "type": .type, "value": .content, "ttl": .ttl}] | @tsv' | sort | awk -F'\t' -v OFS='\t' '
  {
    if ($1 ~ /\.([^.]+)$/) {
      tld = $1 ~ /\.([^.]+)$/ ? substr($1, length($1)-RLENGTH+2) : $1
      zone = $1
      if (zone in zones) {
        zones[zone] = zones[zone] ORS $2
      } else {
        zones[zone] = $2
      }
    }
  }
  END {
    for (zone in zones) {
      file = zone ".tf"
      print "resource \"cloudflare_zone\" \"" zone "\" {"
      print "  zone = \"" zone "\""
      print "}"
      print ""
      print "resource \"cloudflare_record\" \"" zone "\" {"
      print "  zone_id = cloudflare_zone." zone ".id"
      print "  count = " length(zones[zone])
      print "  name = \"" zones[zone][NR]["name"] "\""
      print "  type = \"" zones[zone][NR]["type"] "\""
      print "  value = \"" zones[zone][NR]["value"] "\""
      print "  ttl = " zones[zone][NR]["ttl"]
      print "}"
      for (i = 2; i <= length(zones[zone]); i++) {
        print ""
        print "resource \"cloudflare_record\" \"" zone "_" i "\" {"
        print "  zone_id = cloudflare_zone." zone ".id"
        print "  name = \"" zones[zone][i]["name"] "\""
        print "  type = \"" zones[zone][i]["type"] "\""
        print "  value = \"" zones[zone][i]["value"] "\""
        print "  ttl = " zones[zone][i]["ttl"]
        print "}"
      }
      print ""
      print "output \"" zone "\" {"
      print "  value = cloudflare_zone." zone ".id"
      print "}"
    }
  }
' | awk '{print $0}' RS=^ file= | sed 's/^ //g' > cloudflare.tf

# Create the folders for each zone
echo "Creating folders..."
echo "$resources" | jq -r '.zones[].name' | awk -F'.' '{print $NF}' | sort -u | xargs -I{} mkdir -p {}

# Move the Terraform files to the appropriate folders
echo "Moving Terraform files..."
echo "$resources" | jq -r '.zones[].name' | awk -F'.' '{print substr($0, length($0)-length($NF)+1) ".tf"}' | xargs -I{} sh -c 'zone_name=$(echo {} | cut -f 1 -d "."); mv {} $zone_name/{}'

echo "Done."