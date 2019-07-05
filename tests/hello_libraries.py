#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

import numpy as np  # Helps with data processing
import netCDF4 as nc  # xarray uses this behind the scenes
import Ngl  # Planning to use this for graphics
import Nio  # Not used anymore
import xarray as xr  # Main data processing library
import dask  # xarray uses this behind the scenes

print(Nio.__version__)
print(Ngl.__version__)
