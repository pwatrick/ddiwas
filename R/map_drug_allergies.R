#' Map drug allergies to RxCUI ingredients.
#'
#' @param ehr_drug_allergies A tibble dataframe
#' @return A tibble dataframe \code{drug_allergies}
#' @export

map_drug_allergies <- function(ehr_drug_allergies) {

  #Get drug name from `note_text` column
  ##Convert `note_text` column to lower case
  ehr_drug_allergies$note_text <- tolower(ehr_drug_allergies$note_text)
  ##Get first word in `note_text` column, which will most likely a drug's name
  ehr_drug_allergies$first_word <- word(ehr_drug_allergies$note_text, 1, sep = fixed(" "))
  ##Remove all characters that are not letters
  ehr_drug_allergies$drug_name <- str_extract(ehr_drug_allergies$first_word, regex("[:alpha:]+"))

  #Map drugs to RxCUI ingredients
  ##Map drugs to RxCUIs
  ehr_drug_allergies <- inner_join(ehr_drug_allergies, ddiwas::ddi_rxcui_names, by = "drug_name")
  ##Map RxCUIs to RxCUI ingredients
  ehr_drug_allergies <- inner_join(ehr_drug_allergies, ddiwas::ddi_rxcui2in, by = "rxcui")

  #Remove drug allergies identified prior to observation period
  ##Identify drug allergies documented prior to observation period
  prior_drug_allergies <- ehr_drug_allergies %>%
    filter(first_adr_date < start_date) %>%
    select(person_id, rxcui_ingr, rxcui_ingr_name) %>%
    distinct()
  names(prior_drug_allergies) <- c("person_id", "rxcui_ingr", "prior_rxcui_ingr_name")
  ##Identify drug allergies documented during observation period
  drug_allergies <- ehr_drug_allergies %>%
    filter(first_adr_date >= start_date & first_adr_date <= end_date) %>%
    select(person_id, rxcui_ingr, rxcui_ingr_name) %>%
    distinct()
  ##For each patient, remove drug allergies documented prior to observation period
  drug_allergies <- left_join(drug_allergies,
                              prior_drug_allergies,
                              by = c("person_id", "rxcui_ingr"))
  drug_allergies <- drug_allergies %>%
    filter(is.na(prior_rxcui_ingr_name)) %>%
    select(person_id, rxcui_ingr) %>%
    distinct()
  ##Add back drug names to RxCUI ingredients
  rxcui2in1 <- ddiwas::ddi_rxcui2in %>% select(-rxcui) %>% distinct()
  drug_allergies <- inner_join(drug_allergies, rxcui2in1, by = "rxcui_ingr")
  drug_allergies <- drug_allergies %>%
    select(-rxcui_ingr)
  names(drug_allergies) <- c("person_id", "drug_allergy")

  return(drug_allergies)
}
