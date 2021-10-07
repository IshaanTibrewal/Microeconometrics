clear 
*create a path to save figures
global fig "$/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Figures"
global out_table "$/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"

use "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/sector_state.dta",clear

drop treat
drop post
drop if year < 2000


*gen sector treat variable
gen sec_treat =0

replace sec_treat = 1 if (state == "connecticut" | state == "delaware" | state == "maine" | state == "new hampshire" | state == "new jersey" | state == "new york" | state == "vermont" | state == "maryland" | state == "massachusetts" | state == "rhode island" |  state == "california") & sector == "Electric Power"

*generate post variable
gen post =0
replace post = 1 if year >= 2009

*merging GDP data 
merge m:1 state year using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/GDP.dta"

drop _merge

*merging population data
merge m:1 state year using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/populationdata.dta"


gen RGGI = sec_treat

replace RGGI = 1 if state == "california"

drop _merge

/*
egen RGGI_Post = group(RGGI post)
*creating summary stats by treatment and control group
bysort sec_treat: sum emissions GDP

estpost tabstat emissions, by(RGGI_Post) ///
statistics(mean sd) columns(statistics) listwise
est store A

*1 is Non RGGI sectors pre 
*2 is Non RGGI sectors post
*3 RGGI sectors pre
*4 RGGI sectors post

*label values RGGI_Post summary

esttab A using "stateectorummary.rtf", main(mean) aux(sd) nostar ///
 nonote nonumber nomtitles collabels("Emissions") title("Summary stats by Sectors") replace
 
 estpost tabstat emissions, by(sec_treat) ///
statistics(mean sd) columns(statistics) listwise
est store B

esttab B using "statesectorummary2.rtf", main(mean) aux(sd) nostar ///
 nonote nonumber nomtitles collabels("Emissions") title("Summary stats by Treatment Group") replace
*/

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

replace RPS = 0 if sector != "Electric Power"

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
esttab A B using "sectorsummary.rtf", main(mean) aux(sd) nostar unstack ///
 nonote compress nonumber collabels ("Non RGGI Sectors" "RGGI Sectors") mtitles("Pre RGGI" "Post RGGI") title("Summary stats by RGGI Sectors") replace 
restore


*specifying time period to keep
*keep if year >= 2006 & year <2014
keep if year >=2000 & year <2017

*encoding sector as reghdfe cannot take in string variables
encode sector, gen (sector_n)

*generate state_sector groups for fixed effects
egen state_sector = group(state sector)

*ready to regress
*fixed effects is by state and not by observation unit
*reghdfe emissions sector_n DD GDP, absorb(state year)

*state_sector and year fixed effects
*reghdfe emissions sector_n DD GDP, absorb(state_sector year) 
est store a

*regression with clustered standard errors
*state_sector and year fixed effects

gen log_emissions = log(emissions)
*reghdfe emissions DD GDP population, absorb(state_sector year) cluster(state_sector)


egen statexyear = group(state year)
*************final model***************

*drop california
*drop if state == "california" 
*drop if state == "new jersey"

gen RGGIxPost = RGGI*post
est clear

reghdfe log_emissions RGGIxPost RPS if state != "california" | state != "new jersey", absorb(state_sector statexyear year) cluster(state_sector) 
est store a

*with new jersey
reghdfe log_emissions RGGIxPost RPS if state != "california", absorb(state_sector statexyear year) cluster(state_sector) 
est store b


*wit cali
reghdfe log_emissions RGGIxPost RPS if state != "new jersey", absorb(state_sector statexyear year) cluster(state_sector) 
est store c

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"
esttab a b c using "sector_state_regression.rtf", noconstant compress title("Table 4: Sector level Regression Results") mtitles("main model" "with California" "with new jersey") varwidth(15) modelwidth(11) replace label star(* 0.10 ** 0.05 *** 0.01)  nonum addnote("The outcome variable is log_emissions which is the log of emissions in a sector within a state in a given year. RGGIxPost is an interaction variable between RGGI and when the policy comes on. RPS is a dummy variable for the electric power sector in states with RPS.") 

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project"
preserve
sort year 
by year: egen treat_mean = mean(emissions) if sec_treat == 1
by year: egen control_mean = mean(emissions) if sec_treat != 1

