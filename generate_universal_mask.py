#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Examines all variables in all raw data files from all models in the project and determines which grid cells are
# consistently part of the domain and which are not. Outputs a boolean "universal mask" array indexed by lat/lon with
# True values where there is always valid data and False data where there is not. Also known as
# The One Mask to Rule Them All, this may be the most computationally intensive silhouette of Minnesota ever generated.
import os

from xarray import Dataset
import resources
import xarray as xr
import pandas as pd
import numpy as np


def main():
    # Get all the data and find valid values throughout all of time for each model run
    # (we collapse across time before collapsing across model runs so that differences in time coordinates do not
    # introduce NaNs when the datasets are concatted)
    dataset_arr = {gcm + "/" + rcp + "/" + timeframe: resources.collapse_any_valid(
        resources.get_dataset(gcm, rcp, timeframe).squeeze(dim="lev", drop=True), "time")
        for gcm in set(resources.GCMS) - {"CNRM-CM5"}  # TODO: Include new CNRM when possible (old has odd NaNs in wspd)
        for timeframe in resources.TIMEFRAMES
        for rcp in resources.RCPS_FOR_TIMEFRAME[timeframe]}
    # Somewhat counterintuitively, latter "for...in..." expressions become inner loops

    # Concat all datasets, adding a new dimension
    # noinspection PyTypeChecker
    combined_dataset = xr.concat([dataset_arr[k] for k in dataset_arr],
                                 dim=pd.Index([k for k in dataset_arr], name="modelrun"))  # type: Dataset

    # Collapse the newly-added dimension by 'and'-ing all the values in each grid cell together
    # Also split the dataset into an array with one entry for each variable
    mask_by_variable = {variable: combined_dataset[variable].any(dim="modelrun")
                        for variable in combined_dataset}

    # Concat again
    # noinspection PyTypeChecker
    combined_mask = xr.concat([mask_by_variable[k] for k in mask_by_variable],
                              dim=pd.Index([k for k in mask_by_variable], name="variable"))  # type: Dataset

    # Collapse again
    collapsed_mask = combined_mask.all(dim="variable").rename("mask")

    # Might as well take care of the relaxation zone here
    resources.trim_relaxation_zone(collapsed_mask, replace_with=False)

    print(collapsed_mask)
    print_as_binary(collapsed_mask)

    output_path = resources.OUTPUT_ROOT + "universal_mask.nc"
    if os.path.exists(output_path): os.remove(output_path)
    collapsed_mask.to_netcdf(path=output_path)


if __name__ == "__main__":
    main()
