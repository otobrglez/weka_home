#!/usr/bin/env bash

# oauth-check-training.sh from http://code.google.com/intl/sl-SI/apis/predict/docs/libraries.html#oacurltrainingstatus

# Check training status of a prediction model.
# Usage: oauth-training.sh MODEL_NAME

DATA=$1
KEY=`cat googlekey`

# Encode the model name.
MODEL=`echo $DATA | perl -pe 's:/:%2F:g'`

# Check training status.
java -cp ./oacurl-1.2.0.jar com.google.oacurl.Fetch -X GET \
  "https://www.googleapis.com/prediction/v1.3/training/$MODEL?key=$KEY"
echo