; Written by Stefan Liess.

; ***********************************************
; xy_2.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with multiple curves
;   - Changing the line color for multiple curves in an XY plot
;   - Changing the line thickness for multiple curves in an XY plot
;   - Drawing XY plot curves with both lines and markers
;   - Changing the default markers in an XY plot
;   - Making all curves in an XY plot solid
;
; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "/usr/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in data
;************************************************
;path="/Volumes/Macintosh\ HD\ 2/liess"
path="/scratch/liess"

var="precip_biascorrected"
;var="T2_biascorrected"
;var="precip"
;var="T2"

;
do a=1,1
if(a.eq.0) then
scenario="historical"
z=8
else if(a.eq.1) then
scenario="RCP4.5"
z=2
else
scenario="RCP8.5"
z=8
end if
end if

do yr=z,8,2
if(yr.ne.6) then
yre=yr+1

;---Get list of files from years 1980 to 2008
;   yyyy      = ispan(1980,1999,1)
;  files = systemfunc("ls ~/DATA/LCCMR/*/historical/allyears_daily/IBISinput_ens8ymonmean.nc")  
  files = systemfunc("ls "+path+"/LCCMR/ZZ_all/"+scenario+"/IBISinput_all7_ens"+yr+"ymonmean.nc "+path+"/LCCMR/[a-z,A-Z][a-l,A-L,m-z,M-Z]*/"+scenario+"/allyears_daily/IBISinput_ens"+yr+"ymonmean.nc | sort -f")  
  files1 = systemfunc("ls "+path+"/LCCMR/[a-z,A-Z][a-l,A-L,m-z,M-Z]*/"+scenario+"/allyears_daily/IBISinput_??["+yr+yre+"]?_cst_ymonmean.nc | sort -f")  
;;;  models = systemfunc("ls "+path+"/LCCMR/*/historical/allyears_daily/IBISinput_ens8ymonmean.nc | sort -f | cut -d '/' -f 6; echo MME")  
  models = systemfunc("ls "+path+"/LCCMR/[a-z,A-Z][a-l,A-L,m-z,M-Z]*/historical/allyears_daily/IBISinput_ens8ymonmean.nc | sort -f | cut -d '/' -f 5; echo MME")  


if ( scenario .eq. "historical" ) then
cent=19
else
cent=20
end if

  yrs = cent+""+yr+"0-"+cent+yre+"9"

;  yrs = "20"+yr+"0-20"+yre+"9"
;  scenario = systemfunc("ls ~/DATA/LCCMR/ACCESS1-3/RCP4.5/allyears_daily/IBISinput_ens8ymonmean.nc | cut -d '/' -f 7")  
  print(models)

g = addfile("IBISinput_Minnesota_raw.nc","r")

f = addfiles(files,"r")
f1 = addfiles(files1,"r")
  dsizes = getfiledimsizes(f[0])
file2 = systemfunc("ls "+path+"/LCCMR/ZZ_all/historical/IBISinput_all7_ens8ymonmean.nc")
f2 = addfile(file2,"r")


;all_files = "pottmp." + yyyy + ".nc"
  
;;---Open files using addfiles
;   fall = addfiles (all_files, "r")

;---Read "pottmp" in "join" mode and print a summary of the variable
   ListSetType (f, "join") 
   ListSetType (f1, "join") 

;;   temp = f[:]->T2_biascorrected(:,:,80,80)                                    ; ;get  datapottmp   ; note syntax [:]
   tem = f[:]->$var$                                    ; ;get  datapottmp   ; note syntax [:]
   tem1 = f1[:]->$var$                                    ; ;get  datapottmp   ; note syntax [:]
   tem2 = f2->$var$

   MN_raw = g->MN_raw
   MN_raw@_FillValue = MN_raw@missing_value
   delete(MN_raw@missing_value)      ; not necessary, just cleaning up
   MN_raw0 = conform_dims(dimsizes(tem),MN_raw,(/2,3/))
   MN_raw1 = conform_dims(dimsizes(tem1),MN_raw,(/2,3/))
   MN_raw2 = conform_dims(dimsizes(tem2),MN_raw,(/1,2/))

   te = where(ismissing(MN_raw0),tem@_FillValue,tem)
   te1 = where(ismissing(MN_raw1),tem1@_FillValue,tem1)
   te2 = where(ismissing(MN_raw2),tem2@_FillValue,tem2)
   temp =  wgt_areaave(te, 1.0, 1.0, 0)
   temp1 =  wgt_areaave(te1, 1.0, 1.0, 0)
   temp2 =  wgt_areaave(te2, 1.0, 1.0, 0)
   temp!1 = "Time"
   temp&Time=f[:]->Time(0,:)
