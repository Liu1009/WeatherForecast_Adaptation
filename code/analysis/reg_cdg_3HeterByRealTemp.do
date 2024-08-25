
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
/*  SECTION 1: title  			
    Notes: */
/**********************************************************************/


use treated_hosp_weathter_full_cdg0_HeterByRealized, clear


	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global cntrls ""
	global cls "city_id" 

	local main_dep Expense_total visit 
	local weighted "[aweight=pop_cyg]"
	
	cap erase "$tables/AppendixTable/AppendixTableA8.xls"
	cap erase "$tables/AppendixTable/AppendixTableA8.txt"
	
	foreach w in `main_dep' {
	foreach prefix in "l_" {
		foreach suffix in   `w'_pop  {
			foreach sample in "1"  { 
				
				reghdfejl `prefix'`suffix'  CUM_elow_CB*  CUM_ehigh_CB* L*_elow_CB* L*_ehigh_CB* is_high_L* ///
					${cntrls} `weighted' if `sample' , absorb(${abs}) cluster(${cls})
				
				outreg2 using "$tables/AppendixTable/AppendixTableA8.xls" ,append dec(3) keep(CUM_elow_CB* CUM_ehigh_CB*)
				
				coefplot, omitted vertical keep( CUM_elow_CB*) base  ///
					levels(90) ciopts( recast(rcap)) ///
					ylabel(, grid)  ytit("")  yline(0, lc(dkgreen)) ///
					xtit("Forecast Error (°C)") title("`prefix'`suffix'") xline() ///
					rename(CUM_elow_CB0="<-5" CUM_elow_CB1="0" ///
					CUM_elow_CB2="5" CUM_elow_CB3="10" CUM_elow_CB4="15" CUM_elow_CB5="20" ///
					CUM_elow_CB6="25" CUM_elow_CB7="30" CUM_elow_CB8=">35" ///
					)
					
					graph export "$tables/RB3_HeterByRealized_elow_`sample'_`prefix'`suffix'_wei.png", replace 
					
				coefplot, omitted vertical keep( CUM_ehigh_CB*) base  ///
					levels(90) ciopts(recast(rcap)) ///
					ylabel(, grid)  ytit("")  yline(0, lc(dkgreen)) ///
					xtit("Forecast Error (°C)") title("`prefix'`suffix'") xline() ///
					rename(CUM_ehigh_CB0="<-5" CUM_ehigh_CB1="0" ///
					CUM_ehigh_CB2="5" CUM_ehigh_CB3="10" CUM_ehigh_CB4="15" CUM_ehigh_CB5="20" ///
					CUM_ehigh_CB6="25" CUM_ehigh_CB7="30" CUM_ehigh_CB8=">35" ///
					)
					
					graph export "$tables/RB3_HeterByRealized_ehigh_`sample'_`prefix'`suffix'_wei.png", replace 
                   }
				}
			}
		}
