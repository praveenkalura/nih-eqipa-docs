# 10m Database Preparation

This page outlines the working sequence used to prepare the EQIPA 10 m database before it is connected to the application layer.

---

## Overview

The 10 m preparation workflow has two main parts:

1. Prepare the base system services required by EQIPA.
2. Build the GRASS GIS datasets and derived outputs that feed the application.

The repository already contains helper scripts under `docs/assets/python_scripts/` for the raster-processing part of the workflow.

---

## Prerequisites

Before starting the 10 m preparation workflow, make sure the following are ready:

- PostgreSQL with PostGIS enabled
- GRASS GIS installed and working
- A GRASS database directory created for EQIPA
- Input raster datasets copied to local storage
- Boundary layers such as `IndiaBoundary.geojson`

For the database setup commands, refer to the `System Setup` page.

---

## PostGIS Database Setup

Create the application database and enable the spatial extension:

```bash
createdb -U ipa_india -h localhost ipa_india
psql -U ipa_india -h localhost ipa_india -c "CREATE EXTENSION postgis"
```

Typical credentials used elsewhere in this documentation:

- Database: `ipa_india`
- User: `ipa_india`
- Password: `ipa_india123`

---

## GRASS GIS Workspace

The processing scripts in this repository assume a GRASS workspace similar to the following:

```text
GISDBASE=/path/to/grassdata
LOCATION_NAME=eqipa
MAPSET=data_monthly
```

Each script initializes a GRASS session and creates the target mapset if it does not already exist.

---

## 10m Preparation Workflow

Run the processing scripts in sequence:

1. `1_import_data.py`
2. `2_resampling.py`
3. `3_annual_maps.py`
4. `4_raster_calculation.py`
5. `5_monthly_zonalStats.py`
6. `6_eqipa_zonalStats.py`
7. `7_export_geotiff.py`

These scripts are available in:

```text
docs/assets/python_scripts/
```

At a high level, the workflow does the following:

- imports source rasters into GRASS GIS
- resamples rasters to the working resolution and region
- prepares annual and monthly derived layers
- computes zonal statistics for administrative or command-area boundaries
- exports processed outputs for downstream use

---

## Example Execution

Update the paths inside each script before running them. The existing scripts use machine-specific values such as:

```python
GISDBASE = "/Volumes/ExternalSSD/eqipa_data/grassdata"
LOCATION_NAME = "eqipa"
MAPSET = "data_monthly"
```

Then execute the scripts one by one:

```bash
python docs/assets/python_scripts/1_import_data.py
python docs/assets/python_scripts/2_resampling.py
python docs/assets/python_scripts/3_annual_maps.py
python docs/assets/python_scripts/4_raster_calculation.py
python docs/assets/python_scripts/5_monthly_zonalStats.py
python docs/assets/python_scripts/6_eqipa_zonalStats.py
python docs/assets/python_scripts/7_export_geotiff.py
```

---

## Validation Checks

After preparation, verify that:

- the required rasters exist in the GRASS mapset
- vector boundaries import correctly
- zonal statistics tables are generated without errors
- exported GeoTIFF files are created in the expected output directory
- the Django application points to the same database and data paths

---

## Notes

- The current scripts contain hard-coded file paths and time ranges, so adjust them before production use.
- If a 10 m dataset requires a different boundary, resolution, or output naming rule, update the corresponding script before execution.
- If you want this workflow to be repeatable across environments, move these script parameters into environment variables or a config file.
