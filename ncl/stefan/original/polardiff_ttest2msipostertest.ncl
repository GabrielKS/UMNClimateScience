;**********************************************************
; conOncon_4.ncl
;
; Concepts illustrated:
;   - Overlaying stippled contours on solid line contours
;   - Filling contours with stippling (solid dots)
;   - Adding shading below a specified contour level
;   - Drawing the zero contour line thicker
;   - Drawing negative contour lines as dashed lines
;   - Changing the density of a contour fill pattern
;   - Reading differences and probabilities
;   - Drawing a base plot of differences
;   - Overlaying a stippling pattern for the 5% significance level
;
;***************************************************************
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
                            
begin
  ;sdev    = 1.2
  ;op

i = 8
k = 8
;k = 31
   do while(i.le.k)

;    vari	  = "Z"
;    vari	  = "strf"
;    vari	  = "V"
     if ((i % 2) .eq. 0) then
     vari	  = "T2_biascorrected"
;     vari	  = "T2"
     else
     vari	  = "precip_biascorrected"
;     vari	  = "precip"
     end if
;    meanornot	  = "mean"
    meanornot	  = ""
    j = (i / 2) * 2
;    if ( j .ge. 16 ) then
;    j = j - 16
    if ( j .eq. 0 .or. j .eq. 8 .or. j .eq. 16. .or. j .eq. 24 ) then
    seas   	  = "djf"
    else if ( j .eq. 2 .or. j .eq. 10 .or. j .eq. 18. .or. j .eq. 26 ) then
    seas   	  = "mam"
    else if ( j .eq. 4 .or. j .eq. 12 .or. j .eq. 20. .or. j .eq. 28 ) then
    seas   	  = "jja"
    else if ( j .eq. 6 .or. j .eq. 14 .or. j .eq. 22. .or. j .eq. 30 ) then
    seas   	  = "son"
    end if
    end if
    end if
    end if
    if ( j .le. 22 ) then
    run="RCP4.5"
     if ( j .le. 6 ) then
     w=2
     else if ( j .le. 14 ) then
     w=4
     else
     w=8
     end if
     end if
    else
    run="RCP8.5"
    w=8
    end if

    z=w+1
    numi1="/scratch/liess/LCCMR/[b-z,B-Z][a-l,A-L,n-z,N-Z]*/"+run+"/allyears_daily/IBISinput_20["+w+""+z+"]?_cst_ymonmean"+seas+".nc"
    numi2="/scratch/liess/LCCMR/[b-z,B-Z][a-l,A-L,n-z,N-Z]*/historical/allyears_daily/IBISinput_19[89]?_cst_ymonmean"+seas+".nc"
    print(numi1)

; filp     = "k0200bs"+numi1
; filn     = "g0200pi"+numi1
; filmp    = "k0200bs"+numi1+"timavg"
; filsp    = "k0200bs"+numi1+"timstd"
; filmn    = "g0200pi"+numi1+"timavg"
; filsn    = "g0200pi"+numi1+"timstd"

  ;fili    = "MERRA_144x73_psl_pr_detrend___1979_2012map1.nc"
  filp = systemfunc("ls "+numi1)
  p = addfiles(filp,"r")
  filn = systemfunc("ls "+numi2)
  n = addfiles(filn,"r")
  dsizes = getfiledimsizes(n[0])
  
;  p    = addfiles  (filp+".nc", "r")            ; open the netCDF file
;  n    = addfile  (filn+".nc", "r")            ; open the netCDF file
;  mp    = addfile (filmp+".nc", "r")            ; open the netCDF file
;  mn    = addfile (filmn+".nc", "r")            ; open the netCDF file
;  sp    = addfile (filsp+".nc", "r")            ; open the netCDF file
;  sn    = addfile (filsn+".nc", "r")            ; open the netCDF file

