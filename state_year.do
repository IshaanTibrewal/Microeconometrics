clear 
*create a path to save figures
global fig "$/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Figures"

use "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/state_year.dta",clear

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project"

drop if year < 2000


*merge with gdp datat
merge 1:1 state year using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/GDP.dta
drop _merge

*merging population data
merge m:1 state year using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/populationdata.dta"


drop _merge

*gen treat variable
gen treat =0

replace treat = 1 if state == "connecticut" | state == "delaware" | state == "maine" | state == "new hampshire" | state == "new jersey" | state == "new york" | state == "vermont" | state == "maryland" | state == "massachusetts" | state == "rhode island" |  state == "california" 

gen RGGI = treat

replace treat = 0 if state == "new jersey" & year >= 2012
replace RGGI = 0 if state == "new jersey" & year >= 2012

*generating post variable
gen post =0 
replace post = 1 if year >= 2009
*replace post variables based on first auctions which was 2008- California was 2013
*replace post = 1 if (state == "connecticut" | state == "delaware" | state == "maine" | state == "new hampshire" | state == "new jersey" | state == "new york" | state == "vermont" | state == "maryland" | state == "massachusetts" | state == "rhode island" ) & year >= 2008


*****Adding RPS data
gen RPS = 0
replace RPS = 1 if state == "arizona" & year >= 2006
replace RPS =  1 if state == "california" & year >= 2002
replace RPS = 1 if state == "colorado" & year >= 2004
replace RPS = 1 if state == "connecticut" & year >= 1998
replace RPS = 1 if state == "delaware" & year >= 2005
replace RPS = 1 if state == "hawaii" & year >= 2001
replace RPS = 1 if state == "illinois" & year >= 2007
replace RPS = 1 if state == "indiana" & year >= 2011
replace RPS = 1 if state == "iowa" & year >= 1983
replace RPS = 1 if state == "kansas" & year >= 2009
replace RPS = 1 if state == "maine" & year >= 1999
replace RPS = 1 if state == "maryland" & year >= 2004
replace RPS = 1 if state == "massachusetts" & year >= 1997
replace RPS = 1 if state == "michigan" & year >= 2008
replace RPS = 1 if state == "minnesota" & year >= 2007
replace RPS = 1 if state == "missouri" & year >= 2007
replace RPS = 1 if state == "montana" & year >= 2005
replace RPS = 1 if state == "nevada" & year >= 1997
replace RPS = 1 if state == "new hampshire" & year >= 2007
replace RPS = 1 if state == "new jersey" & year >= 1991
replace RPS = 1 if state == "new mexico" & year >= 2002
replace RPS = 1  if state == "new york" & year >= 2004
replace RPS = 1 if state == "north carolina" & year >= 2007
replace RPS = 1 if state == "north dakota" & year >= 2007
replace RPS = 1 if state == "ohio" & year >= 2008
replace RPS = 1 if state == "oklahoma" & year >= 2010
replace RPS = 1 if state == "Oregon" & year >= 2007
replace RPS = 1 if state == "pennsylvania" & year >= 2004
replace RPS = 1 if state == "rhode island" & year >= 2004
replace RPS = 1 if state == "south carolina" & year >= 2014
replace RPS = 1 if state == "south dakota" & year >= 2008
replace RPS = 1 if state == "texas" & year >= 1999
replace RPS = 1 if state == "utah" & year >= 2008
replace RPS = 1 if state == "vermont" & year >= 2015
replace RPS = 1 if state == "virginia" & year >= 2020
replace RPS = 1 if state == "washington" & year >= 2020
replace RPS = 1 if state == "west virginia" & year >= 2020 & year <2015
replace RPS = 1 if state == "wisconsin" & year >= 1998
replace RPS = 1 if state == "district of columbia" & year >= 2020
*****RPS done******

*creating summary stats
*est clear
*bysort treat: eststo: sum emissions GDP
*esttab, cells("mean sd") label nodepvar
preserve
keep if post == 0
estpost tabstat emissions GDP population, by(RGGI) ///
statistics(mean sd) columns(statistics) listwise
est store A
restore

