
# QMD

https://github.com/tobi/qmd.git

## Build image

```bash
docker compose up -d --build
```

## Bash aliases

```bash
# qmd "Smart Alias" for Docker
qmd() {
  # Check if the container is running
  if [ "$(docker ps -q -f name=qmd-search)" ]; then
    # Execute the command inside the container
    # "$@" passes all your arguments (like search -n 5) to the app
    docker exec -it qmd-search qmd "$@"
  else
    echo "Error: qmd-search container is not running."
    echo "Try: docker compose up -d"
  fi
}

alias getwisdom='_getwisdom() { \
    local url=$1; \
    local timestamp=$(date +%Y%m%d_%H%M%S); \
    local output_dir="$HOME/Github/qmd-service/my-docs"; \
    local tmp_raw=$(mktemp /tmp/raw_XXXXXX.txt); \
    local tmp_clean=$(mktemp /tmp/clean_XXXXXX.txt); \
    \
    echo "--- Fetching and Slicing Content ---"; \
    \
    # 1. Download as text \
    lynx -dump -nolist "$url" > "$tmp_raw"; \
    \
    # 2. Extract content between markers (case-insensitive) \
    sed -n "/Episode transcript/I,/Related posts/I p" "$tmp_raw" > "$tmp_clean"; \
    \
    # 3. Process with Fabric \
    cat "$tmp_clean" | fabric --pattern extract_wisdom > /tmp/wisdom.md; \
    \
    # 4. Save to destination \
    cp /tmp/wisdom.md "$output_dir/wisdom_$timestamp.md"; \
    \
    # Cleanup \
    rm "$tmp_raw" "$tmp_clean"; \
    \
    echo "Success! Wisdom archived as wisdom_$timestamp.md"; \
}; _getwisdom'

```

## Converts PDFs to Markdown

https://github.com/datalab-to/marker

```bash
uv init
uv add install marker-pdf
```

```bash
uv run marker_single --output_dir my-docs "pdf/3DDS-0838-6 - 3DIPCC0838 Standard Flight Code for CASPEX 12M - User Manual and ICD_Customer.pdf"
```

```bash
uv run marker_single --output_dir my-docs "pdf/SRON-TANGO-TN-2025-009iss4 CarCam Protocol Description_signed.pdf"
```
