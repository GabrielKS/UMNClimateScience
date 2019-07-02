import xarray as xr
import os.path

LCCMR_ROOT = os.path.expanduser(  # Replaces a tilde in the path with the user's home directory
    "~/Downloads/LCCMR_IBIS/")

OUTPUT_ROOT = "output/"

GCMS = {"CNRM-CM5", "bcc-csm1-1", "MIROC5", "CESM1", "GFDL-ESM2M"}
RCPS = ("HISTORIC", "RCP4.5", "RCP8.5")
TIMEFRAMES = ("1980-1999", "2040-2059", "2080-2099")


# Can't just use a wildcard for the paths because that would include IBISinput_20yrclim.nc
def get_paths(gcm, rcp, timeframe):
    base = LCCMR_ROOT + gcm + "/" + rcp + "/" + timeframe + "/WRF_IBISinput/IBISinput_"
    year0 = int(timeframe[:4])
    return [base + str(year) + ".nc" for year in range(year0, year0 + 20)]


def get_data_files(gcm, rcp, timeframe):
    return [xr.open_dataset(filename) for filename in get_paths(gcm, rcp, timeframe)]


def get_dataset(gcm, rcp, timeframe):
    filenames = get_paths(gcm, rcp, timeframe)
    # TODO: The next line prints something and I'm not sure what or why....
    return xr.open_mfdataset(filenames, combine="by_coords")


def convert_temp(input, input_units, output_units):
    if input_units == output_units: return input_units

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
