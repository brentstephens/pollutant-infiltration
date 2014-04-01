program define calc_aer

*program to find air exchange rate (aer, 1/hr) during test house particle penetration period
*relying on the TSI Q-Trak data

*arguments
*1 - street name

use "`1'\\`1'_co2_raw.dta”, clear
gen str location = ""
gen outdoor = .
gen outdoor_SD = .
gen hot_decay = .
gen est_co2 = .
gen est_co2_nosource = .
gen aer = .
gen aer_abserr = .
gen aer_se = .
gen aer_r2 = .
gen aer_nosource = .
gen aer_nosource_abserr = .
gen aer_nosource_se = .
gen aer_nosource_r2 = .
gen est_cout = .
gen est_cout_abserr = .
gen coutdiff = .

label var aer "1/hr"
label var aer_abserr "1/hr"

if "`1'" == "wayside" {
replace location = "out" in 3/11
replace location = "out" in 168/175
replace hot_decay = hot - hot[38] in 38/163
}
if "`1'" == "w30th" {
replace location = "out" in 3/10
replace location = "out" in 175/178
replace hot_decay = hot - hot[55] in 55/170
}
if "`1'" == "kingspt" {
replace location = "out" in 3/5
replace location = "out" in 159/162
replace hot_decay = hot - hot[24] in 24/154
}
if "`1'" == "oakland" {
replace location = "out" in 4/8
replace location = "out" in 178/180
replace hot_decay = hot - hot[43] in 43/174
}
if "`1'" == "fialkoff" {
replace location = "out" in 3/4
replace hot_decay = hot - hot[22] in 22/75
}
if "`1'" == "atila" {
replace location = "out" in 1/5
replace location = "out" in 169/172
replace hot_decay = hot - hot[25] in 25/163
}
if "`1'" == "bonnie" {
replace location = "out" in 150/160
replace hot_decay = hot - hot[40] in 40/144
}
if "`1'" == "joe" {
replace location = "out" in 8/10
replace hot_decay = hot - hot[80] in 80/190
}
if "`1'" == "joe2" {
replace location = "out" in 197/198
replace hot_decay = hot - hot[50] in 50/193
}
if "`1'" == "duval" {
replace location = "out" in 4/10
replace location = "out" in 322/323
replace hot_decay = hot - hot[200] in 200/316
}
if "`1'" == "duval2" {
*this is duval with one window open about 1.5 feet
replace location = "out" in 4/10
replace location = "out" in 322/323
replace hot_decay = hot - hot[25] in 25/173
}
if "`1'" == "darling" {
replace location = "out" in 17/22
replace location = "out" in 228/240
replace hot_decay = hot - hot[60] in 60/222
}
if "`1'" == "dartmouth" {
replace location = "out" in 5/7
replace location = "out" in 183/191
replace hot_decay = hot - hot[50] in 50/180
}
if "`1'" == "kb1" {
replace location = "out" in 2/6
replace hot_decay = hot - hot[50] in 50/150
gen hot_decay2 = hot - hot[180] in 180/215
}
if "`1'" == "kj" {
replace location = "out" in 202/211
replace hot_decay = hot - hot[40] in 40/195
}
if "`1'" == "singleton" {
replace location = "out" in 187/193
replace hot_decay = hot - hot[25] in 25/179
}
if "`1'" == "marwa" {
replace location = "out" in 2/7
replace location = "out" in 198/204
replace hot_decay = hot - hot[33] in 33/193
}
if "`1'" == "shahana" {
replace location = "out" in 2/7
replace location = "out" in 227/229
replace hot_decay = hot - hot[50] in 50/224
}
if "`1'" == "kb2" {
replace location = "out" in 2/2
replace location = "out" in 177/181
replace hot_decay = hot - hot[25] in 25/173
}
if "`1'" == "mckinney" {
replace location = "out" in 8/16
replace location = "out" in 240/249
replace hot_decay = hot - hot[65] in 65/235
}
if "`1'" == "may" {
replace location = "out" in 27/35
replace location = "out" in 223/230
replace hot_decay = hot - hot[65] in 65/220
}
if "`1'" == "harthan" {
replace location = "out" in 3/18
replace location = "out" in 216/224
replace hot_decay = hot - hot[40] in 40/210
}

sum co2 if location == "out"
replace outdoor = r(mean) in 1
replace outdoor_SD = r(sd) in 1

local loc = "decay"

*use outdoor measurements of co2, assume no other sources
nl (co2 = {init}*exp(-{aer}*hot_`loc') + (outdoor[1])*(1-exp(-{aer}*hot_`loc'))) if hot_`loc' != ., initial(init 2000 aer 0.2)

replace est_co2 = _coef[/init]*exp(-_coef[/aer]*hot_`loc') + (outdoor[1])*(1-exp(-_coef[/aer]*hot_`loc')) if hot_`loc' !=.

local aer = _coef[/aer]
local aer_se = _se[/aer]
local aer_r2 = e(r2_a)
local init = _coef[/init]

replace aer = `aer' in 1
replace aer_se = `aer_se' in 1
replace aer_r2 = `aer_r2' in 1
replace aer_abserr = aer_nosource*((`aer_se'/`aer')^2 + (outdoor_SD[1]/outdoor[1])^2)^0.5 in 1


save "`1'\\`1'_co2_calc", replace

twoway (scatter co2 hot_`loc') (line est_co2 hot_`loc')


end



