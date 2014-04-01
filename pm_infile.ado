program define pm_infile

*code to infile particle penetration data for field sites
*brent stephens aug 2011

*particle instruments
*ptrak "in" & "out"
*qtrak CO2 data


*arguments
*1 - street name
*example: "th_pen_infile wayside"


*retrieve ptrak data
foreach loc in "in" "out" {
insheet using `1'\\`1'_pt`loc'.txt, comma clear
ren ptconc pt`loc'
gen str test = "`1'"

gen hod = substr(time,1,2)
gen mod = substr(time,4,2)
gen sod = substr(time,7,2)
destring hod, force replace
destring mod, force replace
destring sod, force replace
replace hod = hod + mod/60 + sod/3600
drop mod sod
gen hot = hod - hod[1]

gen n = _n
sort n
save "`1'\\`1'_pt`loc'_raw", replace
}


*merge ptrak data (assumes that counting starts at exactly the same time)
use `1'\\`1'_ptin_raw
merge n using `1'\\`1'_ptout_raw
drop _merge
save "`1'\\`1'_ptrak", replace


*retrieve co2 data from qtrak
insheet using `1'\\`1'_co2.txt, comma clear
gen str test = "`1'"

gen hod = substr(time,1,2)
gen mod = substr(time,4,2)
gen sod = substr(time,7,2)
destring hod, force replace
destring mod, force replace
destring sod, force replace
replace hod = hod + mod/60 + sod/3600
drop mod sod
gen hot = hod - hod[1]

gen n = _n


save "`1'\\`1'_co2_raw", replace




end



