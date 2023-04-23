library(tidyverse)
library(rio)

load("data2_lca2.RData")

fig_lca_fit<- tab_ppio %>%
  dplyr::mutate_if(is.character, as.numeric) %>%  # convert character columns to numeric
  tidyr::pivot_longer(cols = -ModelIndex, #"evryone but index"
                      names_to = "indices", values_to = "value", values_drop_na = F) %>%
  dplyr::mutate(indices = factor(indices, levels = levels, labels = labels)) %>%
  dplyr::filter(grepl("(AIC|BIC)",indices, ignore.case=T))%>%
  dplyr::mutate(ModelIndex= factor(ModelIndex, levels=2:n_class_max)) %>% 
  ggplot(aes(x = ModelIndex, y = value, group = indices, color = indices, linetype = indices)) +
  geom_line(size = 1.5) +
  scale_color_manual(values = manualcolors) +
  #scale_linetype_manual(values = c("solid", "dashed", "dotted")) +
  labs(x = "Number of Classes", y = "Value", color = "Measure", linetype = "Measure") +
  #facet_wrap(.~indices, scales = "free_y", nrow = 4, ncol = 1) +
  theme_bw()

fig_lca_fit

ggsave(fig_lca_fit,filename="./Comparison_models.png", dpi=600)

rio::export(mydata_preds3,"mydata_preds3.dta")