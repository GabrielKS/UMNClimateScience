;/Users/konar008/Desktop/plotPrecip.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

procedure plotPrecip(gcm)
begin

;variableLabels = (/"Historic (1980-1999)", "Mid-Century (2040-2059) RCP4.5", "Late-Century (2080-2099) RCP4.5", "Late-Century (2080-2099) RCP8.5"/)
variableLabels = (/"Historic", "Mid RCP4.5", "Late RCP4.5", "Late RCP8.5"/)
gcmLabel = " "+gcm

input1 = addfile(str_concat((/"/Users/konar008/Desktop/IntermediateData/", gcm, "_results_precip.nc"/)), "r")
domain = input1->domain
avg_t = input1->avg_t
avg_dtr = input1->avg_dtr
diff_t = input1->diff_t
diff_dtr = input1->diff_dtr
p_t = input1->p_t
p_dtr = input1->p_dtr

procedure filterByP(data, ps, threshold)
local data, ps, threshold
begin
data@_FillValue = 9e10
data@missing_value = 9e15
data = where(ps.ge.threshold, data, data@_FillValue)
end

domain4 = (/domain, domain, domain, domain/)
filterByP(avg_t, domain4, 0.5)
filterByP(avg_dtr, domain4, 0.5)
filterByP(diff_t, domain4, 0.5)
filterByP(diff_dtr, domain4, 0.5)
filterByP(p_t, domain4, 0.5)
filterByP(p_dtr, domain4, 0.5)

p_t_filtered = p_t
p_dtr_filtered = p_dtr
filterByP(p_t_filtered, p_t, 0.05)
filterByP(p_dtr_filtered, p_dtr, 0.05)

wks_type = "png"
;wks_type@wkWidth = 2048
;wks_type@wkHeight = 2048

wks = gsn_open_wks(wks_type, str_concat((/"FinalResults/", gcm, "_outputPlot_basic"/)))
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

res_p = res
res_p@cnLevelSelectionMode = "ExplicitLevels"
res_p@cnLevels = (/0.00001, 0.0001, 0.001, 0.01, 0.05, 0.1/)

res@cnLevelSelectionMode = "ManualLevels"
res@lbLabelStride = 2

res_domain = res

res_avg_t = res
res_avg_t@cnMinLevelValF = 2
res_avg_t@cnMaxLevelValF = 17
res_avg_t@cnLevelSpacingF = 1

res_avg_dtr = res
res_avg_dtr@cnMinLevelValF = 2
res_avg_dtr@cnMaxLevelValF = 12
res_avg_dtr@lbLabelStride = 3
res_avg_dtr@cnLevelSpacingF = 0.66666666

res_diff_t = res
res_diff_t@cnMinLevelValF = 1.5
res_diff_t@cnMaxLevelValF = 7
res_diff_t@lbLabelStride = 3
res_diff_t@cnLevelSpacingF = 0.33333333

res_diff_dtr = res
res_diff_dtr@cnMinLevelValF = -1.4
res_diff_dtr@cnMaxLevelValF = 0.2
res_diff_dtr@lbLabelStride = 3
res_diff_dtr@cnLevelSpacingF = 0.15

resP = True
resP@cnFillOn = True
resP@cnLinesOn = True
resP@cnMonoFillPattern = True
resP@cnMonoFillColor = True
resP@gsnAddCyclic = False
resP@cnFillPattern = 17	;17 for dots
;resP@cnFillDotSizeF = 0.002
resP@cnMonoFillScale = True
resP@cnFillScaleF = 0.25
resP@cnNoDataLabelOn = False
resP@cnLinesOn = False
resP@cnLineLabelsOn = False


res_domain@tiMainString = "Domain"+gcmLabel
plot_domain = gsn_csm_contour_map(wks, domain, res_domain)

plot_avg_t = new(4, graphic)
do i = 0, 3
	res_avg_t_this = res_avg_t
	res_avg_t_this@tiMainString = "Avg Temp"+gcmLabel+" "+variableLabels(i)
	plot_avg_t(i) = gsn_csm_contour_map(wks, avg_t(i, :, :), res_avg_t_this)
end do

;gsn_define_colormap(wks, "rainbow")
plot_diff_t = new(3, graphic)
do i = 1, 3
	res_diff_t_this = res_diff_t
	res_diff_t_this@tiMainString = "Temp Chg"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_diff_t(i-1) = gsn_csm_contour_map_overlay(wks, diff_t(i, :, :), p_t_filtered(i, :, :), res_diff_t_this, resP)
end do

plot_avg_dtr = new(4, graphic)
do i = 0, 3
	res_avg_dtr_this = res_avg_dtr
	res_avg_dtr_this@tiMainString = "Avg DTR"+gcmLabel+" "+variableLabels(i)
	plot_avg_dtr(i) = gsn_csm_contour_map(wks, avg_dtr(i, :, :), res_avg_dtr_this)
end do

plot_diff_dtr = new(3, graphic)
do i = 1, 3
	res_diff_dtr_this = res_diff_dtr
	res_diff_dtr_this@tiMainString = "DTR Chg"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_diff_t(i-1) = gsn_csm_contour_map_overlay(wks, diff_dtr(i, :, :), p_dtr_filtered(i, :, :), res_diff_dtr_this, resP)
end do

plot_p_t = new(3, graphic)
do i = 1, 3
	res_p_t_this = res_p
	res_p_t_this@tiMainString = "Temp P"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_p_t(i-1) = gsn_csm_contour_map(wks, p_t(i, :, :), res_p_t_this)
end do

plot_p_dtr = new(3, graphic)
do i = 1, 3
	res_p_dtr_this = res_p
	res_p_dtr_this@tiMainString = "DTR P"+gcmLabel+" "+variableLabels(0)+" to "+variableLabels(i)
	plot_p_dtr(i-1) = gsn_csm_contour_map(wks, p_dtr(i, :, :), res_p_dtr_this)
end do

end