*creating the common trends
twoway (line treat_mean year, c(1)) (line control_mean year, c(1)), xline(2009) title("Carbon emission by sector level treatment groups") ytitle("Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "Treatment Group" 2 "Control Group"))
restore

*******running the 2005 model***************
est clear
preserve
drop post
gen post = 0
replace post = 1 if year >= 2006

reghdfe log_emissions RGGIxPost RPS if state != "california" | state != "new jersey", absorb(state_sector statexyear year) cluster(state_sector)
est store d

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"


drop post 
gen post = 0
replace post = 1 if year >= 2005 & (state == "connecticut" | state == "delaware" |state == "new hampshire" |state == "new jersey" |state == "new york" | state == "vermont")
replace post = 1 if year >= 2007 & (state == "massachusetts" | state == "rhode island" |state == "maryland")
replace post = 1 if post == 0 & year >= 2005

reghdfe log_emissions RGGIxPost  RPS if state != "california" | state != "new jersey", absorb(state_sector year) cluster(state_sector)
est store e

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables"

esttab d e using "2005reg.rtf", noconstant compress title("Table 8: Robustness Check Results") mtitles("Robustness Check 1" "Robustness Check 2") varwidth(15) modelwidth(11) replace label star(* 0.10 ** 0.05 *** 0.01)  nonum addnote("The outcome variable is log_emissions is the log of emissions in a sector within a state in a given year. RGGIxPost is an interaction variable between RGGI and when the policy is assumed to come in 2005. RPS is a dummy variable for the electric power sector in states with RPS.") 
restore

*****************
*****graphical diff in diff analysis
preserve
*creating year dummies
tab year, gen(y)

*
gen treat_2000 = sec_treat*y1
gen treat_2001 = sec_treat*y2
gen treat_2002 = sec_treat*y3
gen treat_2003 = sec_treat*y4
gen treat_2004 = sec_treat*y5
gen treat_2005 = sec_treat*y6
gen treat_2006 = sec_treat*y7
gen treat_2008 = sec_treat*y9
gen treat_2009 = sec_treat*y10
gen treat_2010 = sec_treat*y11
gen treat_2011 = sec_treat*y12
gen treat_2012 = sec_treat*y13
gen treat_2013 = sec_treat*y14
gen treat_2014 = sec_treat*y15
gen treat_2015 = sec_treat*y16
gen treat_2016 = sec_treat*y17

*run actual regression again
reghdfe log_emissions treat_* population RPS GDP, absorb(state_sector year) cluster(state_sector)

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
twoway (rcap se_high se_low year) (connect beta year), title("Effect of RGGI on sectors") ytitle("Carbon Emissions in Million Metric Tonnes") xtitle("Years") xlabel(2000(2)2016) xline(2009) legend(order(1 "95% Confidence Interval" 2 "Beta"))
restore

************** Graphical DD for post == 2005********
preserve
drop post
gen post = 0

*creating year dummies
tab year, gen(y)

*
gen treat_2000 = sec_treat*y1
gen treat_2001 = sec_treat*y2
gen treat_2002 = sec_treat*y3
gen treat_2003 = sec_treat*y4
gen treat_2004 = sec_treat*y5
gen treat_2005 = sec_treat*y6
gen treat_2006 = sec_treat*y7
gen treat_2008 = sec_treat*y9
gen treat_2009 = sec_treat*y10
gen treat_2010 = sec_treat*y11
gen treat_2011 = sec_treat*y12
gen treat_2012 = sec_treat*y13
gen treat_2013 = sec_treat*y14
gen treat_2014 = sec_treat*y15
gen treat_2015 = sec_treat*y16
gen treat_2016 = sec_treat*y17

*run actual regression again
*reghdfe emissions treat_* , absorb(state_sector year) cluster(state_sector)

reghdfe log_emissions treat_* population RPS GDP, absorb(state_sector year) cluster(state_sector)

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
twoway (rcap se_high se_low year) (connect beta year), title("Effect of RGGI on sectors") ytitle("Carbon Emissions in Million Metric Tonnes") xtitle("Years") xlabel(2000(2)2016) xline(2005) legend(order(1 "95% Confidence Interval" 2 "Beta"))
restore


*creating relative year data
gen rel_year = 2005
replace rel_year = year - rel_year

