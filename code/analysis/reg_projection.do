
global root= "E:\Project"
global dofiles= "$root/Dofiles"
global logfiles= "$root/Logfiles"
global raw_data= "$root/Raw_data"
global working_data= "$root/Working_data"
global temp_data= "$root/Temp_data"
global tables= "$root/Tables2"
global figures= "$root/Figures"
cd "$working_data"
set scheme s1color

/**********************************************************************/
/*  SECTION 1: Calculate the temperature distributions under different SSPs
    Notes: */
/**********************************************************************/

use CMIP6_SSPs_Cities.dta, clear
	*use Aggregatedata_v2.dta, clear

	* trans from K to °C
	gen tasmax_C=tasmax-273.15
	gen tasmin_C=tasmin-273.15

	sum tasmax_C tasmin_C

	merge m:1 city using city-城市名list.dta,nogen
		tostring year, gen(year_s)
		tostring month, gen(month_s)
		tostring day, gen(day_s)

		replace month_s="0"+month_s if month<10
		replace day_s="0"+day_s if day<10

		gen 时间=year_s+month_s+day_s
		destring 时间, replace

		replace 城市="福州" if 城市=="厦门"

	merge m:1 城市 source using tbmerge_temp_adj.dta,nogen

	replace tasmax_C=tasmax_C-mdif_max
	replace tasmin_C=tasmin_C-mdif_min

	* divide to temp. bins
	
			cap program drop bin_group0
			program define bin_group0
			    args varname newvar intervals
			    cap drop `newvar'
				gen `newvar' = .
				
			    local num_intervals = wordcount("`intervals'")
			    local first_interval = word("`intervals'", 1)

			    replace `newvar' = 0 if `varname' < `first_interval'
			    					
			    local i = 1
			    foreach low in `intervals' {
			        local high = word("`intervals'", `i' + 1)
			        if "`high'" != "" {
			            replace `newvar' = `i' if `varname' >= `low' & `varname' < `high'
			        }
			        else {
			            replace `newvar' = `i' if `varname' >= `low' & `varname'<.
			        }

					
			        local ++i
			    }

			    tab `newvar' 
				
			end

		bin_group0 tasmax_C bin_tasmax_C  "-5 0 5 10 15 20 25 30"
		bin_group0 tasmin_C bin_tasmin_C  "-5 0 5 10 15 20 25 30"


	*- gen BinDays 

		forvalues j = 0 (1) 8 {

			gen counter_maxb`j'=(bin_tasmax_C==`j')
			bys city year source: egen Days_maxBin`j'=sum(counter_maxb`j')
	
			gen counter_minb`j'=(bin_tasmin_C==`j')
			bys city year source: egen Days_minBin`j'=sum(counter_minb`j')

		}  // end of forvalues j = 1 (1) n

		duplicates drop city year source, force

		keep year 城市 source Days_maxBin* Days_minBin*
		
	save DaysOfBins_SSPs_Cities.dta, replace


		
		

/**********************************************************************/
/*  SECTION 2: Caculate the distribution of forecast erros across cities		
    Notes: */
/**********************************************************************/

use hosp_weathter_full_cdg0s, clear

	*- Generate core explanatory variables
		
		gen dif_TempHigh= p_TempHigh-r_TempHigh 
			
		gen counter1=dif_TempHigh<=-3
		gen counter2=dif_TempHigh==-2
		gen counter3=dif_TempHigh==-1
		gen counter4=dif_TempHigh==0
		gen counter5=dif_TempHigh==1
		gen counter6=dif_TempHigh==2		
		gen counter7=dif_TempHigh>=3
	

		forval i=1(1)7 {
			
			bys city_id: egen num_bin`i'=sum(counter`i')
			
		}
			
		duplicates drop city_id, force
		
		keep city_id 城市 num_bin*
					
save Error_num_bins.dta, replace

/**********************************************************************/
/*  SECTION 3: Merge	
    Notes: */
/**********************************************************************/

 use DaysOfBins_SSPs_Cities.dta, clear
 
	duplicates report year 城市
	merge m:1 城市 using Error_num_bins.dta
	gen coef_name="Coefficient"
	
	cap drop _merge
	merge m:1 城市 using weight_city_pop2020.dta, nogen
	
	merge m:1 coef_name using coef.dta, nogen
			
	gen wrong_freq_high=(num_bin1+num_bin2+num_bin3)/365*1.64/7
	gen wrong_freq_low=(num_bin5+num_bin6+num_bin7)/365*1.29/7
		
	forval i=0(1)8 {
		
		gen demage_bin`i'=(wrong_freq_high*coef_bin`i'_high+wrong_freq_low*coef_bin`i'_low)/365*7
		replace  demage_bin`i'=Days_maxBin`i'*demage_bin`i'
		
	}
	
	gen demage_sum=demage_bin0
 
 	forval i=1(1)8 {
		
		replace demage_sum=demage_sum+demage_bin`i'
	}
	
	collapse (mean) demage_sum [aw=y20_pop], by(year source) 
	tab source
	
	preserve
		keep if source=="daily_ssp_126" 
		set scheme s1color
		twoway scatter demage_sum year,mcolor("112 160 255 %60") msymbol(Oh) || lfitci demage_sum year,ciplot(rline) clcolor("248 118 109 *1.8" ) acolor("248 118 109 *1.8" ) level(99) legend(off) title("SSP1-2.6") xtitle("") alpattern(dash) ylabel(,tposition(inside)) xlabel(,tposition(inside))
		graph save daily_ssp_126.gph, replace
	restore
	
	preserve
		keep if source=="daily_ssp_245"
		set scheme s1color
		twoway scatter demage_sum year,mcolor("112 160 255 %60") msymbol(Oh) ||  lfitci demage_sum year,ciplot(rline) clcolor("248 118 109 *1.8" ) acolor("248 118 109 *1.8" ) level(99) legend(off) title("SSP2-4.5") xtitle("") alpattern(dash) ylabel(,tposition(inside)) xlabel(,tposition(inside))
		graph save daily_ssp_245.gph, replace
	restore
	
	preserve
		keep if source=="daily_ssp_370" 
		set scheme s1color
		twoway scatter demage_sum year,mcolor("112 160 255 %60") msymbol(Oh) ||  lfitci demage_sum year,ciplot(rline) clcolor("248 118 109 *1.8" ) acolor("248 118 109 *1.8" ) level(99) legend(off) title("SSP3-7.0") xtitle("")  alpattern(dash) ylabel(,tposition(inside)) xlabel(,tposition(inside))
		graph save daily_ssp_370.gph, replace
	restore
	
	preserve
		keep if source=="daily_ssp_585" 
		set scheme s1color
		twoway scatter demage_sum year,mcolor("112 160 255 %60") msymbol(Oh) ||  lfitci demage_sum year,ciplot(rline) clcolor("248 118 109 *1.8" ) acolor("248 118 109 *1.8" ) level(99) legend(off) title("SSP5-8.5") xtitle("") alpattern(dash) ylabel(,tposition(inside)) xlabel(,tposition(inside))
		graph save daily_ssp_585.gph, replace
	restore
	
	 gr combine "daily_ssp_585" "daily_ssp_370" "daily_ssp_245" "daily_ssp_126"  , col(2) ycommon
	 gr export $tables/SSPs.png,replace
	 gr save $figures/calculate/calculate.gph,replace
	 
	 
	 

		
		
