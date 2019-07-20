#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Built to replicate the days_tmax_at_or_above_90F variable in Terin's "temperature_threshold_stats.nc"


from xarray import DataArray
import resources
import xarray as xr
import pandas as pd
import numpy as np
import os


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

    # My method (38 differences in data, all are old=number, new=nan):
    """
    # Exclude any cell for which any value is invalid in any GCM at any time
    mask = resources.collapse_all_valid(tmaxes, {"time", "gcm"})
    counts = tmaxes.where(tmaxes >= threshold_C).count(dim="time")  # Apply the threshold and count!
    counts = counts.where(mask)  # Put the NaNs back in
    counts /= resources.YEARS  # Divide to get count per year
    # If a NaN comes up, the output is NaN (though the above filtering should theoretically make sure that the counts
    # for a given cell are either valid for all GCMs or NaN for all GCMs)
    counts = counts.mean(dim="gcm", skipna=False)  # Average across GCMs
    """

    # Hybrid method (3 differences in data, all are old=number, new=very slightly different number):
    """
    # Only exclude cells where *all* values are NaN,
    # and only for individual GCMs and for which this is true (not the whole ensemble)
    mask = resources.collapse_any_valid(tmaxes, "time")
    counts = tmaxes.where(tmaxes >= threshold_C).count(dim="time")
    counts = counts.where(mask)
    counts /= resources.YEARS
    # If a NaN comes up, skip it and calculate the average across the other GCMs for that cell
    # (unlike in my method, this situation does occur)
    counts = counts.mean(dim="gcm", skipna=True)
    """

    # Terin's method (0 differences in data):
    # """
    # Start with things split by years
    start_year, end_year = int(timeframe[:4]), int(timeframe[-4:])
    tmaxes = resources.split_by_year(tmaxes, "time", start_year, end_year)
    # noinspection PyTypeChecker
    tmaxes = xr.concat(tmaxes, dim=pd.Index(range(start_year, end_year + 1), name="year"))  # type: DataArray
    # Only exclude cells where *the first* value (time-wise) is NaN,
    # and only for individual GCMs and *years* for which this is true (not the whole ensemble for all of time)
    mask = ~np.isnan(tmaxes[{"time": 0}])
    del mask["time"]  # Don't care about time anymore
    counts = tmaxes.where(tmaxes >= threshold_C).count(dim="time")
    counts = counts.where(mask)
    # If a NaN comes up, skip it and calculate the average across the other GCMs for that cell
    # (unlike in my method, this situation does occur) and then average across years the same way
    # (trying to do both averages in one step leads to 2 differences in data)
    counts = counts.mean(dim="gcm", skipna=True).mean(dim="year", skipna=True)
    # """

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


def main():
    output_path = resources.OUTPUT_ROOT + "temperature_threshold_stats_replicated.nc"

    # """
    # Do the calculations:
    result = resources.format_dataset([threshold_above_with_difference("RCP4.5", "2040-2059", threshold_F=90)])
    # Delete the existing file to avoid a permissions error when we try to overwrite
    if os.path.exists(output_path): os.remove(output_path)
    result.to_netcdf(path=output_path)
    print("DONE CALCULATING")
    # """

    # """
    # Compare to Terin's (for a more detailed comparison, one would want to page through the values):
    old = xr.open_dataset("compare/temperature_threshold_stats.nc")
    new = xr.open_dataset(output_path)
    name = [key for key in new.keys()][0]
    print("\n\nOLD:")
    print(old)
    print("\nNEW:")
    print(new)
    print("\n\nOLD:")
    print(old[name])
    print("\nNEW:")
    print(new[name])
    print("\n\nELEMENT-WISE DIFFERENCES:")
    for index, old_value in np.ndenumerate(old[name]):
        new_value = new[name][index].values
        # Values are equal if they are both NaN or if they are "close enough" (because of floating-point rounding)
        if not ((np.isnan(old_value) and np.isnan(new_value)) or np.isclose(old_value, new_value)):
            print(str(index) + ": old=" + str(old_value) + ", new=" + str(new_value))
    print("DONE COMPARING")
    # """


if __name__ == "__main__":
    main()
