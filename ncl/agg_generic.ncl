;  Modified by Gabriel Konar-Steenberg in the summer of 2019 from a previous file, agg_4.5_2040-2059_currentcover_aet.ncl.
;  Credit for that file: TET & PKS, 09/17/01 / tetwine@students.wisc.edu / pksnyder@students.wisc.edu.
;  Now part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

;  Takes natural vegetation, corn, and soy model runs and uses a land use map to compute a weighted average of the
;  given input variable across these model runs, then saves this averaged dataset to the given output path.
;  Note: This is a procedure, not a standalone program, so it must be called with parameters from some other NCL code.
;  Example call for the "snod" (snow depth) variable:
;   agg_generic("/path/to/natveg/snod.nc", "/path/to/corn/snod.nc", "/path/to/soy/snod.nc", "/path/to/landuse_map.nc", "snod", "/path/to/desired_output/snod.nc")


procedure agg_generic(natveg_filename, corn_filename, soy_filename, landuse_filename, varname, output_filename)
local natveg_filename, corn_filename, soy_filename, landuse_filename, variable_name, output_filename
begin
;----------------------------------------------------------------------------
; Open files and define parameters
;----------------------------------------------------------------------------
fh1 = addfile(natveg_filename, "r");
natveg = fh1->$varname(180:,:,:);

fh2 = addfile(corn_filename, "r");
corn = fh2->$varname(180:,:,:)

fh3 = addfile(soy_filename, "r");
soy = fh3->$varname(180:,:,:)

fh4 = addfile(landuse_filename, "r");
fsoy     = fh4->fsoy(:,:)
fcorn    = fh4->fcorn(:,:)
fcornsoy = fh4->fcornsoy(:,:)


NLAT= 100 ; dimension of latitude
NLON= 130; dimension of longitude
NMON = 240
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Open new file to write out the $varname data
;----------------------------------------------------------------------------
outfile = addfile(output_filename, "c");
;----------------------------------------------------------------------------


output = new((/ NMON,NLAT,NLON /), float, 9e20);
printVarSummary(output)
printVarSummary(natveg)
output = natveg(:,:,:)

do lon=0,NLON-1
  do lat=0, NLAT-1
   do imon=0, NMON-1
   if (.not.ismissing(natveg(0,lat,lon))) then

       output(imon,lat,lon) = (1-fcorn(lat,lon)-fsoy(lat,lon)-fcornsoy(lat,lon))*natveg(imon,lat,lon) + \
                           fcorn(lat,lon)*corn(imon,lat,lon) + \
                           fsoy(lat,lon)*soy(imon,lat,lon) + \
                           fcornsoy(lat,lon)*(0.5*corn(imon,lat,lon) + 0.5*(soy(imon,lat,lon)))

;       if (output(imon,lat,lon) .gt. 50.) then
;       if (output(imon,lat,lon) .gt. 15.) then
;           output(imon,lat,lon) = 9e20
;       end if

    end if
    end do
  end do
end do

time_month=ispan(1,NMON,1)

;----------------------------------------------------------------------------
; Now write out data to new netcdf file with appropriate metadata, etc.
;----------------------------------------------------------------------------

output!0 = "time";
output&time = time_month
output!1 = "latitude";
output&latitude = fh2->latitude
output!2 = "longitude";
output&longitude = fh2->longitude

outfile->longitude = fh2->longitude
outfile->latitude = fh2->latitude
outfile->time = time_month
outfile->$varname=output


end
