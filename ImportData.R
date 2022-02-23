# Script to save a copy of Premium vs Sum Insured locally from Power BI

# Input load from Power BI, unique rows only from selected columns
# The path to the dataset will change each time you update/reopen Power BI
`dataset` = read.csv('C:/Users/username/REditorWrapper_SHA256_1/input_df_SHA256_2.csv', check.names = FALSE, encoding = "UTF-8", blank.lines.skip = FALSE);

# Rename data columns
colnames(dataset)[colnames(dataset) == "SumInsured_RatedQuotes"] <- "SumInsured"
colnames(dataset)[colnames(dataset) == "Premium_RatedQuotes"] <- "Premium"
colnames(dataset)[colnames(dataset) == "Quote_Converted_YN"] <- "QuoteConverted"

# Drop rows with missing values
dataset <- dataset[which(!is.na(dataset$SumInsured)), ]

# Select data columns only
dataset <- dataset[, c("SumInsured", "Premium", "QuoteConverted")]

# Write data to file locally
write.csv(dataset, file = "./data.csv", row.names = FALSE)

# Remove dataset from memory
rm(dataset)
