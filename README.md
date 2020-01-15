#UMN Climate Science
This repository contains code written by Gabriel Konar-Steenberg in 2019 and 2020 as part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project, and adjacent resources. Below is a brief overview of what the various files are for.

##Top Level
Code that is not in any other folder — this consists of modules to directly accomplish adjectives plus some helper modules.

###Helper Modules
`resources.py`: This file contains code meant to be usable in a variety of other files, including input and output functions and a few data processing tools.

`g_stats.py`: This file contains some statistical routines that I found to be missing from Python, including autocorrelation and the adjusted t-test. At times, I've written functions two ways, one using existing Python building blocks and one from the ground up, when there are subtle methodological details that may or may not be significant.

`generate_universal_mask.py`: An attempt to definitively settle the geographical domain of the study, finding the points where there is valid data from all input data sources.

