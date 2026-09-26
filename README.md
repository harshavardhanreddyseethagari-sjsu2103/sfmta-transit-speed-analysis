# SFMTA Transit Vehicle Speed vs. Distance from Downtown San Francisco

**Author:** Harshavardhan Reddy Seethagari
**Course:** MATH 261A, Fall 2026

## Project Structure
- `paper.qmd` — Quarto report
- `R/fetch_and_clean_data.R` — pulls data from the SFMTA Socrata API, filters to valid SF coordinates, computes distance from reference points
- `references.bib` — BibTeX references
- `data/` — data is pulled via API
- `output/` — contains figures/outputs relevant to the research question

## Data Source and License
Data obtained from the SFMTA "Transit Vehicle Location History (Current Year)" dataset, published by the San Francisco Municipal Transportation Agency via DataSF (https://data.sf.gov). Licensed under the Open Data Commons Public Domain Dedication and License (PDDL) (http://opendatacommons.org/licenses/pddl/1.0/). Data accessed via the 'Socrata Open Data' API on .

## Use of External Resources / LLMs
Claude was used to reason with the research question, and on the methodology on understanding how avg. speed is related to distance of vehicle from a certain point, only.

## To run this project:
1. Open `sfmta-transit-speed-analysis.Rproj` in RStudio
2. Run `R/fetch_and_clean_data.R` to pull and clean the data
3. Render `paper.qmd`