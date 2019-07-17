;/Users/konar008/Desktop/resultsScriptRewritten.ncl
load "/Users/konar008/Desktop/resultsFunctionsRewritten.ncl"
print("ready")
procedure runResultsScript(gcm, basic, extrema, precip)
begin
print("beginning")

NLAT = 100
NLON = 130
NTIME = 7305	;365*15+366*5

filenameSuffix = ""
if basic
filenameSuffix = filenameSuffix+"basic"
end if
if extrema
filenameSuffix = filenameSuffix+"extrema"
end if
if precip
filenameSuffix = filenameSuffix+"precip"
end if

outputFilename = str_concat((/"/Users/konar008/Desktop/IntermediateData/", gcm, "_results_", filenameSuffix, ".nc"/))
logFilename = str_concat((/"/Users/konar008/Desktop/IntermediateData/", gcm, "_log_", filenameSuffix, ".nc"/))
basePath = "/Users/twine/IBIS_INPUT/LCCMR"
baseFilename = "IBISinput"
fileExtension = "nc"
;gcm = "CNRM-CM5"
years = 20
pathway = "historic"
logFile = addfile(logFilename, "c")

print("reading files")
files_0 = getFiles(basePath, baseFilename, fileExtension, gcm, "historic", 1980, years)
files_1_45 = getFiles(basePath, baseFilename, fileExtension, gcm, "RCP4.5", 2040, years)
files_2_45 = getFiles(basePath, baseFilename, fileExtension, gcm, "RCP4.5", 2080, years)
files_2_85 = getFiles(basePath, baseFilename, fileExtension, gcm, "RCP8.5", 2080, years)

print("lat/lon")
lat = files_0[0]->lat
lon = files_0[0]->lon
setFillMissing(lat)
setFillMissing(lon)
print(lat@_FillValue)
lon@units = "degrees_east"	;The values were already negative and thus in degrees east, but they were labeled as degrees west.

print("getData")
;toggleErrors(True)
data = (/getData(files_0, precip), getData(files_1_45, precip), getData(files_2_45, precip), getData(files_2_85, precip)/)
;toggleErrors(False)
print("done getting data")

print("finding valid grid cells")
if precip
domainLogical = (dim_num_n(ismissing(data(0, 0, :, :, :)), 0)+dim_num_n(ismissing(data(1, 0, :, :, :)), 0)+dim_num_n(ismissing(data(2, 0, :, :, :)), 0)+dim_num_n(ismissing(data(3, 0, :, :, :)), 0)).eq.0
else
domainLogical = (dim_num_n(ismissing(data(0, 0, :, :, :)), 0)+dim_num_n(ismissing(data(0, 1, :, :, :)), 0)+dim_num_n(ismissing(data(1, 0, :, :, :)), 0)+dim_num_n(ismissing(data(1, 1, :, :, :)), 0)+dim_num_n(ismissing(data(2, 0, :, :, :)), 0)+dim_num_n(ismissing(data(2, 1, :, :, :)), 0)+dim_num_n(ismissing(data(3, 0, :, :, :)), 0)+dim_num_n(ismissing(data(3, 1, :, :, :)), 0)).eq.0
end if
domainInt = logicalToInt(domainLogical)

if .not.precip
print("SKIPPING filtering by domain")
;filterByDomain(domainLogical, data)
end if

;print("logging stdevs")
;stdevs_min = dim_stddev_n(data(:, 0, :, :, :), 1)
;stdevs_max = dim_stddev_n(data(:, 1, :, :, :), 1)
;setFillMissing(stdevs_min)
;setFillMissing(stdevs_max)
;logFile->stdevs_min = stdevs_min
;logFile->stdevs_max = stdevs_max

if basic
print("TAvg")
t = getTAvg(data)

print("DTR")
dtr = getDTR(data)
end if

if extrema
print("extrema")
minofmin = dim_min_n(data(:, 0, :, :, :), 1)
minofmax = dim_min_n(data(:, 1, :, :, :), 1)
maxofmin = dim_max_n(data(:, 0, :, :, :), 1)
maxofmax = dim_max_n(data(:, 1, :, :, :), 1)
end if
if precip
minofprecip = dim_min_n(data(:, 0, :, :, :), 1)
maxofprecip = dim_max_n(data(:, 0, :, :, :), 1)
end if


;Yeah, I know, the following could all be done more elegantly with arrays and loops....
print("averages")
if basic
avg_t = dim_avg_n_Wrap(t, 1)
avg_dtr = dim_avg_n_Wrap(dtr, 1)
end if
if extrema
avg_min = dim_avg_n_Wrap(data(:, 0, :, :, :), 1)
avg_max = dim_avg_n_Wrap(data(:, 1, :, :, :), 1)
end if
if precip
avg_precip = dim_avg_n_Wrap(data(:, 0, :, :, :), 1)
end if

