#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Global settings, code for getting data, and general helper functions

import xarray as xr
import os.path
import numpy as np
import calendar

# CONSTANTS:

# Where the input data can be found  (expanduser replaces a tilde in the path with the user's home directory)
LCCMR_ROOT = os.path.expanduser("~/Downloads/LCCMR_IBIS/")
STATS_ROOT = os.path.expanduser("~/Downloads/ensemble_average_stats/")

# Where the output data should be stored (getcwd gives us the path to the working directory)
OUTPUT_ROOT = os.getcwd() + "/output/"

# Input options:
GCMS = ("CNRM-CM5", "bcc-csm1-1", "MIROC5", "CESM1", "GFDL-ESM2M")  # Ordered only for convenience
RCPS = ("HISTORIC", "RCP4.5", "RCP8.5")
TIMEFRAMES = ("1980-1999", "2040-2059", "2080-2099")

# Which timeframes go with which RCPs, and vice versa
# TODO: eliminate the redundancy here -- maybe with a different data structure, maybe with one or more functions
TIMEFRAMES_FOR_RCP = {RCPS[0]: (TIMEFRAMES[0],), RCPS[1]: (TIMEFRAMES[1], TIMEFRAMES[2]), RCPS[2]: (TIMEFRAMES[2],)}
RCPS_FOR_TIMEFRAME = {TIMEFRAMES[0]: (RCPS[0],), TIMEFRAMES[1]: (RCPS[1],), TIMEFRAMES[2]: (RCPS[1], RCPS[2])}

# Coordinates are rounded to this number of decimals (see round_coords)
COORD_DECIMALS = 4

# Number of years in each model run (TODO: get this programmatically)
YEARS = 20


# INPUT:

# Get the paths to all the files in a certain dataset
# Can't just use a wildcard for the paths because that would include IBISinput_20yrclim.nc
def get_paths(gcm, rcp, timeframe):
    base = LCCMR_ROOT + gcm + "/" + rcp + "/" + timeframe + "/WRF_IBISinput/IBISinput_"
    year0 = int(timeframe[:4])
    return [base + str(year) + ".nc" for year in range(year0, year0 + 20)]


# Get all the files in a certain dataset
def get_data_files(gcm, rcp, timeframe):
    files = [xr.open_dataset(filename, chunks={}) for filename in get_paths(gcm, rcp, timeframe)]
    for file in files: round_coords(file, {"lat", "lon"})
    return files


def get_dataset(gcm, rcp, timeframe):
    files = get_data_files(gcm, rcp, timeframe)
    # TODO: The next line prints something and I'm not sure exactly what or why....
    combination = xr.combine_by_coords(files)
    for file in files:  # If these assertions fail, then round_coords didn't fulfil its purpose
        assert len(combination["lat"]) == len(file["lat"])
        assert len(combination["lon"]) == len(file["lon"])
    return combination


# MAKING THE DATA LOOK NICER:

# Round coordinates so that if the coordinates vary slightly between files, values can still be combined
# TODO: Maybe replace this with fuzzy coordinate matching (see https://github.com/pydata/xarray/issues/2217)
def round_coords(data, dims):
    for dim in dims: data.coords[dim] = np.round(data.coords[dim], decimals=COORD_DECIMALS)


# Erases likely-inaccurate values at the edge of the simulation
# See Terin's "trimRelaxationZone"
def trim_relaxation_zone(data):
    chunks = undask(data)

    # Terin's code seems to imply that all data in the first 5 and last 5 latitude coordinates,
    # and all data in the first 10 and last 5 longitude coordinates, should be erased:
    """
    data[dict(lat=slice(None, 5))] = np.nan
    data[dict(lat=slice(-5, None))] = np.nan
    data[dict(lon=slice(None, 10))] = np.nan
    data[dict(lon=slice(-5, None))] = np.nan
    """

    # However, Terin's data seems to imply that all data in the first 10 and last 5 latitude coordinates,
    # and all data in the first 5 and last 5 longitude coordinates (see e.g. (0,36,0)), should be erased:
    data[dict(lat=slice(None, 10))] = np.nan
    data[dict(lat=slice(-5, None))] = np.nan
    data[dict(lon=slice(None, 5))] = np.nan
    data[dict(lon=slice(-5, None))] = np.nan

    # TODO: learn more about how and why this should be happening,
    # including why it's 10 at one edge and 5 at all the others.

    redask(data, chunks)
    return data


