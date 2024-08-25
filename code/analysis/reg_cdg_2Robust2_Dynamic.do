
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

global per="13" 

use treated_hosp_weathter_full_cdg0_Dynamic, clear


*- Reg: 
	global abs "date_yrmonth date_weekday city_month groups_month ctrl_nq_* bin_r_TempHigh_L*  "	
	global cntrls ""
	global cls "city_id" 

	local main_dep Expense_total 
	local weighted "[aweight=pop_cyg]"
	
	cap erase "$tables/AppendixTable/AppendixTableA4.xls"
	cap erase "$tables/AppendixTable/AppendixTableA4.txt"
	
	foreach w in `main_dep' {
	foreach prefix in "l_" {
		foreach suffix in   `w'_pop  {
			foreach sample in "1"  {
				
				reghdfejl `prefix'`suffix'   L*_elow_CB* L*_ehigh_CB* is_high_L* ///
					${cntrls} `weighted' if `sample' , absorb(${abs}) cluster(${cls})
					est store dd_`w'_1
					est store dd_`w'_2
					
		set scheme s1color			
		event_plot 	dd_`w'_1 dd_`w'_2, 	///
		stub_lag( L#_elow_CB0 L#_ehigh_CB0 ) 		///		stub_lead(F_#	)		///
			together perturb(-0.1 0.1) trimlead(0) trimlag(13) noautolegend 									///
			plottype(scatter) ciplottype(rcap)  alpha(0.10)													///
				lag_opt1(msymbol(O) msize(1.3) mlwidth(0.5) color("248 118 109 *1.1")) lag_ci_opt1(color("248 118 109 *1.1") lw(0.5)) 	///
				lag_opt2(msymbol(D) msize(1.3) mlwidth(0.5) color("112 160 255 *1.1")) lag_ci_opt2(color("112 160 255 *1.1") lw(0.5)) 	///
						graph_opt(	                                   ///
								xtitle("Lagged Periods")     ///
								ytitle(`prefix'`suffix') xlabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13", tposition(inside)) ///
								ylabel(,tposition(inside)) ///
								yline(   0, lc(gs8) lp(dash)) ///
								legend(order(1 "Lower than Actual Temp." 3 "Higher than Actual Temp." ) ring(1) pos(6) row(1) region(style(none))) 	///
								graphregion(fcolor(white)) ///
								) 							
					graph export "$figures/finnal_graph/Harvesting/RC1_Dynamic_Para_`sample'_`prefix'`suffix'_wei.png", replace 
					graph save "$figures/finnal_graph/Harvesting/RC1_Dynamic_Para_`sample'_`prefix'`suffix'_wei.gph", replace 
					outreg2 using "$tables/AppendixTable/AppendixTableA4.xls" ,append dec(3) keep(L*_elow_CB0)
					outreg2 using "$tables/AppendixTable/AppendixTableA4.xls" ,append dec(3) keep(L*_ehigh_CB0)					
                   } 
				}
			}
		}