print("variances")
if basic
var_t = dim_variance_n_Wrap(t, 1)
var_dtr = dim_variance_n_Wrap(dtr, 1)
end if
if extrema
var_min = dim_variance_n_Wrap(data(:, 0, :, :, :), 1)
var_max = dim_variance_n_Wrap(data(:, 1, :, :, :), 1)
end if
if precip
var_precip = dim_variance_n_Wrap(data(:, 0, :, :, :), 1)
end if

print("Ns")
if basic
n_t = tofloat(dim_num_n(.not.ismissing(t), 1))
n_dtr = tofloat(dim_num_n(.not.ismissing(dtr), 1))
end if
if extrema
n_min = tofloat(dim_num_n(.not.ismissing(data(:, 0, :, :, :)), 1))
n_max = tofloat(dim_num_n(.not.ismissing(data(:, 1, :, :, :)), 1))
end if
if precip
n_precip = tofloat(dim_num_n(.not.ismissing(data(:, 0, :, :, :)), 1))
end if

print("Ns_adj")
if basic
n_t_adj = (/dof(t(0, :, :, :)), dof(t(1, :, :, :)), dof(t(2, :, :, :)), dof(t(3, :, :, :))/)
n_dtr_adj = (/dof(dtr(0, :, :, :)), dof(dtr(1, :, :, :)), dof(dtr(2, :, :, :)), dof(dtr(3, :, :, :))/)
end if
if extrema
n_min_adj = (/dof(data(0, 0, :, :, :)), dof(data(1, 0, :, :, :)), dof(data(2, 0, :, :, :)), dof(data(3, 0, :, :, :))/)
n_max_adj = (/dof(data(0, 1, :, :, :)), dof(data(1, 1, :, :, :)), dof(data(2, 1, :, :, :)), dof(data(3, 1, :, :, :))/)
end if
if precip
n_precip_adj = (/dof(data(0, 0, :, :, :)), dof(data(1, 0, :, :, :)), dof(data(2, 0, :, :, :)), dof(data(3, 0, :, :, :))/)
end if

print("NOT logging Ns")
if basic
setFillMissing(n_t)
setFillMissing(n_dtr)
setFillMissing(n_t_adj)
setFillMissing(n_dtr_adj)
end if
if extrema
setFillMissing(n_min)
setFillMissing(n_max)
setFillMissing(n_min_adj)
setFillMissing(n_max_adj)
end if
if precip
setFillMissing(n_precip)
setFillMissing(n_precip_adj)
end if

;logFile->n_t = n_t
;logFile->n_dtr = n_dtr
;logFile->n_min = n_min
;logFile->n_max = n_max
;logFile->n_precip = n_precip
;logFile->n_t_adj = n_t_adj
;logFile->n_dtr_adj = n_dtr_adj
;logFile->n_min = n_min
;logFile->n_max = n_max
;logFile->n_precip = n_precip

print("t-tests")
if basic
ttest_t_1_45 = ttest(avg_t(0, :, :), var_t(0, :, :), n_t_adj(0, :, :), avg_t(1, :, :), var_t(1, :, :), n_t_adj(1, :, :), False, True)
ttest_t_2_45 = ttest(avg_t(0, :, :), var_t(0, :, :), n_t_adj(0, :, :), avg_t(2, :, :), var_t(2, :, :), n_t_adj(2, :, :), False, True)
ttest_t_2_85 = ttest(avg_t(0, :, :), var_t(0, :, :), n_t_adj(0, :, :), avg_t(3, :, :), var_t(3, :, :), n_t_adj(3, :, :), False, True)
ttest_dtr_1_45 = ttest(avg_dtr(0, :, :), var_dtr(0, :, :), n_dtr_adj(0, :, :), avg_dtr(1, :, :), var_dtr(1, :, :), n_dtr_adj(1, :, :), False, True)
ttest_dtr_2_45 = ttest(avg_dtr(0, :, :), var_dtr(0, :, :), n_dtr_adj(0, :, :), avg_dtr(2, :, :), var_dtr(2, :, :), n_dtr_adj(2, :, :), False, True)
ttest_dtr_2_85 = ttest(avg_dtr(0, :, :), var_dtr(0, :, :), n_dtr_adj(0, :, :), avg_dtr(3, :, :), var_dtr(3, :, :), n_dtr_adj(3, :, :), False, True)
end if
if extrema
ttest_min_1_45 = ttest(avg_min(0, :, :), var_min(0, :, :), n_min_adj(0, :, :), avg_min(1, :, :), var_min(1, :, :), n_min_adj(1, :, :), False, True)
ttest_min_2_45 = ttest(avg_min(0, :, :), var_min(0, :, :), n_min_adj(0, :, :), avg_min(2, :, :), var_min(2, :, :), n_min_adj(2, :, :), False, True)
ttest_min_2_85 = ttest(avg_min(0, :, :), var_min(0, :, :), n_min_adj(0, :, :), avg_min(3, :, :), var_min(3, :, :), n_min_adj(3, :, :), False, True)
ttest_max_1_45 = ttest(avg_max(0, :, :), var_max(0, :, :), n_max_adj(0, :, :), avg_max(1, :, :), var_max(1, :, :), n_max_adj(1, :, :), False, True)
ttest_max_2_45 = ttest(avg_max(0, :, :), var_max(0, :, :), n_max_adj(0, :, :), avg_max(2, :, :), var_max(2, :, :), n_max_adj(2, :, :), False, True)
ttest_max_2_85 = ttest(avg_max(0, :, :), var_max(0, :, :), n_max_adj(0, :, :), avg_max(3, :, :), var_max(3, :, :), n_max_adj(3, :, :), False, True)
end if
if precip
ttest_precip_1_45 = ttest(avg_precip(0, :, :), var_precip(0, :, :), n_precip_adj(0, :, :), avg_precip(1, :, :), var_precip(1, :, :), n_precip_adj(1, :, :), False, True)
ttest_precip_2_45 = ttest(avg_precip(0, :, :), var_precip(0, :, :), n_precip_adj(0, :, :), avg_precip(2, :, :), var_precip(2, :, :), n_precip_adj(2, :, :), False, True)
ttest_precip_2_85 = ttest(avg_precip(0, :, :), var_precip(0, :, :), n_precip_adj(0, :, :), avg_precip(3, :, :), var_precip(3, :, :), n_precip_adj(3, :, :), False, True)
end if

