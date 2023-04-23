<<dd_version: 2>>
<<dd_include: "H:/Mi unidad/Angelica/secreto/IVE/header.txt" >>

# Database (paso 1)

Fecha creación: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Instalar comandos

~~~~
<<dd_do>>
log using "H:\Mi unidad\Angelica\secreto\IVE\registry_lca1_apr23.smcl", replace

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

Necesitamos obtener el archivo y el directorio de trabajo.

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
	scalar drop _all // `n' `ll_null' `ll_alt' `parms_null' `parms_alt' `a' `b' `classes_null' `classes_alt' `lr_test_stat' `modlr_test_stat' `p' `q' `lmrt_p' `__000000' `__00000B' `__00000A' `__00000D' `__00000C' `__000009' `__000005' `__000003' `__000008' `__000004' `__000002' `__000001'
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
	return scalar lmrt = `modlr_test_stat'
	return scalar lmrt_p = chi2tail(`parms_alt' - `parms_null',`modlr_test_stat')
	dis "P value Lo-Mendel:"
	dis %18.17f chi2tail(`parms_alt' - `parms_null',`modlr_test_stat')
	scalar list
	end
<</dd_do>>
~~~~


Fecha de creación: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Acceder a la carpeta

~~~~
<<dd_do: nocommand>>
*para poner la carpeta que aloja a tu proyecto
pathutil split "`c(filename)'"
	cap qui noi cd `"`dir'"'
	global pathdata `"`dir'"' 
<</dd_do>>
~~~~

<<dd_display: "Ubicación= ${pathdata};">>

<<dd_display: "Timestamp:`c(current_time)' `c(current_date)', considerando un SO `c(os)' OS para el usuario: `c(username)'">>


El archivo se encuentra en: <<dd_display: "`c(pwd)'/mydata_preds3_2023_04_21.dta" >>

===================================================================================
## Consolidación y exploración base de datos
===================================================================================

<<dd_do:quietly>>
*a) open 
	use "mydata_preds3_2023_04_21.dta"
	
	*label CAUSAL EDAD_MUJER_REC PUEBLO_ORIGINARIO_REC PAIS_ORIGEN_REC HITO1_EDAD_GEST_SEM_REC MACROZONA AÑO HITO2_DECISION_MUJER_IVE outcome
	cap noi label variable AÑO "Año base de datos"
	cap noi label variable EDAD_MUJER_REC "Edad mujer (5 categorías)"
	cap noi label variable PUEBLO_ORIGINARIO_REC "Pertenece a pueblo originario (binario)"
	cap noi label variable PAIS_ORIGEN_REC "Nacionalidad"
	cap noi label variable PREV_TRAMO_REC "Previsión y tramo"
	cap noi label variable MACROZONA "Macrozona"	
	cap noi label variable HITO1_EDAD_GEST_SEM_REC "Tasa de pobreza multidimensional (5 categorías)"		
	cap noi label variable CAUSAL "Causal"			
	cap noi label variable outcome "Resultado (1=Interrumpe)"
<</dd_do>>


===================================================================================
## LCA 
===================================================================================



Formateamos las variables a factor.

~~~~
<<dd_do>>
*codebook con_quien_vive_joel, tab(100)

foreach vars of varlist CAUSAL-PREV_TRAMO_REC {
cap noi encode `vars', gen(new`vars')
cap confirm variable new`vars'
    if !_rc {		
cap noi drop `vars'
cap noi rename new`vars' `vars'
	}	
}

rename AÑO ANIO
/* 
cap noi decode freq_cons_sus_prin, gen(str_freq_cons_sus_prin)
cap confirm variable str_freq_cons_sus_prin
    if !_rc {	
cap noi drop freq_cons_sus_prin
label def freq_cons_sus_prin2 1 "Less than 1 day a week" 2 "1 day a week or more" 3 "2 to 3 days a week" 4 "4 to 6 days a week" 5 "Daily"
encode str_freq_cons_sus_prin, gen(freq_cons_sus_prin) label (freq_cons_sus_prin2)
	}
*/

/* 
recode freq_cons_sus_prin_rec (1=2 "1 day a week or more") (2=3 "2 to 3 days a week") ///
 (3=4 "4 to 6 days a week")(4=5 "Daily") (5=1 "Less than 1 day a week"), gen(freq_cons_sus_prin_rec_joel)
encode numero_de_hijos_mod_joel, generate(numero_de_hijos_mod_joel_rec)
*/
<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>
global draws = 80 //80
global iterate = 80 //80
global iterate2 = 500 //500
//https://github.com/lindeloev/job
//https://rpubs.com/chinedu2301/833708
//https://rpubs.com/cyanjiner/889802
//https://rpubs.com/liliana/94701
       
set seed 2125
	qui noi gsem(CAUSAL ///
	EDAD_MUJER_REC ///
	PUEBLO_ORIGINARIO_REC /// 
	PAIS_ORIGEN_REC ///
	HITO1_EDAD_GEST_SEM_REC  ///
	MACROZONA  ///	
	ANIO ///
	PREV_TRAMO_REC <- , mlogit), lclass(C 1) 
	//*startvalues(randomid, draws(50)) //* agregado posteriormente 2021-10-08= feasible starting values not found
	estimates store lca_prueba_c1

