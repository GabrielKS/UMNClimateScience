import resources
import xarray as xr
import pandas as pd


# Calculates the number of days that the average tmax is above the threshold
# Returns an xarray DataArray
def threshold_above(rcp, timeframe, threshold_F=None, threshold_C=None, threshold_K=None):
    threshold_F, threshold_C, threshold_K = resources.get_all_temp_units(
        {"F": threshold_F, "C": threshold_C, "K": threshold_K}).values()  # Populate all temperature fields

    datasets = [resources.get_dataset(gcm, rcp, timeframe) for gcm in resources.GCMS]
    tmaxes = xr.concat([dataset["tmax"] # Combine the tmax values from all the Datasets into one DataArray
                       .squeeze(dim="lev", drop=True) for dataset in datasets],  # Get rid of the lev dimension
                       dim=pd.Index(resources.GCMS, name="gcm"))  # New dimension is indexed by GCM name
    avg_tmax = tmaxes.mean(dim="gcm")  # TODO: Not sure exactly why the IDE gives a warning here
    counts = avg_tmax.where(avg_tmax >= threshold_C).count(dim="time")
    counts /= 20  # Divide by number of years. TODO: get this number programmatically
    return counts


# Calculates both the threshold_above and the difference in this metric versus the historic time period
# Returns an xarray DataArray where delta=0 is the current value and delta=1 is the difference
def threshold_above_with_difference(rcp, timeframe, threshold_F=None, threshold_C=None, threshold_K=None):
    current = threshold_above(rcp, timeframe, threshold_F, threshold_C, threshold_K)
    historic = threshold_above(resources.RCPS[0], resources.TIMEFRAMES[0], threshold_F, threshold_C, threshold_K)
    difference = current-historic
    return xr.concat([current, difference], "delta")


def main():
    result = threshold_above_with_difference("RCP4.5", "2040-2059", threshold_F=90)
    print(result)



if __name__ == "__main__":
    main()
