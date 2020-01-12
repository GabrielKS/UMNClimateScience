#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

import scipy.stats
import xarray as xr
import pandas as pd
import numpy as np
import resources
import g_stats
import warnings

GCMS = ("bcc-csm1-1", "MIROC5", "CESM1", "GFDL-ESM2M")  # TODO: expand to resources.GCMS once CNRM is ready

# f: function to calculate, i: info string, u: units
VARIABLES = {
    "tmax": {"f": lambda ds: ds.tmax, "i": "Maximum daily temperature", "u": "degrees C"},
    "tmin": {"f": lambda ds: ds.tmin, "i": "Minimum daily temperature", "u": "degrees C"},
    "tavg": {"f": lambda ds: (ds.tmax + ds.tmin) / 2, "i": "Estimated average daily temperature", "u": "degrees C"},
    "dtr": {"f": lambda ds: ds.tmax - ds.tmin, "i": "Diurnal temperature range", "u": "degrees C"},
    "precip": {"f": lambda ds: ds.prec, "i": "Cumulative daily precipitation(?)", "u": "mm(?)"}}


# Takes a final (e.g. future) dataset and compares it to an initial (e.g. historical) dataset
# Computes the difference in average (avg(final)-avg(initial)) and the p-value and t-statistic associated with a
# t-test between the two datasets, adjusted for lag-1 autocorrelation if adjust=True
# Time is collapsed completely, lat/lon are preserved
# All metadata is copied from the final dataset
def compare(initial, final, adjust=True):  # type: (xr.DataArray, xr.DataArray, bool) -> xr.DataArray
    attrs = final.attrs

    avg_i = initial.mean(dim="time", skipna=False)
    avg_f = final.mean(dim="time", skipna=False)
    d_avg = avg_f - avg_i

    # The SciPy t-test function uses standard deviations instead of variances
    std_i = initial.std(dim="time", skipna=False)
    std_f = final.std(dim="time", skipna=False)

    n_naive_i = initial.count(dim="time")
    n_naive_f = final.count(dim="time")

    # print("adjusting")
    n_adj_i = g_stats.adjusted_n(initial, dim="time") if adjust else None
    n_adj_f = g_stats.adjusted_n(final, dim="time") if adjust else None

    # resources.print_grid(np.round(n_naive_f.values, 1), " ")
    # print()
    # resources.print_grid(np.round(n_adj_f.values, 1), " ")

    # print("t-test")
    with warnings.catch_warnings():
        # print("Suppressing NaN warnings for t-test")
        # TODO further investigate this (probably superfluous) warning
        #  (maybe avoid by using apply_ufunc and filtering out the NaN cells myself)
        warnings.filterwarnings("ignore", message=".*invalid value encountered.*")
        t_test = scipy.stats.ttest_ind_from_stats(avg_i, std_i, n_adj_i if adjust else n_naive_i,
                                                  avg_f, std_f, n_adj_f if adjust else n_naive_f)

    t_stat = t_test.statistic
    # For some reason, the t-statistic gets the xarray metadata but the p-value does not, so we do some grafting:
    p_value = t_stat.copy()
    p_value.data = t_test.pvalue

    output = xr.concat([d_avg, p_value, t_stat], dim=pd.Index(["value", "p", "t"], name="mode"))
    output.attrs = attrs
    return output


# What to do in place of compare() when not given anything to compare to: just output the mean
def summarize(da):
    return da.mean(dim="time", skipna=False)


