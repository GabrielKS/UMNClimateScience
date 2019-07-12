#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Demonstrates the fact that not all LCCMR input files have exactly the same lat/lon coordinates

import resources
import xarray as xr


def main():
    paths = resources.get_paths("CNRM-CM5", "HISTORIC", "1980-1999")
    # Get the files manually (not using resources.get_files because that does lat/lon rounding)
    files = [xr.open_dataset(filename, chunks={}) for filename in paths]
    lat0 = files[0]["lat"].values  # Lat values from year 0 (i.e. 1980)
    lat19 = files[19]["lat"].values  # Lat values from year 19 (i.e. 1999)
    print(lat0)
    print(lat19)
    print(lat19 - lat0)  # Difference (note: if ".values" is omitted above, differences round to 0)


if __name__ == "__main__":
    main()
