clear 
*create a path to save figures
global fig "$/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Figures"

use "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/fuel_sector_state.dta",clear

drop treat
drop post

drop if year < 2000

*merge with gdp data
merge m:1 state year using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/GDP.dta"
drop _merge

*merging population data
merge m:1 state year using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/populationdata.dta"

*drop california
drop if state == "california" | state == "new jersey"

*gen sector treat variable
gen sec_treat =0

replace sec_treat = 1 if (state == "connecticut" | state == "delaware" | state == "maine" | state == "new hampshire" | state == "new jersey" | state == "new york" | state == "vermont" | state == "maryland" | state == "massachusetts" | state == "rhode island" |  state == "california") & sector == "Electric Power"

gen post =0
replace post = 1 if year >= 2009

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

*creating summary stats by treatment and control group
bysort sec_treat: sum emissions GDP

estpost tabstat emissions, by(fueltype) ///
statistics(mean sd) columns(statistics) listwise
est store A

esttab A using "fuelsectorummaryctorummary.rtf", main(mean) aux(sd) nostar ///
 nonote nonumber nomtitles collabels("Emissions") title("Carbon emissions by fueltype within a sector") replace
 

*specifying time period to keep
keep if year >=2000 & year <2017

*encoding sector and fuel type since reghdfe cannot take in string variables
encode sector, gen (sector_n)
encode fueltype, gen (fueltype_n)



*gen observation level fixed effects
egen state_fueltype = group(state fueltype)
egen state_sector_fueltype = group(state sector fueltype)
egen state_sector = group(state sector)
egen statexsectorxyear = group(state_sector year)
egen statexyear = group(state year)
*logging emissions
gen log_emissions = log(emissions)

*run regression
*reghdfe emissions DD GDP  fueltype_n, absorb(state_fueltype year)


*********creat triple diff variables

*gen DD variable
gen RGGI = sec_treat
gen RGGIxPost = RGGI*post
*coal
gen Coal = 1 if fueltype == "Coal"
replace Coal = 0 if Coal == .
gen RGGIxPostxCoal = RGGIxPost*Coal
gen RGGIxCoal = RGGI*Coal
gen postxcoal = post*Coal

*state year fixed effects
*reghdfe emissions RGGIxPost RGGIxPostxCoal GDP population RGGIxCoal postxcoal, absorb(state year)

*state_fuel type fixed effects
*reghdfe log_emissions RGGIxPost RGGIxPostxCoal GDP population RGGIxCoal postxcoal, absorb(state_fueltype year) 
*reghdfe log_emissions RGGIxPost RGGIxPostxCoal GDP population RGGIxCoal postxcoal, absorb(state_fueltype year) 

**final model
reghdfe log_emissions RGGIxPostxCoal, absorb(state_sector_fueltype statexsectorxyear year) cluster(state_sector)
est store a

*Natural Gas
gen Natural = 1 if fueltype == "Natural Gas"
replace Natural = 0 if Natural == .
gen RGGIxPostxNatural = RGGIxPost*Natural
gen RGGIxNatural = RGGI*Natural
gen postxNatural = post*Natural



*state year fixed effects
*reghdfe emissions RGGIxPost RGGIxPostxNatural GDP RGGIxNatural postxNatural population sector_n fueltype_n, absorb(state year) 
*reghdfe log_emissions DD DDD2 GDP treat_Natural post_Natural sector_n fueltype_n, absorb(state year) 
*state_fuel type fixed effects
*reghdfe emissions DD DDD2 GDP treat_Natural post_Natural sector_n fueltype_n, absorb(state_fueltype year)


***final model
reghdfe log_emissions RGGIxPostxNatural, absorb(state_sector_fueltype statexsectorxyear year) cluster(state_sector)
est store b


*Petroleum Products
gen Petroleum = 1 if fueltype == "Petroleum Products"
replace Petroleum = 0 if Petroleum == .
gen RGGIxPostxPetroleum = RGGIxPost*Petroleum
gen RGGIxPetroleum = RGGI*Petroleum
gen postxPetroleum = post*Petroleum

**final model
reghdfe log_emissions RGGIxPostxPetroleum, absorb(state_sector_fueltype statexsectorxyear year) cluster(state_sector)
est store c

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Tables" 

esttab a b c using "fuel_regression.rtf", compress title("Table 7: Fuel level Regression Results") mtitles("Coal" "Natural Gas" "Petroleum Products") varwidth(20) modelwidth(11) replace nonumber noconstant label star(* 0.10 ** 0.05 *** 0.01) addnote ("The outcome variable is log_emissions is the log of emissions in a state in a given year. RGGIxPostxCoal is an interaction variable between RGGI, when the policy comes on, and an indicator variable for coal. RGGIxPostxNatural is an interaction variable between RGGI, when the policy comes on, and an indicator variable for Natural Gas. RGGIxPostxPetroleum is an interaction variable between RGGI, when the policy comes on, and an indicator variable for Petroleum Products")

