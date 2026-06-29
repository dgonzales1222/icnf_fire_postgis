-- 01_setup.sql — enable PostGIS and create the project schema
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA IF NOT EXISTS icnf;

-- verify PostGIS
SELECT postgis_full_version();

