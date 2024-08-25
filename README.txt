# 0.
Repository for "The Role of Weather Forecasts in Climate Adaptation and Reducing Medical Costs in China"

# 1. Structure
## 1.1 The `codes/` directory contains all scripts used to analyze data, as well as construct tables and figures shown in the paper.
Subdirectories include:
	`clean/`, which contains scripts to clean raw data
	`analysis/`, which contains scripts that run all regression analyses
	`plot_code/`, which contains `.do` and `.R` which generate figures of this paper.

### 1.1.1 description of files in `clean/`

--clean_1Main.do: Generate data for baseline analysis.
--clean_2Robust_Dynamic.do: Generate data for robust analysis of dynamic effects.
--clean_2Robust_IsOutpatient.do: Generate data for robust analysis by healthcare visit types.
--clean_2Robust_Disease.do:  Generate data for robust analysis by disease types.
--clean_2Robust_AltRealized.do: Generate data for robust analysis using alternative models.
--clean_2Robust_Others.do: Generate data for robust results using different time windows, as well as using bootstraps.
--clean_2Robust_Others2.do: Generate data for robust results excluding extreme values.
--clean_3HeterByRealTemp.do: Generate data for heterogeneity analysis by realized temperature bins.
--clean_3HeterByHospitals.do: Generate data for heterogeneity analysis by medical institution characteristics.

### 1.1.2 discription of files in `analysis/`

--reg_cdg_1Main_NonParametric.do: Generate baseline results using non-parametric estimation (Equation 1), as shown in Figure 1.
--reg_cdg_1Main_Parametric.do: Generate baseline results using parametric estimation (Equation 2), as shown in Figure 1.
--reg_cdg_2Robust1_AltSpecifications.do: Generate robust results using alternative models, as shown in Appendix Figure A2.
--reg_cdg_2Robust2_Dynamic.do: Generate dynamic results, as shown in Figure 2.
--reg_cdg_2Robust3_ExcludePrearranged.do: Generate robust results by visit types and disease types, as shown in Figure 3 Column 1&2.
--reg_cdg_2Robust4_AltMeasure.do: Generate robust results using alternative measure of realized weather, as shown in Appendix Figure A3.
--reg_cdg_2Robust5_OtherRobust1.do: Generate robust results using different time windows, excluding extreme values, as well as using bootstraps shown in Appendix Table A7.
--reg_cdg_2Robust5_OtherRobust2.do: Generate robust results using permutation tests, as shown in Appendix Figure A4.
--reg_cdg_3HeterByRealTemp.do: Generate heterogeneity analysis by realized temperature bins, as shown in Figure 4.
--reg_cdg_3HeterByHospitals.do: Generate heterogeneity analysis by medical institution characteristics, as shown in Figure 3 Column 3.
--reg_cdg_3HeterByAgeGender.do: Generate heterogeneity analysis by demographic characteristics, as shown in Figure 3 Columns 4&5.
--reg_projection.do: Project the impacts on medical expenses by climate scenarios, as shown in Figure 5.

### 1.1.3 description of files in `plot_code/`
--draw_figure1.do: Generate Figure 1.
--draw_figure3.R: Generate Figure 3.
--draw_figurea3.do: Gnerate Appendix Figure A3.
--Note: Other figures are directly exported form do-files in `analysis/`.

##
1.2 The `results/` directory contains all analysis results. 
Subdirectories include `figures/`, which contains all graphical figures, 
`tables/`, which contains `.xls` which contains all tables in the paper,


# 2. Data availability
The medical expenditure data we use to estimate our econometric models are confidential. 
All regression outputs are stored in this repository, but results cannot be directly reproduced without obtaining access to the underlying dataset from the China Health Insurance Research Association (CHIRA).