---
name: project-humidity-phase4
description: Committee Feedback Phase 4 (PRISM humidity) is COMPLETE — records the working pipeline, the aggregation method, and the headline sensitivity result.
metadata:
  type: project
---

Phase 4 of the `committee_feedback_april_2026` track (acquiring PRISM `tdmean` humidity and integrating it into the state regression pipeline) is **complete** as of 2026-06-09.

**How it was built:**
- `Code/download_prism_humidity.R` pulls annual 4km CONUS `tdmean` grids (BIL) from the open web service `https://services.nacse.org/prism/data/get/us/4km/tdmean/<YYYY>?format=bil` — **no API key**. Skips already-unzipped years (PRISM blocks a file downloaded twice in 24h). Stored under `Data/Climate_Data/State level/PRISM_tdmean/<YYYY>/`. Years acquired: **2009–2025**.
- The unzipped 4km grid is named `prism_tdmean_us_25m_<YYYY>.bil` ("25m" is PRISM's token for 4km res) — match on `\.bil$`, not `_bil.bil`.
- PRISM `tdmean` is in **°C**; converted to `tdmean_F` for project consistency.
- `Code/process_state_humidity.R` aggregates each grid to a state-year panel by **area-weighted zonal mean** (`terra::extract(..., weights=TRUE)`) over Census 2018 cartographic state boundaries (auto-downloaded to `Data/Geo/cb_2018_us_state_20m`). Output `Data/intermediate_humidity.rds` (State, Year, tdmean_C, tdmean_F).
- Only **`terra`** was needed (it bundles GDAL/GEOS/PROJ and reads both rasters and vector boundaries) — `sf`/`tigris` were NOT required, contrary to the old blocker note. Installed as a Windows binary, no compilation.
- Coverage is CONUS only → **Alaska and Hawaii are NA**; 48 contiguous states + DC covered.

**Integration:** joined in `create_state_master.R`; `tdmean_F` lagged in `analysis_pre_processing.R`; humidity-sensitivity block in `run_analysis.R` writes `Analysis/humidity_sensitivity.csv`. Because PRISM coverage shrinks the sample, the headline coefficients are compared on the *identical humidity-available subsample* with vs. without humidity (not by adding humidity to the full-sample primary). See [[project-state-pipeline]].

**Headline result:** the **Cold Shock (1-yr lag) → Medical Debt Share** finding survives humidity adjustment (0.01363, p=0.011 → 0.01368, p=0.017, n=624). Humidity is itself a substantive predictor: higher dew point → higher medical debt (Share +0.0025/°F p=0.009; Median +$16.0/°F p=0.004) and marginally lower premiums (−$13.7/°F p=0.052). Documented in `Analysis/state_analysis_summary.md` §6.4.

**County feasibility (probed, not built):** the same `terra::extract` over Census county polygons works — 3,108/3,220 counties covered — but costs ~90 s/year (~25 min for 2009–2025) vs. seconds for states. Out of scope for the committee (state-only) ask; viable future extension if county humidity is wanted.
