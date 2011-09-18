#!/usr/bin/env bash

# oauth-train.sh from http://code.google.com/intl/sl-SI/apis/predict/docs/libraries.html#oacurltraining

# Train a prediction model.
# Usage: oauth-train.sh MODEL_NAME

ID=$1
KEY=`cat googlekey`

post_data="{\"id\":\"$ID\"}"

# Train the model.
java -cp ./oacurl-1.2.0.jar com.google.oacurl.Fetch -X POST \
-t JSON \
"https://www.googleapis.com/prediction/v1.3/training?key=$KEY" <<< $post_data
echo