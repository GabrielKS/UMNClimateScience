#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# A module containing some helpful statistics methods, including autocorrelation and the adjusted t-test

import numpy as np
import xarray as xr
import time


# Calculates the adjusted sample size accounting for the lag-<lag> autocorrelation
# Collapses dim/axis, iterates over all other dimensions/axes
def adjusted_n(data, dim=None, axis=None, lag=1, method="numpy", filterna=True):
    naive_n = data.count(dim=dim) if dim is not None else data.count(axis=axis)
    autocorr = esacr(data, lag, dim, axis, method)[..., lag]
    return naive_n * (1 - autocorr) / (1 + autocorr)


# Helper function for esacr
def esacr_generic(*args, **kwargs):
    if len(args) >= 1: kwargs["data"] = args[0]
    if len(args) >= 2: kwargs["max_lag"] = args[1]
    return esacr(**kwargs)


# Estimated autocorrelation, a la NCL.
# If method=numpy, then we simply use NumPy's algorithm to calculate the correlation coefficient between two copies of
# the input data offset by the lag in each direction, meaning we end up using the mean and variance of these subsets. If
# method=ncl, then we try to mirror NCL's method as closely as possible, using the mean and variance of the whole
# dataset. As long as the dataset is large and the lag small, the difference should be negligible (it seems like, for
# "nice" datasets, the difference should go to 0 as the ratio data_size/max_lag goes to infinity).
def esacr(data, max_lag, dim=None, axis=None, method="numpy"):
    assert method == "numpy" or method == "ncl"
    # DEALING WITH INPUT FORMATTING
    if dim is not None:
        # We have an xarray DataArray with named dimensions, and we reduce to the NumPy numbered axes case
        # Tried to use apply_ufunc; couldn't figure out how to get it to accept array results for each array input

        # Reorder the dimensions so the one we're messing with is on the end
        inactive_dims = list(data.dims)
        inactive_dims.remove(dim)
        reordered_dims = inactive_dims.copy()
        reordered_dims.append(dim)
        data = data.transpose(*reordered_dims)

        # Do the computation in NumPy form
        result = esacr(data.values, max_lag, None, len(data.dims) - 1, method)

        # Convert back to xarray
        new_dims = inactive_dims.copy()
        new_dims.append("esacr")
        result = xr.DataArray(result, dims=new_dims)
        return result
        # return xr.apply_ufunc(esacr_generic, data, input_core_dims=[[dim]],
        #                       kwargs={"max_lag": max_lag, "axis": -1, "method": method})
    data = np.array(data)  # If it wasn't already a NumPy ndarray, it is now
    if axis is not None:
        # We have a multidimensional array, and we reduce to the one-dimensional case by looping
        if axis < 0: axis = data.ndim + axis
        return np.apply_along_axis(esacr_generic, axis, data, max_lag=max_lag, method=method)
    if data.ndim > 1:
        # We have a multidimensional array, and we reduce to the one-dimensional case by flattening
        return esacr(data.flatten(), max_lag)
    if data.ndim == 0:
        # We have a zero-dimensional array, and we reduce to the one-dimensional array by wrapping
        return esacr(np.array([data]), max_lag)
    assert isinstance(data, np.ndarray), "Internal conversion to NumPy ndarray failed"
    assert data.ndim == 1, "Internal reduction to one dimension failed"

    # ACTUAL ALGORITHMS (for a one-dimensional ndarray)
    if method == "ncl":
        # Built to mirror the NCL code exactly. And yet it still differs very slightly in output.
        # TODO: figure out why.
        # If this is actually used for large datasets, some work should go into optimization.
        avg = data.mean()
        var = data.var()
        results = []
        for k in range(max_lag + 1):  # Loop over the lags, from lag-0 to lag-mxlag
            result = 0
            for t in range(len(data) - k):  # Loop over all lag pairs in the input data
                result += (data[t] - avg) * (data[t + k] - avg)
            result /= len(data) - k  # Divide the sum to get the average
            result /= var
            results.append(result)
        return results
    if method == "numpy":
        r = np.corrcoef(data[:len(data) - max_lag], data[max_lag:])[0]
        return r
    else:
        return None


def main():
    pass


if __name__ == "__main__":
    main()
