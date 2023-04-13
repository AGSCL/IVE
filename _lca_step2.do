<<dd_version: 2>>
<<dd_include: "E:/Mi unidad/Alvacast/SISTRAT 2019 (github)/_mult_state_ags/header.txt" >>
<<dd_include: "C:/Users/CISS Fondecyt/Mi unidad/Alvacast/SISTRAT 2019 (github)/_mult_state_ags/header.txt" >>

# Database (step 1)

Date created: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Install commands that are unavailable or out of date.

~~~~
<<dd_do>>
*<< dd_do : noout > >
clear all

set maxvar 120000, perm
set adosize 10000, perm
set  max_memory ., perm
set niceness 1, perm
*https://onlinelibrary.wiley.com/doi/epdf/10.1002/sim.8894
*https://pclambert.net/pdf/Stata_Nordic2019_Lambert.pdf
*https://slidetodoc.com/automated-reports-using-stata-chuck-huber-ph-d/
*~Mi unidad\Alvacast\SISTRAT 2019 (github)\_supp_mstates\stata\12874_2020_1192_MOESM1_ESM.docx
*https://opr.princeton.edu/workshops/Downloads/2015May_StataGraphicsKoffman.pdf
*http://www.bruunisejs.dk/StataHacks/My%20commands/matprint/matprint_demo/
*https://pure.au.dk/portal/files/140882936/ScientificWorkInStataGoneEasy.pdf
*https://www.stata.com/meeting/nordic-and-baltic18/slides/nordic-and-baltic18_Bruun.pdf
*https://github.com/dvorakt/TIER_exercises/blob/master/dyndoc_debt_growth/debt%20and%20growth%20stata%20dyndoc.do


cap noi which merlin
if _rc==111 {
	cap noi net install merlin, from("https://www.mjcrowther.co.uk/code/merlin/") 
	}
cap noi which sumat
if _rc==111 {
	cap noi scc install matrixtools
	}
cap noi which estwrite
if _rc==111 {
	cap noi ssc install estwrite
	}
cap noi which winsor2
if _rc==111 {
	cap noi ssc install winsor2
	}	
cap noi which matsave
if _rc==111 {
	cap noi ssc install matsave
	}	
<</dd_do>>
~~~~

We need to obtain the file and the work folder.


~~~~
<<dd_do>>
mata : st_numscalar("OK", direxists("/volumes/sdrive/data//"))
if scalar(OK) == 1 {
	cap noi cd "/volumes/sdrive/data//"
	global pathdata "/volumes/sdrive/data//"
	di "Location= ${pathdata}; Date: `c(current_date)', considering an OS `c(os)' for the user: `c(username)'"
}
else display "This file does not exist"

