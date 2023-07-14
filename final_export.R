
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

# Paso 35-------------------------------------------------------------------------

rm(list = ls());gc()
load("data2_lca2_adj_sin_po_ano.RData")

require(ggplot2)

ggsave("_fig2_comparison_adj_sin_po_ano_final.png",fig_lca_fit2, dpi=600)

#Paso 35
rm(list = ls());gc()
load("data2_lca3_sin_po_ano_2023_05_14.RData") #Paso 213 y 214
#variables_probabilities_in_category_sin_po_ano.xlsx
#variables_probabilities_in_category_glca_adj_sin_po.xlsxbootlrt
require(sjPlot)
require(tidyverse)
require(tableone)

manualcolors<- c(paste0("gray",seq(20,80, by=20)))
fig_lca_fit<- tab_ppio %>%
  dplyr::mutate_if(is.character, as.numeric) %>%  # convert character columns to numeric
  tidyr::pivot_longer(cols = -ModelIndex, #"evryone but index"
                      names_to = "indices", values_to = "value", values_drop_na = F) %>%
  dplyr::mutate(indices = factor(indices, levels = levels, labels = labels)) %>%
  dplyr::filter(grepl("(BIC)",indices, ignore.case=T))%>%
  dplyr::mutate(ModelIndex= factor(ModelIndex, levels=2:n_class_max)) %>% 
  ggplot(aes(x = ModelIndex, y = value, group = indices, color = indices, linetype = indices)) +
  geom_line(size = 1.5) +
  scale_color_manual(values = manualcolors) +
  #scale_linetype_manual(values = c("solid", "dashed", "dotted")) +
  labs(x = "Número de clases", y="Valor", color="Medida", linetype="Medida")+
  #facet_wrap(.~indices, scales = "free_y", nrow = 4, ncol = 1) +
  sjPlot::theme_sjplot()

fig_lca_fit
ggsave("__fig2_medidas_de_ajuste_polca_sin_ano_pueb_orig.pdf",fig_lca_fit)


#para hacer la comparación
#table(data2$CAUSAL)
#dplyr::mutate(data2, EDAD_MUJER_REC= as.character(dplyr::case_when(EDAD_MUJER<18~"1.<18", EDAD_MUJER>=18 & EDAD_MUJER<25~"2.18-24", EDAD_MUJER>=25 & EDAD_MUJER<35~"3.25-35",EDAD_MUJER>=35~"4.>=35")), HITO1_EDAD_GEST_SEM_REC= factor(dplyr::case_when(HITO1_EDAD_GESTACIONAL_SEMANAS<14~"1.0-13 semanas", HITO1_EDAD_GESTACIONAL_SEMANAS>=14 & HITO1_EDAD_GESTACIONAL_SEMANAS<28~"2.14-27 semanas", HITO1_EDAD_GESTACIONAL_SEMANAS>=28~ "3.>=28 semanas")))%>% janitor::tabyl(EDAD_MUJER_REC)

