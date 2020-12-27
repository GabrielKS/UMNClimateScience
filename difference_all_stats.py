#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Input: all of the statistics in the NetCDF files within ensemble_average_stats
# Output: same as input, except:
#  - For every 2080-2099 RCP4.5 variable with a delta dimension, delta=2 is now RCP4.5 minus RCP8.5
#  - For every 2080-2099 RCP8.5 variable with a delta dimension, delta=2 is now RCP8.5 minus RCP4.5
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


TYPES = ["temp", "precip"]


# Get the path of a stats file. type is either "precip" or "temp", rcp and timeframe are as in resources
def get_stats_path_relative(type, timeframe, rcp):
    long_type = "temperature" if type == "temp" else type
    return type + "/" + timeframe + "_" + rcp + "/" + long_type + "_threshold_stats.nc"


def get_all_stats_paths_relative():
    paths = {}
    # TODO: There might be a better data structure for this (thinking of something like a DataArray of Datasets)
    for type in TYPES:
        for timeframe in resources.TIMEFRAMES:
            for rcp in resources.RCPS_FOR_TIMEFRAME[timeframe]:
                paths[(type, timeframe, rcp)] = get_stats_path_relative(type, timeframe, rcp)
    return paths


def get_stats_data_files(root=resources.STATS_ROOT):
    files = get_all_stats_paths_relative()
    for key in files:
        files[key] = xr.open_dataset(root + files[key])
    return files


# Takes a Dataset to operate on, data_this, and a comparison Dataset, data_other, and, for each variable in data_this,
# sets delta=2 to be this minus other (similarly to how delta=1 is this minus historical)
def concat_differences(data_this, data_other):
    data_new = {}
    for variable in data_this.variables:
        variable_this = data_this[variable]
        # We only want to work with variables that already have a historical delta (this excludes things like lat/lon)
        if "delta" in variable_this.dims:
            variable_other = data_other[variable]
            difference = variable_this[{"delta": 0}] - variable_other[{"delta": 0}]
            # We can't append, so we have to concatenate
            # noinspection PyTypeChecker
            variable_this = xr.concat([variable_this, difference], dim="delta")  # type: DataArray
            # See the assign_coords comment below
            # variable_this = variable_this.assign_coords(delta=["absolute", "vs_historical", "vs_alternate"])
        data_new[variable] = variable_this
    return resources.format_dataset(data_new)


# Removes an unused dimension
# Could be greatly expanded in the future
def reformat(data_this):
    # Get rid of the singleton
    data_this = data_this.squeeze()
    data_new = {}
    for variable in data_this.variables:
        variable_this = data_this[variable]
        # This part doesn't seem to have the intended effect of assigning coordinates to delta (TODO: figure out why)
        # if "delta" in variable_this.dims:
        #     variable_this = variable_this.assign_coords(delta=["absolute", "vs_historical"])
        data_new[variable] = variable_this
    return resources.format_dataset(data_new)


# Prints a sample of the results so one can verify that they are reasonable
def print_sample():
    samples = 10
    import random
    random.seed(0)  # For reproducibility
    lats = random.sample(range(0, 100), samples)
    lons = random.sample(range(0, 130), samples)

    files = get_stats_data_files(root=resources.OUTPUT_ROOT + "new_ensemble_average_stats/")
    temp_name = "days_tmax_at_or_above_90F"
    precip_name = "yearly_at_or_above_t1"
    variables = {"temp4.5": files[("temp", "2080-2099", "RCP4.5")][temp_name],
                 "temp8.5": files[("temp", "2080-2099", "RCP8.5")][temp_name],
                 "prec4.5": files[("precip", "2080-2099", "RCP4.5")][precip_name],
                 "prec8.5": files[("precip", "2080-2099", "RCP8.5")][precip_name]}
    for sample in range(0, samples):
        for variable in variables:
            print(variable + ": " + str(variables[variable][{"latDim": lats[sample], "lonDim": lons[sample]}].values))
        print()


def main():
    # """
    # Read files
    files = get_stats_data_files()

    # Reformat
    for key in files:
        files[key] = reformat(files[key])

    # Calculate differences
    for key in files:
        output = files[key]
        if key[1] == "2080-2099":
            other_key = (key[0], key[1], "RCP4.5" if key[2] == "RCP8.5" else "RCP8.5" if key[2] == "RCP4.5" else None)
            output = concat_differences(files[key], files[other_key])
        files[key] = output

    # Write files
    for key in files:
        path = resources.OUTPUT_ROOT + "new_ensemble_average_stats/" + get_stats_path_relative(*key)
        folder = os.path.dirname(path)
        if not os.path.exists(folder): os.makedirs(folder)  # Create the enclosing folder structure if necessary
        if os.path.exists(path): os.remove(path)  # Delete the existing file if necessary
        files[key].to_netcdf(path=path)
        # """

    # Test
    print_sample()


if __name__ == "__main__":
    main()
