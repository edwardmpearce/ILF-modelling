# Plot Premium vs Sum Insured and power law curve on log scale from csv

# To create or refresh `data.csv`, set Power BI filepath in `ImportData.R`# 
# source("./ImportData.R")

# Input load from local file
dataset <- read.csv("./data.csv");

# Import plotting library
library(ggplot2)

# Drop rows with missing values
dataset <- dataset[which(!is.na(dataset$SumInsured)), ]

# Calculate column means to find centroid point
centroid <- data.frame(t(colMeans(subset(dataset, select = -c(QuoteConverted)))))

# Let x be the limit value/sum insured on an insurance policy and P(x) be the premium.
# Suppose a power law relation P(x) = exp(beta[0]) * x^beta[1].
# Estimate the parameter vector beta by linear regression on example data
# log(P(x)) = beta[0] + beta[1] * log(x)
powerlaw <- lm(I(log(Premium)) ~ I(log(SumInsured)), data = dataset)
# summary(powerlaw)

# Extract coefficients from the fitted model
intercept <- powerlaw$coef[[1]]
exponent <- powerlaw$coef[[2]]
ILF <- 2^exponent - 1

# Produce a dataframe for plotting the power law curve
dataset$predPremium <- exp(predict(powerlaw, dataset))

# Plot the example data, the centroid point, and the fitted curve
ggplot(data = dataset[which(dataset$QuoteConverted == 'N'), ]) +
  geom_point(aes(x = SumInsured, y  = Premium), size = 2, color = "grey50", alpha = 0.4) + 
  geom_point(data = dataset[which(dataset$QuoteConverted == 'Y'), ], 
             aes(x = SumInsured, y = Premium), size = 2, color = "blue", alpha = 0.6) + 
  geom_point(data = centroid,
             aes(x = SumInsured, y = Premium),
             color = "red", size = 4) +
  geom_line(data = dataset,
            aes(x = SumInsured, y = predPremium),
            color = "red", size = 1, linetype="dashed") +
  labs(title = paste0("Premium curve P(x) = ax^b",
                      ", a = ", signif(exp(intercept), 5),
                      ", b = ", signif(exponent, 5)
                     ),
       subtitle = paste0("ILF = 2^b - 1 = ", signif(100 * ILF, 5), "%",
                        ", Avg Sum Insured = ", signif(centroid$SumInsured / 1000000, 3), "M",
                        ", Avg Premium = ", signif(centroid$Premium / 1000, 3), "K",
                        ", Currency: GBP"
                        )
  ) + 
  scale_x_continuous(name = "Sum Insured (log scale)",
                     labels = scales::dollar_format(prefix = "£"),
                     trans = "log10") + 
  scale_y_continuous(name = "Premium (log scale)",
                     labels = scales::dollar_format(prefix = "£"),
                     trans = "log10") + 
  annotation_logticks(short = unit(0.5, "cm"),
                      mid = unit(0.8, "cm"),
                      long = unit(1, "cm")) +
  theme_light() + 
  theme(text = element_text(size=24),
        panel.grid.minor = element_blank())
