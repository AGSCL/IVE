<<dd_version: 2>>
<<dd_include: "[DIRECTORIO CARPETA]_lca/header.txt" >>

# Database (step 1)

Date created: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Install commands that are unavailable or out of date.

~~~~
<<dd_do>>
log using "[DIRECTORIO CARPETA]_lca\registry_lca1.smcl", replace

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

We need to obtain the file and the work folder.


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


Date created: <<dd_display: "`c(current_time)' `c(current_date)'">>.

Get the folder

~~~~
<<dd_do: nocommand>>
*para poner la carpeta que aloja a tu proyecto
pathutil split "`c(filename)'"
	cap qui noi cd `"`dir'"'
	global pathdata `"`dir'"' 
<</dd_do>>
~~~~

<<dd_display: "Path data= ${pathdata};">>

<<dd_display: "Timestamp:`c(current_time)' `c(current_date)', considering that is a `c(os)' OS for the username: `c(username)'">>


The file is located and named as: <<dd_display: "`c(pwd)'/lca0.dta" >>

===================================================================================
## Database consolidation and explore
===================================================================================

<<dd_do:quietly>>
*a) open 
	use "./_lca/lca0.dta"
	
	*label
	cap noi label variable anio "Año base de datos"
	cap noi label variable edad_mujer "Edad mujer"
	cap noi label variable nacionalidad_rec "Nacionalidad"
	cap noi label variable prev_tramo2 "Previsión y tramo"
	cap noi label variable region_rec "Macrozona"	
	cap noi label variable tpm "Tasa de pobreza multidimensional"		
	cap noi label variable tpm4 "Tasa de pobreza multidimensional (4 cat binning)"		
	cap noi label variable tpm6 "Tasa de pobreza multidimensional (6 cat binning)"		
	cap noi label variable acps "Acompañamiento psicosocial"		
	cap noi label variable causal "Causal"			
	cap noi label variable niv_entrada_rec "Niv. Entrada"
<</dd_do>>

Posteriorly, we brought the urban-rural classification of municipallities from this [link]("https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fwww.masvidarural.gob.cl%2Fwp-content%2Fuploads%2F2021%2F04%2FClasificacion-comunas-PNDR.xlsx&wdOrigin=BROWSELINK").

~~~~
<<dd_do>>
cap qui noi frame create temp
frame temp: import excel "./_lca/Clasificacion-comunas-PNDR.xlsx", firstrow clear
*frame temp: browse
*frame change default

*select code of municipality
frame default: gen str5 comuna_str = ustrregexs(1) if ustrregexm(cod_comuna,"([\d,]+)")

*codebook comuna_str
*recode comuna if 
*http://www.sinim.cl/archivos/centro_descargas/modificacion_instructivo_pres_codigos.pdf
*file:///C:/Users/CISSFO~1/AppData/Local/Temp/MicrosoftEdgeDownloads/4ef08de9-6832-4db6-8124-f69a7b256270/codigoComunas-20180801%20(1).pdf

replace comuna_str= "16101" if strpos(strlower(comuna_str),"8401")>0
replace comuna_str= "16102" if strpos(strlower(comuna_str),"8402")>0
replace comuna_str= "16103" if strpos(strlower(comuna_str),"8406")>0
replace comuna_str= "16104" if strpos(strlower(comuna_str),"8407")>0
replace comuna_str= "16105" if strpos(strlower(comuna_str),"8410")>0
replace comuna_str= "16106" if strpos(strlower(comuna_str),"8411")>0
replace comuna_str= "16107" if strpos(strlower(comuna_str),"8413")>0
replace comuna_str= "16108" if strpos(strlower(comuna_str),"8418")>0
replace comuna_str= "16109" if strpos(strlower(comuna_str),"8421")>0
replace comuna_str= "16201" if strpos(strlower(comuna_str),"8414")>0
replace comuna_str= "16202" if strpos(strlower(comuna_str),"8403")>0
replace comuna_str= "16203" if strpos(strlower(comuna_str),"8404")>0
replace comuna_str= "16204" if strpos(strlower(comuna_str),"8408")>0
replace comuna_str= "16205" if strpos(strlower(comuna_str),"8412")>0
replace comuna_str= "16206" if strpos(strlower(comuna_str),"8415")>0
replace comuna_str= "16207" if strpos(strlower(comuna_str),"8420")>0
replace comuna_str= "16301" if strpos(strlower(comuna_str),"8416")>0
replace comuna_str= "16302" if strpos(strlower(comuna_str),"8405")>0
replace comuna_str= "16303" if strpos(strlower(comuna_str),"8409")>0
replace comuna_str= "16304" if strpos(strlower(comuna_str),"8417")>0
replace comuna_str= "16305" if strpos(strlower(comuna_str),"8419")>0


*frame temp: gen str20 comuna_str = ustrregexs(1) if ustrregexm(cod_com,"([\d,]+)")
*frame temp: tostring cod_com, gen0(comuna_str) 
frame temp: gen comuna_str = string(cod_com)

