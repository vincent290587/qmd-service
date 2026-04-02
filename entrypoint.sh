#!/bin/bash

# 1. Initial Setup
echo "--- Initializing QMD Collection ---"
qmd collection add /docs --name local-docs || echo "Collection already exists."

# 2. Initial Indexing
echo "--- Performing initial indexing ---"
qmd update
qmd embed

# 3. Start the Background Auto-Refresher
(
  while true; do
    sleep 300 # Wait 5 minutes
    echo "--- Auto-syncing new files ---"
    qmd update
    # Optional: qmd embed (only if you have a GPU, otherwise it might lag your CPU)
  done
) &

# 4. Start the MCP Server (This keeps the container running)
echo "--- Starting QMD MCP Server ---"
qmd mcp --http --port 8181
