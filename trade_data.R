rm(list = ls())

# Setting working directory.
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Packages
library(tidyverse)
library(comtradr)

Sys.setenv('COMTRADE_PRIMARY' = "a7a37c32b0774ef89a2e6a276a23e41e")

reporter_code = country_codes |> filter(is.na(exit_year)) |> filter(reporter == "TRUE")

# Removing from reporter codes due to either being overseas territory, regional grouping,
# or in the EU.
# EU = c("AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE")

# Filtering our EU.
# reporter_code = reporter_code |> filter( !(iso_3 %in% EU) )

# Just going to see which countries have actual import data for 2023.
codes = reporter_code |> select(iso_3) |> filter(iso_3 != "R4 ") |> filter(iso_3 != "EUR")
codes = as.vector(codes$iso_3)


# Loading all imports
trade_data_2023 = tibble()
non_reporter = c()

for (i in 1:220) {
  imports = ct_get_data(flow_direction = "import", reporter = codes[i], partner = codes, start_date = 2023, end_date = 2023)
  
  if(ncol(imports) !=1){
    trade_data_2023 = bind_rows(trade_data_2023, imports)
  }
  else{
    index = length(non_reporter)
    non_reporter[index + 1] = codes[i]
  }
  
}

write_csv(trade_data_2023, "2023_data_from_imports.csv")

# Grabbing data from exports for those countries that did not have import data.
code_2 = reporter_code |> select(iso_3) |> filter( !(iso_3 %in% non_reporter) ) |> 
  filter(iso_3 != "R4 ") |> filter(iso_3 != "EUR")
code_2 = as.vector(code_2$iso_3)

# Initializing variables.
no_data = c()
export_table = tibble()

# For loop to download the of countries listed exports for our nonreporters.
for (i in 1:length(code_2)) {
  exports = ct_get_data(flow_direction = "export", reporter = code_2[i], partner = non_reporter, start_date = 2023, end_date = 2023)
  
  if(ncol(exports) !=1){
    export_table = bind_rows(export_table, exports)
  }
  else{
    index = length(no_data)
    no_data[index + 1] = code_2[i]
  }
}

write_csv(export_table, "2023_data_from_exports.csv")
