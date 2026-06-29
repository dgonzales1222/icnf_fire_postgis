'''
download_icnf.py

This script downloads all available files in the ICNF Ardida WFS endpoint.

WFS stands for Web Feature Service. We will use this to download all shapefiles available in ICNF.

WFS URL = https://si.icnf.pt/wfs/areas_ardidas?service=WFS&version=2.0.0&request=GetFeature&typeName=BDG:ardida_2024&outputFormat=SHAPE-ZIP

Download URL Breakdown:
https://si.icnf.pt/wfs/areas_ardidas    ← the WFS endpoint (the server)
?service=WFS                            ← it's a WFS request
&version=2.0.0                          ← which spec version
&request=GetFeature                     ← the operation: "give me features"
&typeName=BDG:ardida_2024               ← which layer (2024 burned areas)
&outputFormat=SHAPE-ZIP                 ← package it as a zipped shapefile

Note: Each year is one WFS GetFeature request returned as a zipped shapefile,
saved to data/raw/icnf_shp/<year>/. Re-running is safe (files overwrite).

AI Prompt Used: Write a Python script to download the ICNF burned-area shapefiles (2009–2024) from their WFS endpoint and unzip each year into data/raw/.
'''

import urllib.request
import zipfile
from pathlib import Path

# --- configuration -------------------------------------------------------
START_YEAR = 2009
END_YEAR = 2025  # inclusive
WFS = "https://si.icnf.pt/wfs/areas_ardidas"
RAW_DIR = Path("data/raw/icnf_shp")
# -------------------------------------------------------------------------

def build_url(year: int) -> str:
    """Compose the WFS GetFeature URL for one year's burned-area layer."""
    return (
        f"{WFS}?service=WFS&version=2.0.0&request=GetFeature"
        f"&typeName=BDG:ardida_{year}&outputFormat=SHAPE-ZIP"
    )

def download_year(year: int) -> None:
    """Download and unzip a single year's shapefile into its own folder."""
    year_dir = RAW_DIR / str(year)
    year_dir.mkdir(parents=True, exist_ok=True)
    zip_path = RAW_DIR / f"{year}.zip"

    print(f"Downloading {year} ...", end=" ", flush=True)
    urllib.request.urlretrieve(build_url(year), zip_path)  # fetch the zip

    with zipfile.ZipFile(zip_path) as z:
        z.extractall(year_dir)  # unpack .shp/.shx/.dbf/.prj

    zip_path.unlink()  # remove the zip; keep only the extracted shapefile
    print(f"done -> {year_dir}")

def main() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for year in range(START_YEAR, END_YEAR + 1):
        download_year(year)
    print(f"\nAll years {START_YEAR}–{END_YEAR} downloaded into {RAW_DIR}/")


if __name__ == "__main__":
    main()

