
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


global per="6" //set window size

use hosp_weathter_full_cdg0s, clear

	
	
	*- Generate core explanatory variables
			
			replace r_TempHigh=rw_TempHigh
		    gen dif_TempHigh= p_TempHigh-r_TempHigh 

	*- Generate fixed effects
	
			*- group indicator
			egen groups =group(group_age group_gender)

			*- year of month
			gen date_yrmonth=substr(str_时间,1,6)
				destring date_yrmonth,replace
			
			gen date_weekday=dow(date_ymd)
				destring date_weekday,replace
				
			cap egen city_month=group(city_id month)
			cap egen groups_month=group(groups month)

			destring year ,replace
			destring month ,replace
			
	*- Define user-defined functions
	
		* a. Define a custom function to group variables: bin_group0
			cap program drop bin_group0
			program define bin_group0
			    args varname newvar intervals
			    cap drop `newvar'
				gen `newvar' = .
				
			    local num_intervals = wordcount("`intervals'")
			    local first_interval = word("`intervals'", 1)

			    * Handle values ​​less than the first interval
			    replace `newvar' = 0 if `varname' < `first_interval'
			    
			    * Generate intervals
					
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

			
		*- b. Compared with bin_group0, bin_group also processes lagged periods
			cap program drop bin_group 
			program define bin_group
			    args varname newvar intervals
			    cap drop `newvar'
				gen `newvar' = .
				
			    local num_intervals = wordcount("`intervals'")
			    local first_interval = word("`intervals'", 1)

			    * Handle values ​​less than the first interval
			    replace `newvar' = 0 if `varname' < `first_interval'
			    
			    * Generate intervals
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
				
				
				//////////////////////////////////////////////////
				

				
				local periods $per
				sort city_id date_ymd		
							
				cap drop  L*_`varname'_B*

				*-  Generate Bins
				forval bins=0(1)`num_intervals' { 
					
					forval j=0(1)`periods' {
					
					cap gen L`j'_`varname'_B`bins'=0

					}
				}	
				
				disp "step1"
				
				*- for Bin_i=0
				
				replace L0_`varname'_B0=1 if `varname' < `first_interval'
				
				forval j=1(1)`periods' {
					
					bys city_id groups (date_ymd): replace L`j'_`varname'_B0=1 if `varname'[_n-`j'] < `first_interval'

				}
				


				*- for Bin_i>0
				
			    local i = 1
			    foreach low in `intervals' {
			        local high = word("`intervals'", `i' + 1)
					
			        if "`high'" != "" {
						
						forval j=0(1)`periods' {
							
							bys city_id groups (date_ymd): replace L`j'_`varname'_B`i'=1 if  `varname'[_n-`j'] >= `low' & `varname'[_n-`j'] < `high'
							
						}
		
						
			        }
					
			        else {
						
						forval j=0(1)`periods' {
							
						bys city_id groups (date_ymd): replace L`j'_`varname'_B`i'=1 if `varname'[_n-`j'] >= `low' & !mi(`varname'[_n-`j'])
							
						}
			        }

					//disp "step3:" `i' "/" `low' "/" `high'
					//disp `k'
			        local ++i
					
			    }
				
							
				*- Check if it is correct
				disp "Check if it is correct"
				
				forval j=0(1)`periods' {
					
					cap drop check_`varname'_L`j'
					gen check_`varname'_L`j'=0
					
					forval bins=0(1)`num_intervals' { 
					
						replace  check_`varname'_L`j'= check_`varname'_L`j'+L`j'_`varname'_B`bins'

					}
					
					tab check_`varname'_L`j'
					
				}
				
				
				*- translate to average cummulative effects
			
				forval bins=0(1)`num_intervals' { 
					
					forval j=0(1)`periods' {
					
						cap drop L`j'_`varname'_CB`bins'
						gen L`j'_`varname'_CB`bins'=. //L`j'_`varname'_B_`bins
					}
					
					replace  L0_`varname'_CB`bins'=L0_`varname'_B`bins'
					
					forval j=1(1)`periods' {
						
						replace  L`j'_`varname'_CB`bins'= L`j'_`varname'_B`bins'-L0_`varname'_B`bins'
						
					}

					replace  L0_`varname'_CB`bins'=L0_`varname'_B`bins'*`periods' 
					rename  L0_`varname'_CB`bins' CUM_`varname'_CB`bins'
					
				}
				

			end
		
	*- Generate bins of forecast errors for non-parametric estimation

	
			bys city_id year: asgen mean_Temp=dif_TempHigh, w(pop_cy)
			replace dif_TempHigh=dif_TempHigh -mean_Temp
			bin_group dif_TempHigh bin_dif_TempHigh "-3 2 -1 1 2 3"
			
			local periods $per
			forval j=0(1)`periods' {
				
				cap drop r_TempHigh_L`j'
				gen r_TempHigh_L`j'=. 
				bys city_id groups (date_ymd): replace  r_TempHigh_L`j'= r_TempHigh[_n-`j']
				bin_group0 r_TempHigh_L`j' bin_r_TempHigh_L`j'  "-5 0 5 10 15 20 25 30"

			}
			
					
			*Set reference group
			cap replace  CUM_dif_TempHigh_CB3=0
			local periods $per
				forval j=0(1)`periods' {
					cap replace L`j'_dif_TempHigh_CB3=0
				}
			
	*- Generate weather & pollution bins

			foreach var in r_WindAvg r_PM25 r_RainVol r_HumiAvg { //r_PresAvg 

				local periods $per
				forval j=0(1)`periods' {
					
					cap drop `var'_L`j'
					gen `var'_L`j'=. 
					bys city_id groups (date_ymd): replace  `var'_L`j'= `var'[_n-`j']
					xtile ctrl_nq_`var'_L`j'=`var'_L`j', nq(10)

				}
				
			}
			

	*- Generate variables of forecast erros for parametric estimation
			
			local periods $per
			forval j=0(1)`periods' {
				

				cap drop dif_TempHigh_L`j'
				bys city_id groups (date_ymd): gen dif_TempHigh_L`j'=dif_TempHigh[_n-`j']
				
				tab bin_r_TempHigh_L`j', gen(r_TempHigh_L`j'_B) //1-9
					
					gen e_bar_L`j'=0
					gen e_low_L`j'=(e_bar_L`j'-dif_TempHigh_L`j')*(dif_TempHigh_L`j'<=e_bar_L`j')
					gen e_high_L`j'=(dif_TempHigh_L`j'-e_bar_L`j')*(dif_TempHigh_L`j'>e_bar_L`j')
					gen is_high_L`j'=(dif_TempHigh_L`j'>e_bar_L`j')		
					
			}
			
			*translate to average cummulative effect
			local bins 0
			
			forval j=0(1)`periods' {
				gen L`j'_rT_CB`bins'=. 
				gen L`j'_elow_CB`bins'=. 
				gen L`j'_ehigh_CB`bins'=. 
				gen L`j'_ishigh_CB`bins'=. 

			}
			
			replace  L0_rT_CB`bins'=r_TempHigh_L0 
			replace  L0_elow_CB`bins'=e_low_L0 
			replace  L0_ehigh_CB`bins'=e_high_L0 
			replace  L0_ishigh_CB`bins'=is_high_L0 
			
			forval j=1(1)`periods' {
				
			replace  L`j'_rT_CB`bins'= r_TempHigh_L`j' -L0_rT_CB`bins'
			replace  L`j'_elow_CB`bins'= e_low_L`j'-L0_elow_CB`bins'
			replace  L`j'_ehigh_CB`bins'= e_high_L`j'-L0_ehigh_CB`bins'
			replace  L`j'_ishigh_CB`bins'= is_high_L`j'-L0_ishigh_CB`bins'
			
			}
			
			replace  L0_elow_CB`bins'=e_low_L0 *`periods'
			replace  L0_ehigh_CB`bins'=e_high_L0 *`periods'
			rename  L0_elow_CB`bins'   CUM_elow_CB`bins'
			rename  L0_ehigh_CB`bins'  CUM_ehigh_CB`bins'

	*- Sample processing: Remove city-year data with missing data
	
		forval i=2013(1)2019 {
			
			drop if Year`i'=="drop" & year==`i'
			drop if Year`i'=="drop2" & year==`i'
		}

	save treated_hosp_weathter_full_cdg0_AltRealized, replace 
	