system("rm -f "+run+""+w+"_acr.nc "+run+""+z+"_acr.nc")

  fh_acrs    = addfile (run+""+w+"_acr.nc", "c")            ; open the netCDF file
  fh_acrc    = addfile (run+""+z+"_acr.nc", "c")            ; open the netCDF file
;  ntime = dimsizes(p->lat)
  nlat = dimsizes(p[0]->LAT)
  nlon = dimsizes(p[0]->LON)

    var	  = vari                                    

  dat_diff_s=p[:]->$var$(:,:,:)
  dat_diff_c=n[:]->$var$(:,:,:)
;  dat_avg_s=p->$var$(:,:,:,:)
;  dat_avg_c=mn->$var$(:,:,:,:)
;  dat_std_s=sp->$var$(:,:,:,:)
;  dat_std_c=sn->$var$(:,:,:,:)

;  nlev = dimsizes(up(0,:,0,0))
;print(nlev)
;sfvp  = uv2sfvpG (up,vp)
;sfvn  = uv2sfvpG (un,vn)

  dat_avg_s=dim_avg_n_Wrap(dat_diff_s,0)
  dat_avg_c=dim_avg_n_Wrap(dat_diff_c,0)
  dat_std_s=dim_stddev_n_Wrap(dat_diff_s,0)
  dat_std_c=dim_stddev_n_Wrap(dat_diff_c,0)

  yrs1 =  dim_num_n(.not.ismissing(dat_diff_c),0)  ; nTime(klev,nlat,mlon)
  yrs2 =  dim_num_n(.not.ismissing(dat_diff_s),0)  ; nTime(klev,nlat,mlon)
print(max(yrs2))
print(min(yrs2))

;  diff = f->$var$(0,:,:)
;  diff = f->$var$(0,15,:,:) ; 20
;  diff = f->$var$(0,5,:,:) ; 500
;  diff = f->$var$(0,2,:,:) ; 850
;  diffall = g->$var$(0,:,:)
;  diffsub = h->$var$(0,:,:)


;  level    =   p->hPa(7:10)
  lat    =   p[0]->LAT
  lon    =   p[0]->LON

print(dimsizes(lat))
print(dimsizes(dat_avg_s))

;levj=level(levi)


;  diffall&lat     =   lat
;  diffall&lon     =   lon
;  diffall&lat@units     = "degrees_north"
;  diffall&lon@units     = "degrees_east"
;  diffall@_FillValue    = -9999
;
;  diffsub&lat     =   lat
;  diffsub&lon     =   lon
;  diffsub&lat@units     = "degrees_north"
;  diffsub&lon@units     = "degrees_east"
;  diffsub@_FillValue    = -9999


;  diff = dat_avg_s(0,0,:,:)-dat_avg_c(0,0,:,:)
;  diff = dat_avg_s(0,5,:,:)-dat_avg_c(0,5,:,:) ; 500 hPa
;  diff = dat_avg_s(0,levi,:,:)-dat_avg_c(0,7,:,:) ; 300 hPa
  diff = dat_avg_s(:,:)-dat_avg_c(:,:)

;  print(dimsizes(diff))
;diff!0 = "level"
diff!0 = "lat"
diff!1 = "lon"
diff@_FillValue = 9e20
  diff&lat     =   lat
  diff&lon     =   lon
  diff&lat@units     = "degrees_north"
  diff&lon@units     = "degrees_east"
;  diff@_FillValue    = -9999

q=getvardims(p)
print(q)
printVarSummary(dat_avg_s)
;dat_avg_s!0 = "season"
;dat_avg_c!0 = "season"
;dat_avg_s!0 = "level"
;dat_avg_c!0 = "level"
dat_avg_s!0 = "lat"
dat_avg_c!0 = "lat"
dat_avg_s!1 = "lon"
dat_avg_c!1 = "lon"
;dat_avg_s&level@units = "hPa"
;dat_avg_c&level@units = "hPa"


