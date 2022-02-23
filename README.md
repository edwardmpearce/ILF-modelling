# ILF Modelling

Two approaches to fit a power law to premium vs sum insured data (including using GLMs) and plot the results.

We suppose a [power law relation][Wikipedia - Power Law] between the **Sum Insured** $x$ and the **Premium** $y$ of an insurance quote. This relation takes the form $$y(x) = \alpha x^{\beta}$$ which may alternatively be expressed as a linear relationship between $\log(x)$ and $\log(y)$ of the form $$\log(y) = \log(\alpha) + \beta \log(x),$$ where $\alpha$ and $\beta$ are constants to be determined.

It follows that for any constant multiplying factor $c$ we have $y(cx) = c^{\beta} y(x)$, and in particular $y(2x) = 2^{\beta} y(x) = (1 + \gamma) y(x)$ for any sum insured $x$, where we call the constant $\gamma = 2^{\beta} - 1$ the **Increased Limit Factor**. This means that in our power law model, doubling the sum insured results in multiplying the premium by a factor of $1 + \gamma$, regardless of the reference sum insured value we doubled.

In the demonstration notebook, we randomly generate a sample of quotes (pairs of sum insured and premium values), estimate the power law parameters using both a log-transformed linear regression model and a [Gamma distributed][Wikipedia - Gamma Distribution] [Generalized Linear Model][Wikipedia - Generalized Linear Model], then plot the results for comparison. We also discuss differences between the two approaches from the viewpoint of statistical theory.

![Demo Data Plot](https://raw.githubusercontent.com/edwardmpearce/ILF-modelling/main/figures/demo-data-plot-1.png)

## References

- [Power Law][Wikipedia - Power Law]
  - [Power law: Estimating the exponent from empirical data]
  - [Power-law Distributions in Empirical Data]
  - [arXiv - Parameter estimation for power-law distributions by maximum likelihood methods]
  - [arXiv - Power-law distributions in empirical data]
- [Gamma Distribution][Wikipedia - Gamma Distribution] and [Generalized Linear Models][Wikipedia - Generalized Linear Model]
  - [Wikipedia - Maximum Likelihood Estimation]
  - [Modeling skewed continuous outcome using Gamma family in glm()]
  - [Fitting Gamma GLMs Multiple Ways - Understanding GLMs through simulation]
  - [Lecture on Gamma Regression]
  - [StackExchange - Using R for GLM with Gamma distribution]
  - [StackExchange - Log-linked Gamma GLM vs log-transformed LM]
- Tools
  - [R Markdown Cheat Sheet]
  - [Knitr Documentation]
  - [Laying out multiple plots on a page with the gridExtra package in R]
  - [Rotating axis labels in base R]

[Wikipedia - Power Law]: https://en.wikipedia.org/wiki/Power_law
[Power law: Estimating the exponent from empirical data]: https://en.wikipedia.org/wiki/Power_law#Estimating_the_exponent_from_empirical_data
[Power-law Distributions in Empirical Data]: https://aaronclauset.github.io/powerlaws/
[arXiv - Parameter estimation for power-law distributions by maximum likelihood methods]: https://arxiv.org/abs/0704.1867
[arXiv - Power-law distributions in empirical data]: https://arxiv.org/abs/0706.1062
[Wikipedia - Generalized Linear Model]: https://en.wikipedia.org/wiki/Generalized_linear_model
[Wikipedia - Gamma Distribution]: http://en.wikipedia.org/wiki/Gamma_distribution
[Wikipedia - Maximum Likelihood Estimation]: https://en.wikipedia.org/wiki/Maximum_likelihood_estimation
[Modeling skewed continuous outcome using Gamma family in glm()]: https://rpubs.com/kaz_yos/glm-Gamma
[Fitting Gamma GLMs Multiple Ways - Understanding GLMs through simulation]: https://seananderson.ca/2014/04/08/gamma-glms/
[Lecture on Gamma Regression]: https://www.groups.ma.tum.de/fileadmin/w00ccg/statistics/czado/lec8.pdf
[StackExchange - Using R for GLM with Gamma distribution]: https://stats.stackexchange.com/questions/58497/using-r-for-glm-with-gamma-distribution
[StackExchange - Log-linked Gamma GLM vs log-transformed LM]: https://stats.stackexchange.com/questions/77579/log-linked-gamma-glm-vs-log-linked-gaussian-glm-vs-log-transformed-lm
[R Markdown Cheat Sheet]: https://www.rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf
[Knitr Documentation]: https://yihui.org/knitr/
[Laying out multiple plots on a page with the gridExtra package in R]: https://cran.r-project.org/web/packages/egg/vignettes/Ecosystem.html
[Rotating axis labels in base R]: https://www.tenderisthebyte.com/blog/2019/04/25/rotating-axis-labels-in-r/
