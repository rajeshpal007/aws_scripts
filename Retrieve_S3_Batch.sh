#!/bin/bash -x

# ------------------------------------------------------------------------
#  Objective : Utility to retrieve Glacier object to S3 bucket   
# ------------------------------------------------------------------------

#=== FUNCTION ================================================================
# NAME: Retrieve_Batch
# DESCRIPTION: To restore glacier to s3 object
# PARAMETER : BUCKET_NAME PREFIXNAME DATERANGE TIERTYPE DATASOURCE
#=============================================================================
function Retrieve_Batch(){
    BUCKETNAME=$1
    DATERANGE=$2
    TIERTYPE=$3
    DATASOURCE=$4
    PREFIXNAME=$5

    if [ -z  "$PREFIXNAME" ]
    then 
        KEY=$DATASOURCE
    else
        KEY=$PREFIXNAME$DATASOURCE
    fi


    # It will get a temporary copy of required Glacier obj. for the duration specified in the restore request
    echo "Start restoring the file $DATASOURCE"
    aws s3api restore-object --bucket $BUCKETNAME --key $KEY  --restore-request '{"Days":'"$DATERANGE"',"GlacierJobParameters":{"Tier":"'"$TIERTYPE"'"}}'
    echo "Completed restoring the file $DATASOURCE"
    
    # Change the obj storage class to Amazon S3 Standard
    echo "copying to bucket as per tier retrieval"
    aws s3 cp s3://$BUCKETNAME/$KEY s3://$BUCKETNAME/$KEY --force-glacier-transfer --storage-class $TIERTYPE
    echo "copied to bucket as per tier retrieval"
}

#=== FUNCTION ================================================================
# NAME: Retrieve_Batch_help
# DESCRIPTION: Retrieve_Batch help & usage.
# PARAMETER : BUCKET_NAME PREFIXNAME DATERANGE TIERTYPE DATASOURCE
#=============================================================================
function Retrieve_Batch_help(){
    bucketname=$2
    daterange=$3
    tiertype=$4
    datasource=$5
    prefixname=$6

    bucketname=$(echo "$bucketname" | tr -d '=')
    daterange=`echo "$daterange"  | tr -d '='`
    tiertype=`echo "$tiertype" | tr -d '='`
    datasource=`echo "$datasource"  | tr -d '='`
    prefixname=`echo "$prefixname" | tr -d '='`

    if [[ "$2" == "-h" ]]; then
        echo Usage: Retrieve_Batch  bucketname daterange tiertype datasource [ prefixname]
    elif [[ ( $# -lt 5 || $# -gt 6 ) || ( "$daterange" == "daterange" || -z $daterange  ) \
    && ( "$bucketname" == "bucketname" || -z $bucketname ) \
    && ( "$tiertype" == "tiertype" || -z $tiertype ) \
    && ( "$datasource" == "datasource" || -z $datasource )]]; then
        echo Usage: Retrieve_Batch  bucketname daterange tiertype datasource [ prefixname]
    else
        #check for optional parameter [ prefixname ]
        if [[ -z $PREFIXNAME  ]]; then
            result=$( Retrieve_Batch $bucketname $daterange $tiertype $datasource)
            echo ${result}
        else
            result=$( Retrieve_Batch $bucketname $daterange $tiertype $datasource $prefixname )
            echo ${result}
        fi
    fi
}

case "$1" in
    Retrieve_Batch)
        Retrieve_Batch_help $*
        ;;
    
    *)
        echo $"Usage: $0 [-h] Retrieve_Batch"
        echo positional argument:
        echo "-h, --help        show this help message and exit"
        exit 1
esac
