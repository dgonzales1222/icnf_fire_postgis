# Wildfire occurrences in Portugal — PostGIS analysis

An exploratory spatial analysis of ICNF burned areas (*áreas ardidas*) in mainland Portugal, built on
a **PostGIS** database. Shapefiles are loaded into PostgreSQL/PostGIS, the spatial analysis is done in
**SQL**, and results are explored from a **Jupyter notebook** that queries the database.

> **Note on topic change.** This project began as a *UPLB weather dashboard* (mid-June 2026). The
> weather data could not be delivered in time, so the topic was switched to Portugal wildfire
> analysis, which has complete, openly available data from ICNF and DGT.

## Topic & questions
- **RQ1** — how has annual burned area evolved, and how dominant are extreme years?
- **RQ2** — where does Portugal burn, and how concentrated is it (district / NUTS III)?
- **RQ3** — how heavy-tailed are fire sizes; do a few fires dominate the area?

## Data sources
| Dataset | Source | Format |
|---|---|---|
| Burned areas 2009–2025 | ICNF — `si.icnf.pt/wfs/areas_ardidas` | Shapefile (WFS SHAPE-ZIP) |
| Administrative boundaries (CAOP 2025, Continente) | DGT — `geo2.dgterritorio.gov.pt/caop` | GeoPackage |

All geometries reprojected to **ETRS89 / PT-TM06 (EPSG:3763)** for area computation.

## Tech stack
PostgreSQL + **PostGIS** · GDAL/**ogr2ogr** (loading) · **DBeaver** (SQL) · **QGIS** (visual check) ·
Python (geopandas, SQLAlchemy, psycopg2) for the notebook.

## Structure
```
data/raw/icnf_shp/<year>/   ICNF burned-area shapefiles (git-ignored)
data/raw/caop/              CAOP 2025 GeoPackage (git-ignored)
scripts/                    download_icnf.py · download_caop.py
sql/                        setup, load checks, analysis queries
notebooks/                  analysis.ipynb (reads from PostGIS)
```

## Progress

| Date | Milestone | Status |
|---|---|---|
| 2026-06-15 | Started UPLB weather dashboard (original topic) | ✅ Done |
| 2026-06-22 | Weather data delayed — decided to change topic | ✅ Done |
| 2026-06-22 | Pivoted to Portugal wildfire analysis; set up repo + git | ✅ Done |
| 2026-06-23 | Created GitHub repository; pushed project structure (sql/, notebooks/) | ✅ Done |
| 2026-06-24 | Phase 1 — install PostgreSQL + PostGIS, create database (`fire_incidence_portugal`, port 5434) | ✅ Done |
| 2026-06-29 | Phase 1 — enabled PostGIS 3.6.3 + created `icnf` schema via `sql/01_setup.sql` | ✅ Done |
| 2026-06-29 | Phase 2 — downloaded ICNF burned areas 2009–2025 (`scripts/download_icnf.py`) | ✅ Done |
| 2026-06-29 | Phase 2 — downloaded CAOP 2025 GeoPackage, all admin/NUTS levels (`scripts/download_caop.py`) | ✅ Done |
| — | Phase 3 — load shapefiles into PostGIS (ogr2ogr, EPSG:3763) | ⬜ Planned |
| — | Phase 4 — spatial analysis in SQL (area-weighted joins) | ⬜ Planned |
| — | Phase 5 — notebook: query PostGIS + visualize | ⬜ Planned |
| — | Report / write-up | ⬜ Planned |

## How to run (filled in as the project progresses)
1. Install PostgreSQL + PostGIS; `createdb icnf_fire`; `CREATE EXTENSION postgis;`
2. Download shapefiles (Phase 2) → `data/raw/`
3. Load with `ogr2ogr` (Phase 3) → tables in schema `icnf`
4. Run `sql/03_analysis.sql` (Phase 4)
5. Open `notebooks/analysis.ipynb` (Phase 5)
