;  Written by Gabriel Konar-Steenberg in the summer of 2019.
;  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

; Provides a simple demonstration of the t-test and adjusted t-test
; Plans are to write a Python version of this and make sure the output is the same

begin
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  ;Things in here seem to be automatically loaded now
function count(series)
local series
begin
return num(.not.ismissing(series))
end

function adjusted_dof(series)
local series
begin
autocorr_array = esacr(series, 1)
autocorr = autocorr_array(1)
n = count(series)
return n*(1-autocorr)/(1+autocorr)
end


;Two one-dimensional arrays (backslashes are line continuation) of autocorrelated data with a difference of about 1
sample_1 = (/10.3, 11.1, 12.4, 13.1, 14.5, 15.9, 16.2, 15.6, 14.5, 13.3, 12.5, 11.8, \
             10.2, 11.7, 12.1, 13.8, 14.2, 15.8, 16.1, 15.8, 14.2, 13.8, 12.4, 11.5/)
sample_2 = (/11.1, 12.6, 13.1, 14.8, 15.0, 16.3, 17.3, 16.9, 15.8, 14.8, 13.7, 12.4, \
             11.1, 12.4, 13.1, 14.4, 15.2, 16.1, 17.3, 16.5, 15.6, 14.2, 13.3, 12.7/)
print("Sample 1:")
print(sample_1)
print("Sample 2:")
print(sample_2)

avg_1 = avg(sample_1)
avg_2 = avg(sample_2)
var_1 = variance(sample_1)
var_2 = variance(sample_2)
n_raw_1 = count(sample_1)
n_raw_2 = count(sample_2)
n_adj_1 = adjusted_dof(sample_1)
n_adj_2 = adjusted_dof(sample_2)
print("Adjusted degrees of freedom")
print((/n_adj_1, n_adj_2/))

ttest_naive = ttest(avg_1, var_1, n_raw_1, avg_2, var_2, n_raw_2, False, False)
ttest_adjusted = ttest(avg_1, var_1, n_adj_1, avg_2, var_2, n_adj_2, False, False)

print("Naive t-test:")
print(ttest_naive)
print("Adjusted t-test:")
print(ttest_adjusted)

;Workaround: deliberately cause a warning to get PyCharm to show NCL output (TODO: find a better way):
unused = addfile("Show me the output!", "please")  ;Remove if you can do so and still get the output of print() to show
exit    ;Another workaround. Remove if you can do so and still get the program to exit
end