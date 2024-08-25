
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
/*  SECTION 1:   			
    Notes: part0. Basic Pattern on Forecast
	*/
/**********************************************************************/

global per="6" 

use treated_hosp_weathter_full_cdg0, clear

			keep if groups==1
			
			tab dif_TempHigh
			
	*- Figure A1 Panel A: distribution of forecast error
			histogram dif_TempHigh, fcolor(red%20) lcolor(red%20) ylabel(, tposition(inside)) xtitle(`"Forecast Error (℃)"') ytitle("") xlabel(-16(4)16) discrete  //normal
			graph export "$tables/RA1_Distribution.png", replace 
			
    *- Figure A1 Panel B: Root Mean Squared Error of forecast error across years
        preserve
		
			* Calculate the error
			gen error = dif_TempHigh

			* Calculate the square of the error
			gen sq_error = error^2

			* Calculate mean square error (MSE)
            egen mse = mean(sq_error), by(year)
			
			* Calculate RMSE and display the result
			gen rmse = sqrt(mse)
			
			* Remove Duplicates
            keep if day==2 & month==1 & 城市=="北京" 
			
			
			twoway scatter rmse year,mcolor("112 160 255 %60") msymbol(Oh) ||  qfitci rmse year,ciplot(rline) clcolor("248 118 109 *1.8" ) acolor("248 118 109 *1.8" ) level(99) legend(order(1 "RMSE" 2 "99%CI" 3 "Fitted values") row(1)) title("") xtitle("") alpattern(dash) xlabel(2013(1)2019,tposition(inside)) ylabel(,tposition(inside))
			graph export "$tables/RA2_RMSE_byYear.png", replace 
        restore  


    *- Figure A1 Panel C: Root Mean Squared Error of forecast error across months
        preserve

			* Calculate the error
			gen error = dif_TempHigh

			* Calculate the square of the error
			gen sq_error = error^2

			* Calculate mean square error (MSE)
			egen mse = mean(sq_error), by(month)
			
			* Calculate RMSE and display the result
			gen rmse = sqrt(mse)
			
			* Remove Duplicates
            keep if day==2 & 城市=="北京"

			twoway scatter rmse month,mcolor("112 160 255 %60") msymbol(Oh) ||  fpfitci rmse month,ciplot(rline) clcolor("248 118 109 *1.8" ) acolor("248 118 109 *1.8" ) level(99) legend(order(1 "RMSE" 2 "99%CI" 3 "Fitted values") row(1)) title("") xtitle("") alpattern(dash) xlabel(1(1)12,tposition(inside)) ylabel(,tposition(inside))

			graph export "$tables/RA2_RMSE_byMonth.png", replace 

        restore 


    *- Figure A1 Panel D: Root Mean Squared Error of forecast error across cities
		preserve
            gen sq_error1 = dif_TempHigh^2
            gen sq_error2 = dif_TempHigh^2

            egen mse1 = mean(sq_error1), by(city_id)
            egen mse2 = mean(sq_error2), by(city_id)
            gen rmse1 = sqrt(mse1)
            gen rmse2 = sqrt(mse2)
			
			*- Figure A1 Panel D are plotted from Arc-Gis
			
        restore
	
	
///////////////////////////////////////////////////////////////////////////////

use treated_hosp_weathter_full_cdg0, clear

	summarize Expense_total_pop visit_pop dif_TempHigh ///
		r_TempHigh r_WindAvg r_RainVol r_HumiAvg  r_PM25 [aweight=pop_cyg]
		
		