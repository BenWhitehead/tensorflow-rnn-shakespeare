#!/usr/bin/env bash

export REGION=us-central1
export MODEL_NAME="shakespeare"
export BUCKET="gs://${PROJECT_NAME}-${MODEL_NAME}"

export SCALE_TIER=${SCALE_TIER:-"STANDARD_1"}

# TODO: Tell the code where the text files are for it to work on
export PACKAGE_PATH="shakespeare/"
export MODULE_NAME="shakespeare.model.rnn_train"

function now() {
  date --utc '+%Y%m%d%H%M%S'
}

function createBucket() { (

  gsutil mb -l "$REGION" "$BUCKET"

) }

function uploadData() { (

  gsutil cp -r shakespeare/* "$BUCKET/data"

) }

function trainLocally() { (

  local outputPath="output"

  gcloud ml-engine local train \
    --job-dir ${outputPath} \
    --package-path "$PACKAGE_PATH" \
    --module-name "$MODULE_NAME" \
    -- \
      --train-files "$(pwd)/shakespeare/data/*.txt"

) }

function trainModel() { (

  local jobName="shakespeare_${SCALE_TIER}_v1"
  local outputPath="${BUCKET}/$jobName"
  echo "Writing results to ${outputPath}" | tee "logs/${jobName}.log"

  mkdir -p logs

  gcloud ml-engine jobs submit training ${jobName} \
    --region ${REGION} \
    --runtime-version 1.10 \
		--python-version 3.5 \
    --scale-tier ${SCALE_TIER} \
    --job-dir ${outputPath} \
    --package-path "$PACKAGE_PATH" \
    --module-name "$MODULE_NAME"


) }


function createModel() { (

  gcloud ml-engine models create "$MODEL_NAME" --regions="$REGION"

) }

function createModelVersion() { (

  gcloud ml-engine versions create "v1" \
    --model ${MODEL_NAME} \
    --origin ${outputPath} \
    --runtime-version 1.10 \
		--python-version 3.5

) }

function queryModel() { (

#  TODO
  true

) }


function main() { (

  queryModel

) }

######################### Delegates to subcommands or runs main, as appropriate
if [[ ${1:-} ]] && declare -F | cut -d' ' -f3 | fgrep -qx -- "${1:-}"
then "$@"
else main
fi
