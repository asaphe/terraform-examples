#!/usr/bin/env bash

echo "Assuming Dev enviroment by default"
echo "Parameters: \$1=CLUSTER_NAME \$2=GOOGLE_PROJECT_ID \$3=TF_CREDS \$4=SERVICE_ACCOUNT_NAME \$5=GCP_ZONE"

CLUSTER_NAME="${1}"
GOOGLE_PROJECT_ID="${2:-google-project-id}"
TF_CREDS="${3:-$(pwd)/gcp.json}"
SERVICE_ACCOUNT_NAME="${4:-terraform}"
GCP_ZONE=${5:-us-central1}

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
gcloud auth activate-service-account ${SERVICE_ACCOUNT_NAME}@${GOOGLE_PROJECT_ID}.iam.gserviceaccount.com --key-file=${KEY_FILE:-gcp.json}
gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "${GCP_ZONE}" --project "${GOOGLE_PROJECT_ID}"
