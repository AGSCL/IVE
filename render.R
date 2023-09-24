# Load the rmarkdown package
library(rmarkdown)

# Specify the path to your Markdown file
markdown_file <- "H:/Mi unidad/Angelica/secreto/LCA2.Rmd"

# Render the Markdown document
rmarkdown::render(
  input = markdown_file,
  output_format = "html_document"  # You can change the output format as needed
)

fidelius::html_password_protected(paste0(here::here(),"LCA2.Rmd"))
#cd H:/Mi unidad/Angelica/secreto/
#Rscript render.R
