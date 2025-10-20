#!/bin/bash
#
# Run a GitHub Actions workflow and tail the logs of the new run.
#
set -euo pipefail

WORKFLOW_NAME="aur-update.yml"

echo "🏃 Triggering workflow: ${WORKFLOW_NAME}"
gh workflow run "${WORKFLOW_NAME}"

# Wait a moment for the run to be initiated on GitHub's side
echo "⏱️ Waiting for the new workflow run to start..."
sleep 5

echo "🔍 Finding the latest run ID..."
RUN_ID=$(gh run list --workflow="${WORKFLOW_NAME}" --limit=1 --json databaseId -q '.[0].databaseId')

if [[ -z "${RUN_ID}" ]]; then
    echo "❌ Could not find the latest run ID. Please check the Actions tab in your repository."
    exit 1
fi

echo "✅ Found run ID: ${RUN_ID}"
echo "🪵 Tailing logs..."

gh run watch "${RUN_ID}" --exit-status
