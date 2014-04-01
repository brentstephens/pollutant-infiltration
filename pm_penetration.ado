program define pm_penetration


*program to find particle penetration factors (and AERs) during particle rebound period at field sites
*brent stephens aug 2011

*Note: The rebound period can be messy, varying by test and instrument. Steady-state periods may be achieved at times, a noticeable rebound period will occur other times, and it's even possible that decay will continue during what should be a rebound period.
*Think about how to select rebound periods
*Rebound periods should align with AER periods
*General rebound mass balance: C(t) = C(0)*exp(-(AER+beta)*time) + ((p*AER*Cout)/(AER+beta))*(1-exp(-(AER+beta)*time))
*Steady state mass balance: Cin = p*AER*Cout/(AER+beta)

*arguments
*1 - street name

***Get AERs first
use "`1'\\`1'_co2_calc”, clear
local aer = aer[1]
local aer_abserr = aer_abserr[1]

***P-Traks
use "`1'\\`1'_ptrak"
ren ptout ptout_raw
gen ptout = ptout_raw
gen hot_decay = .
gen hot_total = .
gen p = .
gen p_abserr = .
gen p_se = .

gen pss = .
gen pss_abserr = .

gen beta = .
gen beta_se = .
gen beta_abserr = .

gen aer = .
gen aer_abserr = .

replace aer = `aer' in 1
replace aer_abserr = `aer_abserr' in 1

gen ptio = ptin/ptout
gen ss = .
gen volume = .

***copy this code to visually determine the data points to use for the decay test
***look for a straight line, beginning a few minutes after leaving the house
*scatter ptin n if n<80, mlabel(n) yscale(log)

*calibrate & set decay period
if "`1'" == "wayside" {
replace hot_total = hot - hot[24] in 24/155
replace hot_decay = hot - hot[24] in 24/46
replace ss = 1 in 90/125
replace volume = 189 in 1
}

if "`1'" == "w30th" {
replace hot_total = hot - hot[17] in 17/158
replace hot_decay = hot - hot[17] in 17/32
replace ss = 1 in 120/158
}

if "`1'" == "kingspt" {
replace hot_total = hot - hot[13] in 13/110
replace hot_decay = hot - hot[13] in 13/26
replace ss = 1 in 60/110
}

if "`1'" == "oakland" {
replace hot_total = hot - hot[10] in 10/166
replace hot_decay = hot - hot[10] in 10/18
replace ss = 1 in 100/160
}

if "`1'" == "fialkoff" {
replace hot_total = hot - hot[23] in 23/165
replace hot_decay = hot - hot[23] in 23/36
replace ss = 1 in 100/165
}

if "`1'" == "atila" {
replace hot_total = hot - hot[15] in 15/161
replace hot_decay = hot - hot[15] in 15/28
replace ss = 1 in 90/140
}

