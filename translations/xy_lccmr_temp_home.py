#  Written by Gabriel Konar-Steenberg in the winter of 2020.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Meant to be a fairly direct translation of xy_lccmr_temp_home.ncl (which is itself based on xy_2.ncl),
# with fairly few external dependencies. From time to time, comments roughly note corresponding lines of the NCL original.
# I wrote two versions of the plotting section, one using the NCAR-sponsored PyNGL library and one using the general-purpose matplotlib.

import os

# import Nio  # We're not going to use PyNIO
import xarray as xr  # Library for working with labeled, n-dimensional data
import pandas as pd  # Library for working with labeled, 1- and 2-dimensional data
import numpy as np  # Library for working with unlabeled, n-dimensional data. Theoretically we could do everything with NumPy alone — data in NCL is mostly unlabeled — but labels make things much easier.
import matplotlib.pyplot as plt
import time

def main():
    path = os.path.dirname(os.getcwd())+"/input/Stefan2"  # To make things slightly simpler, we make this an absolute path now.
    # var = "precip_biascorrected"
    var = "T2_biascorrected"
    ensemble_dir = "ZZ_all"

    # g = Nio.open_file(path+"/LCCMR/ZZ_all/IBISinput_Minnesota_raw.nc")
    g = xr.open_dataset(path+"/LCCMR/ZZ_all/IBISinput_Minnesota_raw.nc", chunks={})  # Original line 69. We could use PyNIO (see previous line), but I find that xarray does everything PyNIO does plus a lot more, with much more versatility. The chunks={} part tells xarray to use Dask behind the scenes — Dask is a library that supports parallelization, lazy evaluation, and other techniques that greatly enhance performance.

    models = [f.name for f in os.scandir(path+"/LCCMR") if f.is_dir()]  # Our models will be each subdirectory of LCCMR; we get the list once, outside of any loops. The syntax on this line is very Pythonic — it generates a list using a loop and an if statement all on one line!
    models.remove(ensemble_dir)  # Alternatively, we could just specify a list of models — this would be the better approach if we want to be any more selective than this.
    models = sorted(models, key=str.lower)  # Sort case-insensitive
    models.append("MME")
    # print(models)

    # scenarios = {"historical": (1980,), "RCP4.5": (2020, 2040, 2080), "RCP8.5": (2080,)}  # This can be edited to select which scenarios and timeframes should be used
    scenarios = {"RCP4.5": (2040,)}  # If only using one timeframe for a given scenario, must put a comma after it
    n_years = 20  # Number of years in each scenario

    for scenario in scenarios:  # Creates a variable scenario that iterates through scenarios. Original lines 31-42.
        for starting_year in scenarios[scenario]:  # Iterate through starting year. Original lines 34,37,40,44-46,57-63.
            print()
            print(scenario)
            print(starting_year)

            decade = starting_year//10 % 10  # Decade is year/10 mod 10 ("//" is integer division)
            files = [path+"/LCCMR/"+model+"/"+scenario+"/allyears_daily/IBISinput_ens"+str(decade)+"ymonmean.nc" for model in models[:-1]]  # Original line 51.
            files.append(path+"/LCCMR/"+ensemble_dir+"/"+scenario+"/IBISinput_all7_ens"+str(decade)+"ymonmean.nc")

            years = range(starting_year, starting_year+n_years)
            files1 = [[path+"/LCCMR/"+model+"/"+scenario+"/allyears_daily/IBISinput_"+str(year)+"_cst_ymonmean.nc" for year in years] for model in models[:-1]]  # Original line 52.

            # print(files)  # I'll keep the original names for variables that exist in the original script.
            # print(files1)

            # The following three lines of code could all be done in one line; I did it this way to make it more readable. Same with the three lines after that.
            files_datasets = [xr.open_dataset(f, chunks={}).assign_coords(Time=range(12)) for f in files]  # Read in the datasets and change the Time coordinates from dates and times (some of which may be incorrect) to months of the year.
            files_datasets = drop_inconsistent_variables(files_datasets)  # drop_inconsistent_variables (function defined below) is necessary because some of the files have a variable called "direction10" and some don't, and concat on the next line requires all datasets to have the same variables. In a future version of xarray, this requirement will be relaxed (see https://github.com/pydata/xarray/pull/3545).
            f = xr.concat(files_datasets, dim=pd.Index(models, name="model"))  # Concatenate all the datasets from files into one dataset, indexed by model name. Original line 84.

            files1_datasets = [[xr.open_dataset(filename, chunks={}).assign_coords(Time=range(12)) for filename in model_set] for model_set in files1]
            files1_by_model = [xr.concat(model_set, dim=pd.Index(years, name="year")) for model_set in files1_datasets]  # Concatenate the datasets in files1 by year.
            files1_by_model = drop_inconsistent_variables(files1_by_model)  # It turns out the inconsistent variables are only across models, not across years within a model.
            f1 = xr.concat(drop_inconsistent_variables(files1_by_model), dim=pd.Index(models[:-1], name="model"))  # Concatenate the datasets in files1 by modelf

            file2 = path+"/LCCMR/ZZ_all/historical/IBISinput_all7_ens8ymonmean.nc"  # Original line 74
            f2 = xr.open_dataset(file2, chunks={}).assign_coords(Time=range(12))  # Original line 75
            # print(f2)

            tem = f[var]  # Original line 88
            tem1 = f1[var]
            tem2 = f2[var]

            MN_raw = g["MN_raw"]  # Original line 92

            te = tem.where(~np.isnan(MN_raw))  # Original line 99. xarray automatically "broadcasts" MN_raw across tem so the dimensions match, so original line 95 is unnecessary.
            te1 = tem1.where(~np.isnan(MN_raw))
            te2 = tem2.where(~np.isnan(MN_raw))

            temp = te.mean(dim=("LON", "LAT"))  # Original line 102.
            temp1 = te1.mean(dim=("LON", "LAT"))
            temp2 = te2.mean(dim=("LON", "LAT"))

            # Now we have, as in the original:
            print(temp)  # temp: Monthly data averaged across years for each of the models and the ensemble
            print(temp1)  # temp1: Monthly (along one dimension) and yearly (along another dimension) data for each of the models (no ensemble)
            print(temp2)  # temp2: Monthly historical data averaged across years for the ensemble only

            # Dimensions and coordinates are:
            #   Time: An integer ranging from 0 to 11 representing the month (unlike in the original script)
            #   year (only in temp1): An integer representing the year of the data (e.g. 2040)
            #   model (not in temp2): A string representing the model name (e.g. "CNRM-CM5") or "MME" for the ensemble

            # As far as plotting libraries go, there are two strong contenders for this kind of non-cartographic data:
            #   PyNGL — an NCAR project that enables plot construction using a "resource"-based syntax similar to in NCL
            #   matplotlib — this library is very commonly used across various disciplines
            # Here, I'll show both.

            use_PyNGL = True    # Make this True to generate figures using PyNGL, False for matplotlib

            if use_PyNGL:   # Using PyNGL:
                pass
            else:
                pass    # Using matplotlib (actually using an interface called matplotlib.pyplot):


def drop_inconsistent_variables(datasets):  # Drops the variables that do not appear in all datasets
    common_variables = set(datasets[0]).intersection(*datasets)  # Figure out which variables exist in all datasets
    datasets = [d.drop_vars([v for v in d if v not in common_variables]) for d in datasets]  # Remove all variables that only exist in some of the datasets
    return datasets


if __name__ == "__main__":
    main()
