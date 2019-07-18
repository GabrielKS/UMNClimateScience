;  Modified by Gabriel Konar-Steenberg in the summer of 2019 from a previous file, agg_4.5_2040-2059_currentcover_aet.ncl.
;  Credit for that file: TET & PKS, 09/17/01 / tetwine@students.wisc.edu / pksnyder@students.wisc.edu.
;  Now part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.


begin
;----------------------------------------------------------------------------
; Open files and define parameters
;----------------------------------------------------------------------------
fh1 = addfile("/Users/twine/IBIS/LCCMR_MNwater/code/CESM1/RCP4.5_2040-2059/output_natveg_RCP4.5_2040-2059/monthly/aet.nc", "r");
natveg = fh1->aet(180:,:,:);

fh2 = addfile("/Users/twine/IBIS/LCCMR_MNwater/code/CESM1/RCP4.5_2040-2059/output_corn_RCP4.5_2040-2059/monthly/aet.nc", "r");
corn = fh2->aet(180:,:,:)

fh3 = addfile("/Users/twine/IBIS/LCCMR_MNwater/code/CESM1/RCP4.5_2040-2059/output_soy_RCP4.5_2040-2059/monthly/aet.nc", "r");
soy = fh3->aet(180:,:,:)

fh4 = addfile("/Users/twine/CropCover/Sun_landuse/maps/USDA_WRF_1112.nc", "r");
fsoy     = fh4->fsoy(:,:)
fcorn    = fh4->fcorn(:,:)
fcornsoy = fh4->fcornsoy(:,:)


NLAT= 100 ; dimension of latitude
NLON= 130; dimension of longitude
NMON = 240
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Open new file to write out the aet data
;----------------------------------------------------------------------------
outfile = addfile("/Users/twine/ncl/LCCMR_prop/CESM1/RCP4.5/2040-2059/aet_2040-2059_500ppm.nc", "c");
;----------------------------------------------------------------------------


aet = new((/ NMON,NLAT,NLON /), float, 9e20);
printVarSummary(aet)
printVarSummary(natveg)
aet = natveg(:,:,:)

do lon=0,NLON-1
  do lat=0, NLAT-1
   do imon=0, NMON-1
   if (.not.ismissing(natveg(0,lat,lon))) then

       aet(imon,lat,lon) = (1-fcorn(lat,lon)-fsoy(lat,lon)-fcornsoy(lat,lon))*natveg(imon,lat,lon) + \
                           fcorn(lat,lon)*corn(imon,lat,lon) + \
                           fsoy(lat,lon)*soy(imon,lat,lon) + \
                           fcornsoy(lat,lon)*(0.5*corn(imon,lat,lon) + 0.5*(soy(imon,lat,lon)))

;       if (aet(imon,lat,lon) .gt. 50.) then
;       if (aet(imon,lat,lon) .gt. 15.) then
;           aet(imon,lat,lon) = 9e20
;       end if

    end if 
    end do
  end do
end do

time_month=ispan(1,NMON,1)

;----------------------------------------------------------------------------
; Now write out data to new netcdf file with appropriate metadata, etc.
;----------------------------------------------------------------------------

aet!0 = "time";
aet&time = time_month
aet!1 = "latitude";
aet&latitude = fh2->latitude
aet!2 = "longitude";
aet&longitude = fh2->longitude

outfile->longitude = fh2->longitude
outfile->latitude = fh2->latitude
outfile->time = time_month
outfile->aet=aet


end