;dat_std_s!0 = "season"
;dat_std_c!0 = "season"
;dat_std_s!0 = "level"
;dat_std_c!0 = "level"
dat_std_s!0 = "lat"
dat_std_c!0 = "lat"
dat_std_s!1 = "lon"
dat_std_c!1 = "lon"

dat_diff_s!0 = "time"
dat_diff_c!0 = "time"
;dat_diff_s!1 = "level"
;dat_diff_c!1 = "level"
dat_diff_s!1 = "lat"
dat_diff_c!1 = "lat"
dat_diff_s!2 = "lon"
dat_diff_c!2 = "lon"
;
; --------------------------------------------------------------
;
;diff = new((/1,nlev,nlat,nlon/),float,0.)
;
diffttest = new((/nlat,nlon/),double)
;print(dimsizes(diffttest))
;diffttest!0 = "time"
;diffttest!0 = "level"
;diffttest&level = level
diffttest!0 = "latitude"
diffttest&latitude = lat
diffttest!1 = "longitude"
diffttest&longitude = lon
;diffttest@_FillValue = 9e20
;diffttest@_FillValue = 9.969209968386869e+36 
;diffttest@_FillValue = diffttest@missing_value
;level =  fh_djf_avg_c->level
;;diffttest&level@units = "hPa"
diffttest&latitude@units     = "degrees_north"
diffttest&longitude@units     = "degrees_east"
;

; --------------------------------------------------------------
; CALCULATE STATISTICS - AUTO-CORRELATION
mxlag = 1
datei = systemfunc("date")
print("before acrc "+ datei)
acrc1   = esacr(dat_diff_c(lat|:, lon|:, time|:),mxlag)
print(dimsizes(acrc1))
acrc = acrc1(:,:,1)
datei = systemfunc("date")		       
print("before acrs "+ datei)		       
acrs1   = esacr(dat_diff_s(lat|:, lon|:, time|:),mxlag)
acrs = acrs1(:,:,1)
acrc=where(acrc.le.1,acrc,1)
acrc=where(acrc.ge.0,acrc,0)
acrs=where(acrs.le.1,acrs,1)
acrs=where(acrs.ge.0,acrs,0)

datei = systemfunc("date")
print("after acrs "+ datei)
;print(acrc)
;acrc = fh_acrc->acrc
;acrs = fh_acrs->acrs
fh_acrc->acrc = acrc
fh_acrs->acrs = acrs
datasizec = new((/nlat,nlon/),double, 9e+20)
;print(dimsizes(dat_avg_sort_c))
print(dimsizes(datasizec))
datasizec = yrs1 * ( 1 - acrc) / ( 1 + acrc)
;datasizec = yrs1 * ( 1 - abs(acrc)) / ( 1 + abs(acrc))
;;datasizec = yrs1
print(max(acrc))
print(min(acrc))
print(max(datasizec))
print(min(datasizec))
datasizes = new((/nlat,nlon/),double, 9e+20)
datasizes = yrs2 * ( 1 - acrs) / ( 1 + acrs)
;datasizes = yrs2 * ( 1 - abs(acrs)) / ( 1 + abs(acrs))
;datasizes = yrs2
print(max(datasizes))
print(min(datasizes))

; --------------------------------------------------------------
print(dimsizes(dat_avg_c))

print("before ttest ")
siglevel = 0.05
;siglevel = 0.1
siglevelstr = siglevel * 100

         prob = ttest(dat_avg_c(:,:),(dat_std_c(:,:))^2,datasizec(:,:), \
                      (dat_avg_s(:,:)),(dat_std_s(:,:))^2,datasizes(:,:), \
                      True,False)
  
prob!0 = "latitude"
prob&latitude = lat
prob!1 = "longitude"
prob&longitude = lon
prob@_FillValue = 9e20
  prob&latitude@units     = "degrees_north"
  prob&longitude@units     = "degrees_east"

fieldsig2=prob
prob_sort2=prob
 fh_acrc->prob = prob

system("rm -f ifile ofile")
system("ln -s "+run+""+z+"_acr.nc ifile")

