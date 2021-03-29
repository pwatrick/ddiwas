#' Calculate contingency table.
#'
#' @param medications A tibble
#' @param covariates A tibble
#' @return A tibble \code{cont_table_output}
#' @export

calculate_contingency_table <- function(medications, covariates) {

  library(varhandle)

  covariates <- covariates %>% select(-person_id)
  medications <- medications %>% select(-person_id)

  cases <- filter(covariates, group_label == 1)
  controls <- filter(covariates, group_label == 0)
  nCases <- nrow(cases)
  nControls <- nrow(controls)

  create_contigency_table <- function(drug) {

    covariates["drug"]<-medications[drug]
    # calculate 2x2 contingency table numbers
    covariates_cases <- filter(covariates, group_label == 1)
    covariates_controls <- filter(covariates, group_label == 0)
    nA <- sum(covariates_cases["drug"])
    nB <- sum(covariates_controls["drug"])
    nC <- nCases-nA
    nD <- nControls-nB
    # store results
    results <- c(drug,nA,nB,nC,nD)

  }
  drugs <- names(medications)
  cont.results <- lapply(drugs, create_contigency_table)
  cont_table_output <- as.data.frame(do.call(rbind, cont.results))
  names(cont_table_output) <- c("rxcui_ingr_name","nA","nB","nC","nD")
  cont_table_output <- as_tibble(cont_table_output)
  cont_table_output <- varhandle::unfactor(cont_table_output)
  cont_table_output <- cont_table_output %>% arrange(desc(nA))

  return (cont_table_output)
}




