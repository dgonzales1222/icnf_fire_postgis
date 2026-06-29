# load.sh
# Bash script for loading the data into PostGIS

set -euo pipefail   # stop on first error; treat unset vars as errors

PG="PG:dbname=fire_incidence_portugal port=5434" #Add PostGIS into the existing fire_incidence_portugal DB we created at port 5434

# Clean slate so re-running is safe (avoids "table already exists" / duplicate rows)
psql "dbname=fire_incidence_portugal port=5434" -c "DROP TABLE IF EXISTS icnf.fires, icnf.caop_freguesias, icnf.caop_municipios, icnf.caop_distritos, icnf.caop_nuts3, icnf.caop_nuts2, icnf.caop_nuts1 CASCADE;"

# All fields are in Portuguese so we need to rename all fields into english
FULL="Ano AS year, PI_DICOFRE AS dicofre, PI_NUTS3 AS nuts3, PI_Distrit AS distrito, PI_Conc AS concelho, PI_Freg AS freguesia, PI_Local AS locality, AreaHaSIG AS area_ha, AreaHaSGIF AS area_ha_sgif, AreaHaPov AS area_ha_forest, AreaHaMato AS area_ha_scrub, AreaHaAgri AS area_ha_agri, Causa_Tipo AS cause_type, Causa_Desc AS cause_desc, DH_Inicio AS start_dt, DH_Fim AS end_dt, Duracao_m AS duration_min"
MIN="Ano AS year, AreaHaSIG AS area_ha"

# --- 1) create icnf.fires from 2014 (full schema) ------------------------
# --config SHAPE_ENCODING "ISO-8859-1": the ICNF shapefiles are Latin-1 but the
# database is UTF-8; without this, accented names (ç, ã, õ, á) corrupt on load.
echo "Creating icnf.fires from 2014..."
ogr2ogr --config SHAPE_ENCODING "ISO-8859-1" -f PostgreSQL "$PG" data/raw/icnf_shp/2014/ardida_2014.shp \
  -nln icnf.fires -t_srs EPSG:3763 -nlt PROMOTE_TO_MULTI \
  -lco GEOMETRY_NAME=geom -lco SPATIAL_INDEX=GIST \
  -sql "SELECT $FULL FROM ardida_2014"

# --- 2) append the other 16 years ---------------------------------------
for year in 2009 2010 2011 2012 2013 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025; do
  if [ "$year" -le 2013 ]; then SQL="SELECT $MIN FROM ardida_$year"; else SQL="SELECT $FULL FROM ardida_$year"; fi
  echo "Appending fires $year..."
  ogr2ogr --config SHAPE_ENCODING "ISO-8859-1" -f PostgreSQL "$PG" "data/raw/icnf_shp/$year/ardida_$year.shp" \
    -nln icnf.fires -append -nlt PROMOTE_TO_MULTI \
    -sql "$SQL"
done

# --- 3) load the 6 CAOP boundary layers ---------------------------------
for lyr in freguesias municipios distritos nuts3 nuts2 nuts1; do
  echo "Loading caop_$lyr..."
  ogr2ogr -f PostgreSQL "$PG" data/raw/caop/Continente_CAOP2025.gpkg "cont_$lyr" \
    -nln "icnf.caop_$lyr" -t_srs EPSG:3763 -nlt PROMOTE_TO_MULTI \
    -lco GEOMETRY_NAME=geom -lco SPATIAL_INDEX=GIST
done

echo "Done. Verify counts in DBeaver."