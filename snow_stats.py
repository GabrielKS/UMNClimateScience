#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

import xarray as xr
import pandas as pd
import numpy as np
import resources

SNOW_GCMS = resources.GCMS
SNOW_THRESHOLD_METERS = 25.4 / 1000


# Computes the average number of days per year where there is SNOW_THRESHOLD_METERS or more of snow on the ground.
def snow_threshold(raw_data):
    count = raw_data.where(raw_data >= SNOW_THRESHOLD_METERS).count(dim="time")
    count = count.where(resources.UNIVERSAL_MASK)
    count /= resources.YEARS

    count.attrs["description"] = "average number of days per year where the snow depth meets or exceeds the threshold"
    count.attrs["threshold"] = str(SNOW_THRESHOLD_METERS) + " meters"
    count.attrs["units"] = "number of days"
    return count


# Computes the maximum yearly snow depth.
# Currently returns an average across all years. Could easily be rewritten to get the maximum depth for each year.
def max_yearly_snow(raw_data):
    max_per_year = raw_data.groupby("time.year").max(dim="time", skipna=False)  # SO EASY
    max_average = max_per_year.sum(dim="year") / resources.YEARS
    max_average = max_average.where(resources.UNIVERSAL_MASK)

    max_average.attrs["description"] = "average maximum yearly snow depth"
    max_average.attrs["units"] = "meters"
    return max_average


# Prints out all the output so it can be scrolled through and sanity-checked by hand
def print_output(output):
    for gcm in output.coords["gcm"].values:
        for scenario in output.coords["scenario"].values:
            for delta in output.coords["delta"].values:
                print(gcm + " " + scenario + " " + delta + " " + "days_snow_above:")
                resources.print_grid(np.round(
                    output["days_snow_above"].loc[{"gcm": gcm, "scenario": scenario, "delta": delta}].values, 1), " ")
                print(gcm + " " + scenario + " " + delta + " " + "max_yearly_snow:")
                resources.print_grid(np.round(
                    output["max_yearly_snow"].loc[{"gcm": gcm, "scenario": scenario, "delta": delta}].values, 1), " ")


def main():
    # This all could probably be condensed
    gcm_arr = []
    for gcm in SNOW_GCMS:
        scenario_arr = [resources.get_dataset(gcm, *scenario, raw=True)["SNOWH"] for scenario in resources.SCENARIOS]
        gcm_arr.append(xr.concat(
            scenario_arr, dim=pd.Index(map(lambda x: x[1] + "_" + x[0], resources.SCENARIOS), name="scenario")))
    snowh = xr.concat(gcm_arr, dim=pd.Index(SNOW_GCMS, name="gcm"))

    output = xr.Dataset({"days_snow_above": snow_threshold(snowh), "max_yearly_snow": max_yearly_snow(snowh)})
    # Keep the attributes so we can reapply them after the concat below erases them
    attrs = {k: output[k].attrs for k in output.variables}

    ensemble = output.mean(dim="gcm")
    ensemble = ensemble.assign_coords(gcm="ensemble").expand_dims("gcm")
    # noinspection PyTypeChecker
    output = xr.concat([ensemble, output], dim="gcm")  # type: xr.Dataset
    delta_historic = output - output[{"scenario": 0}]
    delta_mid = output - output[{"scenario": 1}]
    delta_scenario = xr.concat([
        output[{"scenario": 0}].where(False),  # Keep the entry and metadata but make all values NaN
        output[{"scenario": 1}].where(False),
        (output[{"scenario": 2}] - output[{"scenario": 3}])  # RCP4.5-RCP8.5
            .assign_coords(scenario=output.coords["scenario"][2]).expand_dims("scenario"),  # Put the metadata back in
        (output[{"scenario": 3}] - output[{"scenario": 2}])  # RCP8.5-RCP4.5
            .assign_coords(scenario=output.coords["scenario"][3]).expand_dims("scenario")],
        dim="scenario")
    # noinspection PyTypeChecker
    output = xr.concat([output, delta_historic, delta_mid, delta_scenario],
                       dim=pd.Index(["absolute", "historic", "mid-century", "RCP"], name="delta"))  # type: xr.Dataset

    for variable in output.variables:
        if variable in attrs: output[variable].attrs = attrs[variable]  # Reapply the attributes from above
    output.attrs["credit"] = "Created by Gabriel Konar-Steenberg's code in the summer of 2019. Part of a University " \
                             "of Minnesota Department of Soil, Water, and Climate climate modeling project."
    output.attrs["ensemble"] = "".join(map(lambda x: str(x) + " ", SNOW_GCMS))[:-1]
    output.attrs["delta"] = "0 = absolute = the absolute data, no differencing; " \
                            "1 = historic = projection - historic; " \
                            "2 = mid-century = projection - mid-century; " \
                            "3 = rcp = [NaN, NaN, RCP4.5 - RCP8.5, RCP8/5 - RCP4.5"

    output_path = resources.OUTPUT_ROOT + "snow_stats.nc"
    output.to_netcdf(path=output_path)

    # To test:
    # output_from_file = xr.open_dataset(output_path)
    # print_output(output_from_file)


if __name__ == "__main__":
    main()