def main():
    gcm_arr = []
    for gcm in GCMS:
        scenario_arr = [resources.get_dataset(gcm, *scenario) for scenario in resources.SCENARIOS]
        for ds in scenario_arr: ds["time"].attrs["start time"] = ds["time"][0]
        # Measure time from start of dataset to make all datasets align
        scenario_arr = [ds.assign_coords(time=ds["time"] - ds["time"][0]) for ds in scenario_arr]
        gcm_arr.append(xr.concat(
            scenario_arr, dim=pd.Index(map(lambda x: x[1] + "_" + x[0], resources.SCENARIOS), name="scenario")))
    # noinspection PyTypeChecker
    all_input = xr.concat(gcm_arr, dim=pd.Index(GCMS, name="gcm")).squeeze(dim="lev", drop=True)  # type: xr.Dataset
    ensemble = all_input.mean(dim="gcm", skipna=False).assign_coords(gcm="ensemble").expand_dims("gcm")
    # noinspection PyTypeChecker
    all_input = xr.concat([ensemble, all_input], dim="gcm")  # type: xr.Dataset
    print("Done with input")

    all_output = {}
    for label in VARIABLES:
        v = VARIABLES[label]
        variable_input = (v["f"])(all_input)
        variable_output = []
        for gcm in variable_input.coords["gcm"].values:
            print(label + " of " + gcm)
            gcm_input = variable_input.loc[{"gcm": gcm}]

            absolute = summarize(gcm_input)
            # P-value and t-statistic are undefined for the absolute layer
            absolute = xr.concat([absolute, absolute.where(False), absolute.where(False)],
                                 dim=pd.Index(["value", "p", "t"], name="mode"))
            historic = compare(gcm_input.loc[{"scenario": "1980-1999_HISTORIC"}], gcm_input)
            mid_century = compare(gcm_input.loc[{"scenario": "2040-2059_RCP4.5"}], gcm_input)

            # Make all entries true, then collapse time, then make all entries NaN because the rcp comparison is
            # undefined for historical and mid-century
            rcp_0 = gcm_input.loc[{"scenario": "1980-1999_HISTORIC"}] \
                .where(False, other=True).any(dim="time").where(False)
            rcp_1 = gcm_input.loc[{"scenario": "2040-2059_RCP4.5"}] \
                .where(False, other=True).any(dim="time").where(False)
            # Even though they're undefined, they need the same mode structure as the defined ones to be concatted
            rcp_0 = xr.concat([rcp_0, rcp_0, rcp_0], dim=pd.Index(["value", "p", "t"], name="mode"))
            rcp_1 = xr.concat([rcp_1, rcp_1, rcp_1], dim=pd.Index(["value", "p", "t"], name="mode"))

            # Compare one RCP to the other
            rcp_2 = compare(gcm_input.loc[{"scenario": "2080-2099_RCP8.5"}],
                            gcm_input.loc[{"scenario": "2080-2099_RCP4.5"}])
            rcp_3 = compare(gcm_input.loc[{"scenario": "2080-2099_RCP4.5"}],
                            gcm_input.loc[{"scenario": "2080-2099_RCP8.5"}])
            # Put the scenario information back in
            rcp_2 = rcp_2.assign_coords(scenario=gcm_input.coords["scenario"][2]).expand_dims("scenario")
            rcp_3 = rcp_3.assign_coords(scenario=gcm_input.coords["scenario"][3]).expand_dims("scenario")

            rcp = xr.concat([rcp_0, rcp_1, rcp_2, rcp_3], dim="scenario")

            gcm_output = xr.concat([absolute, historic, mid_century, rcp],
                                   pd.Index(["absolute", "historic", "mid-century", "rcp"], name="delta"))
            variable_output.append(gcm_output)
        variable_output = xr.concat(variable_output, pd.Index(variable_input.coords["gcm"].values, name="gcm"))
        all_output[label] = variable_output
    all_output = xr.Dataset(all_output)
    print(all_output)
    # all of the putting back together is very untested

    output_path = resources.OUTPUT_ROOT + "basic_comparisons.nc"
    all_output.to_netcdf(path=output_path)

def visualize(output):
    for gcm in output.coords["gcm"].values:
        for scenario in output.coords["scenario"].values:
            for delta in output.coords["delta"].values:
                print(gcm + " " + scenario + " " + delta + " " + "days_snow_above:")
                resources.print_grid(np.round(
                    output["days_snow_above"].loc[{"gcm": gcm, "scenario": scenario, "delta": delta}].values, 1),
                    " ")
                print(gcm + " " + scenario + " " + delta + " " + "max_yearly_snow:")
                resources.print_grid(np.round(
                    output["max_yearly_snow"].loc[{"gcm": gcm, "scenario": scenario, "delta": delta}].values, 1),
                    " ")

if __name__ == "__main__":
    main()
