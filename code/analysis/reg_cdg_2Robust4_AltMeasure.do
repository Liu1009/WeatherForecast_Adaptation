
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



use treated_hosp_weathter_full_cdg0_AltRealized, clear

////////////////////////////////////////////////////////////////////////////////////////	


	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global cntrls ""
	global cls "city_id" 

	local weighted "[aweight=pop_cyg]"
	
	*- Reg: 
	
	local main_dep Expense_total  visit
	foreach w in `main_dep' {
	foreach prefix in "l_" {
		foreach suffix in   `w'_pop  {
			foreach sample in "1" { 
		
				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///
					${cntrls} `weighted' if `sample', absorb(${abs}) cluster(${cls})
				
				coefplot, omitted vertical keep( CUM_dif_TempHigh_CB*) base recast(con) ///
					levels(90) ciopts(color(%10) lcolor(navy) recast(rarea)) ///
					ylabel(-0.1 0 0.1 0.3 0.5, grid tposition(inside))  ytit("")  yline(0, lc(navy)) ///
					xtit("Forecast Error (°C)") xline() xlabel(,tposition(inside)) ///
					rename(CUM_dif_TempHigh_CB0="≤-3" CUM_dif_TempHigh_CB1="-2" ///
					CUM_dif_TempHigh_CB2="-1" CUM_dif_TempHigh_CB3="0" ///
					CUM_dif_TempHigh_CB4="1" CUM_dif_TempHigh_CB5="2" ///
					CUM_dif_TempHigh_CB6="≥3" ///
					)
				
				graph export "$tables/RB2_Robust4_Para_`sample'_`prefix'`suffix'_wei.png", replace 
					
                   }
				}
			}
		}

		