; f     = addfile ("~/DATA/LCCMR/ACCESS1-3/historical/allyears_daily/IBISinput_ens8ymonmean.nc","r")
; temp     = f->T2_biascorrected(:,80,80)                                    ; get  data

print(dimsizes(temp))
printVarSummary(temp)

;************************************************
; to plot multiple lines, you must put them into
; a mulidimensional array
;************************************************
 data      = new((/2,dimsizes(temp(0,:))/),float)
print(dimsizes(data))
; obs1 = data

;print(x)
;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","xy_lccmr7_"+var+yr+scenario)                  ; open workstation

 res                   = True                      ; plot mods desired
  res@gsnDraw      =  False                   ; do not draw the plot
  res@gsnFrame     =  False                   ; do not advance the frame

; res@tiMainString      = ""+run+" Precipitation"        ; add title
 res@tiMainString      = scenario+" "+yrs        ; add title
;; res@tiMainString      = "T2 biascorrected [~S~o~N~C]"        ; add title

; note a similiar resource is xyLineThicknessF, which will effect all
; the lines in the array.

if( yr .eq. 2 ) then
  res@trXMinF	         = 14640.00069444444              ; set x-axis minimum
  res@trXMaxF	         = 14975.00833333333              ; set x-axis minimum
end if
if( yr .eq. 4 ) then
  res@trXMinF	         = 21945.00069444444              ; set x-axis minimum
  res@trXMaxF	         = 22280.00833333334              ; set x-axis minimum
end if
if( yr .eq. 8 ) then
if( cent .eq. 19 ) then
  res@trXMinF	         = 30.              ; set x-axis minimum
  res@trXMaxF	         = 365.0083333333333              ; set x-axis minimum
else
  res@trXMinF	         = 36555.00069444445              ; set x-axis minimum
  res@trXMaxF	         = 36890.00833333333              ; set x-axis minimum
end if
end if
if ( var .eq. "T2_biascorrected" .or. var .eq. "T2" ) then
  res@trYMinF	         = -20              ; set x-axis minimum
  res@trYMaxF	         = 40              ; set x-axis minimum
elseif ( var .eq. "precip_biascorrected" .or. var .eq. "precip" ) then
  res@trYMinF	         = 0              ; set x-axis minimum
  res@trYMaxF	         = 16              ; set x-axis minimum
end if

; res@xyMarkLineMode = "MarkLines"               ; Markers *and* lines
 res@xyLineThicknessF = 3.0               ; make 2nd lines thicker
; res@xyMarkers      = (/1,0/)
  res@xyMarkerSizes       = (/0.015,.015/)
; res@xyMarkerThicknesses = (/1.0,5.0/)               ; make 2nd lines thicker
;print( sprintf("%4.0f", temp&Time(0::40)) )

; res@xyMonoLineColor = False
        
colors = read_colormap_file("GMT_wysiwygcont")
colors1 = read_colormap_file("GMT_gray")

;res@xyLineColors      = (/2,6,8,12,16,20,24,28,32/)          ; change line color
  res@tmXBMode          = "Explicit"              ; explicit labels
  res@tmXBValues        = temp&Time(0:11:1)                     ; location of labels 
  res@tmXBLabels        = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
print(temp&Time)
;sprintf("%4.0f", temp&Time(0::40)); -19960000                ; labels themselves
;print(temp&time-19960000)
  res@tmLabelAutoStride = True                    ; nice stride on labels
  res@tmYLAutoPrecision = False
  res@tmYLPrecision = 2
;  res@tmXBMinorOn = True
;  res@tmXBMinorValues        = x(0::4)                     ; location of labels 
;  res@tmXBLabelAngleF = 45
;  res@tmXBLabelJust = TopRight
  res@tmXBLabelFontHeightF     = .017                 ; change font height
;  res@tmYLFormat = "@*+^sg.2"
;  res@tmYLFormat = "@&0.2f"
  res@tiXAxisString = "Month"
  res@tmXTOn = False
;  res@tiYAxisString = var+" mm d~S~-1~N~"

  res1=res