frlink m:1 comuna_str, frame(temp comuna_str) //*Clasificación
frget Clasificación, from(temp)

*70,863
<</dd_do>>
~~~~

We show a table of missing values

~~~~
<<dd_do>>
misstable sum  anio causal edad_mujer nacionalidad region comuna prevision tramo niv_entrada edad_ges acps decision prevision_rec tramo_rec prev_tramo prev_tramo2 niv_entrada_rec decision_rec nacionalidad_rec region_rec cod_comuna tpm tpm4 tpm6 Clasificación
<</dd_do>>
~~~~

And missing patterns

~~~~
<<dd_do>>
misstable pat anio causal edad_mujer nacionalidad region comuna prevision tramo niv_entrada edad_ges acps decision prevision_rec tramo_rec prev_tramo prev_tramo2 niv_entrada_rec decision_rec nacionalidad_rec region_rec cod_comuna tpm tpm4 tpm6 Clasificación
<</dd_do>>
~~~~


===================================================================================
## LCA 
===================================================================================



We also formatted variables as a factor.

~~~~
<<dd_do>>
*codebook con_quien_vive_joel, tab(100)

encode nacionalidad_rec, gen(nacionalidad_rec_factor)
encode region_rec, gen(region_rec_factor)
encode niv_entrada_rec, gen(niv_entrada_rec_factor)
encode acps, gen(acps_factor)
encode Clasificación, gen(clas)
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
global draws = 2 //80
global iterate = 2 //80
global iterate2 = 2 //1000
//https://github.com/lindeloev/job
//https://rpubs.com/chinedu2301/833708
//https://rpubs.com/cyanjiner/889802
//https://rpubs.com/liliana/94701

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
	tpm4 <- , mlogit), lclass(C 1) 
	//*startvalues(randomid, draws(50)) //* agregado posteriormente 2021-10-08= feasible starting values not found
	estimates store lca_prueba_c1

set seed 2125
	forvalues i = 2/7{
	qui noi gsem(decision_rec ///
	anio ///
	nacionalidad_rec_factor /// 
	region_rec_factor ///
	prev_tramo2  ///
	niv_entrada_rec_factor  ///	
	acps_factor ///
	edad_mujer ///
	clas /// //added later, not in R
	tpm4 <- , mlogit), lclass(C `i') nocapslatent nonrtolerance iterate($iterate2 ) ///
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

matrix entr= (0 \ $Entropy__2 \ $Entropy__3 \ $Entropy__4 \ $Entropy__5 \ $Entropy__6 \ $Entropy__7 )

matrix lmrt_mat = (1 \ $lmrt_2 \ $lmrt_3 \ $lmrt_4 \ $lmrt_5 \ $lmrt_6 \ $lmrt_7 )
matrix lmrt_p_mat = (1 \ $lmrt_p_2 \ $lmrt_p_3 \ $lmrt_p_4 \ $lmrt_p_5 \ $lmrt_p_6 \ $lmrt_p_7 )
matrix cs = (1 \ 2 \ 3 \ 4 \ 5 \ 6 \ 7 )

mat lmrt = (cs, entr, lmrt_mat, lmrt_p_mat)
matrix colnames lmrt  = n_classes Entropy LMRT p-value

cap noi estwrite _all using "./_lca/analisis_lcas_tests_real.sters", replace

esttab matrix(lmrt) using "./_lca/lmrt_lca.csv", replace
esttab matrix(lmrt) using "./_lca/lmrt_lca.html", replace
<</dd_do>>
~~~~

<<dd_include: "./_lca/lmrt_lca.html" >>


Then, we compared these models to detect the optimal number of classes.

~~~~
<<dd_do>>
estread "./_lca/analisis_lcas_tests_real.sters"

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

esttab matrix(stats_lca_ppio) using "./_lca/testreg_bic_lca.csv", replace
esttab matrix(stats_lca_ppio) using "./_lca/testreg_bic_lca.html", replace
<</dd_do>>
~~~~

<<dd_include: "./_lca/testreg_bic_lca.html" >>

~~~~
<<dd_do>>
cap qui save "./_lca/lca_step1.dta", all replace emptyok

log close
<</dd_do>>
~~~~

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>

<<dd_do: nocommand>>
/*
FORMA DE EXPORTAR LOS DATOS Y EL MARKDOWN

cap rm "[DIRECTORIO CARPETA]_lca/_lca_step1_corr.html"
dyndoc "[DIRECTORIO CARPETA]_lca\_lca_step1_corr.do", saving("[DIRECTORIO CARPETA]_lca\_lca_step1_corr.html") replace nostop 
copy "[DIRECTORIO CARPETA]_lca\_lca_step1_corr.html" "[DIRECTORIO CARPETA]_lca_step1_corr.html", replace

_outputs
*/
<</dd_do>>
