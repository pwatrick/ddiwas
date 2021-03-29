#' Logistic regression function.
#'
#' @param regression_table A tibble
#' @param rare_events Binary value. Defaults to FALSE. Change to TRUE if you want to test drugs with rare ADR events
#' @return A tibble \code{results}
#' @export

ddiwas_regression <- function(regression_table, rare_events = FALSE) {

  #Data preprocessing
  covariates <- regression_table %>% select(person_id:group_label)
  drug_allergies <- regression_table %>% select(-c("is_m":"group_label"))

  ##First, apply regression for drugs where there are >=5 patients in each cell of 2x2 table
  cont_table_output <- ddiwas::calculate_contingency_table(drug_allergies, covariates)
  names(cont_table_output) <- c("drug", "nA", "nB", "nC", "nD")
  batch1_output <- cont_table_output %>%
    filter(nA >= 5 & nB >= 5 & nC >= 5 & nD >= 5)
  batch2_output <- cont_table_output %>%
    filter(!(drug %in% batch1_output$drug))

  drugs1 <- batch1_output$drug
  batch1_drugs_rxcuis <- c("person_id", drugs1)
  batch1_drugs <- drug_allergies[batch1_drugs_rxcuis]
  batch1_drugs <- names(batch1_drugs[,2:ncol(batch1_drugs)])

  drugs2 <- batch2_output$drug
  batch2_drugs_rxcuis <- c("person_id", drugs2)
  batch2_drugs <- drug_allergies[batch2_drugs_rxcuis]
  batch2_drugs <- names(batch2_drugs[,2:ncol(batch2_drugs)])

  #Function to run regression via for loop
  ddiwas_glm <- function(drug) try({

    test_drug <- c('person_id', drug)
    df_test_drug <- inner_join(covariates, drug_allergies[test_drug], by = "person_id")
    df_test_drug['drug'] <- df_test_drug[drug]
    #Run model to get statistics
    glm_model <- tidy(glm(group_label ~ drug+is_m+is_w+age_n+obs_length_n+num_drug_exposures_n,
                          data = df_test_drug,
                          family = "binomial")) %>%
      mutate(or = exp(estimate)) %>%
      filter(term == "drug")
    #Store results
    results <- tibble(drug = drug,
                      coef = glm_model$estimate[1],
                      se = glm_model$std.error[1],
                      pval = glm_model$p.value[1],
                      or = glm_model$or[1])
    #Join with 2x2 contigency table numbers
    results <- inner_join(results, batch1_output, by = "drug")
  })

  #Function to run Firth regression via for loop
  ddiwas_regression_rare <- function(drug) try({

    test_drug <- c('person_id', drug)
    df_test_drug <- inner_join(covariates, drug_allergies[test_drug], by = "person_id")
    df_test_drug['drug'] <- df_test_drug[drug]

    #Run Firth model to get statistics
    firthModel <- logistf::logistf(group_label ~ drug+is_m+is_w+age_n+obs_length_n+num_drug_exposures_n,
                                   data=df_test_drug,
                                   firth=TRUE,
                                   pl=TRUE)

    #Store results
    results <- tibble(drug = drug,
                      coef = firthModel$coefficients[2],
                      se = sqrt(diag(vcov(firthModel)))[2],
                      pval = firthModel$prob[2],
                      or = exp(firthModel$coefficients[2]))
    #Join with 2x2 contigency table numbers
    results <- inner_join(results, batch2_output, by = "drug")

    return(results)
  })

  results <- tibble(drug = character(),
                    coef = double(),
                    se = double(),
                    pval = double(),
                    or = double(),
                    nA = double(),
                    nB = double(),
                    nC = double(),
                    nD = double())

  for (drug in batch1_drugs[1:length(batch1_drugs)]){
    results1 <- ddiwas_glm(drug)
    results <- bind_rows(results, results1)
  }

  #To test drugs with rare ADR events
  if(rare_events == TRUE & length(batch2_drugs) > 0) {

    results_rare <- tibble(drug = character(),
                      coef = double(),
                      se = double(),
                      pval = double(),
                      or = double(),
                      nA = double(),
                      nB = double(),
                      nC = double(),
                      nD = double())

    for (drug in batch2_drugs[1:length(batch2_drugs)]){
      results_rare1 <- ddiwas_regression_rare(drug)
      results_rare <- bind_rows(results_rare, results_rare1)
    }

    results <- bind_rows(results, results_rare)
  }

  return(results)
}
