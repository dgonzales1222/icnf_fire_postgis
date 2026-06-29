-- 02_load_checks.sql — verify the PostGIS load (run after scripts/load.sh).
-- Read-only sanity checks: row counts, year coverage, CRS, encoding, nulls.

-- 1) Row counts per table (expect: freguesias 3049, municipios 278,
--    distritos 18, nuts3 24, nuts2 7, nuts1 1; fires in the tens of thousands)
SELECT 'fires'       AS tbl, count(*) FROM icnf.fires
UNION ALL SELECT 'freguesias', count(*) FROM icnf.caop_freguesias
UNION ALL SELECT 'municipios', count(*) FROM icnf.caop_municipios
UNION ALL SELECT 'distritos',  count(*) FROM icnf.caop_distritos
UNION ALL SELECT 'nuts3',      count(*) FROM icnf.caop_nuts3
UNION ALL SELECT 'nuts2',      count(*) FROM icnf.caop_nuts2
UNION ALL SELECT 'nuts1',      count(*) FROM icnf.caop_nuts1;

-- 2) Year coverage (expect one row per year, 2009-2025, none missing)
SELECT year, count(*) AS n_fires
FROM icnf.fires
GROUP BY year
ORDER BY year;

-- 3) CRS check (every geometry must be SRID 3763)
SELECT DISTINCT ST_SRID(geom) AS srid FROM icnf.fires;

-- 4) Encoding check (accented names must render cleanly, not mojibake)
SELECT DISTINCT distrito
FROM icnf.fires
WHERE distrito IN ('Évora', 'Setúbal', 'Bragança', 'Santarém')
ORDER BY distrito;

-- 5) Schema-discontinuity check: 2009-2013 have NULL admin/cause fields,
--    2014-2025 are populated. (expect dicofre NULL only for <= 2013)
SELECT year, count(*) FILTER (WHERE dicofre IS NULL) AS null_dicofre,
              count(*)                               AS total
FROM icnf.fires
GROUP BY year
ORDER BY year;