if "`1'" == "bonnie" {
replace hot_total = hot - hot[50] in 50/159
replace hot_decay = hot - hot[50] in 50/80
replace ss = 1 in 143/159
}
if "`1'" == "joe" {
replace hot_total = hot - hot[22] in 22/190
replace hot_decay = hot - hot[22] in 22/34
replace ss = 1 in 185/190
*not really steady, aer too low
}
if "`1'" == "joe2" {
replace ptout = ptout[_n - 161] in 161/190
replace ptio = ptin/ptout[_n - 161] in 161/190
replace ptio = . if n<100
replace hot_total = hot - hot[163] in 163/190
replace hot_decay = hot - hot[22] in 100/130
replace ss = 1 in 185/190
*not really steady, aer too low
}
if "`1'" == "duval" {
replace hot_total = hot - hot[25] in 25/136
replace hot_decay = hot - hot[25] in 25/50
replace ss = 1 in 100/136
replace volume = 56 in 1
*not really steady, aer too low
}
if "`1'" == "duval2" {
replace hot_total = hot - hot[8] in 8/163
replace hot_decay = hot - hot[8] in 8/19
replace ss = 1 in 140/163
*not really steady, aer too low
}
if "`1'" == "darling" {
replace hot_total = hot - hot[32] in 32/225
replace hot_decay = hot - hot[32] in 32/52
replace ss = 1 in 150/225
}
if "`1'" == "dartmouth" {
replace hot_total = hot - hot[22] in 22/177
replace hot_decay = hot - hot[22] in 22/37
replace ss = 1 in 100/175
}
if "`1'" == "kb1" {
replace hot_total = hot - hot[80] in 80/145
replace hot_decay = hot - hot[157] in 157/168
replace ss = 1 in 110/145
}
if "`1'" == "kj" {
replace hot_total = hot - hot[38] in 38/198
replace hot_decay = hot - hot[38] in 38/69
replace ss = 1 in 180/198
*not really steady
}
if "`1'" == "singleton" {
*replace hot_total = hot - hot[12] in 12/181
*replace hot_decay = hot - hot[12] in 12/27
replace hot_total = hot - hot[34] in 34/181
replace hot_decay = hot - hot[34] in 34/47
replace ss = 1 in 125/181
}
if "`1'" == "marwa" {
replace hot_total = hot - hot[70] in 70/191
replace hot_decay = hot - hot[70] in 70/97
replace ss = 1 in 165/184
}
if "`1'" == "shahana" {
replace hot_total = hot - hot[50] in 50/219
replace hot_decay = hot - hot[20] in 20/39
replace ss = 1 in 165/219
}
if "`1'" == "kb2" {
replace hot_total = hot - hot[20] in 20/175
replace hot_decay = hot - hot[20] in 20/45
replace ss = 1 in 150/175
}
if "`1'" == "mckinney" {
replace hot_total = hot - hot[40] in 20/232
replace hot_decay = hot - hot[40] in 40/70
replace ss = 1 in 210/220
}
if "`1'" == "may" {
replace hot_total = hot - hot[17] in 17/196
replace hot_decay = hot - hot[17] in 17/31
replace ss = 1 in 100/196
}
if "`1'" == "harthan" {
replace hot_total = hot - hot[14] in 14/204
replace hot_decay = hot - hot[14] in 14/24
replace ss = 1 in 150/204
}


local aer = aer[1]
local aer_abserr = aer_abserr[1]

********
*Run regression on just those data w/out a source term
*Assume that this is the first 0.5 hours (30 minutes)
*Visually inspect fit for appropriateness of this method

nl (ptin = {init}*exp(-(`aer' + abs({beta}))*hot_decay)) if hot_decay!=., initial(init 3000 beta .5)

local beta = _coef[/beta]
local beta_se = _se[/beta]

gen est_ptin_decay = _coef[/init]*exp(-(`aer' + abs(`beta'))*hot_decay) if hot_decay!=.
twoway (scatter ptin hot_decay) (scatter ptout hot_decay) (line est_ptin_decay hot_decay) if hot_decay!=.


********
*rebound method rest of data
*assuming no indoor sources
nl (ptin = ptin[_n-1] + (1/60)*(ptout[_n-1]*{p}*`aer' - `aer'*ptin[_n-1] - abs(`beta')*ptin[_n-1])) if hot_total!=.
gen est_ptin_total = ptin[_n-1] + (1/60)*(ptout[_n-1]*_coef[/p]*`aer' - `aer'*ptin[_n-1] - abs(`beta')*ptin[_n-1]) if hot_total != .

replace p = _coef[/p] in 1
replace p_se = _se[/p] in 1
replace beta = `beta' in 1
replace beta_se = `beta_se' in 1

*error calcs
replace beta_abserr = beta[1]*((`aer_abserr'/`aer')^2 + (beta_se[1]/beta[1])^2 )^0.5 in 1
replace p_abserr = p[1]*(( ((((`aer_abserr'/`aer')^2 + (p_se[1]/p[1])^2)^0.5)^2 + (beta_abserr[1]/beta[1])^2 )^0.5)^2 + 0.1^2)^0.5 in 1

twoway (scatter ptin hot_total) (scatter ptout hot_total) (line est_ptin_total hot_total) if hot_total!=.

sort n

********
*Check against constant I/O ratio
*quietly sum hot_total
*sum ptio if hot_total <= r(max) & hot_total> r(max) - 0.5
sum ptio if ss==1
local ptio_err = ((r(sd)/r(mean))^2 + 0.1^2)^0.6
local pss = r(mean)*(`beta'+`aer')/`aer'
di "p from I/O ratio = " + `pss'

replace pss = `pss' in 1
replace pss_abserr = pss[1]*( (`ptio_err')^2 + (((`aer_abserr'/`aer')^2 + (beta_abserr[1]/beta[1])^2 )^0.5 )^2 )^0.5 in 1

save "`1'\\`1'_ptrak_calc", replace


end


