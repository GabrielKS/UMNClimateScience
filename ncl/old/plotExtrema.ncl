;/Users/konar008/Desktop/plotExtrema.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

procedure plotExtrema(gcm)
begin

;variableLabels = (/"Historic (1980-1999)", "Mid-Century (2040-2059) RCP4.5", "Late-Century (2080-2099) RCP4.5", "Late-Century (2080-2099) RCP8.5"/)
variableLabels = (/"Historic", "Mid RCP4.5", "Late RCP4.5", "Late RCP8.5"/)
gcmLabel = " "+gcm
;gcmLabel = " "+gcm
gcmLabel = ""

input1 = addfile(str_concat((/"/Users/konar008/Desktop/IntermediateData/", gcm, "_results_extrema.nc"/)), "r")
domain = input1->domain
avg_max = input1->avg_max
avg_min = input1->avg_min
diff_max = input1->diff_max
diff_min = input1->diff_min
p_max = input1->p_max
p_min = input1->p_min
minofmin = input1->minofmin
minofmax = input1->minofmax
maxofmin = input1->maxofmin
maxofmax = input1->maxofmax

procedure filterByP(data, ps, threshold)
local data, ps, threshold
begin
data@_FillValue = 9e10
data@missing_value = 9e15
data = where(ps.ge.threshold, data, data@_FillValue)
end

domain4 = (/domain, domain, domain, domain/)
filterByP(avg_max, domain4, 0.5)
filterByP(avg_min, domain4, 0.5)
filterByP(diff_max, domain4, 0.5)
filterByP(diff_min, domain4, 0.5)
filterByP(p_max, domain4, 0.5)
filterByP(p_min, domain4, 0.5)
filterByP(minofmin, domain4, 0.5)
filterByP(minofmax, domain4, 0.5)
filterByP(maxofmin, domain4, 0.5)
filterByP(maxofmax, domain4, 0.5)

p_max_filtered = p_max
p_min_filtered = p_min
filterByP(p_max_filtered, p_max, 0.05)
filterByP(p_min_filtered, p_min, 0.05)

wks_type = "png"
wks_type@wkWidth = 2000
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type, str_concat((/"FinalResults/", gcm, "_outputPlot_extrema"/)))
gsn_define_colormap(wks, "BlueRed")

res = True
res@cnFillOn = True
res@mpOutlineBoundarySets = "AllBoundaries"
res@gsnAddCyclic = False
res@mpMinLonF = -100
res@mpMaxLonF = -88
res@mpMinLatF = 41
res@mpMaxLatF = 50
res@cnMonoFillScale = True
res@gsnSpreadColors = True
res@lgAutoManage = False	;Doesn't seem to change anything.
res@lgLabelFontHeightF = 0.5	;Doesn't seem to work.
res@cnMissingValFillColor = 0
res@cnGridBoundFillColor = 0
res@cnLinesOn = True

;Only some of these work, and there are probably more.
res@cnConstFLabelFontThicknessF = 3.0
res@cnConstFLabelPerimThicknessF = 2.0
res@cnGridBoundPerimThicknessF = 2.0
res@cnHighLabelFontThicknessF = 2.0
res@cnHighLabelPerimThicknessF = 2.0
res@cnInfoLabelFontThicknessF = 2.0
res@cnInfoLabelPerimThicknessF = 2.0
res@cnLineLabelFontThicknessF = 2.0
res@cnLineLabelPerimThicknessF = 2.0
res@cnMonoLineThickness = True
res@cnLineThicknessF = 2.0
res@cnLowLabelFontThicknessF = 2.0
res@cnLowLabelPerimThicknessF = 2.0
res@cnMissingValPerimThicknessF = 2.0
res@cnOutOfRangePerimThicknessF = 2.0
res@lbBoxLineThicknessF = 2.0
res@lbFillLineThicknessF = 2.0
res@lbLabelFontThicknessF = 2.0
res@lbPerimThicknessF = 2.0
res@lbTitleFontThicknessF = 2.0
res@mpGeophysicalLineThicknessF = 2.0
res@mpGridLineThicknessF = 2.0
res@mpLimbLineThicknessF = 2.0
res@mpNationalLineThicknessF = 2.0
res@mpPerimLineThicknessF = 2.0
res@mpUSStateLineThicknessF = 2.0
res@lgBoxLineThicknessF = 2.0
res@lgLabelFontThicknessF = 2.0
;res@lgLineLabelFontThicknessF = 2.0
;res@lgLineThicknessF = 2.0
;res@lgMarkerThicknessF = 2.0
res@lgPerimThicknessF = 2.0
res@lgTitleFontThicknessF = 2.0

res_p = res
res_p@cnLevelSelectionMode = "ExplicitLevels"
res_p@cnLevels = (/0.00001, 0.0001, 0.001, 0.01, 0.05, 0.1/)

res@cnLevelSelectionMode = "ManualLevels"
res@lbLabelStride = 2

res_domain = res
res_minofmin = res
res_minofmax = res
res_maxofmin = res
res_maxofmax = res

res_avg_max = res
res_avg_max@cnMinLevelValF = 4
res_avg_max@cnMaxLevelValF = 21
res_avg_max@cnLevelSpacingF = 1

