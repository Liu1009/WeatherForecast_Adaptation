
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


use treated_hosp_weathter_full_cdg_IsOutpatient.dta, clear

	cap erase "$tables/AppendixTable/AppendixTableA5_1.xls"
	cap erase "$tables/AppendixTable/AppendixTableA5_1.txt"
	
	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global cntrls ""
	global cls "city_id" 

	local main_dep Expense_total visit 
	local weighted "[aweight=pop_cyg]"

	foreach w in `main_dep' {
		
		forval i=0(1)1 {
	
		foreach prefix in "l_" {
			foreach suffix in   `w'_pop  {
				
				foreach sample in "1"  {
				
				reghdfejl `prefix'`suffix'  CUM_elow_CB*  CUM_ehigh_CB* L*_elow_CB* L*_ehigh_CB* is_high_L* ///
					${cntrls} `weighted' if `sample' & type_IsOutpatient==`i', absorb(${abs}) cluster(${cls}) level(90)
				
				est store type_IsOutpatient`i'
				outreg2 using "$tables/AppendixTable/AppendixTableA5_1.xls" ,append dec(3) keep(L*_elow_CB0 L*_ehigh_CB0)
					
                   }
				}
			}
		}			
		
	}
	
	

use treated_hosp_weathter_full_cdg_Disease.dta, clear

	
	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global cntrls ""
	global cls "city_id" 

	local main_dep Expense_total visit 
	local weighted "[aweight=pop_cyg]"

	foreach w in `main_dep' {
		
		forval i=0(1)2 {
	
		foreach prefix in "l_" {
			foreach suffix in   `w'_pop  {
				
				foreach sample in "1"  {
				
				reghdfejl `prefix'`suffix'  CUM_elow_CB*  CUM_ehigh_CB* L*_elow_CB* L*_ehigh_CB* is_high_L* ///
					${cntrls} `weighted' if `sample' & type_dises==`i', absorb(${abs}) cluster(${cls}) level(90)
				
				est store type_dises`i'
				outreg2 using "$tables/AppendixTable/AppendixTableA5_1.xls" ,append dec(3) keep(L*_elow_CB0 L*_ehigh_CB0)
					
                   }
				}
			}
		}			
		
	}