mata : st_numscalar("OK", direxists("E:\Mi unidad\Alvacast\SISTRAT 2019 (github)\_mult_state_ags\"))
if scalar(OK) == 1 {
	cap noi cd "E:\Mi unidad\Alvacast\SISTRAT 2019 (github)\"
	global pathdata "E:\Mi unidad\Alvacast\SISTRAT 2019 (github)\"
	global pathdata2 "E:/Mi unidad/Alvacast/SISTRAT 2019 (github)/"
	di "Location= ${pathdata}; Date: `c(current_date)', considering an OS `c(os)' for the user: `c(username)'"
}
else display "This file does not exist"
	
mata : st_numscalar("OK", direxists("C:\Users\CISS Fondecyt\Mi unidad\Alvacast\SISTRAT 2019 (github)\_mult_state_ags\"))
if scalar(OK) == 1 {
	cap noi cd "C:\Users\CISS Fondecyt\Mi unidad\Alvacast\SISTRAT 2019 (github)"
	global pathdata "C:\Users\CISS Fondecyt\Mi unidad\Alvacast\SISTRAT 2019 (github)\_mult_state_ags"
	global pathdata2 "C:/Users/CISS Fondecyt/Mi unidad/Alvacast/SISTRAT 2019 (github)/_mult_state_ags/"
	di "Location= ${pathdata}; Date: `c(current_date)', considering an OS `c(os)' for the user: `c(username)'"
}
else display "This file does not exist"

mata : st_numscalar("OK", direxists("C:\Users\andre\Desktop\_mult_state_ags\"))
if scalar(OK) == 1 {
	cap noi cd "C:\Users\andre\Desktop\_mult_state_ags"
	global pathdata "C:\Users\andre\Desktop\_mult_state_ags"
	global pathdata2 "C:/Users/andre/Desktop/_mult_state_ags/"
	di "Location= ${pathdata}; Date: `c(current_date)', considering an OS `c(os)' for the user: `c(username)'"
}
else display "This file does not exist"

mata : st_numscalar("OK", direxists("C:\Users\CISS Fondecyt\OneDrive\Documentos\"))
if scalar(OK) == 1 {
	cap noi cd "C:\Users\CISS Fondecyt\Mi unidad\Alvacast\SISTRAT 2019 (github)"
	global pathdata "C:\Users\CISS Fondecyt\Mi unidad\Alvacast\SISTRAT 2019 (github)"
	global pathdata2 "C:/Users/CISS Fondecyt/Mi unidad/Alvacast/SISTRAT 2019 (github)/"
	di "Location= ${pathdata}; Date: `c(current_date)', considering an OS `c(os)' for the user: `c(username)'"
}
else display "This file does not exist"

<</dd_do>>
~~~~


~~~~
<<dd_do>>

*para sacar LMR 
	*https://www.statalist.org/forums/forum/general-stata-discussion/general/1412686-calculating-entropy-for-lca-latent-class-analysis-in-stata-15/page3
cap program drop lmrtest
program lmrtest, rclass
	version 15.0
	args estimates_null estimates_alternative
	tempname n ll_null ll_alt parms_null parms_alt a b classes_null classes_alt lr_test_stat modlr_test_stat p q //*anadi el parametro b
	noi {
	scalar drop _all
	estimates restore `1'
	scalar `n' = e(N)
	scalar `ll_null' = e(ll)
	scalar `parms_null' = e(rank) //* los cambié, originalmente K y cambié por rank
	matrix `a' = e(lclass_k_levels)
	scalar `classes_null' = `a'[1,1]
	estimates restore `2'
	scalar `ll_alt' = e(ll)
	scalar `parms_alt' = e(rank) //* los cambié, originalmente K y cambié por rank
	matrix `b' = e(lclass_k_levels)
	scalar `classes_alt' = `b'[1,1]
	scalar `p' = (3 * `classes_alt' - 1) //* los cambié, originalmente 3 y cambié por `classes_alt'
	scalar `q' = (3 * `classes_null' - 1) //* los cambié, originalmente 3
	scalar `lr_test_stat' = -2 * (`ll_null' - `ll_alt')
	scalar `modlr_test_stat' = `lr_test_stat' / (1 + ((`p' - `q') * ln(`n')) ^ -1)	
	}
	dis "LMR LT test statistic:"
	di `modlr_test_stat'
	return scalar lmrt_p = chi2tail(`parms_alt' - `parms_null',`modlr_test_stat')
	dis "P value Lo-Mendel:"
	dis %18.17f chi2tail(`parms_alt' - `parms_null',`modlr_test_stat')
	scalar list
	end

<</dd_do>>
~~~~



<<dd_display: "Path data= ${pathdata};">>

<<dd_display: "Timestamp:`c(current_time)' `c(current_date)', considering that is a `c(os)' OS for the username: `c(username)'">>

First we open the files and drop the variables that would mistakenly amplify the sample, and define labels.

The file is located and named as: <<dd_display: "${pathdata2}CONS_C1_df_dup_SEP_2020_joel_oct_2021.dta" >>
 

<<dd_do:quietly>>
*a) open 
	use "${pathdata2}CONS_C1_df_dup_SEP_2020_joel_oct_2021.dta", clear	
	
	*label
	cap noi label variable hash_key "Masked Identifier(RUT)"
	cap noi label variable edad_al_ing "Age at admission"
	cap noi label variable sexo_2 "Sex of user"
	cap noi label variable escolaridad_rec "Educational Attainment"
	cap noi label variable estado_conyugal_2 "Marital status"	
	cap noi label variable edad_ini_cons "Age of onset of drug use"		
	cap noi label variable freq_cons_sus_prin "Frequency of use of the primary substance at admission"		
	cap noi label variable dias_treat_imp_sin_na "Days of treatment (missing dates replaced with last follow-up)"			
	cap noi label variable via_adm_sus_prin_act "Route of administration of substance"
	cap noi label variable numero_de_hijos_mod_joel "Number of children (+1 if pregnant)"
<</dd_do>>

Posteriorly, we formatted the dates, and added a censored date of November 13 of 2019 for Ongoing Treatments.

~~~~
<<dd_do>>
*Reemplazar los perdidos por la diferencia hasta el last followup
replace fech_egres_imp= 21866 if motivodeegreso_mod_imp==6

*Formatear las fechas para hacerlas entendibles
gen fech_egres_imp_dofc = fech_egres_imp - td(01jan1960)
gen fech_ing_dofc = fech_ing- td(01jan1960)

format fech_ing_dofc %td
format fech_egres_imp_dofc  %td

*Para comprobar cómo se comporta
list fech_egres_imp_dofc if fech_egres_imp==21866
<</dd_do>>
~~~~

There were 3 cases that ahd a missing difference between treatment, but also figured as an event (as having a readmission).

~~~~
<<dd_do>>
*Ver por qué se da los perdidos en la fecha
list row fech_ing motivodeegreso_mod_imp fech_egres_imp diff_bet_treat event if missing(diff_bet_treat) & event==1
list row fech_ing motivodeegreso_mod_imp fech_egres_imp diff_bet_treat event if !missing(diff_bet_treat) & event==0

replace event=0 if missing(diff_bet_treat) & event==1
<</dd_do>>
~~~~

We deleted 2 cases that had a missing cause of admission.

~~~~
<<dd_do>>
*perdidos en motivo de egreso
codebook motivodeegreso_mod_imp, tab(100)
list row fech_egres_imp if missing(motivodeegreso_mod_imp)

drop if inlist(row, 16163, 2207)

<</dd_do>>
~~~~

There are 69 cases that have no days of difference between one treatment with the following. To avoid ties, we added a day to these cases. After resolving some inconsistencies, we set the database as a renewal time. We deleted the two cases without cause of discharge.

~~~~
<<dd_do>>
*di date("2019-11-13","YMD") * 21866

codebook diff_bet_treat , tab(100)

list motivodeegreso_mod_imp fech_egres_imp diff_bet_treat if diff_bet_treat==0

**To avoid ties
replace diff_bet_treat = 1 if diff_bet_treat==0
<</dd_do>>
~~~~

We also formatted `con_quien_vive_joel`, `freq_cons_sus_prin` and `numero_de_hijos_mod_joel` as a factor.

~~~~
<<dd_do>>
*codebook con_quien_vive_joel, tab(100)

encode con_quien_vive_joel, generate(con_quien_vive_joel_rec)
encode freq_cons_sus_prin, gen(freq_cons_sus_prin_rec)
recode freq_cons_sus_prin_rec (1=2 "1 day a week or more") (2=3 "2 to 3 days a week") ///
 (3=4 "4 to 6 days a week")(4=5 "Daily") (5=1 "Less than 1 day a week"), gen(freq_cons_sus_prin_rec_joel)
encode numero_de_hijos_mod_joel, generate(numero_de_hijos_mod_joel_rec)

<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>



~~~~
<<dd_do>>
*definir vriables, cambiar la familia y el enlace, que lso valores de partida sean similares y poner opciones robustas después
*numero_de_hijos_mod_joel_rec escolaridad_rec freq_cons_sus_prin_rec_joel compromiso_biopsicosocial

set seed 4345
	forvalues i = 2/10{
	qui noi gsem(con_quien_vive_joel_rec ///
	sexo_2 ///
	estado_conyugal_2 /// 
	sus_ini_mod_mvv via_adm_sus_prin_act  ///
	tipo_centro macrozona ///
	tenencia_de_la_vivienda_mod condicion_ocupacional_corr ///
	comorbidity_icd_10 <- , mlogit)(edad_al_ing edad_ini_cons <- , regress)(numero_de_hijos_mod_joel_rec escolaridad_rec freq_cons_sus_prin_rec_joel ///
	 compromiso_biopsicosocial<- , ologit), lclass(C `i') nocapslatent nonrtolerance iterate(1000) ///
	emopts(iterate(80) difficult) ///
	startvalues(randomid, draws(80) seed(4345)) ///
	//*startvalues(randomid, draws(50)) //* agregado posteriormente 2021-10-08= feasible starting values not found
	estimates store lca_prueba_c`i'
	matrix b`i' = e(b)

	*estimates save lca_prueba_c`i', replace
	estat lcgof
	
	quietly predict classpost* if e(sample) == 1, classposteriorpr
	unab myvars : classpost*
	local count : word count `myvars'
	forvalues k = 1/`count' {       
	 quietly gen sum_p_lnp_`k' = classpost`k'*ln(classpost`k') if e(sample) == 1
	 }
	quietly egen sum_p_lnp = rowtotal(sum_p_lnp_*) if e(sample) == 1
	summ sum_p_lnp, meanonly
	local sum = r(sum)
	quietly count if !missing(sum_p_lnp) & e(sample) == 1
	scalar Entropy = 1+`sum'/(r(N)*ln(`count'))
	cap drop classpost*
	cap drop sum_p_lnp*
	display "Entropy:"
	display Entropy 
		cap noi lmrtest lca_prueba_c`=`i'-1' lca_prueba_c`i'
		*ll_null	__000001
		*ll_alt	__000002 
		*parms_alt'	__000004
		*b	 __000006
		*classes_null	__000007
		*p	__000008
		*lr_test_stat	__000009
		*modlr_test_stat	__00000A
		*b	__00000B
		*q	__00000C
	}	
	
*likelihood-ratio statistic is also known as the G2 statistic.
*p > chi2: We fail to reject the null hypothesis that our model fits 
*as well as the saturated model.

*If you don't get standard errors, that means the model has not converged 
*adequately - basically, you aren't sure (because Stata is not sure) 
*if you are at a global maximum of the likelihood function. 

cap estwrite _all using "${pathdata2}analisis_joel_lcas_tests.sters"
if _rc==111 {
	cap noi estwrite _all using "${pathdata2}analisis_joel_lcas_tests.sters", replace
	}	
	
<</dd_do>>
~~~~

Then, we compared these models to detect the optimal number of classes.

~~~~
<<dd_do>>
estread "${pathdata2}analisis_joel_lcas_tests.sters"

estimates stats _all

cap qui save "${pathdata2}analisis_joel_an1.dta", all replace emptyok
<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>
