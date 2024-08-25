
	import excel "figurea3.xlsx", sheet("Sheet1") firstrow clear

set scheme s1color
twoway  (rarea ub lb time if type==2 & var=="expense" ,color("112 160 255 %60") lc(blue%60))  ///
 ( connect coef time if type==1 & var=="expense",color("248 118 109 *1.8" ) legend(off)) ( rarea ub lb time if type==1 & var=="expense",color("248 118 109 %30" ) lc(red)) ///
 ( connect coef time if type==2 & var=="expense",color("112 160 255 *1.8") ) ///
 (scatter coef time if time==3 & var=="expense",color(black%60)  yline(0) xtitle("Forecast Error (°C)")  ytitle("Medical Expenses") xlabel(0 "≤-3" 1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2" 6 "≥3", tposition(inside)) ylabel(, tposition(inside))) 


set scheme s1color
twoway  (rarea ub lb time if type==2 & var=="visit" ,color("112 160 255 %60") lc(blue%60))  ///
 ( connect coef time if type==1 & var=="visit",color("248 118 109 *1.8" ) legend(off)) ( rarea ub lb time if type==1 & var=="visit",color("248 118 109 %30" ) lc(red)) ///
 ( connect coef time if type==2 & var=="visit",color("112 160 255 *1.8") ) ///
 (scatter coef time if time==3 & var=="visit",color(black%60)  yline(0) xtitle("Forecast Error (°C)")  ytitle("Healthcare visit") xlabel(0 "≤-3" 1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2" 6 "≥3", tposition(inside)) ylabe(, tposition(inside)) ) 