print("diffs")
if basic
diff_t_1_45 = avg_t(1, :, :)-avg_t(0, :, :)
diff_t_2_45 = avg_t(2, :, :)-avg_t(0, :, :)
diff_t_2_85 = avg_t(3, :, :)-avg_t(0, :, :)
diff_dtr_1_45 = avg_dtr(1, :, :)-avg_dtr(0, :, :)
diff_dtr_2_45 = avg_dtr(2, :, :)-avg_dtr(0, :, :)
diff_dtr_2_85 = avg_dtr(3, :, :)-avg_dtr(0, :, :)
end if
if extrema
diff_min_1_45 = avg_min(1, :, :)-avg_min(0, :, :)
diff_min_2_45 = avg_min(2, :, :)-avg_min(0, :, :)
diff_min_2_85 = avg_min(3, :, :)-avg_min(0, :, :)
diff_max_1_45 = avg_max(1, :, :)-avg_max(0, :, :)
diff_max_2_45 = avg_max(2, :, :)-avg_max(0, :, :)
diff_max_2_85 = avg_max(3, :, :)-avg_max(0, :, :)
end if
if precip
diff_precip_1_45 = avg_precip(1, :, :)-avg_precip(0, :, :)
diff_precip_2_45 = avg_precip(2, :, :)-avg_precip(0, :, :)
diff_precip_2_85 = avg_precip(3, :, :)-avg_precip(0, :, :)
end if

print("collating")
if basic
p_t = (/new((/NLAT, NLON/), float, 9e20), ttest_t_1_45(0, :, :), ttest_t_2_45(0, :, :), ttest_t_2_85(0, :, :)/)
t_t = (/new((/NLAT, NLON/), float, 9e20), ttest_t_1_45(1, :, :), ttest_t_2_45(1, :, :), ttest_t_2_85(1, :, :)/)
diff_t = (/new((/NLAT, NLON/), float, 9e20), diff_t_1_45, diff_t_2_45, diff_t_2_85/)
p_dtr = (/new((/NLAT, NLON/), float, 9e20), ttest_dtr_1_45(0, :, :), ttest_dtr_2_45(0, :, :), ttest_dtr_2_85(0, :, :)/)
t_dtr = (/new((/NLAT, NLON/), float, 9e20), ttest_dtr_1_45(1, :, :), ttest_dtr_2_45(1, :, :), ttest_dtr_2_85(1, :, :)/)
diff_dtr = (/new((/NLAT, NLON/), float, 9e20), diff_dtr_1_45, diff_dtr_2_45, diff_dtr_2_85/)
end if
if extrema
p_min = (/new((/NLAT, NLON/), float, 9e20), ttest_min_1_45(0, :, :), ttest_min_2_45(0, :, :), ttest_min_2_85(0, :, :)/)
t_min = (/new((/NLAT, NLON/), float, 9e20), ttest_min_1_45(1, :, :), ttest_min_2_45(1, :, :), ttest_min_2_85(1, :, :)/)
diff_min = (/new((/NLAT, NLON/), float, 9e20), diff_min_1_45, diff_min_2_45, diff_min_2_85/)
p_max = (/new((/NLAT, NLON/), float, 9e20), ttest_max_1_45(0, :, :), ttest_max_2_45(0, :, :), ttest_max_2_85(0, :, :)/)
t_max = (/new((/NLAT, NLON/), float, 9e20), ttest_max_1_45(1, :, :), ttest_max_2_45(1, :, :), ttest_max_2_85(1, :, :)/)
diff_max = (/new((/NLAT, NLON/), float, 9e20), diff_max_1_45, diff_max_2_45, diff_max_2_85/)
end if
if precip
p_precip = (/new((/NLAT, NLON/), float, 9e20), ttest_precip_1_45(0, :, :), ttest_precip_2_45(0, :, :), ttest_precip_2_85(0, :, :)/)
t_precip = (/new((/NLAT, NLON/), float, 9e20), ttest_precip_1_45(1, :, :), ttest_precip_2_45(1, :, :), ttest_precip_2_85(1, :, :)/)
diff_precip = (/new((/NLAT, NLON/), float, 9e20), diff_precip_1_45, diff_precip_2_45, diff_precip_2_85/)
end if

