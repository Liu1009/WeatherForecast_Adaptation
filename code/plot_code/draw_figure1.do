
	import excel "figure1.xlsx", sheet("Sheet1") firstrow clear


	cap gen y_Expense_total=.
	cap gen y_visit=.
	cap gen xxx=.
					
	replace xxx=0 if _n==1
	replace xxx=3 if _n==2
	replace xxx=6 if _n==3
	
	replace y_Expense_total=0.137*3 if _n==1
	replace y_Expense_total=0 if _n==2
	replace y_Expense_total=0.046*3 if _n==3
	
	replace y_visit=0.073*3 if _n==1
	replace y_visit=0 if _n==2
	replace y_visit=0.027*3 if _n==3


set scheme s1color
twoway  (rarea ub lb time if type==2 & var=="expense" ,color("112 160 255 %60") lc(blue%60))  ///
 ( connect coef time if type==1 & var=="expense",color("248 118 109 *1.8" ) legend(off)) ( rarea ub lb time if type==1 & var=="expense",color("248 118 109 %30" ) lc(red)) ///
 ( connect coef time if type==2 & var=="expense",color("112 160 255 *1.8") ) ///
 (scatter coef time if time==3 & var=="expense",color(black%60)  yline(0) xtitle("Forecast Error (°C)")  ytitle("Medical Expenses") xlabel(0 "≤-3" 1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2" 6 "≥3", tposition(inside)) ylabel(, tposition(inside))) 

		addplot: scatter y_Expense_total xxx  if _n<3 & xxx>=0, connect(l) lcolor("248 118 109 *1.8") lpattern(longdash)  msymbol(none) norescaling
		addplot: scatter y_Expense_total xxx  if _n>1 & xxx<=7 ,connect(l) lcolor("112 160 255 *1.8") lpattern(dash)  msymbol(none) norescaling

set scheme s1color
twoway  (rarea ub lb time if type==2 & var=="visit" ,color("112 160 255 %60") lc(blue%60))  ///
 ( connect coef time if type==1 & var=="visit",color("248 118 109 *1.8" ) legend(off)) ( rarea ub lb time if type==1 & var=="visit",color("248 118 109 %30" ) lc(red)) ///
 ( connect coef time if type==2 & var=="visit",color("112 160 255 *1.8") ) ///
 (scatter coef time if time==3 & var=="visit",color(black%60)  yline(0) xtitle("Forecast Error (°C)")  ytitle("Healthcare visit") xlabel(0 "≤-3" 1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2" 6 "≥3", tposition(inside)) ylabe(, tposition(inside)) ) 

		addplot: scatter y_visit xxx  if _n<3 & xxx>=0, connect(l) lcolor("248 118 109 *1.8") lpattern(longdash)  msymbol(none) norescaling
		addplot: scatter y_visit xxx  if _n>1 & xxx<=7 ,connect(l) lcolor("112 160 255 *1.8") lpattern(dash)  msymbol(none) norescaling