system("bash ~/scripts/ncl/ncap2.sh")
system("mv -f ofile "+run+""+z+"_out.nc")
system("rm -f ifile")

  fh_acrc2    = addfile (run+""+z+"_out.nc", "w")            ; open the netCDF file
srt_map = fh_acrc2->srt_map
;srt_map@_FillValue =-1
fieldsig2=(srt_map+1)*0.1/13000
;;;fieldsig2=0.1/4608
;fieldsig2=1-(1-0.1)^10512
prob_sort2=where(prob.le.fieldsig2,fieldsig2,prob@_FillValue)
fh_acrc2->fieldsig2=fieldsig2
fh_acrc2->prob_sort2=prob_sort2

;do s=0,nlev-1
   do y=0,nlat-1
      do x=0,nlon-1
;;;         if (.not.ismissing(prob_sort2(y,x))) then
         if (.not.ismissing(prob(y,x))) then
;;         if (.not.ismissing(dat_diff_c(0,y,x))) then
;            if (prob(s,y,x).lt.siglevel) then
            if (prob(y,x).lt.siglevel) then
;;            if (prob_sort2(y,x).lt.siglevel) then
;               diffttest(s,y,0) = ( dat_avg_s(s,y,{a:b}) - dat_avg_c(s,y,{a:b}) ) * 86400000
;               diffttest(s,h,y,0) = ( dat_avg_s(s,h,y,0) - dat_avg_c(s,h,y,0) ) * 100000000 ; K/100km
               diffttest(y,x) = dat_avg_s(y,x) - dat_avg_c(y,x)
            else
;               diffttest(s,h,y,0) = ( dat_avg_s(s,h,y,0) - dat_avg_c(s,h,y,0) ) * 100000000 ; K/100km
;;               diffttest(y,x) = 9e20
               diffttest(y,x) = diffttest@_FillValue
            end if
         end if
;               diff(s,h,y,0) = ( dat_avg_s(s,h,y,0) - dat_avg_c(s,h,y,0) ) *1000
;               diff(s,h,y,0) = dat_avg_s(s,h,y,0) - dat_avg_c(s,h,y,0) * 100000000
      end do
   end do
;end do
;
prob_sort2!0 = "latitude"
prob_sort2&latitude = lat
prob_sort2!1 = "longitude"
prob_sort2&longitude = lon
prob_sort2@_FillValue = 9e20
  prob_sort2&latitude@units     = "degrees_north"
  prob_sort2&longitude@units     = "degrees_east"

;; fh_acrc->prob_sort = prob_sort
;diffttest&level@units = "hPa"
;stream function *10^-6
  if ( vari .eq. "strf" ) then
diffttest=diffttest/10^6
diff=diff/10^6
end if
;
print("before plot ")
fh_acrc2->diffttest=diffttest
;print(diffttest(50,50))


; ========================= PLOT 1 ==============================
  type = "png"
  type@wkBackgroundColor = "white"
  type@wkForegroundColor = "black"

;;;  wks   = gsn_open_wks (type, "MSIposter19"+run+""+w+""+var+"_"+seas )   ; open workstation 
;;  wks   = gsn_open_wks (type, "MSIposter19"+run+""+w+""+var+"_"+seas+"biascorr" )   ; open workstation 
  wks   = gsn_open_wks (type, "paper19"+run+""+w+""+var+"_"+seas+"biascorr" )   ; open workstation 

  res = True                                 ; plot mods desired

;  res@gsnPolar             = "SH"                 ; specify the hemisphere
;  res@gsnPolarLabelSpacing = 30                   ; how frequently to label
;   res@mpCenterLonF = 180    

res@mpDataBaseVersion = "MediumRes"
  res@mpFillOn		    = False
  res@mpOutlineOn           = True                ; turn on map outline
;  res@mpOutlineBoundarySets = "USStates"          ; turn on state boundaries
  res@mpOutlineBoundarySets = "AllBoundaries"          ; turn on state boundaries
  
