#!/bin/bash

# Update a pre-trained predictive model with new data.
# Usage: oauth-update.sh MODEL_NAME LABEL DATA

DATA=$1
LABEL="$2"
INPUT="$3"

KEY=`cat googlekey`

# encode model name                                                                                         
model=`echo $DATA | perl -pe 's:/:%2F:g'`
data="{\"classLabel\" : \" $LABEL \", \"csvInstance\" : [ $INPUT ]}"

# update a model                                                                                            
java -cp ./oacurl-1.2.0.jar com.google.oacurl.Fetch -X PUT \
-t JSON \
"https://www.googleapis.com/prediction/v1.3/training/$model?key=$KEY" <<< $data
echo