# Built to replicate the days_tmax_at_or_above_90F variable in Terin's "temperature_threshold_stats.nc"
from xarray import DataArray

import resources
import xarray as xr
import pandas as pd
import os
import datetime
import numpy as np


# Calculates the number of days that the tmax is above the threshold, then averages this across all GCMs
# Returns an xarray DataArray
def threshold_above(rcp, timeframe, threshold_F=None, threshold_C=None, threshold_K=None):
    temp_dict = {"F": threshold_F, "C": threshold_C, "K": threshold_K}
    threshold_string = resources.get_temp_string(temp_dict)  # Record what temperature is being used for naming purposes
    # Populate all temperature fields
    threshold_F, threshold_C, threshold_K = resources.get_all_temp_units(temp_dict).values()

    datasets = [resources.get_dataset(gcm, rcp, timeframe) for gcm in resources.GCMS]  # Load the data
    tmax_arr = [dataset["tmax"].squeeze(dim="lev", drop=True) for dataset in datasets]  # Select tmax and get rid of lev
    # Put it together with a new dimension indexed by GCM name
    # noinspection PyTypeChecker
    tmaxes = xr.concat(tmax_arr, dim=pd.Index(resources.GCMS, name="gcm"))  # type: DataArray
    tmaxes = resources.trim_relaxation_zone(tmaxes)
    mask = resources.collapse_find_valid(tmaxes, {"time", "gcm"})  # Keep track of where the NaNs are
    counts = tmaxes.where(tmaxes >= threshold_C).count(dim="time")  # Apply the threshold and count!
    counts = counts.where(mask)  # Put the NaNs back in
    counts /= resources.YEARS  # Divide to get count per year
    counts = counts.mean(dim="gcm", skipna=False)  # Average across GCMs

    counts.name = "days_tmax_at_or_above_" + threshold_string
    counts.attrs["threshold (F C)"] = str(np.round(threshold_F, 4)) + " " + str(np.round(threshold_C, 4))
    return counts


# Calculates both the threshold_above and the difference in this metric versus the historic time period
# Returns an xarray DataArray where delta=0 is the current value and delta=1 is the difference
def threshold_above_with_difference(rcp, timeframe, threshold_F=None, threshold_C=None, threshold_K=None):
    current = threshold_above(rcp, timeframe, threshold_F, threshold_C, threshold_K)
    historic = threshold_above(resources.RCPS[0], resources.TIMEFRAMES[0], threshold_F, threshold_C, threshold_K)
    difference = current - historic
    # noinspection PyTypeChecker
    combined = xr.concat([current, difference], "delta")  # type: DataArray
    combined.attrs = current.attrs
    return combined


# Turns the output of threshold_above_with_difference into a Dataset formatted like Terin's NetCDF file
def format_dataset(data):
    dataset = xr.Dataset({data.name: data})
    dataset.attrs["creation_date"] = str(datetime.datetime.now())
    dataset.attrs["delta"] = "delta=0: counts; delta=1: change from historical"
    model_suite_string = ""
    for model in resources.GCMS: model_suite_string = model_suite_string + model + " "
    dataset.attrs["model suite"] = model_suite_string[:-1]
    # If necessary, lat and lon could be renamed latDim and lonDim, "singleton" could be added, etc.
    return dataset


def main():
    # Do the calculations:
    result = format_dataset(threshold_above_with_difference("RCP4.5", "2040-2059", threshold_F=90))
    path = resources.OUTPUT_ROOT + "temperature_threshold_stats_replicated.nc"
    # Delete the existing file to avoid a permissions error when we try to overwrite
    if os.path.exists(path): os.remove(path)
    result.to_netcdf(path=path)
    print("DONE CALCULATING")

    # Compare to Terin's (for a more detailed comparison, one would want to page through the values):
    name = [key for key in result.keys()][0]
    old = xr.open_dataset("compare/temperature_threshold_stats.nc")
    new = xr.open_dataset(path)
    print("\n\nOLD:")
    print(old)
    print("\nNEW:")
    print(new)
    print("\n\nOLD:")
    print(old[name])
    print("\nNEW:")
    print(new[name])


if __name__ == "__main__":
    main()