table_homolog<-
cbind.data.frame(
Name = c("n", "CAUSAL", "CAUSAL", "CAUSAL", "EDAD_MUJER_REC", 
                        "EDAD_MUJER_REC", "EDAD_MUJER_REC", "EDAD_MUJER_REC", "EDAD_MUJER_REC", 
                        "PAIS_ORIGEN_REC", "PAIS_ORIGEN_REC", "PAIS_ORIGEN_REC", "HITO1_EDAD_GEST_SEM_REC", 
                        "HITO1_EDAD_GEST_SEM_REC", "HITO1_EDAD_GEST_SEM_REC", "HITO1_EDAD_GEST_SEM_REC", 
                        "MACROZONA", "MACROZONA", "MACROZONA", "MACROZONA", "MACROZONA", 
                        "MACROZONA", "AÑO", "AÑO", "AÑO", "AÑO", "AÑO", "PREV_TRAMO_REC", 
                        "PREV_TRAMO_REC", "PREV_TRAMO_REC", "PREV_TRAMO_REC", "PREV_TRAMO_REC", 
                        "HITO2_DECISION_MUJER_IVE", "HITO2_DECISION_MUJER_IVE", "HITO2_DECISION_MUJER_IVE"),
level = c("", "2", "3", "4", "1", "2", "3", "4", "5", "1", 
          "2", "3", "1", "2", "3", "4", "1", "2", "3", "4", "5", "6", "2", 
          "3", "4", "5", "6", "1", "2", "3", "4", "5", "CONTINUAR EL EMBARAZO", 
          "INTERRUMPIR EL EMBARAZO", "NO APLICA, INSCONSCIENTE"),
cat = c("", "Causal 1", "Causal 2", "Causal 3", "[Perdidos]", "1. <18", "2. 18-24", "3. 25-35", "4. >=35", 
          "[Perdidos]", "Chile", "Otros", "[Perdidos]", "1. 0-13 semanas", "2. 14-27 semanas", "3. >=28 semanas", 
          "[Perdidos]", "Centro", "Centro Norte", "Centro Sur", "Norte", "Sur", "2018", "2019", "2020", "2021", "2022", 
          "[Perdidos]", "ISAPRE o FFAA", "FONASA A/B", "FONASA C/D", "NINGUNA", "CONTINUAR EL EMBARAZO", "INTERRUMPIR EL EMBARAZO", "NO APLICA, INSCONSCIENTE")
)
run_tableone(listVars =c("CAUSAL", "EDAD_MUJER_REC", "PAIS_ORIGEN_REC", 
                         "HITO1_EDAD_GEST_SEM_REC","MACROZONA", "AÑO", "PREV_TRAMO_REC",
                         "HITO2_DECISION_MUJER_IVE"), df= mydata_preds3, 
             catVars= c("CAUSAL", "EDAD_MUJER_REC", "PAIS_ORIGEN_REC", 
                        "HITO1_EDAD_GEST_SEM_REC","MACROZONA", "AÑO", "PREV_TRAMO_REC"),
             strata= "outcome") %>%  
  dplyr::left_join(table_homolog, by= c("Name"="Name","level"="level")) %>% 
  dplyr::select(Name, cat, everything()) %>% 
  dplyr::select(-level) %>% 
  knitr::kable("html", caption="Descriptivos (acotado)") %>% kableExtra::kable_classic()