# Takes a DataArray and returns true for every cell where all the values along dims are defined (i.e. not NaN)
# Use to reinsert markers of invalid data when an operation has put a (false) valid value in
def collapse_all_valid(data, dims):
    return ~np.isnan(data).any(dim=dims)  # Data is valid if not any of it is NaN, i.e. all of it is non-NaN


# Same as collapse_all_valid but returns true for every cell where *any* of the values along dims are defined
def collapse_any_valid(data, dims):
    return ~np.isnan(data).all(dim=dims)  # Data is valid if not all of it is NaN, i.e. any of it is non-NaN


# Outputs an array of DataArrays creating by splitting the input DataArray into yearly chunks
# Input data must have one entry per day between the beginning of start_year and the end of end_year
# TODO: Seems like there might be a built-in function for this?
def split_by_year(data, key, start_year, end_year):
    lengths = year_lengths(start_year, end_year)
    assert len(data[key]) == np.sum(lengths)
    sections = []
    start_day = 0
    for year in range(0, end_year - start_year + 1):
        end_day = start_day + lengths[year]
        sections.append(data[{key: slice(start_day, end_day)}])
        # Time now refers to day of the year (side effect: huge performance boost)
        sections[year][key] = range(0, len(sections[year]["time"]))
        start_day = end_day
    return sections


# HELPER FUNCTIONS:

# Convert temperature. Works with "F" for Fahrenheit, "C" for Celsius, "K" for Kelvin.
def convert_temp(input_temp, input_units, output_units):
    if input_units == output_units: return input_temp

    if input_units == "F" and output_units == "C": return (input_temp - 32) * 5 / 9
    if input_units == "C" and output_units == "F": return input_temp * 9 / 5 + 32

    if input_units == "K" and output_units == "C": return input_temp - 273.15
    if input_units == "C" and output_units == "K": return input_temp + 273.15

    if input_units == "F" and output_units == "K": return convert_temp(convert_temp(input_temp, "F", "C"), "C", "K")
    if input_units == "K" and output_units == "F": return convert_temp(convert_temp(input_temp, "K", "C"), "C", "F")


# Outputs a dict with temperature in all three units.
# Input should be a dict, labeled by "F," "C," and "K," with at least one temperature in it.
# If more than one temperature is input, the first one takes priority.
def get_all_temp_units(temps):
    input_unit = None
    for unit in temps:
        if temps[unit] is not None:
            input_unit = unit
            break
    input_temp = temps[input_unit]

    result = {}
    for unit in temps: result[unit] = convert_temp(input_temp, input_unit, unit)
    return result


# Outputs a string with the temperature value that takes priority in get_all_temp_units, labeled by its units
# Input should be formatted as in get_all_temp_units (e.g. 90F)
def get_temp_string(temps):
    for unit in temps:
        if temps[unit] is not None:
            return str(temps[unit]) + unit


# Print all the data within a DataArray (or the like) in a format similar to what you'd get in NCL with
# print(file->variable), minus the metadata
def print_data_and_coordinates(data):
    for index, value in np.ndenumerate(data):
        print(str(index) + "\t" + str(value))


# Print the indices of either all NaN entries, for find_nans=true, or all non-NaN entries, for find_nans=false
# Useful for debugging
def print_validity_indices(data, find_nans):
    for index, value in np.ndenumerate(data):
        if (find_nans and np.isnan(value)) or ((not find_nans) and (not np.isnan(value))):
            print(index)


# Outputs an array filled with the number of days in each year from start_year to end_year inclusive
def year_lengths(start_year, end_year):
    return [366 if calendar.isleap(year) else 365 for year in range(start_year, end_year + 1)]  # :)


# If the data is in Dask parallelizable form, load it all into memory so addresses can be assigned
def undask(data):
    chunks = data.chunks
    if chunks is not None: data.load()
    return chunks


# If the data was in Dask form, put it back
def redask(data, chunks):
    if chunks is not None: data.chunk(chunks)
