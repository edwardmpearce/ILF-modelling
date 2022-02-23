# This script defines functions to generate a dataframe of (x,y) pairs which
# follow a power law relation y = ax^b with random noise and
# calculate the 'increased limit factor' ILF = 2^b - 1.

library(ggplot2)


generate_powerlaw_dataset <- function(N = 5000, a = 1.5, b = 0.5, gamma_family_shape = 10, rseed = NULL) {
  # Let x be the limit/sum insured on an insurance quote, and y be the premium.
  # Suppose a power law relation y = ax^b, then log(y) = log(a) + b*log(x).
  # This function generates a sample of N quotes whose premium follows the above
  # power law for the input parameters a, b with a Gamma error distribution
  # of fixed shape specified by the gamma_family_shape argument.
  # A random seed integer rseed may be provided for reproducibility.
  set.seed(rseed)

  # Sample values for sums insured from a Gamma distribution with parameters
  # Shape k = alpha = 2, Scale = theta = 1/beta = 2; Mean is £4M and mode is £2M
  x <- rgamma(N, shape = 2, scale = 2) * 1000000
  # Calculate the expected values E[Y|X] of the premium for each sum insured
  y_true <- a * (x ^ b)
  
  # We sample y values from a Gamma distribution (of fixed shape/dispersion).
  # This is to model positive-only data with positively-skewed errors.
  y <- rgamma(N, shape = gamma_family_shape, scale = y_true/gamma_family_shape)
  
  # Package the generated data into a dataframe and return
  dataset <- data.frame(SumInsured = x, Premium = y, meanPremium = y_true)
}


exponent_to_ilf <- function(b) {
  # Calculate the Increased Limit Factor as a percentage from a power law exponent b
  signif(100 * (2^b - 1), 5)
}


summarize_estimates <- function(models, model_names, coef_idx) {
  # Package coefficient estimates from a list of models into a dataframe format suitable for ggplot
  data.frame(model = model_names,
             estimate = sapply(models, function(model) coef(model)[coef_idx]),
             lower_bound = sapply(models, function(model) confint(model)[coef_idx, 1]),
             upper_bound = sapply(models, function(model) confint(model)[coef_idx, 2])
  )
}


plot_estimates <- function(estimates_df, title = NULL, true_value = NULL) {
  # Plot model estimates with error bars
  ggplot(data = estimates_df, aes(x = model, y = estimate, colour = model, group = model)) +
    # Add line for true model value of a
    geom_hline(yintercept = true_value, colour = "grey50", linetype = "dashed", size = 1) + 
    # Plot estimate and confidence interval for each model
    geom_errorbar(aes(ymin = lower_bound, ymax = upper_bound), colour = "black", width = .1) +
    geom_point(size=3) + 
    labs(title = title) + 
    theme_light() + 
    theme(text = element_text(size = 12),
          axis.text.x = element_text(angle = 30, hjust=1),
          panel.grid.minor = element_blank())
}
