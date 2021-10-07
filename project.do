clear

*create a path to save figures
global fig "$/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/Figures"

*****cleaning gdp data
import delimited "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/download.csv", clear 

gen rownumber = _n

drop if rownumber >= 53
drop if rownumber == 1
drop geofips

rename geoname state 

reshape long year, i(state) j(GDP)
drop rownumber

rename GDP ABC
rename year GDP
rename ABC year
replace state = lower(state)

drop if year < 2000
drop if year > 2017
save "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/GDP.dta", replace
********************

*******cleaning pop data
import excel "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/pop2010-2019.xlsx", sheet("NST01") firstrow clear

gen rownumber = _n

drop if rownumber == 1 | rownumber == 2 | rownumber == 3 | rownumber == 4 | rownumber == 5 | rownumber == 57 |rownumber == 58 | rownumber == 59 | rownumber == 60 | rownumber == 61 | rownumber == 62 | rownumber == 63 

drop Census EstimatesBase

local i = 2010

foreach var of varlist D E F G H I J K L M {
 
 rename `var' year_`i', force replace
 local i = `i' + 1
}
*generate state variable
gen state = substr(Geographicarea, 2, .)
replace state = lower(state)
*this data is cleaned
drop rownumber
save "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/pop2010-2019.dta", replace

*importing the 2000-2009 data
import excel "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/popdata 2000-2010.xls", sheet("ST-EST00INT-01.xls") firstrow clear

gen rownumber = _n

drop if rownumber == 1 | rownumber == 2 | rownumber == 3 | rownumber == 4 | rownumber == 5 | rownumber == 57 |rownumber == 58 | rownumber == 59 | rownumber == 60 | rownumber == 61 | rownumber == 62 | rownumber == 63 | rownumber == 64 | rownumber == 65 | rownumber == 66
drop B

local i = 2000

foreach var of varlist C D E F G H I J K L  {
 
 rename `var' year_`i', force replace
 local i = `i' + 1
}

drop M N rownumber
gen state = lower(substr(Geographicarea, 2, .))

*merging with 2010 onwards data
merge 1:1 state using "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/pop2010-2019.dta"

drop Geographicarea

*reshaping data to merge
reshape long year_, i(state) j(population)

rename population year 
rename year_ population

*save this data to merge with main data
drop _merge
save "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/populationdata.dta", replace

***********


clear

cd "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/data by outcome in industry"


import excel "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/data by outcome in industry/alaska.xlsx", sheet("Sheet1") clear

drop if C ==.

gen state = "alaska"
gen sector = ""
gen fueltype = ""


*** renaming variables
local i = 1980

foreach var of varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN{
 
 rename `var' year_`i', force replace
 local i = `i' + 1
}

drop if B == ""
drop A

*generate variable containing row numbers
gen rownumber = _n

*replacing sector variables
replace sector = "Residential" if rownumber == 1 | rownumber == 2 | rownumber == 3 |rownumber == 4 
replace sector = "Commercial" if rownumber == 5 | rownumber == 6 | rownumber == 7 |rownumber == 8
replace sector = "Industrial" if rownumber == 9 | rownumber == 10 | rownumber == 11 |rownumber == 12
replace sector = "Transportation" if rownumber == 13 | rownumber == 14 | rownumber == 15 |rownumber == 16
replace sector = "Electric Power" if rownumber == 17 | rownumber == 18 | rownumber == 19 |rownumber == 20

*drop data which can be regenerated using other data
drop if rownumber == 21 | rownumber == 22 | rownumber == 23 |rownumber == 24

*replace fueltype
replace fueltype = "Coal" if rownumber == 1 | rownumber == 5 | rownumber == 9 |rownumber == 13 |rownumber ==  17
replace fueltype = "Petroleum" if rownumber == 2 | rownumber == 6 | rownumber == 10 |rownumber == 14 |rownumber == 18
replace fueltype = "Natural" if rownumber == 3 | rownumber == 7 | rownumber == 11 |rownumber == 15 |rownumber == 19

*try reshaping data now
reshape long year_, i(state sector fueltype) j(emissions)

rename emissions ABC
rename ABC year
rename year_ emissions

drop fueltype
rename B fueltype

save "states.dta",replace


*trying to write code to import excel files using a loop
foreach state in alabama arizona arkansas california colorado connecticut delaware florida georgia hawaii idaho illinois indiana iowa kansas kentucky louisiana maine maryland massachusetts michigan minnesota mississippi missouri montana nebraska nevada new_hampshire new_jersey new_mexico new_york north_carolina north_dakota ohio oklahoma oregon pennsylvania rhode_island south_carolina south_dakota tennessee texas utah vermont virginia washington west_virginia wisconsin wyoming district_of_columbia  {
    import excel "`state'.xlsx", sheet("Sheet1") clear
	
	
************Method 1
drop if C ==.

gen state = "`state'"
gen sector = ""
gen fueltype = ""


*** renaming variables
local i = 1980

foreach var of varlist C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN{
 
 rename `var' year_`i', force replace
 local i = `i' + 1
}

drop if B == ""
drop A

*generate variable containing row numbers
gen rownumber = _n

*replacing sector variables
replace sector = "Residential" if rownumber == 1 | rownumber == 2 | rownumber == 3 |rownumber == 4 
replace sector = "Commercial" if rownumber == 5 | rownumber == 6 | rownumber == 7 |rownumber == 8
replace sector = "Industrial" if rownumber == 9 | rownumber == 10 | rownumber == 11 |rownumber == 12
replace sector = "Transportation" if rownumber == 13 | rownumber == 14 | rownumber == 15 |rownumber == 16
replace sector = "Electric Power" if rownumber == 17 | rownumber == 18 | rownumber == 19 |rownumber == 20

*drop data which can be regenerated using other data
drop if rownumber == 21 | rownumber == 22 | rownumber == 23 |rownumber == 24

*replace fueltype
replace fueltype = "Coal" if rownumber == 1 | rownumber == 5 | rownumber == 9 |rownumber == 13 |rownumber ==  17
replace fueltype = "Petroleum" if rownumber == 2 | rownumber == 6 | rownumber == 10 |rownumber == 14 |rownumber == 18
replace fueltype = "Natural" if rownumber == 3 | rownumber == 7 | rownumber == 11 |rownumber == 15 |rownumber == 19

*try reshaping data now
reshape long year_, i(state sector fueltype) j(emissions)

rename emissions ABC
rename ABC year
rename year_ emissions

drop fueltype
rename B fueltype

append using "states.dta"
save "states.dta",replace
}

*renaming state variables
replace state =  "new hampshire" if state == "new_hampshire"
replace state =  "new jersey" if state == "new_jersey" 
replace state =  "new mexico" if state == "new_mexico" 
replace state =  "new york" if state == "new_york" 
replace state =  "north carolina" if state == "north_carolina"
replace state =  "north dakota" if state == "north_dakota"
replace state =  "rhode island" if state == "rhode_island"  
replace state =  "south carolina" if state == "south_carolina" 
replace state =  "south dakota" if state == "south_dakota"  
replace state =  "district of columbia" if state == "district_of_columbia" 
replace state =  "west virginia" if state == "west_virginia" 
 

drop rownumber
*generating treat variable
gen treat =.

*replace treat = 1 for RGGI states as well as California which has its own cap and trade market
replace treat = 1 if state == "connecticut" | state == "delaware" | state == "maine" | state == "new hampshire" | state == "new jersey" | state == "new york" | state == "vermont" | state == "maryland" | state == "massachusetts" | state == "rhode island" |  state == "california" 


*merge gdp data 
*generating post variable
gen post =.

*replace post variables based on first auctions which was 2008- California was 2013
replace post = 1 if (state == "connecticut" | state == "delaware" | state == "maine" | state == "new hampshire" | state == "new jersey" | state == "new york" | state == "vermont" | state == "maryland" | state == "massachusetts" | state == "rhode island" ) & year >= 2008

replace post = 1 if state == "california" & year >= 2013

save "projectdata.dta", replace
*can theoretically run the diff in diff now

*****creating the three different data sets

*1 creating sector by state data
preserve
keep if fueltype == "Total"
*saving this data
save "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/sector_state.dta",replace
restore

*2 creating fueltype by sector by state data
preserve
drop if fueltype == "Total"
*saving this data
save "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/fuel_sector_state.dta",replace
restore

*3 create state by year data
preserve
keep if fueltype == "Total"

sort state year sector

egen state_years_obs = group(state year)

order state_years_obs

gen state_emmissions = .

forvalues i=1/1938 {
  replace state_emmissions = sum(emissions) if state_years_obs == `i'
  
}

forvalues i=1/1938 {
  keep if sector == "Transportation"
}

keep state year state_emmissions
rename state_emmissions emissions

save "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/state_year.dta",replace
restore

*run state_year analysis
do "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/state_year.do"

*run sector year analysis
do "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/sector_state.do"

*run fuel_sector_state analysis
do "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/fuel_sector_state.do"
/*
RGGI was first established in 2005 and auctions were first done in 2008
 In 2005 Connecticut, Delaware, Maine, New Hampshire, New Jersey, New York, and Vermont joined 
 and in 2007 Maryland, Massachusetts, and Rhode Island joined 
 ****New Jersey withdrew in 2012 and re joined in 2020
 RGGI requires fossil fuel power plants with capacity greater than 25 megawatts to obtain an allowance for each ton of carbon dioxide they emit annually (RGGI website)
 Between 2008 and 2013, RGGI operated using the original Model Rule, 
 California enacted carbon cap and trade in 2013
*/






