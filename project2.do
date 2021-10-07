clear

*import excel "C:\Users\tibrewal\Desktop\Seminar in Microeconometrics\project\state_co2_emissions_from_fossil_fuel_combustion_1990-2018.xlsx", sheet("Table 1") firstrow

import excel "/Users/ishaantibrewal/Desktop/Classes/F2/Seminar in Microeconometrics/project/state_co2_emissions_from_fossil_fuel_combustion_1990-2018.xlsx",sheet("Table 1") clear



rename C Year1990
rename D Year1991
rename E Year1992
rename F Year1993
rename G Year1994
rename H Year1995
rename I Year1996
rename J Year1997
rename K Year1998
rename L Year1999
rename M Year2000
rename N Year2001
rename O Year2002
rename P Year2003
rename Q Year2004
rename R Year2005
rename S Year2006
rename T Year2007
rename U Year2008
rename V Year2009
rename W Year2010
rename X Year2011
rename Y Year2012
rename Z Year2013
rename AA Year2014
rename AB Year2015
rename AC Year2016
rename AD Year2017
rename AE Year2018



rename A State

drop if State == "State"
rename B  Sector

*reshape wide stub, i(State) j(Sector), string
reshape long Year, i(State Sector) j(Emissions)

rename Emissions ABC 
rename Year Emissions
rename ABC Year
