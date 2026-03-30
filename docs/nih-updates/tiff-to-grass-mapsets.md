# Tiff to GRASS Mapsets

This page outlines the workflow used to create GRASS GIS mapsets, import TIFF datasets, copy rasters between mapsets, and prepare annual and LULC layers for EQIPA.

---

## Overview

The workflow has five main parts:

1. Create the GRASS database, location, and required mapsets.
2. Import TIFF files into the target monthly mapset.
3. Copy selected rasters from an existing source mapset.
4. Generate annual outputs in the annual mapset.
5. Apply LULC categories and color rules required by the application.

For the initial GRASS setup, refer to the `GRASS GIS Quickstart` page, especially the steps on creating a location and mapset.

---

## Prerequisites

Before starting, make sure the following are ready:

- GRASS GIS is installed and accessible from the terminal
- a GRASS database directory is available on local storage
- the `eqipa` location is created in EPSG:4326
- the required TIFF files are copied to the machine
- the GRASS helper scripts are available locally

If GRASS is not added to the environment variables, open the command prompt from the GRASS installation directory before running the commands below.

---

## 1. Create the Database, Location, and Mapset

Create the state-level GRASS database and the `eqipa` location using EPSG:4326.

Example on Windows:

```bash
grass84 -c EPSG:4326 C:\Bihar\eqipa
```

This creates the GRASS location. After that, create the required mapset:

```bash
g.mapset -c mapset=ind_monthly_data location=eqipa
```

Typical notes for this step:

- create the state-level GRASS database first
- keep the location name as `eqipa`
- create the monthly processing mapset before importing rasters

---

## 2. Import TIFF Data into the Monthly Mapset

Use the script `1_importdata_mapset.py` to copy the TIFF files into the target mapset.

Update the following variables inside the script before running it:

```python
input_folder = "/home/psk/Downloads/nw"
GISDBASE = "/home/psk/PSK_web/eqipa_india/grassdata1"
MAPSET = "nrsc_lulc_original"
```

This script imports the raster data into the selected mapset.

Important:

- the raster file names should match the names used in the old mapsets
- confirm that `GISDBASE`, location, and mapset values point to the correct workspace before execution

---

## 3. Copy Existing Raster Layers from Another Mapset

Use the script `copyMapsetRas` to copy rasters from an existing source mapset into `ind_monthly_data`.

Update the script parameters as required:

```python
gisdb = "/home/psk/PSK_web/eqipa_india/grassdata1"
location = "eqipa"
target_mapset = "ind_monthly_data"
source_mapset = "monthly"
pattern = "wapor3_tbp_2024"
```

Parameter notes:

- `target_mapset` is the mapset where the rasters will be copied
- `source_mapset` is the mapset from which the rasters will be read
- `pattern` is the prefix used to select the raster names to copy

Both the source and target mapsets must be inside the same GRASS database and location.

---

## 4. Generate Annual Data in `ind_annual_data`

Use the script `3_annual_maps` to convert the required monthly data into annual outputs in the `ind_annual_data` mapset.

Update the script values before execution:

```python
shapefile = "jandk.geojson"
GISDBASE = "/home/psk/PSK_web/eqipa_india/Andhra Pradesh"
```

The region resolution can also be adjusted if needed:

```python
gs.run_command("g.region", vector=vector_name, res=0.0000898)
```

Notes:

- keep the GeoJSON file in the same location as the script
- use a simplified GeoJSON boundary where possible
- change the resolution only if the workflow requires a different output grid

---

## 5. Add LULC Categories and Color Rules

After importing and processing the LULC raster, add the required class categories.

```bash
r.category LULC_250k_2023_2024 separator=":" rules=- << EOF
0:Non-Crop
1:Kharif_Only
2:Kharif_Rabi
3:Kharif_Rabi_Zaid
4:Water
5:Plantations
6:Rabi_Only
7:Rabi_Zaid
8:Kharif_Zaid
EOF
```

This command is referenced in the existing `NIH_lulc_class` workflow.

Then apply the color rules:

```bash
r.colors map=LULC_250k_2018_2019 rules=/home/psk/grass_pyScript/NIHcolorruless.txt
```

These two steps are required for correct display in the EQIPA application:

- without categories, application calculations based on LULC classes can fail
- without color rules, the LULC map and pie chart in the report can appear black

---

## Validation Checks

After completing the workflow, verify that:

- the `ind_monthly_data` and `ind_annual_data` mapsets exist
- the imported TIFF rasters are visible in the target mapset
- copied rasters from the source mapset are available with the expected names
- annual layers are created successfully
- LULC categories and colors are applied correctly

---

## Notes

- The script paths in the source workflow are machine-specific, so update them before running.
- Keep naming consistent with the older mapsets to avoid downstream issues in the application.
- If you are preparing data for a new state database, confirm the database path and boundary file before executing the annual-processing step.
