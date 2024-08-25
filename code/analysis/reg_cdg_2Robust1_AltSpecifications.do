
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

global per="6" 

use treated_hosp_weathter_full_cdg0, clear

	*- Generate quadratic term of controls
			foreach var in r_WindAvg r_PM25 r_RainVol r_HumiAvg { 

				local periods $per
				forval j=0(1)`periods' {
					
					cap drop `var'_L`j'
					gen `var'_L`j'=. 
					bys city_id groups (date_ymd): replace  `var'_L`j'= `var'[_n-`j']
					*xtile ctrl_nq_`var'_L`j'=`var'_L`j', nq(10)
					gen f2_`var'_L`j'=`var'_L`j'^2
					gen f1_`var'_L`j'=`var'_L`j'

				}
				
			}
			

	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global abs1 "date_yrmonth city_id#groups  "	
	global abs2 "date_yrmonth date_weekday city_month groups_month  bin_r_TempHigh_L*  "	
	global abs3 "date_ymd date_weekday city_month groups_month  bin_r_TempHigh_L*  "	
	global abs4 "date_yrmonth date_weekday city_id#c.year city_month groups_month  bin_r_TempHigh_L*  "	
	global cntrls "f2* f1*"
	global cls "city_id"

	local main_dep Expense_total visit 
	local weighted "[aweight=pop_cyg]"


	cap erase "$tables/AppendixTable/AppendixTableA3.xls"
	cap erase "$tables/AppendixTable/AppendixTableA3.txt"
	
	foreach w in `main_dep' {
	foreach prefix in "l_" {
		foreach suffix in   `w'_pop  {
			foreach sample in "1" { 
				
 				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///${cntrls}
 				`weighted' if `sample' , absorb(${abs}) cluster(${cls})
				outreg2 using "$tables/AppendixTable/AppendixTableA3.xls" ,append dec(3) keep(CUM_dif_TempHigh_CB*)
 					est store dd_`w'_1
					
 				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///${cntrls} 
 					`weighted' if `sample' , absorb(${abs1}) cluster(${cls})
				outreg2 using "$tables/AppendixTable/AppendixTableA3.xls" ,append dec(3) keep(CUM_dif_TempHigh_CB*)
 					est store dd_`w'_2					
					
 				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///${cntrls} 
 					`weighted' if `sample' , absorb(${abs2}) cluster(${cls})
					outreg2 using "$tables/AppendixTable/AppendixTableA3.xls" ,append dec(3) keep(CUM_dif_TempHigh_CB*)
 					est store dd_`w'_3
					
 				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///
 					${cntrls} `weighted' if `sample' , absorb(${abs3}) cluster(${cls})
					outreg2 using "$tables/AppendixTable/AppendixTableA3.xls" ,append dec(3) keep(CUM_dif_TempHigh_CB*)
 					est store dd_`w'_4
	
				reghdfejl `prefix'`suffix'  CUM_dif_TempHigh_CB* L*_dif_TempHigh_CB* ///${cntrls}
					`weighted' if `sample' , absorb(${abs4}) cluster(${cls})
					outreg2 using "$tables/AppendixTable/AppendixTableA3.xls" ,append dec(3) keep(CUM_dif_TempHigh_CB*)
					est store dd_`w'_5
					
					
		colorpalette			
		event_plot 	dd_`w'_1 dd_`w'_2 dd_`w'_3 dd_`w'_4 dd_`w'_5, 	///
		stub_lag( CUM_dif_TempHigh_CB# ) 		///		stub_lead(F_#	)		///
			together perturb(0) trimlead(0) trimlag(7) noautolegend 									///perturb(-0.1 0.1) 
			plottype(line) ciplottype(line)  alpha(0.10)													///
				lag_opt1(msymbol(Oh) msize(1.2) mlwidth(0.3) color("`r(p1)'"%80)) lag_ci_opt1(color("`r(p1)'"%10) lw(0.1) lwidth(thick) lpattern(dash)) 	///
				lag_opt2(msymbol(Sh) msize(1.2) mlwidth(0.3) color("`r(p15)'"%60)) lag_ci_opt2(color("`r(p15)'"%0) lw(0.1)) 	///
				lag_opt3(msymbol(Th) msize(1.2) mlwidth(0.3) color("`r(p15)'"%60)) lag_ci_opt3(color("`r(p15)'"%0) lw(0.1)) 	///				
				lag_opt4(msymbol(Oh) msize(1.2) mlwidth(0.3) color("`r(p15)'"%60)) lag_ci_opt4(color("`r(p15)'"%0) lw(0.1)) 	///				
				lag_opt5(msymbol(sh) msize(1.2) mlwidth(0.3) color("`r(p15)'"%60)) lag_ci_opt5(color("`r(p15)'"%0) lw(0.1)) 	///							
				graph_opt(	                                   ///
								xtitle("Forecast Error (°C)")     ///
								ytitle(`var') xlabel(0 "≤-3" 1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2" 6 "≥3", tposition(inside)) ///
								ylabel(,tposition(inside)) ///
								yline(   0, lc(gs8) lp(dash)) ///
								legend(off) ///order(1 "Lower than Actual Temp." 3 "Higher than Actual Temp." ) ring(1) pos(6) row(1) region(style(none))) 	///
								graphregion(fcolor(white)) ///
								) 
					graph export "$tables/RC1_Dynamic_Para_`sample'_`prefix'`suffix'_wei.png", replace 
					graph save "$figures/Robust/RC1_Dynamic_Para_`sample'_`prefix'`suffix'_wei.gph", replace 
                   }
				}
			}
		}

