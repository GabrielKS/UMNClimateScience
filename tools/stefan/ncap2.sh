# Written by Stefan Liess.
ncap2 -O -s "prob_sort=asort(prob,&srt_map)" ifile ofile
ncatted -a _FillValue,srt_map,d,, ofile
