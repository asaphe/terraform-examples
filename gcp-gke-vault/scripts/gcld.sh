#!/usr/bin/env bash

echo "Assuming Dev enviroment by default"
echo "Parameters: \$1=CLUSTER_NAME \$2=ZONE \$3=GOOGLE_PROJECT_ID \$4=TF_CREDS"

GOOGLE_PROJECT_ID="${3:-dev}"
TF_CREDS="${4:-$(pwd)/tmp/gcp-creds.json}"

export GOOGLE_PROJECT_ID="${GOOGLE_PROJECT_ID}"
export TF_CREDS="${TF_CREDS}"
export GOOGLE_APPLICATION_CREDENTIALS="${TF_CREDS}"

if [[ -z "${1}" ]];
  then
    echo "Cluster name must be specified";
    exit 1;
  else
    export CLUSTER_NAME="${1}"
fi

gcloud config configurations activate "${GOOGLE_PROJECT_ID}"
gcloud auth activate-service-account terraform@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com --key-file=${KEY_FILE:-gcp.json}
gcloud container clusters get-credentials "${1}" --zone "${2:-us-central1}" --project "${GOOGLE_PROJECT_ID}"
