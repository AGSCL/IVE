<<dd_version: 2>>
<<dd_include: "H:/Mi unidad/Angelica/secreto/IVE/header.txt" >>

# Database (paso2 2)

Fecha creación: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Instalar comandos

~~~~
<<dd_do>>
log using "H:\Mi unidad\Angelica\secreto\IVE\registry_lca2_apr23.smcl", replace

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


cap noi which rcsgen
if _rc==111 {	
	ssc install rcsgen
	}	
cap noi which matselrc
if _rc==111 {		
cap noi net install dm79, from("http://www.stata.com/stb/stb56")
	}
cap noi which tabout
if _rc==111 {
	cap noi ssc install tabout
	}
cap noi which pathutil
if _rc==111 {
	cap noi net install pathutil, from("http://fmwww.bc.edu/repec/bocode/p/") 
	}
cap noi which pathutil
if _rc==111 {
	ssc install dirtools	
	}
cap noi which project
if _rc==111 {	
	ssc install project
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

Fecha creación: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Acceder a carpeta

~~~~
<<dd_do: nocommand>>
*para poner la carpeta que aloja a tu proyecto
pathutil split "`c(filename)'"
	cap qui noi cd `"`dir'"'
	global pathdata `"`dir'"' 
	di "Fecha: `c(current_date)', considering an OS `c(os)' to the user: `c(username)'"
<</dd_do>>
~~~~

<<dd_display: "Ubicación= ${pathdata};">>

<<dd_display: "Tiempo: `c(current_date)', considerando un SO `c(os)'">>


El archivo se encuentra en: <<dd_display: "`c(pwd)'/_lca/lca_step1.dta" >>

<<dd_do:quietly>>
*a) open 
	use "./lca_step1_apr23.dta"

<</dd_do>>

De acuerdo a los datos, el mejor modelo asumía 5 clases latentes.

~~~~
<<dd_do>>
*cap noi estread "./analisis_lcas_tests_prueba.sters"
cap noi estread "./analisis_lcas_tests_real_apr23.sters"

estimates describe lca_prueba_c5
estimates replay lca_prueba_c5
estimates restore lca_prueba_c5
matrix b5_start= e(b)
<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>
*startvalues are computed b randomly assigning observations to initial classes
set seed 2125


qui noi gsem(decision_rec ///
	anio ///
	nacionalidad_rec_factor /// 
	region_rec_factor ///
	prev_tramo2  ///
	niv_entrada_rec_factor  ///	
	acps_factor ///
	edad_mujer ///
	clas /// //added later, not in R	
	tpm4 <- , mlogit), lclass(C 5) nocapslatent nonrtolerance iterate(1000) vce(robust) ///
	startvalues(randomid, draws(80) seed(2125)) emopts(iterate(80) difficult) ///
	from(b5_start, skip)

estimates store an_lca_c5_220315 //* previous had an invalid name


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

*cap noi estwrite _all using "./analisis_lcas_tests_definitivo_prueba.sters", replace
cap noi estwrite _all using "./analisis_lcas_tests_definitivo_apr23.sters", replace

<</dd_do>>
~~~~

<<dd_display: "Tiempo= `c(current_time)' `c(current_date)'">>


## Estimaciones y figuras

Para obtener estimaciones de entroppía del modelo activo

~~~~
<<dd_do>>
*Without nose, takes time

*reports the probabilities of class membership.
estat lcprob //takes too many time
*reports the estimated mean for each item in each class.
estat lcmean	//takes too many time
*error-too many options	
*update: when I changed the initial command to only have about 25 variables or so, the solution was not with an iteration that had "(not concave)" noted. After this, the "estat lcmean" command worked.
*Having thresholds fixed at -15 or +15 is not a problem. It just means that for endorsing that particular item the probability is one or zero in that class. It can be helpful for defining the class.

<</dd_do>>
~~~~

<<dd_display: "Tiempo post lcmean y lcprob= `c(current_time)' `c(current_date)'">>

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

*cap noi estread "./analisis_lcas_tests_definitivo_prueba.sters"
cap noi estread "./analisis_lcas_tests_definitivo_apr23.sters"

margins, predict(classpr class(1)) ///
	predict(classpr class(2)) ///
	predict(classpr class(3)) ///
	predict(classpr class(4)) ///
	predict(classpr class(5)) 
marginsplot, xtitle("") ytitle("") ///
	xlabel(1 "Class 1" 2 "Class 2" 3 "Class 3" 4 "Class 4" 5 "Class 5") ///
	title("Predicted Latent Class Probabilities with 95% CI")
	cap noi graph save "./plot_predict_probs_apr23.gph"
	
<</dd_do>>
~~~~

<<dd_graph: saving("./lca.svg") width(800) replace>>

<<dd_display: "Tiempo post-predicciones= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>

*predict classprior*, classpr
predict an_lca_c5_220315*, classposteriorpr
format %9.4f an_lca_c5_220315*
 *We can determine the expected class for each individual based 
 *on whether the posterior probability is greater than 0.5
 
 forvalues i = 1/4{
generate exp_an_lca_c5_220315`i' = (an_lca_c5_220315`i'>0.5)
tab exp_an_lca_c5_220315`i'
}
cap noi estwrite _all using "./analisis_lcas_tests_definitivo2_apr23.sters", replace

<</dd_do>>
~~~~

<<dd_display: "Guardado en= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>

cap qui save "./lca_step2_apr23.dta", all replace emptyok

log close
<</dd_do>>
~~~~

<<dd_do: nocommand>>
/*
FORMA DE EXPORTAR LOS DATOS Y EL MARKDOWN

cap rm "H:/Mi unidad/Angelica/secreto/IVE/lca_step2_corr.html"
dyndoc "H:\Mi unidad\Angelica\secreto\IVE\_lca_step2_corr.do", saving("H:\Mi unidad\Angelica\secreto\IVE\lca_step2_corr.html") replace nostop 
copy "H:\Mi unidad\Angelica\secreto\IVE\lca_step2_corr.html" "H:\Mi unidad\Angelica\secreto\IVE\lca_step2_corr_back.html", replace

_outputs
*/
<</dd_do>>
