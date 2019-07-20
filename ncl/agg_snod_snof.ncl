;  Written by Gabriel Konar-Steenberg in the summer of 2019.
;  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.

; Uses agg_generic to compute the weighted averages between various land cover options of
;  snod (snow depth) and snof (snow frequency), separately, and outputs to the appropriate files


begin
MAP_FILENAME = "/Users/Gabriel/Downloads/IBIS_stuff/USDA_WRF_1112.nc"
; UNFINISHED because we don't seem to have daily snod and snof from IBIS

;Workaround: deliberately cause a warning to get PyCharm to show NCL output (see t_test_example.ncl):
unused = addfile("Show me the output!", "please")  ;Remove if you can do so and still get the output of print() to show
exit    ;Another workaround. Remove if you can do so and still get the program to exit
end