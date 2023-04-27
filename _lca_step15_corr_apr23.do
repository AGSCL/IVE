<<dd_version: 2>>
<<dd_include: "H:/Mi unidad/Angelica/secreto/IVE/header.txt" >>

# Análisis de clases latentes (paso 1.5)

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
cap noi which lclogit2
if _rc==111 {
	cap noi ssc install lclogit2
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

Se construyen distintos modelos para ver la relación con el outcome.

<<dd_display: "Time= `c(current_time)' `c(current_date)'">>

~~~~
<<dd_do>>
*lclogitml2 depvar [ varlist1 ] [ if ] [ in ], group( varname ) rand( varlist2 ) nclasses( # ) [ id( varname ) membership( varlist3 ) constraints( numlist ) seed( # ) from( init_specs ) noninteractive_options ]
*lclogit2 depvar [ varlist1 ] [ if ] [ in ], group( varname ) rand( varlist2 ) nclasses( # ) [ id( varname ) membership( varlist3 ) constraints( numlist ) seed( # ) iterate( # ) ltolerance( # ) tolerance( # ) tolcheck nolog]

/*
    Use lclogit2 to estimate a 4-class model, assuming all choice model
    coefficients are heterogeneous. Then, pass the results as starting values
    to lclogitml2.

        . lclogit2 y, rand(price contract local wknown tod seasonal) id(pid)
            group(gid) nclasses(4)
        . matrix start = e(b)
        . lclogitml2 y, rand(price contract local wknown tod seasonal) id(pid)
            group(gid) nclasses(4) from(start)
*/

set seed 2125
	forvalues i = 2/8{
lclogit2 outcome  rand( CAUSAL EDAD_MUJER_REC PUEBLO_ORIGINARIO_REC PAIS_ORIGEN_REC HITO1_EDAD_GEST_SEM_REC  MACROZONA  PREV_TRAMO_REC), lclass(`i') seed(2125)
estimates store an_lca_logit_`i' //* previous had an invalid name
}

cap noi estwrite _all using "./analisis_lclogit.sters", replace

<</dd_do>>
~~~~

<<dd_display: "Tiempo= `c(current_time)' `c(current_date)'">>

 