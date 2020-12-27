#  Written by Gabriel Konar-Steenberg in the winter of 2020.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Meant to be a fairly direct translation of xy_lccmr_temp_home.ncl (which is itself based on xy_2.ncl),
# with fairly few external dependencies. From time to time, comments roughly note corresponding lines of the NCL original.
# I wrote two versions of the plotting section, one using the NCAR-sponsored PyNGL library and one using the general-purpose matplotlib.

import os

# import Nio  # We're not going to use PyNIO
import Ngl  # We are going to use PyNGL (for one of the two plotting methodologies)
import xarray as xr  # Library for working with labeled, n-dimensional data
import pandas as pd  # Library for working with labeled, 1- and 2-dimensional data
import numpy as np  # Library for working with unlabeled, n-dimensional data. Theoretically we could do everything with NumPy alone — data in NCL is mostly unlabeled — but labels make things much easier.
import matplotlib.pyplot as plt  # General-purpose library for plotting
import time  # Used for introducing delays for debugging (time.sleep(x) delays for x seconds)
import copy  # For copying objects


def main():
    path = os.path.dirname(os.getcwd())+"/input/Stefan2"  # To make things slightly simpler, we make this an absolute path now.
    # var = "precip_biascorrected"
    var = "precip_biascorrected"
    ensemble_dir = "ZZ_all"

    # g = Nio.open_file(path+"/LCCMR/ZZ_all/IBISinput_Minnesota_raw.nc")
    g = xr.open_dataset(path+"/LCCMR/ZZ_all/IBISinput_Minnesota_raw.nc", chunks={})  # Original line 69. We could use PyNIO (see previous line), but I find that xarray does everything PyNIO does plus a lot more, with much more versatility. (Also, PyNIO has been deprecated along with NCL — see https://www.pyngl.ucar.edu/Nio.shtml.) The chunks={} part tells xarray to use Dask behind the scenes — Dask is a library that supports parallelization, lazy evaluation, and other techniques that greatly enhance performance.

    # models = [f.name for f in os.scandir(path+"/LCCMR") if f.is_dir()]  # Our models will be each subdirectory of LCCMR; we get the list once, outside of any loops. The syntax on this line is very Pythonic — it generates a list using a loop and an if statement all on one line!
    # models.remove(ensemble_dir)  # Alternatively, we could just specify a list of models — this would be the better approach if we want to be any more selective than this.
    # models = sorted(models, key=str.lower)  # Sort case-insensitive
    # models.append("MME")
    models = ['bcc-csm1-1', 'CCSM4', 'CMCC-CM', 'CNRM-CM5', 'GFDL-ESM2M', 'IPSL-CM5A-LR', 'MIROC5', 'MRI-CGCM3', 'MME']

    # scenarios = {"historical": (1980,), "RCP4.5": (2020, 2040, 2080), "RCP8.5": (2080,)}  # This can be edited to select which scenarios and timeframes should be used
    scenarios = {"RCP4.5": (2040,)}  # If only using one timeframe for a given scenario, must put a comma after it
    n_years = 20  # Number of years in each scenario

    for scenario in scenarios:  # Creates a variable scenario that iterates through scenarios. Original lines 31-42.
        for starting_year in scenarios[scenario]:  # Iterate through starting year. Original lines 34,37,40,44-46,57-63.
            print()
            print(scenario)
            print(starting_year)

            decade = starting_year//10 % 10  # Decade is year/10 mod 10 ("//" is integer division)
            files = [path+"/LCCMR/"+model+"/"+scenario+"/allyears_daily/IBISinput_ens"+str(decade)+"ymonmean.nc" for model in models[:-1]]  # Original line 51. In Python, you have to explicitly convert from numbers to strings with str().
            files.append(path+"/LCCMR/"+ensemble_dir+"/"+scenario+"/IBISinput_all7_ens"+str(decade)+"ymonmean.nc")

            years = range(starting_year, starting_year+n_years)
            files1 = [[path+"/LCCMR/"+model+"/"+scenario+"/allyears_daily/IBISinput_"+str(year)+"_cst_ymonmean.nc" for year in years] for model in models[:-1]]  # Original line 52.

            # print(files)  # I'll keep the original names for variables that exist in the original script.
            # print(files1)

            # The following three lines of code could all be done in one line; I did it this way to make it more readable. Same with the three lines after that.
            files_datasets = [xr.open_dataset(f, chunks={}).assign_coords(Time=range(12)) for f in files]  # Read in the datasets and change the Time coordinates from dates and times (some of which may be incorrect) to months of the year. We do this now because it is much less resource-intensive to concatenate data that aligns — otherwise xarray would expand each year's data to span the whole time period and fill in the other years with NaNs.
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
            # print(temp)  # temp: Monthly data averaged across years for each of the models and the ensemble
            # print(temp1)  # temp1: Monthly (along one dimension) and yearly (along another dimension) data for each of the models (no ensemble)
            # print(temp2)  # temp2: Monthly historical data averaged across years for the ensemble only

            # Dimensions and coordinates are:
            #   Time: An integer ranging from 0 to 11 representing the month (unlike in the original script)
            #   year (only in temp1): An integer representing the year of the data (e.g. 2040)
            #   model (not in temp2): A string representing the model name (e.g. "CNRM-CM5") or "MME" for the ensemble

            # As far as plotting libraries go, there are two strong contenders for this kind of non-cartographic data:
            #   PyNGL — an NCAR project that enables plot construction using a "resource"-based syntax similar to in NCL
            #   matplotlib — this library is very commonly used across various disciplines
            # Here, I'll show both.

            use_PyNGL = False    # Make this True to generate figures using PyNGL, False for matplotlib

            if use_PyNGL:  # Using PyNGL — this whole section is going to be *very* similar to the original:
                wks = Ngl.open_wks("png", "xy_lccmr7_"+var+str(decade)+scenario)  # Original line 125

                res = Ngl.Resources()  # Original line 127
                res.nglDraw = False  # Original line 128
                res.nglFrame = False
                res.nglMaximize = False  # Set to False to mimic the original, which does this by default, but one might want to set this to True

                res.tiMainString = scenario+" "+str(starting_year)+"-"+str(starting_year+n_years-1) # Original line 132
                if var == "T2_biascorrected" or var == "T2":
                    res.trYMinF = -20
                    res.trYMaxF = 40
                elif var == "precip_biascorrected" or var == "precip":
                    res.trYMinF = 0
                    res.trYMaxF = 16
                res.xyLineThicknessF = 3.0
                res.xyMarkerSizes = [0.015, 0.015]

                colors = Ngl.read_colormap_file("GMT_wysiwygcont")
                colors1 = Ngl.read_colormap_file("GMT_gray")

                res.tmXBMode = "Explicit"
                res.tmXBValues = temp["Time"].values  # Unlike in the original, these values are just the integers 0 through 11
                res.tmXBLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                res.tmLabelAutoStride = True
                res.tmYLAutoPrecision = False
                res.tmYLPrecision = 2
                res.tmXBLabelFontHeightF = 0.017
                res.tiXAxisString = "Month"
                res.tmXTOn = False

                res1 = copy.copy(res)  # Original line 196. Because of how Python works, if we did res1=res, then they would point to the same object, so changing res1 would change res.
                res.xyLineColors = colors[0::18]  # Original line 197. As in the original, this actually creates 11 colors.
                res1.xyLineColor = colors1[8]

                res.pmLegendDisplayMode = "Always"
                res.pmLegendSide = "Bottom"

                if var == "precip_biascorrected" or var == "precip":
                    res1.tiYAxisString = var+" mm d~S~-1~N~"
                    res.pmLegendParallelPosF = 0.2
                    res.pmLegendOrthogonalPosF = -1.15  # Had to change this value slightly to get the same effect
                else:
                    res1.tiYAxisString = var+" ~S~o~N~C"
                    res.pmLegendParallelPosF = 0.5
                    res.pmLegendOrthogonalPosF = -0.52

                res2 = copy.copy(res)   # If we create res2 after setting res.lg things, we get warnings about the lg things not being valid resources
                res2.pmLegendDisplayMode = "NoCreate"

                res.pmLegendWidthF = 0.13
                res.pmLegendHeightF = 0.2
                res.lgAutoManage = False    # The reference (https://www.pyngl.ucar.edu/Resources/defaults.shtml) states that this is set to False automatically when lgLabelFontHeightF is set, but I have found that it isn't.
                res.lgLabelFontHeightF = 0.015
                res.lgTitleOn = False
                res.xyExplicitLegendLabels = models[::-1]  # We're reversing this to get the top of the alphabet to appear at the top of the legend, I guess
                res.lgLabelJust = "CenterLeft"  # Not necessary in the original

                res4 = copy.copy(res)   # We want res4 to inherit res's legend settings, not res2's lack thereof
                res4.pmLegendDisplayMode = "Always"
                res4.pmLegendSide = "Top"
                res4.pmLegendParallelPosF = 0.8
                res4.pmLegendOrthogonalPosF = -0.18
                res4.pmLegendHeightF = 0.04
                res4.xyExplicitLegendLabels = ["1980-1999 Obs."]

                res.xyDashPatterns = [x for x in range(17)]  # A direct translation did not produce the same dash patterns. 17 is the maximum number of dash patterns available.
                res4.xyDashPatterns = 11  # Original line 233

                if var == "T2_biascorrected" or var == "T2":  # Unit conversion for temperature
                    ZERO_CELSIUS = 273.15  # A fun way to do this conversion in one line for all three variables would be: temp, temp1, temp2 = map(lambda x: x-273.15, [temp, temp1, temp2])
                    temp -= ZERO_CELSIUS
                    temp1 -= ZERO_CELSIUS
                    temp2 -= ZERO_CELSIUS

                temp1 = temp1.stack(z=("model", "year")).transpose()  # PyNGL requires our arrays to have a maximum of two dimensions, so we stack model and year into one dimension, and it requires this stacked dimension to be leftmost, so we transpose

                plot = Ngl.xy(wks, temp["Time"].values, temp.sel(model=slice(None, None, -1)).values, res)  # Plot of monthly data per model+ensemble, averaged across years (rainbow)
                plot2 = Ngl.xy(wks, temp["Time"].values, temp.sel(model="MME").values, res2)  # Plot of monthly data for just ensemble, averaged across years (black). Also appears in "plot"; presumably plot2 is to get it on top.
                plot1 = Ngl.xy(wks, temp["Time"].values, temp1.values, res1)  # Plot of monthly data per model per year (no ensemble) (gray)
                plot3 = Ngl.xy(wks, temp["Time"].values, temp2.values, res4)  # Plot of monthly data for historical ensemble (black)

                Ngl.overlay(plot1, plot)
                Ngl.overlay(plot1, plot2)
                Ngl.overlay(plot1, plot3)

                Ngl.draw(plot1)
                Ngl.frame(wks)

                Ngl.end()
                # That should produce a plot that is almost exactly the same as in the original. Notable differences:
                #   The tickmarks appear on the inside of the graph instead of the outside; I couldn't figure out how to change this
                #   The positioning of the legends may be slightly different; this can be adjusted

            else:  # Using matplotlib:
                fig, ax = plt.subplots()  # Get a Figure and Axes from matplotlib.pyplot

                temp1 = temp1.stack(z=("model", "year"))

                plot1 = ax.plot(temp["Time"], temp1, color="gray")
                plot = ax.plot(temp["Time"], temp.transpose())
                plot2 = ax.plot(temp["Time"], temp.sel(model="MME"), color="black")
                plot3 = ax.plot(temp["Time"], temp2, "-", color="black")

                leg = ax.legend(plot, temp["model"].values)
                leg2 = ax.legend(plot3, ("1980-1999 Obs.",))
                ax.add_artist(leg)

                fig.savefig("fig.png")


def drop_inconsistent_variables(datasets):  # Drops the variables that do not appear in all datasets
    common_variables = set(datasets[0]).intersection(*datasets)  # Figure out which variables exist in all datasets
    datasets = [d.drop_vars([v for v in d if v not in common_variables]) for d in datasets]  # Remove all variables that only exist in some of the datasets
    return datasets


def ps(s):  # For debugging, prints and sleeps
    print(s)
    time.sleep(1)


if __name__ == "__main__":
    main()