#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_
#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_
#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_
if(no_mostrar==0){
  #    dplyr::select(HITO2_DECISION_MUJER_IVE, c("CAUSAL", "EDAD_MUJER_REC", "PAIS_ORIGEN_REC", "HITO1_EDAD_GEST_SEM_REC","MACROZONA", "AÑO", "PREV_TRAMO_REC")) %>% 
  chisquare_test<-
  mydata_preds3%>% 
    dplyr::select( 
      c("CAUSAL", "EDAD_MUJER_REC", "PAIS_ORIGEN_REC", 
        "HITO1_EDAD_GEST_SEM_REC","MACROZONA", "PREV_TRAMO_REC", "outcome")) %>% 
    tidyr::gather(variable,measure, -outcome) %>% 
    dplyr::group_by(variable) %>%
    dplyr::do(cbind.data.frame(broom::tidy(chisq.test(.$outcome, .$measure)),
                               broom::tidy(sum(table(.$outcome, .$measure))))
    ) %>% 
    #casos completos
    #chisq.test(table(Base_fiscalia_v14_filt$motivodeegreso_mod_imp_rec, Base_fiscalia_v14_filt$sus_principal_mod, exclude=NULL))
    dplyr::mutate(p.value=ifelse(p.value<.001,"<0.001",sprintf("%1.3f",p.value))) %>% 
    dplyr::mutate(statistic=sprintf("%2.0f",statistic)) %>% 
    dplyr::mutate(report=paste0("X²(",parameter,", ",x,")=",statistic,"; p", ifelse(p.value=="<0.001",p.value, paste0("=",p.value)))) %>%
    dplyr::mutate(report=sub("0\\.","0,",sub("\\.",",",report)))
  
  # chisq.test(Base_fiscalia_v14_filt$motivodeegreso_mod_imp_rec, is.na(Base_fiscalia_v14_filt$offender_d)) 
  # chisq.test(Base_fiscalia_v14_filt$motivodeegreso_mod_imp_rec, is.na(Base_fiscalia_v14_filt$offender_d)) 
  # 
  fisher_test<-
  mydata_preds3 %>% 
    dplyr::select( 
      c("CAUSAL", "EDAD_MUJER_REC", "PREV_TRAMO_REC", "outcome")) %>% 
    tidyr::gather(variable,measure, -outcome) %>% 
    dplyr::group_by(variable) %>%
    dplyr::do(fisher.test(table(.$outcome, .$measure, exclude=NULL), 
                          workspace = 2e10, simulate.p.value = T, B=1e5) %>% 
                broom::tidy()) 

  #EDAD_MUJER  HITO1_EDAD_GESTACIONAL_SEMANAS  
paste0(
  "Edad mujer (IVE): ",
  quantile(data2$EDAD_MUJER[mydata_preds3$outcome==1],.5, na.rm=T), "(",
  quantile(data2$EDAD_MUJER[mydata_preds3$outcome==1],.25, na.rm=T),", ",
  quantile(data2$EDAD_MUJER[mydata_preds3$outcome==1],.75, na.rm=T),")"
  )
paste0(
  "Edad mujer (no IVE): ",
  quantile(data2$EDAD_MUJER[mydata_preds3$outcome==0],.5, na.rm=T), "(",
  quantile(data2$EDAD_MUJER[mydata_preds3$outcome==0],.25, na.rm=T),", ",
  quantile(data2$EDAD_MUJER[mydata_preds3$outcome==0],.75, na.rm=T),")"
  )

paste0(
  "Edad gestacional en semanas (IVE): ",
  quantile(data2$HITO1_EDAD_GESTACIONAL_SEMANAS[mydata_preds3$outcome==1],.5, na.rm=T), "(",
  quantile(data2$HITO1_EDAD_GESTACIONAL_SEMANAS[mydata_preds3$outcome==1],.25, na.rm=T),", ",
  quantile(data2$HITO1_EDAD_GESTACIONAL_SEMANAS[mydata_preds3$outcome==1],.75, na.rm=T),")"
)
paste0(
  "Edad gestacional en semanas (no IVE): ",
  quantile(data2$HITO1_EDAD_GESTACIONAL_SEMANAS[mydata_preds3$outcome==0],.5, na.rm=T), "(",
  quantile(data2$HITO1_EDAD_GESTACIONAL_SEMANAS[mydata_preds3$outcome==0],.25, na.rm=T),", ",
  quantile(data2$HITO1_EDAD_GESTACIONAL_SEMANAS[mydata_preds3$outcome==0],.75, na.rm=T),")"
)
  
  # Kurksal Wallis
  kruskal<-
  rbind.data.frame(
  name=paste0("Edad mujer (continua): H(",kruskal.test(data2$EDAD_MUJER ~ mydata_preds3$outcome)$parameter,")=",
         round(kruskal.test(data2$EDAD_MUJER ~ mydata_preds3$outcome)$statistic,1), ", p=",
         round(kruskal.test(data2$EDAD_MUJER ~ mydata_preds3$outcome)$p.value,3)),
  name=paste0("Edad gestacional (continua): H(",kruskal.test(data2$HITO1_EDAD_GESTACIONAL_SEMANAS ~ mydata_preds3$outcome)$parameter,")=",
         round(kruskal.test(data2$HITO1_EDAD_GESTACIONAL_SEMANAS ~ mydata_preds3$outcome)$statistic,1), ", p=",
         round(kruskal.test(data2$HITO1_EDAD_GESTACIONAL_SEMANAS ~ mydata_preds3$outcome)$p.value,3))
  )
  colnames(kruskal)<-"names"
  rio::export(list(chisquare_test = chisquare_test, 
                   fisher_test = fisher_test, 
                   kruskal= kruskal), "tableone_extension.xlsx")
   
}

# Paso 36-------------------------------------------------------------------------


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
