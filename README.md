# penguinmalaria2025

Reproducible code and data to generate **Figure 5** (Google Trends analysis)

## Overview
The script downloads/reads pre-saved Google Trends outputs and produces:
- A monthly time series of search interest for “avian malaria + penguin” and “malaria + penguin”.
- Choropleth-style maps of relative search interest by country.

## Contents
- `fig05_code.R` — main script to reproduce Figure 5.
- `data/` — input CSVs (Google Trends exports cleaned for analysis).
- `README.md` — this file.
- `LICENSE` — usage terms.
- `CITATION.cff` — citation metadata for GitHub/Zenodo.

## Reproducibility
- **R version:** 4.3.x (tested)  
- **OS:** macOS/Linux/Windows
- **Packages:** `readr`, `dplyr`, `tidyr`, `stringr`, `janitor`, `sf`, `rnaturalearth`,
  `rnaturalearthdata`, `countrycode`, `ggplot2`, `scales`, `patchwork`.

The script auto-installs missing packages:

```r
required_packages <- c(
  "readr","dplyr","tidyr","stringr","janitor",
  "sf","rnaturalearth","rnaturalearthdata","countrycode",
  "ggplot2","scales","patchwork"
)
installed <- required_packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(required_packages[!installed])