res@xyLineColors      = (colors(0::18,:))          ; change line color 9
;res@xyLineColors      = (colors(0::22,:))          ; change line color 7
res1@xyLineColor      = (colors1(8,:))          ; change line color
res1@xyMonoDashPattern = True

  res@pmLegendDisplayMode    = "Always"            ; turn on legend
;  res@pmLegendSide           = "Top"               ; Change location of 
;  res@pmLegendParallelPosF   = 1.2                 ; move units right
;  res@pmLegendOrthogonalPosF = -0.3                ; move units down
  res@pmLegendSide           = "Bottom"               ; Change location of 

if ( var .eq. "precip_biascorrected" .or. var .eq. "precip" ) then
  res1@tiYAxisString = var+" mm d~S~-1~N~"
  res@pmLegendParallelPosF   = 0.2                 ; move units right ; precip
  res@pmLegendOrthogonalPosF = -1.17                ; move units down 
else
  res1@tiYAxisString = var+" ~S~o~N~C"
  res@pmLegendParallelPosF   = 0.5                 ; move units right ; temp
  res@pmLegendOrthogonalPosF = -0.52                ; move units down
;  res1@tmYRLabelsOn = True		; turn the YR labels on
;  res@tmYRMode   = "Explicit"  			; explicitly set Y-axis labels
;  res1@tmYUseLeft = False		; use different resources for the right Y-axis
;  res1@tmYRValues = (/"-20","-10","0","10","20","30","40"/)
;  res1@tmYRLabels = (/"-4","14","32","50","68","86","104"/)
end if

  res@pmLegendWidthF         = 0.13                ; Change width and
  res@pmLegendHeightF        = 0.2                ; height of legend.
  res@lgLabelFontHeightF     = .015                 ; change font height
  res@lgTitleOn              = False                ; turn on legend title
;  res@lgTitleString          = "Sahel precip."           ; create legend title
;  res@lgTitleFontHeightF     = .025                ; font of legend title
   res2=res
   res2@pmLegendDisplayMode    = "NoCreate"            ; turn off legend
  res@xyExplicitLegendLabels = (/models(::-1)/)         ; explicit labels
   res4 = res2
   res4@xyDashPatterns         = 11
   res4@pmLegendDisplayMode    = "Always"            ; turn on legend
   res4@pmLegendSide           = "Top"               ; Change location of 
   res4@pmLegendParallelPosF   = 0.8                 ; move units right ; precip
   res4@pmLegendOrthogonalPosF = -0.18                ; move units down 
   res4@pmLegendHeightF        = 0.04                ; height of legend.
   res4@xyExplicitLegendLabels           = (/"1980-1999 Obs."/)           ; create legend title


; plot  = gsn_csm_xy (wks,x,temp,res) ; create plot
if ( var .eq. "T2_biascorrected" .or. var .eq. "T2" ) then
 plot  = gsn_csm_xy (wks,temp&Time,temp(::-1,:)-273.15,res) ; create plot
 plot2  = gsn_csm_xy (wks,temp&Time,temp(9,:)-273.15,res2) ; create plot
 plot1  = gsn_csm_xy (wks,temp&Time,temp1(::-1,:)-273.15,res1) ; create plot
 plot3  = gsn_csm_xy (wks,temp&Time,temp2(:)-273.15,res4) ; create plot
; plot only extreme minimum in 1980-1999
; plot1  = gsn_csm_xy (wks,temp&Time,temp1(11:11:-1,:)-273.15,res1) ; create plot
; plot only extreme minimum in 2020-2039
; plot1  = gsn_csm_xy (wks,temp&Time,temp1(140:140:-1,:)-273.15,res1) ; create plot
else
 plot  = gsn_csm_xy (wks,temp&Time,temp(::-1,:),res) ; create plot
 plot2  = gsn_csm_xy (wks,temp&Time,temp(9,:),res2) ; create plot
 plot1  = gsn_csm_xy (wks,temp&Time,temp1(::-1,:),res1) ; create plot
 plot3  = gsn_csm_xy (wks,temp&Time,temp2(:),res4) ; create plot
end if

  overlay(plot1,plot)                       ; overlay the U-wind plot on the temperature plot
  overlay(plot1,plot2)                       ; overlay the U-wind plot on the temperature plot
  overlay(plot1,plot3)                       ; overlay the U-wind plot on the temperature plot
  draw(plot1)                                  ; draw the temperature plot (with the U-wind plot overlaid)
  frame(wks)                                  ; advance the frame

delete([/res,res1,res2,res4/])
end if
end do
end do
;
end
