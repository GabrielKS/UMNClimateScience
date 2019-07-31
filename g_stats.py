#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# A module containing some helpful statistics methods, including autocorrelation and the adjusted t-test

import numpy as np
import xarray as xr


def esacr_generic(*args, **kwargs):
    if len(args) >= 1: kwargs["data"] = args[0]
    if len(args) >= 2: kwargs["max_lag"] = args[1]
    # print(kwargs)
    # exit()
    esacr(**kwargs)


def esacr(data, max_lag, dim=None, axis=None, method="numpy"):
    # DEALING WITH INPUT FORMATTING
    if dim is not None:
        print(1)
        # We have an xarray DataArray with named dimensions, and we reduce to the NumPy numbered axes case
        return xr.apply_ufunc(esacr_generic, data, input_core_dims=[[dim]],
                              kwargs={"max_lag": max_lag, "axis": -1, "method": method})
    data = np.array(data)  # If it wasn't already a NumPy ndarray, it is now
    if axis is not None:
        print(2)
        # We have a multidimensional array, and we reduce to the one-dimensional case by looping
        if axis < 0: axis = data.ndim + axis
        print("axis"+str(axis))
        return np.apply_along_axis(esacr_generic, axis, data, max_lag=max_lag, method=method)
    if data.ndim > 1:
        print(3)
        # We have a multidimensional array, and we reduce to the one-dimensional case by flattening
        return esacr(data.flatten())
    if data.ndim == 0:
        print(4)
        # We have a zero-dimensional array, and we reduce to the one-dimensional array by wrapping
        return esacr(np.array([data]))
    print(5)
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
        return np.corrcoef(data[:len(data) - max_lag], data[max_lag:])[0]
    else:
        return None


def main():
    pass


if __name__ == "__main__":
    main()
