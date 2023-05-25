
library(DiagrammeR) #⋉
if(!require(DiagrammeRsvg)){install.packages("DiagrammeRsvg")}
if(!require(rsvg)){install.packages("rsvg")}


gr_lca2<-
  DiagrammeR::grViz("
digraph flowchart {
    fontname='Comic Sans MS'

  # Nodes
  subgraph samelevel {
    CAUSAL [label = 'Causal',fontsize=10,shape = box]
    MUJER_REC [label = 'Sexo\n(mujer)',fontsize=10,shape = box]
    EDAD_MUJER_REC [label = 'Edad\nmujer',fontsize=10,shape = box]
    HITO1_EDAD_GEST_SEM_REC [label = 'Edad\nGestacional\nHito 1',fontsize=10,shape = box]
    MACROZONA [label = 'Macrozona',fontsize=10,shape = box]
    PAIS_ORIGEN_REC [label = 'País de\norigen',fontsize=10,shape = box]
    PREV_TRAMO_REC [label = 'Previsión y\ntramo',fontsize=10,shape = box]
    
  {rank=same; rankdir= 'TB'; CAUSAL MUJER_REC EDAD_MUJER_REC HITO1_EDAD_GEST_SEM_REC MACROZONA PAIS_ORIGEN_REC PREV_TRAMO_REC }
  }
  LCA [label= 'Clases\nlatentes', shape= circle, style=filled, color=lightgrey, fontsize=10]
  
  inter [label = 'Interupción\nembarazo',fontsize=10,shape = box, height=.00002] # set the position of the inter node pos='15,100'

  # Nodes
  subgraph {
   LCA ->  {CAUSAL MUJER_REC EDAD_MUJER_REC HITO1_EDAD_GEST_SEM_REC MACROZONA PAIS_ORIGEN_REC PREV_TRAMO_REC } [rank=same; rankdir= 'TB'] 
}
  subgraph {
   LCA -> inter [minlen=14] #minlen es necesario para correr arrowhead = none; 
  {rank=same; LCA inter [rankdir='LR']}; #; 
}
}")#, width = 1200, height = 900
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3733703/
#Cohort matching on a variable associated with both outcome and censoring
#Cohort matching on a confounder. We let A denote an exposure, Y denote an outcome, and C denote a confounder and matching variable. The variable S indicates whether an individual in the source population is selected for the matched study (1: selected, 0: not selected). See Section 2-7 for details.
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7064555/
DPI = 1200
WidthCM = 21
HeightCM = 8

gr_lca2 %>%
  export_svg %>% charToRaw %>% rsvg_pdf("fig1_main_flowchart_lca_adj_sin_po_ano.pdf")

gr_lca2 %>% export_svg()%>%charToRaw %>% rsvg(width = WidthCM *(DPI/2.54), height = HeightCM *(DPI/2.54)) %>% png::writePNG("fig1_main_flowchart_lca0_adj_sin_po.png")

htmlwidgets::saveWidget(gr_lca2, "fig1_main_flowchart_lca_adj_sin_po_ano.html")
webshot::webshot("fig1_main_flowchart_lca_adj_ano.html", "fig1_main_flowchart_lca_adj_sin_po_ano.png",vwidth = 1200, vheight = 800, zoom = 2)

# Paso 35

rm(list = ls());gc()
load("data2_lca2_adj_sin_po_ano.RData")

require(ggplot2)

ggsave("_fig2_comparison_adj_sin_po_ano_final.png",fig_lca_fit2, dpi=600)

#Paso 35
rm(list = ls());gc()
load("data2_lca3_sin_po_ano_2023_05_14.RData")
#variables_probabilities_in_category_sin_po_ano.xlsx
#variables_probabilities_in_category_glca_adj_sin_po.xlsxbootlrt

#Paso 36
rm(list = ls());gc()
load("data2_lca3_glca_sin_po_ano.RData")

apply(data.frame(bootlrt$boot), 1,mean)
bootlrt$gtable %>% 
  data.frame() %>% 
  dplyr::select(BIC, entropy, Gsq, Boot.p.value) %>% 
  rio::export("table_fit.xlsx")

#Paso 216
rm(list = ls());gc()
load("data2_lca2_adj216_alt_sin_po_ano_2023_05_14.RData")

apply(data.frame(bootlrt2$boot), 1,mean)
bootlrt2$gtable %>% 
  data.frame() %>% 
  dplyr::select(BIC, entropy, Gsq, Boot.p.value) %>% 
  rio::export("table_fit2.xlsx")

#Paso 3.5
rm(list = ls());gc()
load("data2_lca3_sin_po_ano_2023_05_14.RData")
table(LCA_best_model_adj_mod$predclass)
