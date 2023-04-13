<<dd_version: 2>>
<<dd_include: "H:/Mi unidad/Angelica/secreto/_lca/header.txt" >>

# Database (step 2)

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
	
<</dd_do>>
~~~~

Date created: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Get the folder

~~~~
<<dd_do: nocommand>>
*para poner la carpeta que aloja a tu proyecto
pathutil split "`c(filename)'"
	cap qui noi cd `"`dir'"'
	global pathdata `"`dir'"' 
	di "Fecha: `c(current_date)', considerando un SO `c(os)' para el usuario: `c(username)'"
<</dd_do>>
~~~~

<<dd_display: "Path data= ${pathdata};">>

<<dd_display: "Time: `c(current_date)', considering an OS `c(os)'">>


The file is located and named as: <<dd_display: ".dta" >>

<<dd_do:quietly>>
*a) open 
	use ".dta", clear	

<</dd_do>>

According to the data, the model with six latent classes was the model that had best fit to the data.

~~~~
<<dd_do>>
estread "${pathdata2}analisis_joel_lcas_tests.sters"

estimates describe lca_prueba_c10
estimates replay lca_prueba_c10
estimates restore lca_prueba_c10
matrix b10_start= e(b)
<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>
*startvalues are computed b randomly assigning observations to initial classes
set seed 4345

qui noi gsem(con_quien_vive_joel_rec ///
	sexo_2 ///
	estado_conyugal_2 /// 
	sus_ini_mod_mvv via_adm_sus_prin_act  ///
	tipo_centro macrozona ///
	tenencia_de_la_vivienda_mod condicion_ocupacional_corr ///
	comorbidity_icd_10 <- , mlogit)(edad_al_ing edad_ini_cons <- , regress)(numero_de_hijos_mod_joel_rec escolaridad_rec freq_cons_sus_prin_rec_joel ///
	 compromiso_biopsicosocial<- , ologit), lclass(C 10) nocapslatent iterate(1000) vce(robust) ///
	startvalues(randomid, draws(80) seed(4345)) emopts(iterate(80) difficult) ///
	from(b10_start, skip)

estimates store an_joel_c10_211006 //* previous had an invalid name

*startvalues(randomid, draws(50) seed(4345)) emopts(iter(50)) ///

*entropy. functions after getting the model.
*https://www.statalist.org/forums/forum/general-stata-discussion/general/1412686-calculating-entropy-for-lca-latent-class-analysis-in-stata-15/page3

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
drop sum_p_lnp* classpost*
display "Entropy:"
display Entropy 
*.70111211
estat lcgof

estwrite _all using "${pathdata2}analisis_joel_lca_final.sters", replace

<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>


## Estimates & plots

To obtain entropy estimates from an active model

~~~~
<<dd_do>>
*Without nose, takes time

*reports the probabilities of class membership.
estat lcprob
*reports the estimated mean for each item in each class.
estat lcmean	
*error-too many options	
*update: when I changed the initial command to only have about 25 variables or so, the solution was not with an iteration that had "(not concave)" noted. After this, the "estat lcmean" command worked.
*Having thresholds fixed at -15 or +15 is not a problem. It just means that for endorsing that particular item the probability is one or zero in that class. It can be helpful for defining the class.

<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>


~~~~
<<dd_do>>
*the estimation of standard errors for marginal means and marginal probabilities can be timeconsuming
*with large models. If you are interested only in the means and probabilities, you can
*specify the nose option with estat lcmean and estat lcprob to speed up estimation. With this
*option, no standard errors, test statistics, or confidence intervals are reported.
*reports the probabilities of class membership.

*Takes time
* Programar según clases

*estimates restore  lca_prueba_c4 //* to activate the model
*estat lcgof
*estimates esample: //* to allow to predict

margins, predict(classpr class(1)) ///
	predict(classpr class(2)) ///
	predict(classpr class(3)) ///
	predict(classpr class(4)) ///
	predict(classpr class(5)) ///
	predict(classpr class(6)) ///
	predict(classpr class(7)) ///
	predict(classpr class(8)) ///
	predict(classpr class(9)) ///
	predict(classpr class(10)) 
	marginsplot, xtitle("") ytitle("") ///
	xlabel(1 "Class 1" 2 "Class 2" 3 "Class 3" 4 "Class 4" 5 "Class 5" 6 "Class 6" 7 "Class 7" 8 "Class 8" 9 "Class 9" 10 "Class 10") ///
	title("Predicted Latent Class Probabilities with 95% CI")
	*graph save "${pathdata2}plot_predict_probs.gph"
	
<</dd_do>>
~~~~

<<dd_graph: saving(analisis_joel_predict.svg) width(800) replace>>

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>

*predict classprior*, classpr
predict cl_ps_anj_211006_*, classposteriorpr
format %9.4f cl_ps_anj_211006_*
 *We can determine the expected class for each individual based 
 *on whether the posterior probability is greater than 0.5
 
 forvalues i = 1/6{
generate exp_cl_ps_anj_211006_`i' = (cl_post_anj_211006_`i'>0.5)
tab exp_cl_ps_anj_211006_`i'
}
<</dd_do>>
~~~~

<<dd_display: "Saved at= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>

cap qui save "${pathdata2}analisis_joel_an2.dta", all replace emptyok
<</dd_do>>
~~~~