res@cnLinesOn             = True
;  res@mpLandFillColor        = 0
  res@mpGeophysicalLineColor = "Black"
  res@mpNationalLineColor    = "Black"
  res@mpUSStateLineColor     = "Black"
  res@mpGridLineColor        = "Black"
  res@mpLimbLineColor        = "Black"
  res@mpPerimLineColor       = "Black"

  res@mpNationalLineThicknessF = 3.
  res@mpUSStateLineThicknessF = 3.

   res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
   if ( var .eq. "T2_biascorrected" .or. var .eq. "T2" ) then
  res@cnMinLevelValF       = -7            ; set min contour level
  res@cnMaxLevelValF       =  7             ; set max contour level
  res@cnLevelSpacingF      =  0.5           ; set contour spacing
  else
  res@cnMinLevelValF       = -4            ; set min contour level
  res@cnMaxLevelValF       =  4             ; set max contour level
  res@cnLevelSpacingF      =  0.5           ; set contour spacing
  end if
;  res@cnMinLevelValF       =  -160          ; set min contour level
;  res@cnMaxLevelValF       =   160         ; set max contour level
;  res@cnLevelSpacingF      =    20        ; set contour spacing

;  res@cnMinLevelValF       = -200             ; set min contour level
;  res@cnMaxLevelValF       =  200             ; set max contour level
;  res@cnLevelSpacingF      =   25            ; set contour spacing

;  res@cnMinLevelValF       = -10.             ; set min contour level
;  res@cnMaxLevelValF       =  10.             ; set max contour level
;  res@cnLevelSpacingF      =   1.25            ; set contour spacing

;  res@cnMinLevelValF       = -120             ; set min contour level
;  res@cnMaxLevelValF       =  120             ; set max contour level
;  res@cnLevelSpacingF      =   15            ; set contour spacing

;;  res@cnMinLevelValF       = -12.             ; set min contour level
;;  res@cnMaxLevelValF       =  12.             ; set max contour level
;;  res@cnLevelSpacingF      =   1.5            ; set contour spacing
  res@cnLineLabelsOn = False

  res@gsnDraw              = False           ; Do not draw plot
  res@gsnFrame             = False           ; Do not advance frome
  res@gsnAddCyclic	   = False       ; Do not add cyclic point for non-global

;  res@mpMinLatF             = 41.46884                 ; zoom in on a subregion
  res@mpMinLatF             = 41.72071
  res@mpMaxLatF             = 49.78038
;  res@mpMinLonF             = -99.375
;  res@mpMinLonF             = -99.29166
  res@mpMinLonF             = -99.125
;  res@mpMaxLonF             = -88.625
  res@mpMaxLonF             = -88.875
  
  res@cnNoDataLabelOn   = True
	res@cnInfoLabelOn = False

;  res1 = res
        res1                       = True
  res1@mpGeophysicalLineThicknessF = 1.5
	res1@gsnDraw             = False       ; Do not draw plot
  	res1@gsnFrame            = False       ; Do not advance frome
	res1@cnFillOn             = True
  res1@cnMonoFillColor      = True
  res1@cnMonoFillPattern    = False
  res1@cnFillPatterns       =  (/17,17,17,17,17,17,17,17,17,17,17,17, \
                                  17,17,17,17/)
        res1@cnFillDotSizeF 	  = 0.0025
	                res1@gsnLeftString = " "
                        res1@gsnRightString = " "
                        res1@tiXAxisString = " "
			res1@pmLabelBarDisplayMode = "Never"          ; turns off label bar

  res1@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res1@cnMinLevelValF      = -0.001        ; set min contour level
  res1@cnMaxLevelValF      = 0.051        ; set max contour level
  res1@cnLevelSpacingF     = 0.051        ; set contour spacing

  res1@cnInfoLabelOn       = False       ; turn off info label

  res1@cnLinesOn           = False       ; do not draw contour lines
  res1@cnLineLabelsOn      = False       ; do not draw contour labels

  res1@cnFillScaleF        = 0.6         ; add extra density
  res1@lbLabelBarOn          = False



  res2 = res
  res2@mpGeophysicalLineThicknessF = 1.5
  res2@cnFillOn              = True
  res2@cnLinesOn             = False
  res@cnFillOn              = False
  res2@tmXBLabelFontHeightF  = 0.018
  res2@tmYLLabelFontHeightF  = 0.018
  res2@lbLabelStride        = 2 ; every other label bar label
