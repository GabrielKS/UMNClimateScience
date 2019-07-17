;/Users/konar008/Desktop/allResults.ncl
load "/Users/konar008/Desktop/resultsScriptRewritten.ncl"

;runResultsScript("CNRM-CM5", True, False, False)
;runResultsScript("MIROC5", True, False, False)
;runResultsScript("bcc-csm1-1", True, False, False)

;runResultsScript("CNRM-CM5", False, True, False)
;runResultsScript("MIROC5", False, True, False)
;runResultsScript("bcc-csm1-1", False, True, False)

runResultsScript("CNRM-CM5", False, False, True)
runResultsScript("MIROC5", False, False, True)
runResultsScript("bcc-csm1-1", False, False, True)