preserve
keep if post == 1
estpost tabstat emissions GDP population, by(RGGI) ///
statistics(mean sd) columns(statistics) listwise
est store B
cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"
esttab A B using "statesummary.rtf", main(mean) aux(sd) nostar unstack ///
 nonote compress nonumber collabels ("Non RGGI States" "RGGI States") mtitles("Pre RGGI" "Post RGGI") title("Summary stats by RGGI States") replace
restore 
*generate the DD variable


/*creating summary stats by treatment and control group
bysort treat: sum emissions GDP
sum emissions GDP if treat == 1
est store A
esttab A using "statesummary.rtf"
*/

keep if year >=2000 & year <2017

*regression
*reghdfe emissions DD GDP, absorb(state year)
est store a


gen log_emissions = log(emissions)
*reghdfe emissions DD GDP population, absorb(state year) cluster(state)

*********** final model***********

gen RGGIxpost = RGGI*post

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"
est clear
*without cali and new jersey
reghdfe log_emissions RGGIxpost RPS GDP population if state != "california" | state != "new jersey", absorb(state year) cluster(state)
est store a

*with new jersey
reghdfe log_emissions RGGIxpost RPS GDP population if state != "california", absorb(state year) cluster(state)
est store b

*with california
reghdfe log_emissions RGGIxpost RPS GDP population if state != "new jersey", absorb(state year) cluster(state)
est store c


*esttab a using "states_regression.rtf", compress title("State level Regression Results") mtitles("State level Model") varwidth(14) modelwidth(11) replace nonumber label star(* 0.10 ** 0.05 *** 0.01)
cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"
esttab a b c using "state_regression.rtf", compress title("Table 5: State level Regression Results") mtitles("state level model" "with California" "with new jersey") varwidth(15) noconstant modelwidth(11) replace label star(* 0.10 ** 0.05 *** 0.01) addnote("The outcome variable is log_emissions is the log of emissions in a state in a given year. RGGIxPost is an interaction variable between RGGI and when the policy comes on. RPS is a dummy variable for states with RPS.")

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project"


******creating parallel trends graph
preserve
sort year 
by year: egen treat_mean = mean(emissions) if treat == 1
by year: egen control_mean = mean(emissions) if treat != 1

*creating the common trends
twoway (line treat_mean year, c(1)) (line control_mean year, c(1)), xline(2008) title("Carbon emission by state level treatment groups") ytitle("Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "Treatment Group" 2 "Control Group"))
restore



*graphinal diff in diff analysis
*creating year dummies
tab year, gen(y)

*
gen treat_2000 = treat*y1
gen treat_2001 = treat*y2
gen treat_2002 = treat*y3
gen treat_2003 = treat*y4
gen treat_2004 = treat*y5
gen treat_2005 = treat*y6
gen treat_2006 = treat*y7
gen treat_2008 = treat*y9
gen treat_2009 = treat*y10
gen treat_2010 = treat*y11
gen treat_2011 = treat*y12
gen treat_2012 = treat*y13
gen treat_2013 = treat*y14
gen treat_2014 = treat*y15
gen treat_2015 = treat*y16
gen treat_2016 = treat*y17

*run actual regression again
*reghdfe emissions treat_* , absorb(state year)

reghdfe log_emissions treat_* RPS population GDP , absorb(state year)
*creating beta and SEhigh and SElow
gen beta = .
gen se_high = .
gen se_low = .


*running a loop to fill in these 3 values
forvalues i = 2000(1)2006{
replace beta = _b[treat_`i'] if year == `i'
replace se_high = _b[treat_`i'] + 1.96*_se[treat_`i'] if year == `i'
replace se_low =_b[treat_`i'] - 1.96*_se[treat_`i'] if year == `i'
}


forvalues i = 2008(1)2016{
replace beta = _b[treat_`i'] if year == `i'
replace se_high = _b[treat_`i'] + 1.96*_se[treat_`i'] if year == `i'
replace se_low =_b[treat_`i'] - 1.96*_se[treat_`i'] if year == `i'
}

*set beta = 0 for 2007
replace beta = 0 if year == 2007

*collapsing the data
collapse beta se_high se_low, by(year)

*plotting data
twoway (rcap se_high se_low year) (connect beta year)
twoway (rcap se_high se_low year) (connect beta year), xlabel(2000(2)2016)ytitle("Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "95% Confidence Interval" 2 "Beta")) title("Effect of RGGI on states") xline(2009)









