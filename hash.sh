#! /bin/bash

# Do some prep work
command -v jq >/dev/null 2>&1 || { echo >&2 "We require jq for this script to run, but it's not installed.  Aborting."; exit 1; }
command -v sha1sum >/dev/null 2>&1 || { echo >&2 "We require sha1sum for this script to run, but it's not installed.  Aborting."; exit 1; }

# quick checksum generator for all zip packages in this repo root folder
echo -n "[vdm.io] -- Building checksum and info file for all zip Packages found in this repository......"

# setup: positional arguments to pass in literal variables, query with code    
jq_args=( )
jq_query='.'
# counter
nr=1

for filename in *.zip; do
	# get the hash
    fileHash=$(sha1sum "$filename" | awk '{print $1}')
	# build the hash file name
	hashFileName="${filename/.zip/.sha}"
	# create/update the file checksum
	echo "$fileHash" > "$hashFileName"
	# shop file name
	shopFileName="${filename/.zip/.info}"
	# pull the info file from zip for shop
	unzip -q "$filename" info.vdm
	mv info.vdm "$shopFileName"
	# load the values for json
	jq_args+=( --arg "key$nr"   "$filename"   )
    jq_args+=( --arg "value$nr" "$fileHash" )
	# build query for jq
	jq_query+=" | .[\$key${nr}]=\$value${nr}"
	#next
	nr=$((nr+1))
done
# run the generated command with jq
jq "${jq_args[@]}" "$jq_query" <<<'{}' > checksum.json

# done with hash
echo "done"
