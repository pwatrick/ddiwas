#' Process covariates.
#'
#' @param covariates A tibble dataframe
#' @param df_drug_exposures A tibble dataframe
#' @return A tibble dataframe \code{covariates}
#' @export

process_covariates <- function(covariates, df_drug_exposures) {

  #Calculate number of unique drug ingredient exposures during observation period
  ##Map drug exposures to RxCUI ingredients
  ###Map OHDSI concept ids to RxCUIs
  df_drug_exposures <- inner_join(df_drug_exposures, ddiwas::ddi_ohdsi_rxnorm, by = "concept_id")
  df_drug_exposures <- df_drug_exposures %>%
    select(person_id, rxcui) %>%
    distinct()
  ###Map RxCUIs to RxCUI ingredients
  df_drug_exposures <- inner_join(df_drug_exposures, ddiwas::ddi_rxcui2in, by = "rxcui")
  df_drug_exposures <- df_drug_exposures %>%
    select(person_id, rxcui_ingr) %>%
    distinct()

  ##Output with number of unique drug ingredient exposures per patient
  df_drug_exposures <- df_drug_exposures %>%
    group_by(person_id) %>%
    tally()
  names(df_drug_exposures) <- c("person_id", "num_drug_exposures")

  #Calculate age and remove patients not between ages of 18 and 90 at start of observation period
  ##Calculate age
  covariates$age <- interval(covariates$dob, covariates$start_date)
  covariates$age <- time_length(covariates$age, "year")
  ##Remove patients not between ages of 18 and 90 at start of observation period.
  covariates <- covariates %>%
    filter(age >= 18 & age < 90)

  #Calculate observation period length in days
  covariates$obs_length <- interval(covariates$start_date, covariates$end_date)
  covariates$obs_length <- time_length(covariates$obs_length, "day")

  #Obtain final covariates to use in regression
  ##Add number of unique drug ingredient exposures to covariates
  covariates <- inner_join(covariates, df_drug_exposures, by = "person_id")
  ##Normalize covariates
  ###Age
  v1 <- covariates$age
  v2 <- (v1-min(v1))/(max(v1)-min(v1))
  covariates$age_n <- v2
  ###obs_length
  v1 <- covariates$obs_length
  v2 <- (v1-min(v1))/(max(v1)-min(v1))
  covariates$obs_length_n <- v2
  ###num_drug_exposures`
  v1 <- covariates$num_drug_exposures
  v2 <- (v1-min(v1))/(max(v1)-min(v1))
  covariates$num_drug_exposures_n <- v2
  ###convert binary variables
  covariates$is_m <- if_else(covariates$gender == "M", 1, 0)
  covariates$is_w <- if_else(covariates$race == "W", 1, 0)

  return(covariates)
}
