"""
download_caop.py

The DGT ships CAOP as a single zipped GeoPackage (~112 MB) holding all the
administrative layers (freguesias, concelhos, distritos). Saved to
data/raw/caop/. Re-running is safe (files overwrite).
"""

import urllib.request
import zipfile
from pathlib import Path

# --- configuration -------------------------------------------------------
URL = "https://geo2.dgterritorio.gov.pt/caop/CAOP_Continente_2025-gpkg.zip"
RAW_DIR = Path("data/raw/caop")
# -------------------------------------------------------------------------


def main() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    zip_path = RAW_DIR / "CAOP_Continente_2025-gpkg.zip"

    print(f"Downloading CAOP 2025 (Continente) ...", end=" ", flush=True)
    urllib.request.urlretrieve(URL, zip_path)  # fetch the ~112 MB zip
    print("done")

    print("Extracting ...", end=" ", flush=True)
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(RAW_DIR)  # unpack the .gpkg (and any docs)
    zip_path.unlink()  # remove the zip; keep only the extracted files
    print(f"done -> {RAW_DIR}/")

    gpkg = next(RAW_DIR.glob("*.gpkg"), None)
    print(f"\nGeoPackage ready: {gpkg}" if gpkg else "\nWarning: no .gpkg found after extract")


if __name__ == "__main__":
    main()
