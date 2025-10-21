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
    RUN_DATA=$(gh run list --workflow="${WORKFLOW_NAME}" --limit=1 --json databaseId,url --template '{{range .}}{{printf "%.0f" .databaseId}}
{{.url}}{{end}}')

    if [[ -n "${RUN_DATA}" ]]; then
        # Read the first line into RUN_ID and the second into RUN_URL
        RUN_ID=$(echo "${RUN_DATA}" | head -n 1)
        RUN_URL=$(echo "${RUN_DATA}" | tail -n 1)
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

echo "✅ Found run ID: ${RUN_ID}"
echo "🌐 View on web: ${RUN_URL}"
echo "🪵 Tailing logs..."

if ! gh run watch "${RUN_ID}" --exit-status; then
    echo
    echo "❌ Workflow run failed. Fetching full logs..."
    echo "🌐 View on web: ${RUN_URL}"
    gh run view "${RUN_ID}" --log
    exit 1
fi

echo "✅ Workflow run completed successfully."
