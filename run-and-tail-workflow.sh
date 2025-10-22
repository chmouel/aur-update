#!/bin/bash
#
# Run a GitHub Actions workflow and tail the logs of the new run.
#
set -euo pipefail

WORKFLOW_NAME="aur-update.yml"

echo "🏃 Triggering workflow: ${WORKFLOW_NAME}"
gh workflow run "${WORKFLOW_NAME}"

echo "🔍 Waiting for the new workflow run to appear..."

# Retry logic to wait for the run to be created
RUN_ID=""
RUN_URL=""
ATTEMPTS=0
MAX_ATTEMPTS=12 # 12 * 5s = 60s timeout
while [[ -z "${RUN_ID}" ]]; do
  # Fetch the latest run's ID and URL on separate lines for robust parsing.
  # We use printf "%.0f" to format the databaseId as a whole number.
  RUN_DATA=$(gh run list --workflow=.github/workflows/aur-update.yml --limit 2 --json conclusion,databaseId,url --jq '.[] | select(.conclusion == "") | "\(.databaseId)\t\(.url)"')

  # If there is multiple take the first one
  if [[ $(echo "${RUN_DATA}" | wc -l) -gt 1 ]]; then
    RUN_DATA=$(echo "${RUN_DATA}" | head -n1)
  fi

  if [[ -n "${RUN_DATA}" ]]; then
    # Read the first line into RUN_ID and the second into RUN_URL
    RUN_ID=$(echo "${RUN_DATA}" | cut -f1)
    RUN_URL=$(echo "${RUN_DATA}" | cut -f2)
  fi

  if [[ -z "${RUN_ID}" ]]; then
    ATTEMPTS=$((ATTEMPTS + 1))
    if [[ ${ATTEMPTS} -ge ${MAX_ATTEMPTS} ]]; then
      echo "❌ Timed out waiting for the workflow run to start. Please check the Actions tab in your repository."
      exit 1
    fi
    echo "   ...not found, waiting 5s (attempt ${ATTEMPTS}/${MAX_ATTEMPTS})"
    sleep 5
  fi
done

JOB_ID=$(gh run view ${RUN_ID} --json jobs --jq '.["jobs"][0].databaseId')
RUN_JOB_ID=${RUN_URL}/job/${JOB_ID}
echo "✅ Found run ID: ${RUN_ID}"
echo "🌐 View on web: ${RUN_JOB_ID}"
gh run view -j ${JOB_ID} -w "${RUN_ID}"
echo "🪵 Tailing logs..."

if ! gh run watch "${RUN_ID}" --exit-status; then
  echo
  printf '\e]99;;❌ Workflow %s Failed\a' ${WORKFLOW_NAME%%.yml}
  echo "❌ Workflow run failed. Fetching full logs..."
  echo "🌐 View on web: ${RUN_URL}"
  if ! gh run view "${RUN_ID}" -j ${JOB_ID} --log-failed; then
    :
  fi
  echo "Run the following command to see the full logs:"
  echo "gh run view ${RUN_ID} -j ${JOB_ID} --log"
  exit 1
else
  printf '\e]99;;✅ Workflow %s Succeeded\a' ${WORKFLOW_NAME%%.yml}
fi

echo "✅ Workflow run completed successfully."