;  gsn_define_colormap(wks,"nrl_sirkes")
;  res2@cnFillColors    = (/2,3,4,5,6,7,8,9,10,13,14,15,16,17,18,19,20,21,22/)
   if ( var .eq. "T2_biascorrected" .or. var .eq. "T2" ) then
   gsn_define_colormap(wks,"cmp_b2r")
   res2@cnFillColors    = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64/)
   else
   gsn_define_colormap(wks,"precip4_diff_19lev")
;   res2@cnFillColors    = (/1,1,2,3,4,5,6,7,8,9,10,13,14,15,16,17,18,19,20,21,1,1/)
   res2@cnFillColors    = (/2,3,4,5,6,7,8,9,10,13,14,15,16,17,18,19,20,21,1,1/)
   end if
;  res2@cnFillColors    = (/2,3,4,5,6,7,8,10,12,12,13,14,15,17,18,19,20,21,22/)
;  res@cnFillColors    = (/0,13,15,17,18,19,20,21,22,23/)
;  res@cnFillColors    = (/0,13,13.75,14.5,15.25,16, 16.75,17.5,18.25,19,19.75,20.5,21.25,22,22.75/)

  res2@lbLabelBarOn          = True
  res2@lbAutoManage         = "off"
;;;res@lbOrientation =   "vertical"          ; vertical label bar
  res2@lbTopMarginF         = 0.2
  res2@lbBottomMarginF         = -0.2
;  res4 = res2
;  res4@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
;  res4@cnMinLevelValF       = -10.8            ; set min contour level
;  res4@cnMaxLevelValF       =  10.8             ; set max contour level
;  res4@cnLevelSpacingF      =  0.9           ; set contour spacing



  plot = gsn_csm_contour_map(wks,diffttest(:,:), res2)  
;;  plot = gsn_csm_contour_map(wks,diff(:,:), res)  
;;  plot  = ShadeGtContour(plot2, 0.95, 17)  ; shade all areas less than the
                                          ; 0.05 contour level
;;;  plot = ZeroNegDashLineContour (plot)
;=====================================================END of PLOT1===============================================

;  plot2 = gsn_csm_contour(wks,diffttest(:,:), res2) 
;  plot2 = gsn_csm_contour(wks,diffttest(5,:,:), res2) 
  plot2 = gsn_csm_contour(wks,diff(:,:), res) 
;  plot2 = gsn_csm_contour(wks,diffttest(15,:,:), res2) 
;plot2  = ShadeGtContour(plot2, 0.95, 17)  
;;;  plot2 = ZeroNegDashLineContour (plot2)

;=====================================================END of PLOT2===============================================

  overlay(plot,plot2)

  plot3 = gsn_csm_contour(wks,prob_sort2(:,:), res1)  
;  plot3  = ShadeGtContour(plot3, 0.5, 17)  ; shade all areas less than the
                                          ; 9999 contour level

;  plot3 = gsn_csm_contour(wks,diffttest(:,:)*9/5, res4)  

;=====================================================END of PLOT3===============================================
;  overlay(plot,plot3)

draw (plot)
  frame(wks)

delete([/filp,filn,p,n,dat_diff_s,dat_diff_s,dat_diff_c,dat_avg_s,dat_avg_c,dat_std_s,dat_std_c,res2/])
i=i+1
   end do
   
end;**********************************************************