*************graphical DD analysis to see where drop in emissions is coming from 

*****Coal*****************
preserve
*creating year dummies
tab year, gen(y)

*****triple diff graph?

*we will leave out 2007 as reference year
gen treat_2000 = sec_treat*y1*Coal
gen treat_2001 = sec_treat*y2*Coal
gen treat_2002 = sec_treat*y3*Coal
gen treat_2003 = sec_treat*y4*Coal
gen treat_2004 = sec_treat*y5*Coal
gen treat_2005 = sec_treat*y6*Coal
gen treat_2006 = sec_treat*y7*Coal
gen treat_2008 = sec_treat*y9*Coal
gen treat_2009 = sec_treat*y10*Coal
gen treat_2010 = sec_treat*y11*Coal
gen treat_2011 = sec_treat*y12*Coal
gen treat_2012 = sec_treat*y13*Coal
gen treat_2013 = sec_treat*y14*Coal
gen treat_2014 = sec_treat*y15*Coal
gen treat_2015 = sec_treat*y16*Coal
gen treat_2016 = sec_treat*y17*Coal

*run actual regression again
*reghdfe emissions treat_* , absorb(state_sector year) cluster(state_sector)

reghdfe log_emissions treat_*  RGGIxPostxCoal, absorb(state_sector_fueltype statexsectorxyear statexyear  year) cluster(state_sector)

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
twoway (rcap se_high se_low year) (connect beta year), xlabel(2000(2)2016)ytitle("Coal Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "95% Confidence Interval" 2 "Beta")) title("Effect of RGGI on Coal") xline(2009)

restore

********Natural gas*****************
preserve
*creating year dummies
tab year, gen(y)

*we will leave out 2007 as reference year
gen treat_2000 = sec_treat*y1*Natural
gen treat_2001 = sec_treat*y2*Natural
gen treat_2002 = sec_treat*y3*Natural
gen treat_2003 = sec_treat*y4*Natural
gen treat_2004 = sec_treat*y5*Natural
gen treat_2005 = sec_treat*y6*Natural
gen treat_2006 = sec_treat*y7*Natural
gen treat_2008 = sec_treat*y9*Natural
gen treat_2009 = sec_treat*y10*Natural
gen treat_2010 = sec_treat*y11*Natural
gen treat_2011 = sec_treat*y12*Natural
gen treat_2012 = sec_treat*y13*Natural
gen treat_2013 = sec_treat*y14*Natural
gen treat_2014 = sec_treat*y15*Natural
gen treat_2015 = sec_treat*y16*Natural
gen treat_2016 = sec_treat*y17*Natural

*run actual regression again
reghdfe log_emissions treat_* RGGIxPost RGGIxPostxNatural GDP population RGGIxNatural postxNatural, absorb(state_sector_fueltype statexsectorxyear statexyear  year) cluster(state_sector)

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


twoway (rcap se_high se_low year) (connect beta year), xlabel(2000(2)2016) ytitle("Natural Gas Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "95% Confidence Interval" 2 "Beta")) title("Effect of RGGI on Natural Gas") xline(2009)
restore

********Petroleum Products*****************
preserve
*creating year dummies
tab year, gen(y)

*we will leave out 2007 as reference year
gen treat_2000 = sec_treat*y1*Petroleum
gen treat_2001 = sec_treat*y2*Petroleum
gen treat_2002 = sec_treat*y3*Petroleum
gen treat_2003 = sec_treat*y4*Petroleum
gen treat_2004 = sec_treat*y5*Petroleum
gen treat_2005 = sec_treat*y6*Petroleum
gen treat_2006 = sec_treat*y7*Petroleum
gen treat_2008 = sec_treat*y9*Petroleum
gen treat_2009 = sec_treat*y10*Petroleum
gen treat_2010 = sec_treat*y11*Petroleum
gen treat_2011 = sec_treat*y12*Petroleum
gen treat_2012 = sec_treat*y13*Petroleum
gen treat_2013 = sec_treat*y14*Petroleum
gen treat_2014 = sec_treat*y15*Petroleum
gen treat_2015 = sec_treat*y16*Petroleum
gen treat_2016 = sec_treat*y17*Petroleum

*run actual regression again
reghdfe log_emissions treat_* RGGIxPost RGGIxPostxPetroleum GDP population RGGIxPetroleum postxPetroleum, absorb(state_sector_fueltype statexsectorxyear statexyear year) cluster(state_sector)

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
twoway (rcap se_high se_low year) (connect beta year), xlabel(2000(2)2016)ytitle("Petroleum Products Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "95% Confidence Interval" 2 "Beta")) title("Effect of RGGI on Petroleum Products") xline(2009)
restore

