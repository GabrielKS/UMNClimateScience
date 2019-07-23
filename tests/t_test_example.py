#  Written by Gabriel Konar-Steenberg in the summer of 2019.
#  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

# Provides a demonstration of the t-test and adjusted t-test
# Meant to be parallel to the one in NCL at t_test_example.ncl
# As far as I can tell, the methods are now exactly the same, but the numbers still come out slightly different.
# TODO: figure out why

import numpy as np
import pandas as pd
import scipy.stats


def count(series):
    return np.count_nonzero(~np.isnan(series))


# Meant to be an exact replica of https://www.ncl.ucar.edu/Document/Functions/Built-in/esacr.shtml
# Sources: the above page and https://archive.org/details/ChatfieldC.TimeSeriesForecasting/page/n33
# Currently matches the NCL version to about a thousandth. Not sure where the tiny difference is coming from.
# Currently untested with multidimensional input
def esacr(x, mxlag):
    avg = x.mean()
    var = x.var()
    results = []
    for k in range(mxlag + 1):  # Loop over the lags, from lag-0 to lag-mxlag
        result = 0
        for t in range(len(x) - k):  # Loop over all lag pairs in the input data
            result += (x[t] - avg) * (x[t + k] - avg)
        result /= len(x) - k  # Divide the sum to get the average
        result /= var
        results.append(result)
    return results

    # Instead of dividing by the variance of x above, as NCL does, we could follow Chatfield and normalize by dividing
    # everything by the lag-0 result (which should always come out as 1).
    # These are mathematically and practically equivalent.
    # results_normalized = []
    # for i in range(len(results)):
    #     results_normalized.append(results[i] / results[0])
    # return results_normalized


# I took esacr and made some modifications to make it equivalent to the Pandas and NumPy methods.
# This reveals that Pandas and Numpy use the mean and variance/standard deviation of the subsets ([0:n-k] and [k:n])
# whereas NCL follows Chatfield's recommendation to use the mean and variance/standard deviation of the entire input
def naive_acr(x, mxlag):
    results = []
    for k in range(mxlag + 1):  # Loop over the lags, from lag-0 to lag-mxlag
        result = 0
        avg1 = x[:len(x) - k].mean()
        avg2 = x[k:].mean()
        std1 = x[:len(x) - k].std()
        std2 = x[k:].std()
        var = std1 * std2
        for t in range(len(x) - k):  # Loop over all lag pairs in the input data
            result += (x[t] - avg1) * (x[t + k] - avg2) / var
        result /= len(x) - k  # Divide the sum to get the average
        results.append(result)
    return results


def adjusted_dof(series):
    # In NCL, the autocorrelation coefficients are: Sample 1: 0.7796; Sample 2: 0.7816
    # Using Pandas:
    # autocorr = pd.Series(series).autocorr(lag=1)  # Sample 1: 0.8156; Sample 2: 0.8200
    # Using NumPy (see https://stackoverflow.com/questions/643699/how-can-i-use-numpy-correlate-to-do-autocorrelation):
    # autocorr = np.corrcoef(series[:-1], series[1:])[0, 1]  # Sample 1: 0.8156; Sample 2: 0.8200
    # Reimplementing esacr myself:
    autocorr = esacr(series, 1)[1]  # Sample 1: 0.7781; Sample 2: 0.7801
    print("Autocorrelation: " + str(autocorr))
    n = count(series)
    return n * (1 - autocorr) / (1 + autocorr)


def main():
    # Two one-dimensional Numpy arrays (newlines can be ignored) of autocorrelated data with a difference of about 1
    sample_1 = np.array([10.3, 11.1, 12.4, 13.1, 14.5, 15.9, 16.2, 15.6, 14.5, 13.3, 12.5, 11.8,
                         10.2, 11.7, 12.1, 13.8, 14.2, 15.8, 16.1, 15.8, 14.2, 13.8, 12.4, 11.5])
    sample_2 = np.array([11.1, 12.6, 13.1, 14.8, 15.0, 16.3, 17.3, 16.9, 15.8, 14.8, 13.7, 12.4,
                         11.1, 12.4, 13.1, 14.4, 15.2, 16.1, 17.3, 16.5, 15.6, 14.2, 13.3, 12.7])
    print("Sample 1:")
    print(sample_1)
    print("Sample 2:")
    print(sample_2)

    avg_1 = sample_1.mean()
    avg_2 = sample_2.mean()
    std_1 = sample_1.std()  # For the SciPy t-test we use standard deviations, not variances
    std_2 = sample_2.std()
    n_raw_1 = count(sample_1)
    n_raw_2 = count(sample_2)
    n_adj_1 = adjusted_dof(sample_1)
    n_adj_2 = adjusted_dof(sample_2)
    print("Adjusted degrees of freedom: " + str([n_adj_1, n_adj_2]))

    # noinspection PyUnresolvedReferences
    ttest_naive = scipy.stats.ttest_ind_from_stats(avg_1, std_1, n_raw_1, avg_2, std_2, n_raw_2).pvalue
    # noinspection PyUnresolvedReferences
    ttest_adjusted = scipy.stats.ttest_ind_from_stats(avg_1, std_1, n_adj_1, avg_2, std_2, n_adj_2).pvalue

    print("Naive t-test: " + str(ttest_naive))
    print("Adjusted t-test: " + str(ttest_adjusted))


if __name__ == "__main__":
    main()
