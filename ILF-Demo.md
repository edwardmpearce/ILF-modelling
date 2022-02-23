## Background

We suppose a [power law
relation](https://en.wikipedia.org/wiki/Power_law) between the **Sum
Insured** *x* and the **Premium** *y* of an insurance quote. This
relation takes the form
*y*(*x*) = *α**x*<sup>*β*</sup>
which may alternatively be expressed as a linear relationship between
log (*x*) and log (*y*) of the form
log (*y*) = log (*α*) + *β*log (*x*),
where *α* and *β* are constants to be determined.

It follows that for any constant multiplying factor *c* we have
*y*(*c**x*) = *c*<sup>*β*</sup>*y*(*x*), and in particular
*y*(2*x*) = 2<sup>*β*</sup>*y*(*x*) = (1+*γ*)*y*(*x*) for any sum
insured *x*, where we call the constant *γ* = 2<sup>*β*</sup> − 1 the
**Increased Limit Factor**. This means that in our power law model,
doubling the sum insured results in multiplying the premium by a factor
of 1 + *γ*, regardless of the reference sum insured value we doubled.

## Setup

Import plotting libraries

    library(ggplot2)
    library(gridExtra)

Import utility functions

    # Can alternatively use the knitr 'file' chunk option to display the imported code
    source('./GenerateData.R')

## Dataset

For demonstration purposes, we randomly generate a sample of *N* quotes
whose sums insured *X*<sub>*i*</sub> (in millions GBP) are i.i.d. from
Gamma(*k*=2,*θ*=2) and whose premiums *Y*<sub>*i*</sub> are distributed
about the power law
*μ*<sub>*i*</sub> = *α**x*<sub>*i*</sub><sup>*β*</sup> with [Gamma error
distribution](http://en.wikipedia.org/wiki/Gamma_distribution)
(*Y*<sub>*i*</sub>|*X*<sub>*i*</sub>) ∼ Gamma(*k*=*k*<sub>0</sub>,*θ*=*μ*<sub>*i*</sub>/*k*<sub>0</sub>)
where *k*<sub>0</sub> is a constant determining the shape/dispersion of
the Gamma family of error distributions.

Therefore, the theoretical mean and mode for the *X*<sub>*i*</sub> are
£4m and £2m respectively, and the expected and mode value for each
*Y*<sub>*i*</sub> given *X*<sub>*i*</sub> will be *μ*<sub>*i*</sub> and
$\\mu\_{i} \\cdot\\frac{k\_{0}-1}{k\_{0}}$ respectively.

    # Set our power law parameters
    a <- 1.5
    b <- 0.5

    # Generate a dataset of N samples
    dataset <- generate_powerlaw_dataset(N = 10000, a = a, b = b, gamma_family_shape = 10, rseed = 42)

    # Calculate the means of the generated sums insured and premiums
    arithmetic_mean <- data.frame(t(colMeans(dataset)))
    geometric_mean <- data.frame(t(exp(colMeans(log(dataset)))))

<img src="https://raw.githubusercontent.com/edwardmpearce/ILF-modelling/main/figures/demo-data-plot-1.png" width="100%" />

## Modelling methods

We compare two modelling methods for estimating the parameters *α* and
*β*, and hence the **Increased Limit Factor** *γ*.

1.  Linear regression on log-transformed data
2.  Log-linked Gamma GLM

We will also fit and plot a linear model (i.e. line of best fit) to the
data for reference.

### Linear regression on log-transformed data

In this first model, we assume
log (*y*<sub>*i*</sub>) = log (*α*) + *β*log (*x*<sub>*i*</sub>) + *ϵ*
where *ϵ* ∼ *N*(0,*σ*), or equivalently
log (*Y*<sub>*i*</sub>) ∼ *N*(log(*μ*<sub>*i*</sub>),*σ*), and apply
**linear regression** on the log data to estimate log (*α*) and *β* and
subsequently calculate *α* and the increased limit factor
*γ* = 2<sup>*β*</sup> − 1.

This is known to lead to a [biased
estimate](https://en.wikipedia.org/wiki/Power_law#Estimating_the_exponent_from_empirical_data)
of the scaling component *β*. This is because generally
𝔼\[log(*Y*<sub>*i*</sub>)|*X*<sub>*i*</sub>\] ≠ log (𝔼\[*Y*<sub>*i*</sub>|*X*<sub>*i*</sub>\])
and is related to a log-normal assumption on the error distribution.

### Log-linked Gamma GLM

In our case of estimating a power law, and more generally modelling
continuous outcomes which are positively skewed and always taking
positive values, adopting a [generalized linear
model](https://en.wikipedia.org/wiki/Generalized_linear_model) framework
may provide better results due to using a [maximum likelihood
method](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation) for
model fitting.

We assume that
(*Y*<sub>*i*</sub>|*X*<sub>*i*</sub>) ∼ Gamma(*k*=*k*<sub>0</sub>,*θ*=*μ*<sub>*i*</sub>/*k*<sub>0</sub>)
for some constant shape/dispersion parameter *k*<sub>0</sub> where
𝔼\[*Y*<sub>*i*</sub>|*X*<sub>*i*</sub>\] = *μ*<sub>*i*</sub> = *α**x*<sub>*i*</sub><sup>*β*</sup> = exp (log(*α*)+*β*log(*x*<sub>*i*</sub>)).
These assumptions allow us to fit a Gamma distributed Generalized Linear
Model to the data where the link function is exp<sup>−1</sup> = log  and
the linear relation is with log (*X*<sub>*i*</sub>) rather than
*X*<sub>*i*</sub> directly. i.e. A proportional change in the
independent variable *X*<sub>*i*</sub> leads to a proportional change in
the dependent variable *Y*<sub>*i*</sub>, though the respective
proportions may differ.

Further commentary comparing this method to the log-transform linear
regression approach from the previous section is provided in the
[References](#references).

    ## Power law models
    # Fit a linear regression to the log transformed data
    m_log_lm <- lm(I(log(Premium)) ~ I(log(SumInsured)), data = dataset)

    # Fit a log-linked Gamma GLM to the data
    m_gamma_glm <- glm(Premium ~ I(log(SumInsured)), data = dataset, family = Gamma(link = "log"))

    ## Straight line models
    # Fit a linear regression to the data
    m_lm <- lm(Premium ~ SumInsured, data = dataset)

    # Fit an identity-linked Gamma GLM to the data
    # m_gaussian_glm <- glm(Premium ~ SumInsured, data = dataset, family = Gamma(link = "identity"))

## Model summaries

Having fitted the two model types, we now display the summary for each
one. Note that the coefficients ‘Intercept’ and ‘I(log(SumInsured))’
correspond to log (*α*) and *β* in the power law
*y* = *α**x*<sup>*β*</sup>, respectively.

    summary(m_log_lm)

    ## 
    ## Call:
    ## lm(formula = I(log(Premium)) ~ I(log(SumInsured)), data = dataset)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -1.42700 -0.21054  0.01635  0.22790  0.96748 
    ## 
    ## Coefficients:
    ##                    Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)        0.469115   0.060520   7.751 9.98e-15 ***
    ## I(log(SumInsured)) 0.492938   0.004048 121.774  < 2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.3267 on 9998 degrees of freedom
    ## Multiple R-squared:  0.5973, Adjusted R-squared:  0.5973 
    ## F-statistic: 1.483e+04 on 1 and 9998 DF,  p-value: < 2.2e-16

Note that the dispersion parameter *ϕ* estimated by the Gamma GLM
relates to the reciprocal 1/*k*<sub>0</sub> of the shape *k*<sub>0</sub>
we chose when generating the premium values *y*<sub>*i*</sub>. See
[StackExchange - Using R for GLM with Gamma
distribution](https://stats.stackexchange.com/questions/58497/using-r-for-glm-with-gamma-distribution)
for a discussion of relevant underlying assumptions when fitting Gamma
GLMs in R with the standard glm() function.

    summary(m_gamma_glm)

    ## 
    ## Call:
    ## glm(formula = Premium ~ I(log(SumInsured)), family = Gamma(link = "log"), 
    ##     data = dataset)
    ## 
    ## Deviance Residuals: 
    ##      Min        1Q    Median        3Q       Max  
    ## -1.18928  -0.25134  -0.03498   0.18148   1.07970  
    ## 
    ## Coefficients:
    ##                    Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)        0.505492   0.059071   8.557   <2e-16 ***
    ## I(log(SumInsured)) 0.493959   0.003951 125.021   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for Gamma family taken to be 0.1016634)
    ## 
    ##     Null deviance: 2484.5  on 9999  degrees of freedom
    ## Residual deviance: 1032.6  on 9998  degrees of freedom
    ## AIC: 162415
    ## 
    ## Number of Fisher Scoring iterations: 4

## Plotting the predicted model functions

Use the fitted models to calculate predicted values for each of the
datapoints.

    # Predict with the various models
    dataset$pred_log_lm <- exp(predict(m_log_lm, dataset))
    dataset$pred_gamma_glm <- predict(m_gamma_glm, dataset, type = "response")
    dataset$pred_lm <- predict(m_lm, dataset)
    # dataset$pred_gaussian_glm <- predict(m_gaussian_glm, dataset, type = "response")

### Linear scale plot

First plot the predicted curves on a linear scale. Note that visually,
the gamma glm follows the true curve most closely over the displayed
domain, with the log-transformed linear model undershooting the true
curve as the sum insured increases due to a slightly lower estimate for
*β*.

The simple linear model minimizes the mean squared error between the
data points and predicted values, and passes through the
centroid/arithmetic mean point by construction, making a reasonable
approximation to the true curve over a limited range, but underfitting
for particularly high or low sum insured values. Note that since this
best-fit line does not pass through the origin, it does not satisfy the
increased limit factor assumption. Enforcing such a requirement would
restrict the problem to finding an optimal value for *α* (in this case,
the gradient of the line *y* = *α**x*) and assume *β* = 1 and hence an
increased limit factor of *γ* = 1 = 100%.

<img src="https://raw.githubusercontent.com/edwardmpearce/ILF-modelling/main/figures/demo-linear-plot-1.png" width="100%" />

### Log scale plot

Secondly, we plot the model predictions on a log scale to emphasise the
linear relation between the log data. Note that, by construction, the
log-transformed linear model will pass through the geometric mean of the
data $(\\exp(\\overline{\\log(X)}), \\exp(\\overline{\\log(Y)}))$.

The Gamma GLM model will not necessarily pass through the arithmetic nor
geometric mean point of the data, but will rather [estimate the
parameters](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation)
such that the likelihood of the observed data given our modelling
assumptions (power law with Gamma distributed errors) is maximized.

<img src="https://raw.githubusercontent.com/edwardmpearce/ILF-modelling/main/figures/demo-log-plot-1.png" width="100%" />

## Plotting coefficient estimates with confidence intervals

We further compare the two modelling methods by plotting their estimated
coefficients with confidence intervals against the parameters we used to
generate the data.

First we calculate the confidence intervals around the estimated
coefficients.

    # Package coefficient estimates from a list of models into a dataframe format suitable for ggplot
    log_alpha_estimates <- summarize_estimates(list(m_log_lm, m_gamma_glm), c("log-trans lm", "gamma glm"), 1)
    beta_estimates <- summarize_estimates(list(m_log_lm, m_gamma_glm), c("log-trans lm", "gamma glm"), 2)

    # Apply transformations to the numeric fields (all but the first column) to obtain estimates for alpha and the ILF
    alpha_estimates <- data.frame(log_alpha_estimates)
    alpha_estimates[-1] <- exp(log_alpha_estimates[-1])

    ilf_estimates <- data.frame(beta_estimates)
    ilf_estimates[-1] <- exponent_to_ilf(beta_estimates[-1])

### Intercept estimate plots

Plot the estimated values and confidence intervals for the log intercept
log (*α*) and exponentiate to obtain estimates for *α*.

    log_alpha_est_plot <- plot_estimates(estimates_df = log_alpha_estimates, 
                                    title = "Estimates of log(a)", 
                                    true_value = log(a))
    alpha_est_plot <- plot_estimates(estimates_df = alpha_estimates, 
                                   title = "Estimates of a", 
                                   true_value = a)
    grid.arrange(log_alpha_est_plot, alpha_est_plot, nrow = 1)

<img src="https://raw.githubusercontent.com/edwardmpearce/ILF-modelling/main/figures/demo-intercept-estimate-plots-1.png" width="100%" />

### Exponent estimate plots

Plot the estimated values and confidence intervals for the power law
exponent *β* and transform this into estimates for the increased limit
factor *γ* using the relation *γ* = 2<sup>*β*</sup> − 1.

    beta_est_plot <- plot_estimates(estimates_df = beta_estimates, 
                                    title = "Estimates of b", 
                                    true_value = b)
    ilf_est_plot <- plot_estimates(estimates_df = ilf_estimates, 
                                   title = "Estimates of ILF %", 
                                   true_value = exponent_to_ilf(b))
    grid.arrange(beta_est_plot, ilf_est_plot, nrow = 1)

<img src="https://raw.githubusercontent.com/edwardmpearce/ILF-modelling/main/figures/demo-exponent-estimate-plots-1.png" width="100%" />

## Conclusion

When estimating the exponent of a supposed power law relation, using
linear regression on the log-transformed data is a simple and easily
interpreted method but may lead to a biased estimate due to the
underlying modelling assumptions.

Adopting a generalized linear model framework allows greater flexibility
around modelling assumptions without sacrificing interpretability and is
also fairly straightforward to implement and analyse in R.

Furthermore, using [maximum likelihood
estimation](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation)
for model fitting provides better guarantees around consistency and
efficiency of estimates (bounded and decreasing bias as sample size
increases), as well as functional equivariance, which is relevant when
transforming between maximum likelihood estimators of log (*α*) and *α*
and between *β* and ILF *γ*.

## Future directions

In order to further compare the robustness of these different modelling
methods, and examine the consistency and efficiency properties of
maximum likelihood estimation, we might like to adopt the machine
learning paradigm of splitting a dataset into training and test sets to
better understand generalizability to out-of-sample data.

In the case of this regression problem, an appropriate metric to use
will be the mean squared error. It is the separating off of the test set
that penalizes models which overfit to the training data.

## References

-   [Power Law](https://en.wikipedia.org/wiki/Power_law)
    -   [Power law: Estimating the exponent from empirical
        data](https://en.wikipedia.org/wiki/Power_law#Estimating_the_exponent_from_empirical_data)
    -   [Power-law Distributions in Empirical
        Data](https://aaronclauset.github.io/powerlaws/)
    -   [arXiv - Parameter estimation for power-law distributions by
        maximum likelihood methods](https://arxiv.org/abs/0704.1867)
    -   [arXiv - Power-law distributions in empirical
        data](https://arxiv.org/abs/0706.1062)
-   [Gamma
    Distribution](http://en.wikipedia.org/wiki/Gamma_distribution) and
    [Generalized Linear
    Models](https://en.wikipedia.org/wiki/Generalized_linear_model)
    -   [Wikipedia - Maximum Likelihood
        Estimation](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation)
    -   [Modeling skewed continuous outcome using Gamma family in
        glm()](https://rpubs.com/kaz_yos/glm-Gamma)
    -   [Fitting Gamma GLMs Multiple Ways - Understanding GLMs through
        simulation](https://seananderson.ca/2014/04/08/gamma-glms/)
    -   [Lecture on Gamma
        Regression](https://www.groups.ma.tum.de/fileadmin/w00ccg/statistics/czado/lec8.pdf)
    -   [StackExchange - Using R for GLM with Gamma
        distribution](https://stats.stackexchange.com/questions/58497/using-r-for-glm-with-gamma-distribution)
    -   [StackExchange - Log-linked Gamma GLM vs log-transformed
        LM](https://stats.stackexchange.com/questions/77579/log-linked-gamma-glm-vs-log-linked-gaussian-glm-vs-log-transformed-lm)
-   Tools
    -   [R Markdown Cheat
        Sheet](https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf)
    -   [Knitr Documentation](https://yihui.org/knitr/)
    -   [Laying out multiple plots on a page with the gridExtra package
        in
        R](https://cran.r-project.org/web/packages/egg/vignettes/Ecosystem.html)
    -   [Rotating axis labels in base
        R](https://www.tenderisthebyte.com/blog/2019/04/25/rotating-axis-labels-in-r/)
