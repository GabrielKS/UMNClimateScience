;/Users/konar008/Desktop/resultsFunctionsRewritten.ncl
begin
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
err = NhlGetErrorObjectId()

NLAT = 100
NLON = 130
NTIME = 7305	;365*15+366*5

outputFilename = "/Users/konar008/Desktop/IntermediateData/results.nc"
basePath = "/Users/twine/IBIS_INPUT/LCCMR"
baseFilename = "IBISinput"
fileExtension = "nc"
gcm = "CNRM-CM5"
years = 20
pathway = "historic"

procedure toggleErrors(suppress)
local suppress
begin
if suppress
	print(" - suppressing errors - ")
	setvalues err
	"errPrint": "False"
	end setvalues
else
	print(" - allowing errors - ")
	setvalues err
	"errPrint": "True"
	end setvalues
end if
end

function getFiles(basePath, baseFilename, fileExtension, gcm, pathway, year0, years)
local basePath, baseFilename, fileExtension, gcm, pathway, year0, years, path
begin
path = str_concat((/basePath, "/", gcm, "_", pathway, "_", tostring(year0), "-", tostring(year0+years-1)/))
filenames = new(years, string)
do i = 0, years-1
	filenames(i) = str_concat((/path, "/", baseFilename, "_", tostring(year0+i), ".", fileExtension/))
end do
files = addfiles(filenames, "r")
return files
end

function getData(files, precip) ;combine temperature extremes and precip from each of the 20 files into one dataset
local files, precip, t, i
begin
if precip
t = new((/1, NTIME, NLAT, NLON/), float, 9e20)
else
t = new((/2, NTIME, NLAT, NLON/), float, 9e20)
end if
i = 0
do year = 0, years-1
	print("year"+tostring(year))
	days = 365
	if isleapyear(year)
		days = days+1
	end if
	do day = 0, days-1
		if precip
		t(0, i, :, :) = files[year]->prec(day, 0, :, :)
		else
		t(0, i, :, :) = files[year]->tmin(day, 0, :, :)
		t(1, i, :, :) = files[year]->tmax(day, 0, :, :)
		end if
		i = i+1
	end do
end do
return t
end

function getTAvg(data)
local data
begin
return (data(:, 0, :, :, :)+data(:, 1, :, :, :))/2
end

function getDTR(data)
local data
begin
return data(:, 1, :, :, :)-data(:, 0, :, :, :)
end

procedure setFillMissing(data)
local data
begin
data@_FillValue = 9e20
data@missing_value = 9e20
end

procedure setMetadata(data, lat, lon)
local data
begin
data!0 = "variable"
data!1 = "lat"
data!2 = "lon"
data&lat = lat
data&lon = lon
setFillMissing(data)
end

function logicalToInt(input)
local input
begin
return dim_num_n((/input, input/), 0)/2	;Hacky but it gets the job done. TODO find a more elegant way of doing this.
end

procedure filterByDomain(domainLogical, data)
local lat, lon, missingCell, domainLogical
begin
missingCell = new(7305, float, 9e20)
do lat = 0, NLAT-1
	do lon = 0, NLON-1
		if .not.domainLogical(lat, lon)
			data(0, 0, :, lat, lon) = missingCell
			data(0, 1, :, lat, lon) = missingCell
			data(1, 0, :, lat, lon) = missingCell
			data(1, 1, :, lat, lon) = missingCell
			data(2, 0, :, lat, lon) = missingCell
			data(2, 1, :, lat, lon) = missingCell
			data(3, 0, :, lat, lon) = missingCell
			data(3, 1, :, lat, lon) = missingCell
		end if
	end do
end do
end

function maxStdev(data)
local data
begin
maxs = dim_max_n(data, 0)-dim_avg_n(data, 0)
stdevs = dim_stddev_n(data, 0)
return maxs/stdevs
end

function minStdev(data)
local data
begin
mins = dim_min_n(data, 0)-dim_avg_n(data, 0)
stdevs = dim_stddev_n(data, 0)
;print(stdevs)
return -mins/stdevs
end

procedure filterMin(data, minVal)
local data, minVal
begin
dims = dimsizes(data)
do i = 0, dims(0)-1
	if ismissing(data(i)).or.data(i).lt.minVal
		data(i) = 9e20
	end if
end do
end

procedure filterMax(data, maxVal)
local data, maxVal
begin
dims = dimsizes(data)
do i = 0, dims(0)-1
	if ismissing(data(i)).or.data(i).gt.maxVal
		data(i) = 9e20
	end if
end do
end

procedure filterMinStdev(data, minStdev)
local data, minStdev, mean, stdev, minVal
begin
mean = avg(data)
stdev = stddev(data)
minVal = mean-stdev*minStdev
;print(mean)
;print(stdev)
;print(minStdev)
;print(minVal)
filterMin(data, minVal)
end

procedure filterMaxStdev(data, maxStdev)
local data, maxStdev, mean, stdev, maxVal
begin
mean = avg(data)
stdev = stddev(data)
maxVal = mean+stdev*maxStdev
filterMin(data, maxVal)
end

procedure filterByThreshold(domainLogical, data_0, data_1_45, data_2_45, data_2_85, mins, maxs)
local lat, lon, missingCell
begin
do lat = 0, NLAT-1
	print(str_concat((/"lat", tostring(lat)/)))
	do lon = 0, NLON-1
		if domainLogical(lat, lon)
			filterMinStdev(data_1_45(0, :, lat, lon), mins(lat, lon))
			filterMaxStdev(data_1_45(1, :, lat, lon), maxs(lat, lon))
			filterMinStdev(data_2_45(0, :, lat, lon), mins(lat, lon))
			filterMaxStdev(data_2_45(1, :, lat, lon), maxs(lat, lon))
		end if
	end do
end do
end

function dof(data)
local data, reordered
begin
data!0 = "time"
data!1 = "lat"
data!2 = "lon"
reordered = data(lat|:, lon|:, time|:)
;print(reordered)
autoCorrArr = esacr(reordered, 1)
autoCorr = autoCorrArr(:, :, 1)
;print(autoCorr)
n = dim_num_n(.not.ismissing(data), 0)-1
newN = n*(1-autoCorr)/(1+autoCorr)
return newN
end

print("loaded")
end


;t_0
;t_1_45
;t_2_45
;t_2_85
;dtr_0
;dtr_1_45
;dtr_2_45
;dtr_2_85

;avg_t
;avg_dtr
;n_t
;n_dtr
;p_t
;p_dtr
;t_t
;t_dtr