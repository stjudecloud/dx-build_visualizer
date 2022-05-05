#!/bin/bash
set -e -x -u -o pipefail

main() {

  . ~/environment
  PROJECT_ID=$DX_PROJECT_CONTEXT_ID
	PROJECT_ARGS="-p \"$PROJECT_ID\""

  VIEWER_FILE_ID=$(echo $viewer_file | jq '.["$dnanexus_link"]' -r)
  VIEWER_FILE_JSON=$(dx describe $VIEWER_FILE_ID --json)
  VIEWER_FILE_FOLDER=$(echo $VIEWER_FILE_JSON | jq '.folder' -r)
  VIEWER_FILE_NAME=$(echo $VIEWER_FILE_JSON | jq '.name' -r)
  VIEWER_ARGS="-v \"$VIEWER_FILE_FOLDER/$VIEWER_FILE_NAME\""

	FILE_ARGS="-f "
	OUTPUT_SAMPLE_NAMES=""
  for file in $(echo ${files_to_view[@]} | jq .[] -r); do
		FILE_ARGS+="\"$file\" "
		SAMPLE_NAME=$(dx describe $file --json | jq .name -r)
		OUTPUT_SAMPLES+="${SAMPLE_NAME%.*},"
  done

	# trim string
	FILE_ARGS=$(echo $FILE_ARGS | xargs)

	echo "OUTPUT_SAMPLES=$OUTPUT_SAMPLES"
	OUTPUT_ARGS="-o \"$output_name (${OUTPUT_SAMPLES%?})\""
  chmod +x make_dnanexus_shortcut
  bookmark_record=$(eval "./make_dnanexus_shortcut \
                    $VIEWER_ARGS \
                    $FILE_ARGS \
                    $OUTPUT_ARGS \
                    $PROJECT_ARGS \
                    --no-select \
                    --verbose")
  dx-jobutil-add-output bookmark_record "$bookmark_record" --class=record
}
