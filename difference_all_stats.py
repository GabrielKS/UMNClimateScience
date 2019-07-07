#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Takes all of the statistics in ensemble_average_stats and outputs a single file with:
#  - the statistics themselves (from the input)
#  - differences from historical (from the input)
#  - differences between RCP4.5 and RCP8.5 (calculated here)


import resources
import xarray as xr


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
def get_stats_path(type, rcp, timeframe):
    long_type = "temperature" if type == "temp" else type
    return resources.STATS_ROOT+type+"/"+timeframe+"_"+rcp+"/"+long_type+"_threshold_stats.nc"


def get_all_stats_paths():
    paths = {}
    for type in ["temp", "precip"]:
        for timeframe in resources.TIMEFRAMES:
            for rcp in resources.RCPS_FOR_TIMEFRAME[timeframe]:
                paths[(type, timeframe, rcp)] = get_stats_path(type, rcp, timeframe)
    return paths


def get_stats_data_files():
    files = get_all_stats_paths()
    for key in files:
        files[key] = xr.open_dataset(files[key], chunks={})
        resources.round_coords(files[key], {"latDim", "lonDim"})
    return files


def main():
    print(get_stats_data_files())


if __name__ == "__main__":
    main()
