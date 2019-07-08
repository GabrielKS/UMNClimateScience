#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Input: all of the statistics in the NetCDF files within ensemble_average_stats
# Output: same as input, except:
#  - the lat/lon coordinates are rounded
#  - For every 2080-2099 RCP4.5 variable with a delta dimension, delta=2 is now RCP4.5 minus RCP8.5
#  - For every 2080-2099 RCP8.5 variable with a delta dimension, delta=2 is now RCP8.5 minus RCP4.5
#  - Delta is now labeled: [absolute, vs_historical, vs_alternate]
from xarray import DataArray
import resources
import xarray as xr
import os


# Input:
#  precip
#   2080-2099_RCP4.5
#    precip_threshold_stats.nc
#   2080-2099_RCP8.5
#    precip_threshold_stats.nc
#   2040-2059_RCP4.5
#    precip_threshold_stats.nc
#   1980-1999_HISTORIC
#    precip_threshold_stats.nc
#  temperature
#   2080-2099_RCP4.5
#    temperature_threshold_stats.nc
#   2080-2099_RCP8.5
#    temperature_threshold_stats.nc
#   2040-2059_RCP4.5
#    temperature_threshold_stats.nc
#   1980-1999_HISTORIC
#    temperature_threshold_stats.nc


# Get the path of a stats file. type is either "precip" or "temp", rcp and timeframe are as in resources
def get_stats_path_relative(type, rcp, timeframe):
    long_type = "temperature" if type == "temp" else type
    return type + "/" + timeframe + "_" + rcp + "/" + long_type + "_threshold_stats.nc"


def get_all_stats_paths_relative():
    paths = {}
    # TODO: There might be a better data structure for this (thinking of something like a DataArray of Datasets)
    for type in ["temp", "precip"]:
        for timeframe in resources.TIMEFRAMES:
            for rcp in resources.RCPS_FOR_TIMEFRAME[timeframe]:
                paths[(type, timeframe, rcp)] = get_stats_path_relative(type, rcp, timeframe)
    return paths


def get_stats_data_files():
    files = get_all_stats_paths_relative()
    for key in files:
        files[key] = xr.open_dataset(resources.STATS_ROOT + files[key], chunks={})
        resources.round_coords(files[key], {"latDim", "lonDim"})
    return files


# Takes a Dataset to operate on, data_this, and a comparison Dataset, data_that, and, for each variable in data_this,
# sets delta=2 to be this minus other (similarly to how delta=1 is this minus historical)
def concat_differences(data_this, data_other):
    data_new = {}
    for variable in data_this:
        variable_this = data_this[variable]
        # We only want to work with variables that already have a historical delta (this excludes things like lat/lon)
        if "delta" in variable_this.dims:
            variable_other = data_other[variable]
            difference = variable_this[{"delta": 0}] - variable_other[{"delta": 0}]
            # We can't append, so we have to concatenate
            # noinspection PyTypeChecker
            variable_this = xr.concat([variable_this, difference], dim="delta")  # type: DataArray
            variable_this = variable_this.assign_coords(delta=["absolute", "vs_historical", "vs_alternate"])
        data_new[variable] = variable_this
    return resources.format_dataset(data_new)


# Does the same reformatting as concat_differences without actually adding any data (used for consistency)
def reformat_similarly(data_this):
    data_new = {}
    for variable in data_this:
        variable_this = data_this[variable]
        if "delta" in variable_this.dims:
            variable_this = variable_this.assign_coords(delta=["absolute", "vs_historical"])
        data_new[variable] = variable_this
    return resources.format_dataset(data_new)


def main():
    files = get_stats_data_files()
    for key in files:
        output = None
        if key[1] == "2080-2099":
            other_key = (key[0], key[1], "RCP4.5" if key[2] == "RCP8.5" else "RCP8.5" if key[2] == "RCP4.5" else None)
            output = concat_differences(files[key], files[other_key])
        else:
            output = reformat_similarly(files[key])
        path = resources.OUTPUT_ROOT + "new_ensemble_average_stats/" + get_stats_path_relative(*key)
        folder = os.path.dirname(path)
        if not os.path.exists(folder): os.makedirs(folder)  # Create the enclosing folder structure if necessary
        if os.path.exists(path): os.remove(path)  # Delete the existing file if necessary
        output.to_netcdf(path=path)


if __name__ == "__main__":
    main()
