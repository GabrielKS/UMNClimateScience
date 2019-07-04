# Built to replicate the days_tmax_at_or_above_90F variable in Terin's "temperature_threshold_stats.nc"
import resources
import xarray as xr
import pandas as pd
import numpy as np
import os
import datetime


# Calculates the number of days that the average tmax is above the threshold
# Returns an xarray DataArray
def threshold_above(rcp, timeframe, threshold_F=None, threshold_C=None, threshold_K=None):
    temp_dict = {"F": threshold_F, "C": threshold_C, "K": threshold_K}
    threshold_string = resources.get_temp_string(temp_dict)  # Record what temperature is being used for naming purposes
    # Populate all temperature fields
    threshold_F, threshold_C, threshold_K = resources.get_all_temp_units(temp_dict).values()

    datasets = [resources.get_dataset(gcm, rcp, timeframe) for gcm in resources.GCMS]   #Load the data
    for dataset in datasets: print(dataset["tmax"]["lat"])
    tmaxes = xr.concat([dataset["tmax"]  # Combine the tmax values from all the Datasets into one DataArray
                       .squeeze(dim="lev", drop=True) for dataset in datasets],  # Get rid of the lev dimension
                       dim=pd.Index(resources.GCMS, name="gcm"))  # New dimension is indexed by GCM name
    print("***"+str(tmaxes["lat"]))
    tmaxes = resources.trim_relaxation_zone(tmaxes.load())
    mask = resources.collapse_find_valid(tmaxes, {"time", "gcm"})
    counts = tmaxes.where(tmaxes >= threshold_C).count(dim="time")
    counts = counts.where(mask)
    counts /= 20  # Divide by number of years. TODO: get this number programmatically
    counts = counts.mean(dim="gcm", skipna=False)
    counts.name = "days_tmax_at_or_above_" + threshold_string
    counts.attrs["threshold (F C)"] = str(threshold_F) + " " + str(threshold_C)
    return counts


# Calculates both the threshold_above and the difference in this metric versus the historic time period
# Returns an xarray DataArray where delta=0 is the current value and delta=1 is the difference
def threshold_above_with_difference(rcp, timeframe, threshold_F=None, threshold_C=None, threshold_K=None):
    current = threshold_above(rcp, timeframe, threshold_F, threshold_C, threshold_K)
    historic = threshold_above(resources.RCPS[0], resources.TIMEFRAMES[0], threshold_F, threshold_C, threshold_K)
    difference = current - historic
    combined = xr.concat([current, difference], "delta")
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
    # Do the calculations
    # TODO: Not sure exactly why the IDE gives a warning here
    result = format_dataset(threshold_above_with_difference("RCP4.5", "2040-2059", threshold_F=90))
    # print(result)
    path = resources.OUTPUT_ROOT + "temperature_threshold_stats_replicated.nc"
    # Delete the existing file to avoid a permissions error when we try to overwrite
    if os.path.exists(path): os.remove(path)
    # TODO: Not exactly sure what the RuntimeWarning here is about
    #  (it happens anytime the result of a calculation is accessed (e.g. printing values will do it too))
    result.to_netcdf(path=path)

    name = "days_tmax_at_or_above_90F"
    # Compare to Terin's
    old = xr.open_dataset("compare/temperature_threshold_stats.nc")
    new = xr.open_dataset(path)
    # print("\nOLD:")
    # print(old)
    # print("\nNEW:")
    # print(new)
    # print("\nOLD:")
    # print(old[name])
    # print("\nNEW:")
    # print(new[name])


if __name__ == "__main__":
    main()
