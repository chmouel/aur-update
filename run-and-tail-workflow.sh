#!/usr/bin/env bash
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
set -euxfo pipefail

#
# Run a GitHub Actions workflow and tail the logs of the new run.
#

WORKFLOW_NAME="aur-update.yml"

echo "🏃 Triggering workflow: ${WORKFLOW_NAME}"
gh workflow run "${WORKFLOW_NAME}"

# Wait a moment for the run to be initiated on GitHub's side
echo "⏱️ Waiting for the new workflow run to start..."
sleep 5

echo "🔍 Finding the latest run..."
# Use --template to format the output and read to assign to variables
read -r RUN_ID RUN_URL < <(gh run list --workflow="${WORKFLOW_NAME}" --limit=1 --json databaseId,url --template '{{range .}}{{.databaseId}}{"\t"}{{.url}}{{end}}')

if [[ -z "${RUN_ID}" ]]; then
  echo "❌ Could not find the latest run. Please check the Actions tab in your repository."
  exit 1
fi

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