res_avg_min = res
res_avg_min@cnMinLevelValF = -3
res_avg_min@cnMaxLevelValF = 12
res_avg_min@cnLevelSpacingF = 1

res_diff_max = res
;res_diff_max@cnMinLevelValF = 1.5
;res_diff_max@cnMaxLevelValF = 6.6
;res_diff_max@lbLabelStride = 3
;res_diff_max@cnLevelSpacingF = 0.33333333

res_diff_min = res
;res_diff_min@cnMinLevelValF = 1.5
;res_diff_min@cnMaxLevelValF = 7.5
;res_diff_min@cnLevelSpacingF = 0.5


;Scales for late-century RCP8.5 diff_max vs. diff_min comparisons. If a broader comparison is desired, comment out the following lines and uncomment the lines above.
res_diff_min@cnMinLevelValF = 5.0
res_diff_max@cnMinLevelValF = 5.0
res_diff_min@cnMaxLevelValF = 7.2
res_diff_max@cnMaxLevelValF = 7.2
res_diff_min@cnLevelSpacingF = 0.2
res_diff_max@cnLevelSpacingF = 0.2

resP = True
resP@cnFillOn = True
resP@cnLinesOn = True
resP@cnMonoFillPattern = True
resP@cnMonoFillColor = True
resP@gsnAddCyclic = False
resP@cnFillPattern = 17	;17 for dots
resP@cnFillDotSizeF = 0.002
resP@cnMonoFillScale = True
resP@cnFillScaleF = 0.4
resP@cnNoDataLabelOn = False
resP@cnLinesOn = False
resP@cnLineLabelsOn = False

res_domain@tiMainString = "Domain"+gcmLabel
plot_domain = gsn_csm_contour_map(wks, domain, res_domain)

plot_minofmin = new(4, graphic)
do i = 0, 3
	res_minofmin_this = res_minofmin
	res_minofmin_this@tiMainString = "Minimum of Minima"+gcmLabel+" "+variableLabels(i)
	plot_minofmin(i) = gsn_csm_contour_map(wks, minofmin(i, :, :), res_minofmin_this)
end do

plot_minofmax = new(4, graphic)
do i = 0, 3
	res_minofmax_this = res_minofmax
	res_minofmax_this@tiMainString = "Minimum of Maxima"+gcmLabel+" "+variableLabels(i)
	plot_minofmax(i) = gsn_csm_contour_map(wks, minofmax(i, :, :), res_minofmax_this)
end do

plot_maxofmin = new(4, graphic)
do i = 0, 3
	res_maxofmin_this = res_maxofmin
	res_maxofmin_this@tiMainString = "Maximum of Minima"+gcmLabel+" "+variableLabels(i)
	plot_maxofmin(i) = gsn_csm_contour_map(wks, maxofmin(i, :, :), res_maxofmin_this)
end do

plot_maxofmax = new(4, graphic)
do i = 0, 3
	res_maxofmax_this = res_maxofmax
	res_maxofmax_this@tiMainString = "Maximum of Maxima"+gcmLabel+" "+variableLabels(i)
	plot_maxofmax(i) = gsn_csm_contour_map(wks, maxofmax(i, :, :), res_maxofmax_this)
end do

plot_avg_max = new(4, graphic)
do i = 0, 3
	res_avg_max_this = res_avg_max
	res_avg_max_this@tiMainString = "Average Maximum,"+gcmLabel+" "+variableLabels(i)
	plot_avg_max(i) = gsn_csm_contour_map(wks, avg_max(i, :, :), res_avg_max_this)
end do

plot_diff_max = new(3, graphic)
do i = 1, 3
	res_diff_max_this = res_diff_max
	res_diff_max_this@tiMainString = "Change in Max.,"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_diff_max(i-1) = gsn_csm_contour_map_overlay(wks, diff_max(i, :, :), p_max_filtered(i, :, :), res_diff_max_this, resP)
end do

plot_avg_min = new(4, graphic)
do i = 0, 3
	res_avg_min_this = res_avg_min
	res_avg_min_this@tiMainString = "Average Minimum,"+gcmLabel+" "+variableLabels(i)
	plot_avg_min(i) = gsn_csm_contour_map(wks, avg_min(i, :, :), res_avg_min_this)
end do

plot_diff_min = new(3, graphic)
do i = 1, 3
	res_diff_min_this = res_diff_min
	res_diff_min_this@tiMainString = "Change in Min.,"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_diff_max(i-1) = gsn_csm_contour_map_overlay(wks, diff_min(i, :, :), p_min_filtered(i, :, :), res_diff_min_this, resP)
end do

plot_p_max = new(3, graphic)
do i = 1, 3
	res_p_max_this = res_p
	res_p_max_this@tiMainString = "P for Maximum"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_p_max(i-1) = gsn_csm_contour_map(wks, p_max(i, :, :), res_p_max_this)
end do

plot_p_min = new(3, graphic)
do i = 1, 3
	res_p_min_this = res_p
	res_p_min_this@tiMainString = "P for Minimum"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_p_min(i-1) = gsn_csm_contour_map(wks, p_min(i, :, :), res_p_min_this)
end do

end