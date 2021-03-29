#' Create regression table.
#'
#' @param drug_allergie A tibble
#' @param covariates A tibble
#' @return A tibble \code{regression_table}
#' @export

create_regression_table <- function(drug_allergies, covariates) {

  drug_allergies$count <- 1

  regression_table <- drug_allergies %>%
    pivot_wider(names_from = drug_allergy,
                values_from = count,
                values_fill = list(count = 0))

  regression_table <- left_join(covariates,
                                regression_table,
                                by = "person_id")
  regression_table <- regression_table %>% replace(is.na(.), 0)

  #Only test drugs with >= 1 patients in each cell of 2x2 table
  ##Create confusion matrix
  covariates <- regression_table %>% select(person_id:group_label)
  drug_allergies <- regression_table %>% select(-c("is_m":"group_label"))
  cont_table_output <- ddiwas::calculate_contingency_table(drug_allergies, covariates)
  ##Exclude drugs that do not have at least 1 patient in each cell of 2x2 table
  cont_table_output1 <- cont_table_output %>%
    filter(nA >= 1 & nB >= 1 & nC >= 1 & nD >= 1)
  drugs1 <- cont_table_output1$rxcui_ingr_name
  batch1_drugs_rxcuis <- c("person_id", drugs1)
  batch1_drugs <- drug_allergies[batch1_drugs_rxcuis]
  ##Re-join with covariates
  regression_table <- left_join(covariates,
                                batch1_drugs,
                                by = "person_id")
  return(regression_table)
}
