# Clearing the environment.
rm(list = ls())

# Setting working directory.
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Packages
library(tidyverse)

# Loading Data.
trade_data_2023_imports = read_csv("2023_data_from_imports.csv")
trade_data_2023_exports = read_csv("2023_data_from_exports.csv")

# Selecting variables to keep.
trade_data_2023_imports = trade_data_2023_imports |> 
  select(reporterISO, partnerISO, cifvalue, fobvalue)

trade_data_2023_exports = trade_data_2023_exports |> 
  select(reporterISO, partnerISO, cifvalue, fobvalue)

# First just dealing with CIF values.
has_cif_imports = trade_data_2023_imports |> filter(!is.na(cifvalue))
has_cif_imports = has_cif_imports |> select(reporterISO, partnerISO, cifvalue)

# Turning into an import-export table. Should be able to use this to create the 
# graph.
has_cif_imports = has_cif_imports |> pivot_wider(names_from = partnerISO, values_from = cifvalue)

# Now dealing with FOB values.
has_fob_imports = trade_data_2023_imports |> filter(is.na(cifvalue))
has_fob_imports = has_fob_imports |> select(reporterISO, partnerISO, fobvalue)

# Doing a 15% adjustment so FOB is closer to CIF. ad-hoc and will change later.
has_fob_imports = has_fob_imports |> mutate(fobvalue = fobvalue * (1+0.2))

# Pivoting.
has_fob_imports = has_fob_imports |> pivot_wider(names_from = partnerISO, values_from = fobvalue)

# Turning to exports.
has_cif_exports = trade_data_2023_exports |> filter(!is.na(cifvalue))
has_cif_exports = has_cif_exports |> select(!fobvalue)

# Pivoting.
has_cif_exports = has_cif_exports |> pivot_wider(names_from = reporterISO, values_from = cifvalue)

# FOB values.
has_fob_exports = trade_data_2023_exports |> filter(is.na(cifvalue)) |> select(!cifvalue)

# Doing a 15% adjustment so FOB is closer to CIF. ad-hoc and will change later.
has_fob_exports = has_fob_exports |> mutate(fobvalue = fobvalue * (1+0.2))

# Pivoting.
has_fob_exports = has_fob_exports |> pivot_wider(names_from = reporterISO, values_from = fobvalue)

# Now to join all of these together. Will start with joining the imports together.
# They just need a row bind plus name changes.
has_cif_imports = has_cif_imports |> rename("importer" = "reporterISO")
has_fob_imports = has_fob_imports |> rename("importer" = "reporterISO")

# Binding.
importer_data = bind_rows(has_cif_imports, has_fob_imports)

# Now to combine data from exporters together.
# Renaming.
has_cif_exports = has_cif_exports |> rename("importer" = "partnerISO")
has_fob_exports = has_fob_exports |> rename("importer" = "partnerISO")

# Joining them together.
exporter_data = full_join(has_fob_exports, has_cif_exports, by = c("importer"))

# Now just need to combine
trade_data_matrix = bind_rows(importer_data, exporter_data)

# Replacing NA values with 0.
trade_data_matrix[is.na(trade_data_matrix)] = 0

# Setting Importer column to be alphabetical.
trade_data_matrix = trade_data_matrix |> arrange(importer)

# Reordering columns to be alphabetical.
column_names = names(trade_data_matrix)[2:220]
column_names = sort(column_names)

trade_data_matrix = trade_data_matrix[, c("importer", column_names)]


write_csv(trade_data_matrix, "2023_trade_data_matrix.csv")
