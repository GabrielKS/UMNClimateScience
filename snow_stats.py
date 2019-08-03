#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

import xarray as xr
import pandas as pd
import resources

SNOW_GCMS = ("bcc-csm1-1", "GFDL-ESM2M")  # TODO: expand to resources.GCMS as soon as data is available for all
SNOW_THRESHOLD_METERS = 25.4 / 1000


# Computes the average number of days per year where there is SNOW_THRESHOLD_METERS or more of snow on the ground.
def snow_threshold(input):
    count = input.where(input >= SNOW_THRESHOLD_METERS).count(dim="time")
    count = count.where(resources.UNIVERSAL_MASK)
    count /= resources.YEARS
    return count


# Computes the maximum yearly snow depth.
# Currently returns an average across all years. Could easily be rewritten to get the maximum depth for each year.
def max_yearly_snow(input):
    max_per_year = input.groupby("time.year").max(dim="time", skipna=False)  # SO EASY
    max_average = max_per_year.sum(dim="year") / resources.YEARS
    max_average = max_average.where(resources.UNIVERSAL_MASK)
    return max_average


def main():
    output = xr.DataArray(None)
    scenarios = [("HISTORIC", "1980-1999"), ("RCP4.5", "2040-2059"), ("RCP4.5", "2080-2099"), ("RCP8.5", "2080-2099")]
    # This all could probably be condensed
    gcm_arr = []
    for gcm in SNOW_GCMS:
        scenario_arr = [resources.get_dataset(gcm, *scenario, raw=True)["SNOWH"] for scenario in scenarios]
        gcm_arr.append(xr.concat(scenario_arr, dim=pd.Index(map(lambda x: x[1]+"_"+x[0], scenarios), name="scenario")))
    input = xr.concat(gcm_arr, dim=pd.Index(SNOW_GCMS, name="gcm"))


    # input_data = resources.get_dataset(SNOW_GCMS[0], resources.RCPS[0], resources.TIMEFRAMES[0], raw=True)["SNOWH"]
    # input_data = resources.trim_relaxation_zone(input_data)
    # print(max_yearly_snow(input_data))


if __name__ == "__main__":
    main()