print("metadata")
domainInt!0 = "lat"
domainInt!1 = "lon"
domainInt&lat = lat
domainInt&lon = lon
if basic
setMetadata(avg_t, lat, lon)
setMetadata(avg_dtr, lat, lon)
setMetadata(n_t, lat, lon)
setMetadata(n_dtr, lat, lon)
setMetadata(p_t, lat, lon)
setMetadata(p_dtr, lat, lon)
setMetadata(t_t, lat, lon)
setMetadata(t_dtr, lat, lon)
setMetadata(diff_t, lat, lon)
setMetadata(diff_dtr, lat, lon)
end if
if extrema
setMetadata(avg_max, lat, lon)
setMetadata(avg_min, lat, lon)
setMetadata(n_max, lat, lon)
setMetadata(n_min, lat, lon)
setMetadata(p_max, lat, lon)
setMetadata(p_min, lat, lon)
setMetadata(t_max, lat, lon)
setMetadata(t_min, lat, lon)
setMetadata(diff_max, lat, lon)
setMetadata(diff_min, lat, lon)
setMetadata(minofmin, lat, lon)
setMetadata(minofmax, lat, lon)
setMetadata(maxofmin, lat, lon)
setMetadata(maxofmax, lat, lon)
end if
if precip
setMetadata(avg_precip, lat, lon)
setMetadata(n_precip, lat, lon)
setMetadata(p_precip, lat, lon)
setMetadata(t_precip, lat, lon)
setMetadata(diff_precip, lat, lon)
setMetadata(minofprecip, lat, lon)
setMetadata(maxofprecip, lat, lon)
end if

print("outputting")
outputFile = addfile(outputFilename, "c")

outputFile->domain = domainInt
outputFile->lat = lat
outputFile->lon = lon
if basic
outputFile->avg_t = avg_t
outputFile->avg_dtr = avg_dtr
outputFile->n_t = n_t
outputFile->n_dtr = n_dtr
outputFile->p_t = p_t
outputFile->p_dtr = p_dtr
outputFile->t_t = t_t
outputFile->t_dtr = t_dtr
outputFile->diff_t = diff_t
outputFile->diff_dtr = diff_dtr
end if
if extrema
outputFile->avg_max = avg_max
outputFile->avg_min = avg_min
outputFile->n_max = n_max
outputFile->n_min = n_min
outputFile->p_max = p_max
outputFile->p_min = p_min
outputFile->t_max = t_max
outputFile->t_min = t_min
outputFile->diff_max = diff_max
outputFile->diff_min = diff_min
outputFile->minofmin = minofmin
outputFile->minofmax = minofmax
outputFile->maxofmin = maxofmin
outputFile->maxofmax = maxofmax
end if
if precip
outputFile->avg_precip = avg_precip
outputFile->n_precip = n_precip
outputFile->p_precip = p_precip
outputFile->t_precip = t_precip
outputFile->diff_precip = diff_precip
outputFile->minofprecip = minofprecip
outputFile->maxofprecip = maxofprecip
end if

print("done")
end

	;Old:
;t_0
;t_1_45
;t_2_45
;t_2_85
;dtr_0
;dtr_1_45
;dtr_2_45
;dtr_2_85

	;Originals:
;avg_t
;avg_dtr
;n_t
;n_dtr
;p_t
;p_dtr
;t_t
;t_dtr
;diff_t
;diff_dtr
	;Maxs and mins:
;avg_max
;avg_min
;n_max
;n_min
;p_max
;p_min
;t_max
;t_min
;diff_max
;diff_min
	;Precipitation:
;avg_precip
;n_precip
;p_precip
;t_precip
;diff_precip
	;Test for reasonability:
;minofmin
;minofmax
;minofprecip
;maxofmin
;maxofmax
;maxofprecip