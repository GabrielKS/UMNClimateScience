import xarray as xr
import os.path
import numpy as np

LCCMR_ROOT = os.path.expanduser(  # expanduser replaces a tilde in the path with the user's home directory
    "~/Downloads/LCCMR_IBIS/")

OUTPUT_ROOT = os.getcwd() + "/output/"  # getcwd gives us the path to the working directory

GCMS = ("CNRM-CM5", "bcc-csm1-1", "MIROC5", "CESM1", "GFDL-ESM2M")
RCPS = ("HISTORIC", "RCP4.5", "RCP8.5")
TIMEFRAMES = ("1980-1999", "2040-2059", "2080-2099")

COORD_DECIMALS = 4  # Coordinates are rounded to this number of decimals


# Can't just use a wildcard for the paths because that would include IBISinput_20yrclim.nc
def get_paths(gcm, rcp, timeframe):
    base = LCCMR_ROOT + gcm + "/" + rcp + "/" + timeframe + "/WRF_IBISinput/IBISinput_"
    year0 = int(timeframe[:4])
    return [base + str(year) + ".nc" for year in range(year0, year0 + 20)]


def inspect_lats():
    for gcm in GCMS:
        for rcp in RCPS:
            for timeframe in TIMEFRAMES:
                try:
                    get_data_files(gcm, rcp, timeframe)
                except:
                    pass


def get_data_files(gcm, rcp, timeframe):
    files = [xr.open_dataset(filename) for filename in get_paths(gcm, rcp, timeframe)]
    for file in files: round_coords(file, {"lat", "lon"})
    return files


# Round coordinates so that if the coordinates vary slightly between files, values can still be combined
def round_coords(data, dims):
    for dim in dims: data.coords[dim] = np.round(data.coords[dim], decimals=COORD_DECIMALS)


def get_dataset(gcm, rcp, timeframe):
    """
    filenames = get_paths(gcm, rcp, timeframe)
    # TODO: The next line prints something and I'm not sure what or why....
    return xr.open_mfdataset(filenames, combine="by_coords")
    """
    files = get_data_files(gcm, rcp, timeframe)
    return xr.combine_by_coords(files)


def trim_relaxation_zone(data):
    data[dict(lat=slice(None, 5))] = np.nan
    data[dict(lat=slice(-5, None))] = np.nan
    data[dict(lon=slice(None, 10))] = np.nan
    data[dict(lat=slice(-5, None))] = np.nan
    return data


# Takes a DataArray and returns true for every cell where all the values along dim are defined (i.e. not NaN)
# TODO: find a less hacky but no more brute force way to do this?
def collapse_find_valid(data, dims):
    return ~np.isnan(data.sum(dim=dims, skipna=False))


def convert_temp(input, input_units, output_units):
    if input_units == output_units: return input

    if input_units == "F" and output_units == "C": return (input - 32) * 5 / 9
    if input_units == "C" and output_units == "F": return input * 9 / 5 + 32

    if input_units == "K" and output_units == "C": return input - 273.15
    if input_units == "C" and output_units == "K": return input + 273.15

    if input_units == "F" and output_units == "K": return convert_temp(convert_temp(input, "F", "C"), "C", "K")
    if input_units == "K" and output_units == "F": return convert_temp(convert_temp(input, "K", "C"), "C", "F")


def get_all_temp_units(temps):
    # Temps should be a dict, labeled by "F," "C," and "K," with at least one temperature in it.
    # Outputs a dict with temperature in all three units.
    # If more than one temperature is input, the first one takes priority.

    input_unit = None
    for unit in temps:
        if temps[unit] != None:
            input_unit = unit
            break
    input_temp = temps[input_unit]

    result = {}
    for unit in temps: result[unit] = convert_temp(input_temp, input_unit, unit)
    return result


def get_temp_string(temps):
    # Temps formatted as in get_all_temp_units
    # Outputs a string with the temperature value that takes priority in get_all_temp_units, labeled by its units
    # (e.g. 90F)
    for unit in temps:
        if temps[unit] != None:
            return str(temps[unit]) + unit
