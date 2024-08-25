
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



global per="6" 

use treated_hosp_weathter_full_cdg0, clear

	summarize Expense_total_pop visit_pop dif_TempHigh r_TempHigh r_WindAvg r_RainVol r_HumiAvg  r_PM25 [aweight=]

////////////////////////////////////////////////////////////////////////////////////////	




	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global cntrls ""
	global cls "city_id" 

	local weighted "[aweight=pop_cyg]"
	
	*- Plot fitted line estimated From Parametric Estimation
	
	cap gen y_Expense_total=.
	cap gen y_visit=.
	cap gen xxx=.
					
	replace xxx=1 if _n==1
	replace xxx=4 if _n==2
	replace xxx=7 if _n==3
	
	replace y_Expense_total=0.137*3 if _n==1 
	replace y_Expense_total=0 if _n==2
	replace y_Expense_total=0.046*3 if _n==3
	
	replace y_visit=0.073*3 if _n==1
	replace y_visit=0 if _n==2
	replace y_visit=0.027*3 if _n==3
	
	*- Reg: 
	
	local main_dep Expense_total  
	foreach w in `main_dep' {
	foreach prefix in "l_" {

		foreach suffix in   `w'_pop  {
			foreach sample in "1" { 
		
				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///
					${cntrls} `weighted' if `sample' , absorb(${abs}) cluster(${cls})
				
				coefplot, omitted vertical keep( CUM_dif_TempHigh_CB*) base recast(con) ///
					levels(90) ciopts(color(%10) lcolor(navy) recast(rarea)) ///
					ylabel(-0.1 0 0.1 0.3 0.5, grid tposition(inside))  ytit("")  yline(0, lc(navy)) ///
					xtit("Forecast Error (°C)") xline() xlabel(,tposition(inside)) ///
					rename(CUM_dif_TempHigh_CB0="≤-3" CUM_dif_TempHigh_CB1="-2" ///
					CUM_dif_TempHigh_CB2="-1" CUM_dif_TempHigh_CB3="0" ///
					CUM_dif_TempHigh_CB4="1" CUM_dif_TempHigh_CB5="2" ///
					CUM_dif_TempHigh_CB6="≥3" ///
					)
				
				addplot: scatter y_`main_dep' xxx  if _n<3 & xxx>=1, connect(l) lpattern(longdash)  msymbol(none) norescaling
				addplot: scatter y_`main_dep' xxx  if _n>1 & xxx<=7 ,connect(l) lpattern(dash)  msymbol(none) norescaling
				
				graph export "$tables/RB1_Main_Para_`sample'_`prefix'`suffix'_wei.png", replace 
				graph save "$figures/Baseline/Figure1_`sample'_`prefix'`suffix'_wei.gph",replace
					
                   }
				}
			}
		}

	local main_dep visit 

	foreach w in `main_dep' {
	foreach prefix in "l_" {
		foreach suffix in   `w'_pop  {
			foreach sample in "1" { 
		
				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///
					${cntrls} `weighted' if `sample' , absorb(${abs}) cluster(${cls})
				
				coefplot, omitted vertical keep( CUM_dif_TempHigh_CB*) base recast(con) ///
					levels(90) ciopts(color(%10) lcolor(navy) recast(rarea)) ///
					ylabel(-0.1 0 0.1 0.3 0.5, grid tposition(inside))  ytit("")  yline(0, lc(navy)) ///
					xtit("Forecast Error (°C)") xline() xlabel(,tposition(inside)) ///
					rename(CUM_dif_TempHigh_CB0="≤-3" CUM_dif_TempHigh_CB1="-2" ///
					CUM_dif_TempHigh_CB2="-1" CUM_dif_TempHigh_CB3="0" ///
					CUM_dif_TempHigh_CB4="1" CUM_dif_TempHigh_CB5="2" ///
					CUM_dif_TempHigh_CB6="≥3" ///
					)
				
				addplot: scatter y_`main_dep' xxx  if _n<3 & xxx>=1, connect(l) lpattern(longdash)  msymbol(none) norescaling
				addplot: scatter y_`main_dep' xxx  if _n>1 & xxx<=7 ,connect(l) lpattern(dash)  msymbol(none) norescaling
				
				graph export "$tables/RB1_Main_Para_`sample'_`prefix'`suffix'_wei.png", replace 
				graph save "$figures/Baseline/Figure1_`sample'_`prefix'`suffix'_wei.gph",replace
					
                   }
				}
			}
		}