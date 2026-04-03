
# QMD

https://github.com/tobi/qmd.git

## Build image

```bash
cp server.ts ./qmd/src/mcp/server.ts
docker compose up -d --build
```

## CLI

```bash
qmd query "question"              # Auto-expand + rerank
qmd query $'lex: X\nvec: Y'       # Structured
qmd query $'expand: question'     # Explicit expand
qmd query --json --explain "q"    # Show score traces (RRF + rerank blend)
qmd search "keywords"             # BM25 only (no LLM)
qmd get "#abc123"                 # By docid
qmd multi-get "journals/2026-*.md" -l 40  # Batch pull snippets by glob
qmd multi-get notes/foo.md,notes/bar.md   # Comma-separated list, preserves order
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
    local url="$1"; \
    local timestamp=$(date +%Y%m%d_%H%M%S); \
    local output_dir="$HOME/Github/qmd-service/my-docs"; \
    local tmp_raw=$(mktemp /tmp/raw_XXXXXX.txt); \
    local tmp_clean=$(mktemp /tmp/clean_XXXXXX.txt); \
    \
    # Create output dir if missing \
    mkdir -p "$output_dir"; \
    \
    echo "--- Fetching and Slicing Content ---"; \
    \
    # 1. Download as text \
    lynx -dump -nolist "$url" > "$tmp_raw"; \
    \
    # Check if download actually worked \
    if [ ! -s "$tmp_raw" ]; then echo "Error: Download failed or page is empty."; rm "$tmp_raw"; return 1; fi; \
    \
    # 2. Hard check for "transcript" keyword \
    if ! grep -qi "transcript" "$tmp_raw"; then \
        echo "Error: Keywork '\''transcript'\'' not found on page. Skipping."; \
        rm "$tmp_raw"; \
        return 1; \
    fi; \
    \
    # 2. Extract content between markers (case-insensitive) \
    sed -n "/Episode transcript/I,/Related posts/I p" "$tmp_raw" > "$tmp_clean"; \
    \
    # 3. Process with Fabric \
    cat "$tmp_clean" | fabric --pattern extract_wisdom | tee /tmp/wisdom.md; \
    \
    # 4. Save to destination \
    cp /tmp/wisdom.md "$output_dir/wisdom_$timestamp.md"; \
    \
    # Cleanup \
    rm "$tmp_raw" "$tmp_clean"; \
    \
    echo "Success! Wisdom archived as $output_dir/wisdom_$timestamp.md"; \
}; _getwisdom'

```

Execute on each line of a file:

```bash
while IFS= read -r line; do getwisdom "$line"; echo "sleeping 80s..."; sleep 80; done < memo.md
```

## Powershell aliases

```powershell
notepad $PROFILE

function GetWisdom {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url
    )

    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    # C:\Users\vgol\Documents\01_Firmware\xx_BlackOps\qmd-service
    $OutputDir = "$HOME\Github\qmd-service\my-docs"
    $TempWisdom = "$env:TEMP\wisdom.md"

    # Create directory if missing
    if (!(Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

    Write-Host "--- Checking: $Url ---" -ForegroundColor Cyan

    try {
        # 1. Download
        $WebResponse = Invoke-WebRequest -Uri $Url -UseBasicParsing -UserAgent "Mozilla/5.0"
        $RawText = $WebResponse.Content

        # 2. Hard check for "transcript" keyword
        if ($RawText -notmatch "transcript") {
            Write-Host "Error: Keyword 'transcript' not found on page. Skipping." -ForegroundColor Red
            return
        }

        # 3. Slice content
        # Matches everything between the two markers (case-insensitive, single-line mode)
        Write-Host "Transcript found. Extracting wisdom..." -ForegroundColor Yellow
        $Pattern = "(?si)Episode transcript(.*?)Related posts"

        if ($RawText -match $Pattern) {
            $CleanText = $Matches[1].Trim()
        } else {
            Write-Host "Error: Marker range not found. Skipping." -ForegroundColor Red
            return
        }

        # 4. Process with Fabric and display
        $CleanText | fabric --pattern extract_wisdom | Tee-Object -FilePath $TempWisdom

        # 5. Save and Cleanup
        $FinalPath = Join-Path $OutputDir "wisdom_$Timestamp.md"
        Move-Item -Path $TempWisdom -Destination $FinalPath -Force

        Write-Host "`nDone! Saved to: $FinalPath" -ForegroundColor Green

    } catch {
        Write-Host "Error: Failed to process $Url. $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

Executes on each line of a file:

```powershell
Get-Content memo.md | ForEach-Object { GetWisdom $_; Write-Host "Sleeping for 80s..."; Start-Sleep -s 80 }
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
