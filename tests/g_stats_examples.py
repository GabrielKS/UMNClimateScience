#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

import g_stats
import xarray as xr
import numpy as np


def main():
    sample_1 = xr.DataArray(
        [[[10.3, 11.1, 12.4, 13.1],
          [14.5, 15.9, 16.2, 15.6],
          [14.5, 13.3, 12.5, 11.8]],

         [[11.1, 12.6, 13.1, 14.8],
          [15.2, 16.1, 17.3, 16.5],
          [15.6, 14.2, 13.3, 12.7]]]
        , dims=["x", "y", "z"])
    sample_2 = xr.DataArray(
        [[[10.7, 11.1, 12.2, 14.8],
          [14.9, 15.5, 17.2, 15.0],
          [14.7, 13.1, 12.2, 12.8]],

         [[11.9, 12.5, 14.2, 14.0],
          [15.7, 16.1, 17.2, 17.8],
          [15.9, 14.5, 14.2, 12.0]]]
        , dims=["x", "y", "z"])

    print("Compare values:")
    print(g_stats.esacr(sample_1, 1, dim="z")[{"esacr": 1}])
    print(g_stats.esacr(sample_2, 1, dim="z")[{"esacr": 1}])

    print("\nWhen dim is not at the end:")
    print(g_stats.esacr(sample_1.transpose("y", "z", "x"), 1, dim="z")[{"esacr": 1}])

    print("\nAdjusted n:")
    u = g_stats.adjusted_n(sample_1, dim="z")
    print(xr.apply_ufunc(lambda x: np.round(x, 2), u))


if __name__ == "__main__":
    main()
