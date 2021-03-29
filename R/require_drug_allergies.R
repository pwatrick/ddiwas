#' Removes drug ingredient allergies documented prior to observation period and requires all patients to have >=1 drug allergy list entry during observation period.
#'
#' @param ehr_drug_allergies A tibble
#' @param covariates A tibble
#' @return A tibble \code{covariates}
#' @export

require_drug_allergies <- function(ehr_drug_allergies, covariates) {

  ehr_drug_allergies <- ehr_drug_allergies %>%
    filter(first_adr_date >= start_date & first_adr_date <= end_date) %>%
    distinct()

  ehr_drug_allergies <- ehr_drug_allergies %>%
    select(person_id) %>%
    distinct()

  covariates <- covariates %>%
    select(person_id, is_m, is_w, age_n, obs_length_n, num_drug_exposures_n, group_label)
  covariates <- covariates %>%
    filter(person_id %in% ehr_drug_allergies$person_id)

  return(covariates)
}
