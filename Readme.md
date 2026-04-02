
# QMD

https://github.com/tobi/qmd.git

## Build image

```bash
docker compose up -d --build
```

## Converts PDFs

```bash
python -m pip install marker-pdf
```

```bash
marker_single --output_dir my-docs my-docs/SPW_Manual.pdf
```

```bash
marker_single --output_dir my-docs "my-docs/3DDS-0838-6 - 3DIPCC0838 Standard Flight Code for CASPEX 12M - User Manual and ICD_Customer.pdf"
```

```bash
marker_single --output_dir my-docs "my-docs/SRON-TANGO-TN-2025-009iss4 CarCam Protocol Description_signed.pdf"
```
