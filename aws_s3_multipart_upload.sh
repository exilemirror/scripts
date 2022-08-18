#!/bin/bash
# This script is used to split files and upload them to S3 using the multipart upload.
# 1. Execute the script, set the number of files to be splitted.
# 2. Provide the filename.

split_upload () {
    # split the file into chunks
    echo "Spliiting file...."
    split -n $numinput $filename $filename-

    # this will generate an uplaod id
    aws s3api create-multipart-upload --bucket dips-multipart-test --key $filename > key_uploadId.json
    uploadId=$(sed -n '/UploadId/ s/.*\: //p' key_uploadId.json | sed 's/\(\"\|\"\)//g')
    echo " "
    echo "UploadID is ${uploadId}"

    # Upload each part
    echo " "
    totalFiles=$(ls -l ${filename}-* | wc -l)
    i=1
    letter=a

    while [ $i <= $totalFiles ] 
    do
        echo "Uploading ${filename} part ${i}"
        aws s3api upload-part --bucket dips-multipart-test --key $filename --part-number $i --body $filename-a$letter --upload-id $uploadId
        filecount+=1
        letter=$(echo "$letter" | tr "0-9a-z" "1-9a-z_")
    done
}

############################# MAIN MENU FUNCTION ########################################
mainmenu () {
    # Get the number & filename
    echo "##########################################################"
    echo "1. Please enter number (2-10) for number of parts to split"
    echo "##########################################################"
    echo ""
    read -n 2 -p "Input Selection: " numinput
    echo ""

    echo "##############################"
    echo "2. Please enter the filename."
    echo "##############################"
    echo ""
    echo "Press x to exit the script"
    echo ""
    read -n 2 -p "Input Selection: " filename
    echo ""

    if [ "$filename" = "x" ]; then 
        exit 0
    else
        split_upload
    fi
}

mainmenu

# # Get all the ETags and part numbers
# aws s3api list-parts --bucket dips-multipart-test --key <key_name_from_step_2> --upload-id $uploadId

# # After parts uploaded. Compile Etag and part number into one json file and upload.
# aws s3api complete-multipart-upload --multipart-upload file://<jsonfilename> --bucket dips-multipart-test --key <key_name_from_step_2> --upload-id $uploadId