set seed 2125
	forvalues i = 2/8{
	qui noi gsem(CAUSAL ///
	EDAD_MUJER_REC ///
	PUEBLO_ORIGINARIO_REC /// 
	PAIS_ORIGEN_REC ///
	HITO1_EDAD_GEST_SEM_REC  ///
	MACROZONA  ///	
	ANIO ///
	PREV_TRAMO_REC <- , mlogit), lclass(C `i') nocapslatent nonrtolerance iterate($iterate2 ) ///
	emopts(iterate($iterate ) difficult) ///
	startvalues(randomid, draws($draws ) seed(2125)) ///
	//*startvalues(randomid, draws(50)) //* agregado posteriormente 2021-10-08= feasible starting values not found
	estimates store lca_prueba_c`i'
	matrix b`i' = e(b)

	*estimates save lca_prueba_c`i', replace
	cap noi estat lcgof
	
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
	scalar Entropy_`i' = 1+`sum'/(r(N)*ln(`count'))
	cap noi drop classpost*
	cap noi drop sum_p_lnp*
	cap noi display "Entropy:"
	cap noi display Entropy_`i' 
	global Entropy__`i' = Entropy_`i'
		cap noi lmrtest lca_prueba_c`=`i'-1' lca_prueba_c`i'
		return list
		global lmrt_`i' = r(lmrt)
		global lmrt_p_`i' =  r(lmrt_p)
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

matrix entr= (0 \ $Entropy__2 \ $Entropy__3 \ $Entropy__4 \ $Entropy__5 \ $Entropy__6 \ $Entropy__7 \ $Entropy__8 )

matrix lmrt_mat = (1 \ $lmrt_2 \ $lmrt_3 \ $lmrt_4 \ $lmrt_5 \ $lmrt_6 \ $lmrt_7 \ $lmrt_8 )
matrix lmrt_p_mat = (1 \ $lmrt_p_2 \ $lmrt_p_3 \ $lmrt_p_4 \ $lmrt_p_5 \ $lmrt_p_6 \ $lmrt_p_7 \ $lmrt_p_8 )
matrix cs = (1 \ 2 \ 3 \ 4 \ 5 \ 6 \ 7 \ 8)

mat lmrt = (cs, entr, lmrt_mat, lmrt_p_mat)
matrix colnames lmrt  = n_classes Entropy LMRT p-value

cap noi estwrite _all using "./analisis_lcas_tests_real_apr23.sters", replace

esttab matrix(lmrt) using "./lmrt_lca.csv", replace
esttab matrix(lmrt) using "./lmrt_lca.html", replace
<</dd_do>>
~~~~

<<dd_include: "lmrt_lca.html" >>


Luego comparamos los modelos para detectar el número óptimo de clases.

~~~~
<<dd_do>>
estread "./analisis_lcas_tests_real_apr23.sters"

estimates stats _all
matrix stats_lca_ppio= r(S)

estimates clear
** to order AICs
*https://www.statalist.org/forums/forum/general-stata-discussion/general/1665263-sorting-matrix-including-rownames

mata :

void st_sort_matrix(
//argumento de la matriz
    string scalar matname, 
//argumento de las columnas
    real   rowvector columns
    )
{
    string matrix   rownames
    real  colvector sort_order
// defino una base	
	//Y = st_matrix(matname)
	//[.,(1, 2, 3, 4, 6, 5)]
 //ordeno las columnas  
    rownames = st_matrixrowstripe(matname) //[.,(1, 2, 3, 4, 6, 5)]
    sort_order = order(st_matrix(matname),  (columns))
    st_replacematrix(matname, st_matrix(matname)[sort_order,.])
    st_matrixrowstripe(matname, rownames[sort_order,.])
}

end

mata: st_sort_matrix("stats_lca_ppio",6)

esttab matrix(stats_lca_ppio) using "./testreg_bic_lca.csv", replace
esttab matrix(stats_lca_ppio) using "./testreg_bic_lca.html", replace
<</dd_do>>
~~~~

<<dd_include: "testreg_bic_lca.html" >>

~~~~
<<dd_do>>
cap qui save "./lca_step1_apr23.dta", all replace emptyok

log close
<</dd_do>>
~~~~

<<dd_display: "Tiempo de guardado= `c(current_time)' `c(current_date)'">>

<<dd_do: nocommand>>
/*
FORMA DE EXPORTAR LOS DATOS Y EL MARKDOWN

cap rm "H:/Mi unidad/Angelica/secreto/IVE/lca_step1_corr_apr23.html"
dyndoc "H:\Mi unidad\Angelica\secreto\IVE\_lca_step1_corr_apr23.do", saving("H:\Mi unidad\Angelica\secreto\IVE\lca_step1_corr_apr23.html") replace nostop 
copy "H:\Mi unidad\Angelica\secreto\IVE\lca_step1_corr_apr23.html" "H:\Mi unidad\Angelica\secreto\IVE\lca_step1_corr_back.html", replace

_outputs
*/
<</dd_do>>
