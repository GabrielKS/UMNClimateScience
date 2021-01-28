#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# From raw snow height data, calculates metrics that are more meaningful and comprehensible to a human audience.
# Note: Depending on how the input data are structured, one might consider using the "skipna=False" option more often.

import xarray as xr
import pandas as pd
import numpy as np
import resources

SNOW_GCMS = resources.GCMS
SNOW_THRESHOLD_METERS = 25.4 / 1000


# Computes the average number of days per year where there is SNOW_THRESHOLD_METERS or more of snow on the ground.
def snow_threshold(raw_data, by_year=True):
    result = {}
    for label in raw_data:
        scenario = raw_data[label]
        count = scenario.where(scenario >= SNOW_THRESHOLD_METERS)
        if by_year: count = count.groupby("time.year")
        count = count.count(dim="time")
        if not by_year: count /= resources.YEARS
        count = count.where(resources.UNIVERSAL_MASK)

        if by_year:
            # Number years 0, 1, 2, ..., 19 instead of with the calendar year so different time periods are directly comparable
            count = count.assign_coords(year=count["year"]-count["year"][0])
        count.attrs["description"] = "number of days in each year where the snow depth meets or exceeds the threshold" + ("" if by_year else ", averaged over the whole time period")
        count.attrs["threshold"] = str(SNOW_THRESHOLD_METERS) + " meters"
        count.attrs["units"] = "number of days"
        result[label] = count
    return xr.concat(result.values(), dim=pd.Index(result.keys(), name="scenario"))


# Computes the maximum yearly snow depth.
# Currently returns an average across all years. Could easily be rewritten to get the maximum depth for each year.
def max_yearly_snow(raw_data):
    result = {}
    for label in raw_data:
        scenario = raw_data[label]
        max_per_year = scenario.groupby("time.year").max(dim="time", skipna=False)  # SO EASY
        max_average = max_per_year.sum(dim="year") / resources.YEARS
        max_average = max_average.where(resources.UNIVERSAL_MASK)

        max_average.attrs["description"] = "average maximum yearly snow depth"
        max_average.attrs["units"] = "meters"
        result[label] = max_average
    return xr.concat(result.values(), dim=pd.Index(result.keys(), name="scenario"))


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
    # New methodology: keep the scenarios separate to begin with; it makes it easier to deal with years individually.
    scenario_dict = {}
    for scenario in resources.SCENARIOS:
        gcm_arr = [resources.get_dataset(gcm, *scenario, raw=True)["SNOWH"] for gcm in SNOW_GCMS]
        # for a in gcm_arr: print(list(a["time"].values)[::100])
        scenario_dict[scenario[1]+"_"+scenario[0]] = xr.concat(gcm_arr, dim=pd.Index(SNOW_GCMS, name="gcm"))

    output = xr.Dataset({"days_snow_above": snow_threshold(scenario_dict), "max_yearly_snow": max_yearly_snow(scenario_dict)})
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

    output_path = resources.OUTPUT_ROOT + "snow_stats4.nc"
    output.to_netcdf(path=output_path)

    # To test:
    # output_from_file = xr.open_dataset(output_path)
    # print_output(output_from_file)


if __name__ == "__main__":
    main()
