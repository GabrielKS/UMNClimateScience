# UMN Climate Science
This repository contains code written by Gabriel Konar-Steenberg in 2019 and 2020 as part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project, and adjacent resources. Below is a brief overview of what the various Python files are for; see the comments within each of these files for more information.

## Top Level
Code that is not in any other folder — this consists of scripts to directly accomplish objectives plus some helper modules.

### Scripts
 * `basic_comparisons.py`: Calculates long-term means, differences in means between various datasets, and p-values for the t-tests corresponding to these comparisons.
 * `difference_all_stats.py`: Computes even more differences.
 * `snow_stats.py`: Digests raw snow height data to find maximum yearly snow depth and number of days per year with more than an inch of snow.
 * `temperature_threshold_stats_replication.py`: Replicates an existing algorithm written (elsewhere) in NCL to ensure consistency.

### Helper Modules
* `resources.py`: This file contains code meant to be usable in a variety of other files, including input and output functions and a few data processing tools.
* `g_stats.py`: This file contains some statistical routines that I found to be missing from Python, including autocorrelation and the adjusted t-test. At times, I've written functions two ways, one using existing Python building blocks and one from the ground up, when there are subtle methodological details that may or may not be significant.
* `generate_universal_mask.py`: An attempt to definitively settle the geographical domain of the study, finding the points where there is valid data from all input data sources.

