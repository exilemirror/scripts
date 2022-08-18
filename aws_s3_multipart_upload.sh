#!/bin/bash
# Created by Hasshim Ali
# Version 1.0
# This script is used to split files and upload them to S3 using the multipart upload.
# 1. Execute the script, set the number of files to be splitted.
# 2. Provide the filename.
############################################################################

split_upload () {
    # Split the file into chunks
    echo "Spliiting file ${filename} into $numinput parts."
    split -n $numinput $filename $filename-
    ls $filename-* | sort > files.txt
    cat files.txt

    # This will generate the key and an upload id
    aws s3api create-multipart-upload --bucket dips-multipart-test --key $filename > key_uploadId.json
    uploadId=$(sed -n '/UploadId/ s/.*\: //p' key_uploadId.json | sed 's/\(\"\|\"\)//g')
    echo " "
    echo "aws s3api UploadID: ${uploadId}"

    # Perform file part count
    echo " "
    totalFiles=$(ls -l ${filename}-* | wc -l)
    i=1
    letter=a

    # Create list.json file.
    echo '{"Parts":[' > list.json

    # Loop through the filelist and upload
    while [ $i -le $totalFiles ];
    do
        bodyName=$(sed -n ${i}p files.txt)
        echo "Uploading ${bodyName} part ${i}"
        ETag=$(aws s3api upload-part --bucket dips-multipart-test --key ${filename} --part-number ${i} --body ${bodyName} --upload-id ${uploadId} | sed -n '/ETag/ s/.*\: //p')

        if [ $i -eq $totalFiles ]; then
            echo '{ "PartNumber": '${i}', "ETag": '${ETag}'}]}' >> list.json
        else
            echo '{ "PartNumber": '${i}', "ETag": '${ETag}'},' >> list.json
        fi

        ((i++))
        letter=$(echo "$letter" | tr "0-9a-z" "1-9a-z_")
        echo " "
    done

    # Get the parts
    aws s3api list-parts --bucket dips-multipart-test --key $filename --upload-id $uploadId > parts.json

    # After parts uploaded. Compile Etag and part number into one json file and upload.
    echo " "
    echo "Completing ${filename} multipart-upload"
    aws s3api complete-multipart-upload --multipart-upload file://list.json --bucket dips-multipart-test --key $filename --upload-id $uploadId
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
    read -p "Input Selection: " filename
    echo ""

    if [ "$filename" = "x" ]; then 
        exit 0
    else
        split_upload
    fi
}

mainmenu