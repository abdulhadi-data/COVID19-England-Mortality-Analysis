
# DS7006 – Quantitative Data Analysis
# COVID-19  ) Project
# Dataset: Final_Covid_Normalized.csv
#===========================================================

#-----Section 01-------------------------------------------
# Set working directory and import data
setwd(dirname(file.choose()))
getwd()

Covid.LA <- read.csv("Final_Covid_Normalized.csv", stringsAsFactors = FALSE)
head(Covid.LA)
str(Covid.LA)

# Verify expected number of local authorities (post-join)
nrow(Covid.LA)

#-----Section 02-------------------------------------------
# Data quality checks and basic cleaning

# Missing values per column
apply(Covid.LA, MARGIN = 2, FUN = function(x) sum(is.na(x)))

# Duplicate rows
sum(duplicated(Covid.LA))

# Remove redundant composite variable if present (avoids duplicated information)
if("dep3plus_per_1000_households" %in% names(Covid.LA)){
  myvars <- names(Covid.LA) %in% c("dep3plus_per_1000_households")
  Covid.LA <- Covid.LA[!myvars]
  rm(myvars)
}
"dep3plus_per_1000_households" %in% names(Covid.LA)
ncol(Covid.LA)
names(Covid.LA)

# Dependent variable
DV <- "deaths_per_1000"
summary(Covid.LA[[DV]])

#-----Section 03-------------------------------------------
# Exploratory Data Analysis (EDA): distributional checks for key variables

key.vars <- c("deaths_per_1000",
              "age_75plus_per_1000",
              "bad_or_very_bad_health_per_1000",
              "dep2_per_1000_households",
              "shared_dwellings_per_1000")

key.vars <- key.vars[key.vars %in% names(Covid.LA)]
key.vars

for(v in key.vars){
  x <- Covid.LA[[v]]
  x <- x[is.finite(x)]
  if(length(unique(x)) <= 2) next
  if(length(x) < 5) next
  if(sd(x) == 0) next
  
  hist(x, main = paste("Histogram + Density:", v),
       xlab = v, probability = TRUE)
  lines(density(sort(x)))
  rug(x)
  
  boxplot(x, main = paste("Boxplot:", v), ylab = v)
  
  qqnorm(x, xlab = paste("Theoretical Quantiles:", v))
  qqline(x, col = 2)
}

# Normality tests summary table (K-S and Shapiro-Wilk)
normal.tbl <- data.frame(variable = character(),
                         n = integer(),
                         ks_p = numeric(),
                         shapiro_p = numeric(),
                         stringsAsFactors = FALSE)

for(v in key.vars){
  x <- Covid.LA[[v]]
  x <- x[is.finite(x)]
  if(length(unique(x)) <= 2) next
  if(length(x) < 3) next
  if(sd(x) == 0) next
  
  ks.p <- tryCatch(ks.test(x, "pnorm", mean(x), sd(x))$p.value,
                   error = function(e) NA)
  sh.p <- tryCatch(shapiro.test(x)$p.value,
                   error = function(e) NA)
  
  normal.tbl <- rbind(normal.tbl,
                      data.frame(variable = v, n = length(x),
                                 ks_p = ks.p, shapiro_p = sh.p))
}
normal.tbl

#-----Section 04-------------------------------------------
# Bivariate analysis: correlation, scatterplot, and simple linear regression

if(all(c("dep2_per_1000_households", DV) %in% names(Covid.LA))){
  
  cor.test(Covid.LA$dep2_per_1000_households, Covid.LA[[DV]], method = "spearman")
  
  plot(Covid.LA$dep2_per_1000_households, Covid.LA[[DV]],
       main = "Scatterplot: deaths_per_1000 vs dep2_per_1000_households",
       xlab = "dep2_per_1000_households", ylab = DV)
  
  model1 <- lm(Covid.LA[[DV]] ~ Covid.LA$dep2_per_1000_households)
  abline(model1, col = "red")
  summary(model1)
  
  hist(model1$residuals, main = "Histogram: model1 residuals", xlab = "residuals")
  rug(model1$residuals)
  plot(model1$residuals ~ model1$fitted.values,
       xlab = "fitted values", ylab = "residuals",
       main = "Residuals vs fitted (model1)")
  ks.test(model1$residuals, "pnorm", mean(model1$residuals), sd(model1$residuals))
}

if(all(c("bad_or_very_bad_health_per_1000", DV) %in% names(Covid.LA))){
  cor.test(Covid.LA$bad_or_very_bad_health_per_1000, Covid.LA[[DV]], method = "spearman")
}
if(all(c("age_75plus_per_1000", DV) %in% names(Covid.LA))){
  cor.test(Covid.LA$age_75plus_per_1000, Covid.LA[[DV]], method = "spearman")
}
if(all(c("shared_dwellings_per_1000", DV) %in% names(Covid.LA))){
  cor.test(Covid.LA$shared_dwellings_per_1000, Covid.LA[[DV]], method = "spearman")
}

#-----Section 05-------------------------------------------
# Correlation matrix and visualisation (Spearman)

id.list <- c("LA_code", "LA_name")
myvars <- names(Covid.LA) %in% id.list
Covid.num <- Covid.LA[!myvars]
rm(myvars)

Covid.num <- Covid.num[, sapply(Covid.num, is.numeric)]

cor.matrix <- cor(Covid.num, use = "pairwise.complete.obs", method = "spearman")
cor.df <- as.data.frame(round(cor.matrix, 2))

if(DV %in% colnames(cor.matrix)){
  head(sort(cor.matrix[, DV], decreasing = TRUE), 10)
  tail(sort(cor.matrix[, DV], decreasing = TRUE), 10)
}
head(sort(cor.matrix[, DV], decreasing = TRUE), 10)
tail(sort(cor.matrix[, DV], decreasing = TRUE), 10)

library(corrplot)

vars4corr <- c("deaths_per_1000",
               "age_75plus_per_1000",
               "bad_or_very_bad_health_per_1000",
               "dep2_per_1000_households",
               "shared_dwellings_per_1000",
               "dep3_per_1000_households",
               "dep4_per_1000_households")
vars4corr <- vars4corr[vars4corr %in% names(Covid.LA)]

if(length(vars4corr) >= 3){
  cor.small <- cor(Covid.LA[, vars4corr], use = "pairwise.complete.obs", method = "spearman")
  
  new.names <- c("Deaths/1000","Age75+","BadHealth","Dep2","SharedDwl","Dep3","Dep4")
  names(new.names) <- vars4corr
  colnames(cor.small) <- new.names[colnames(cor.small)]
  rownames(cor.small) <- new.names[rownames(cor.small)]
  
  par(mfrow = c(1,1))
  par(mar = c(1, 6, 2, 2))
  corrplot(cor.small, method = "circle", type = "upper", diag = FALSE,
           tl.col = "black", tl.srt = 0, tl.cex = 1.0, cl.cex = 0.9,
           mar = c(0, 0, 1, 0))
  title("Spearman correlation (selected variables)")
}

#-----Section 06-------------------------------------------
# Partial correlation analysis

library(ppcor)

controls <- c("age_75plus_per_1000",
              "bad_or_very_bad_health_per_1000",
              "dep2_per_1000_households")
controls <- controls[controls %in% names(Covid.LA)]
controls

pc.tbl <- data.frame(predictor = character(),
                     controls = character(),
                     partial_r = numeric(),
                     p_value = numeric(),
                     n = integer(),
                     stringsAsFactors = FALSE)

if(length(controls) >= 1 && DV %in% names(Covid.LA)){
  
  preds <- setdiff(names(Covid.num), c(DV, controls))
  preds <- preds[preds %in% names(Covid.LA)]
  
  for(v in preds){
    tmp <- Covid.LA[, c(DV, v, controls)]
    tmp <- tmp[complete.cases(tmp), ]
    if(nrow(tmp) < 10) next
    if(sd(tmp[[DV]]) == 0 || sd(tmp[[v]]) == 0) next
    
    pc <- tryCatch(pcor.test(tmp[[DV]], tmp[[v]], tmp[, controls, drop = FALSE]),
                   error = function(e) NULL)
    if(is.null(pc)) next
    
    pc.tbl <- rbind(pc.tbl,
                    data.frame(predictor = v,
                               controls = paste(controls, collapse = ", "),
                               partial_r = pc$estimate,
                               p_value = pc$p.value,
                               n = nrow(tmp)))
  }
  
  pc.tbl <- pc.tbl[order(pc.tbl$p_value), ]
  pc.tbl
}
pc.tbl
head(pc.tbl, 6)

#-----Section 07-------------------------------------------
# Sampling adequacy (KMO/MSA) and Principal Components Analysis (PCA)

myvars <- names(Covid.LA) %in% c("LA_code", "LA_name", DV, "total_covid_deaths")
Covid.pca <- Covid.LA[!myvars]
rm(myvars)

Covid.pca <- Covid.pca[, sapply(Covid.pca, is.numeric)]
str(Covid.pca)

# Remove reference categories from compositional variable blocks
myvars <- names(Covid.pca) %in% c("age_0_15_per_1000",
                                  "good_or_very_good_health_per_1000",
                                  "dep0_per_1000_households")
Covid.pca <- Covid.pca[!myvars]
rm(myvars)

str(Covid.pca)

library(psych)
library(nFactors)
library(GPArotation)

R <- cor(Covid.pca, use = "pairwise.complete.obs", method = "pearson")
KMO(R)

ev <- eigen(R)
ev$values

plot(ev$values, type = "b", col = "blue",
     xlab = "number of components", ylab = "eigenvalue",
     main = "Scree plot (eigenvalues)")

ev.sum <- 0
for(i in 1:length(ev$values)){
  ev.sum <- ev.sum + ev$values[i]
}
ev.list1 <- 1:length(ev$values)
for(i in 1:length(ev$values)){
  ev.list1[i] <- ev$values[i]/ev.sum
}
ev.list2 <- 1:length(ev$values)
ev.list2[1] <- ev.list1[1]
for(i in 2:length(ev$values)){
  ev.list2[i] <- ev.list2[i-1] + ev.list1[i]
}
plot(ev.list2, type = "b", col = "red",
     xlab = "number of components", ylab = "cumulative proportion",
     main = "Cumulative proportion of variance")

fit <- principal(R, nfactors = 4, rotate = "varimax", scores = FALSE)
fit

fit2 <- principal(Covid.pca, nfactors = 4, rotate = "varimax", scores = TRUE)
fit.data <- data.frame(fit2$scores)
head(fit.data)

round(cor(fit.data, method = "pearson"), 2)

#-----Section 08-------------------------------------------
# Hierarchical clustering and hypothesis test across clusters

X <- scale(Covid.pca)
d <- dist(X, method = "euclidean")
hc <- hclust(d, method = "ward.D2")

plot(hc, labels = FALSE, hang = -1,
     main = "Hierarchical clustering (Ward.D2)",
     xlab = "", ylab = "Height")

k <- 4
rect.hclust(hc, k = k, border = 2:5)

groups <- cutree(hc, k = k)
table(groups)

Covid.LA$cluster <- factor(groups)

boxplot(Covid.LA[[DV]] ~ Covid.LA$cluster,
        main = "COVID deaths per 1,000 by cluster group",
        xlab = "cluster group", ylab = DV,
        col = "grey")

kruskal.test(Covid.LA[[DV]] ~ Covid.LA$cluster)

aggregate(Covid.pca, by = list(cluster = Covid.LA$cluster), FUN = mean)

#-----Section 09-------------------------------------------
# Multiple regression modelling, tuning, and diagnostics

library(car)
library(RcmdrMisc)
library(relaimpo)

myvars <- names(Covid.LA) %in% c("LA_code", "LA_name")
Covid.reg <- Covid.LA[!myvars]
rm(myvars)

# Exclude total deaths count when the dependent variable is a rate
if("total_covid_deaths" %in% names(Covid.reg)){
  myvars <- names(Covid.reg) %in% c("total_covid_deaths")
  Covid.reg <- Covid.reg[!myvars]
  rm(myvars)
}

# Remove reference categories from compositional blocks
if("age_16_49_per_1000" %in% names(Covid.reg)){
  myvars <- names(Covid.reg) %in% c("age_16_49_per_1000")
  Covid.reg <- Covid.reg[!myvars]; rm(myvars)
}
if("good_or_very_good_health_per_1000" %in% names(Covid.reg)){
  myvars <- names(Covid.reg) %in% c("good_or_very_good_health_per_1000")
  Covid.reg <- Covid.reg[!myvars]; rm(myvars)
}
if("dep0_per_1000_households" %in% names(Covid.reg)){
  myvars <- names(Covid.reg) %in% c("dep0_per_1000_households")
  Covid.reg <- Covid.reg[!myvars]; rm(myvars)
}

Covid.reg <- Covid.reg[, sapply(Covid.reg, is.numeric)]
str(Covid.reg)

# Full model (all available predictors)
preds <- setdiff(names(Covid.reg), DV)
form.full <- as.formula(paste(DV, "~", paste(preds, collapse = " + ")))

model.full <- lm(form.full, data = Covid.reg)
summary(model.full)

vif(model.full)
sqrt(vif(model.full)) > 2

# Theoretically motivated models (reduced multicollinearity)
model.vif1 <- lm(deaths_per_1000 ~ age_75plus_per_1000 +
                   bad_or_very_bad_health_per_1000 +
                   dep2_per_1000_households +
                   shared_dwellings_per_1000,
                 data = Covid.reg)
summary(model.vif1)
vif(model.vif1)

model.vif2 <- lm(deaths_per_1000 ~ age_75plus_per_1000 +
                   bad_or_very_bad_health_per_1000 +
                   dep2_per_1000_households +
                   unshared_dwellings_per_1000,
                 data = Covid.reg)
summary(model.vif2)
vif(model.vif2)

model.vif3 <- lm(deaths_per_1000 ~ age_75plus_per_1000 +
                   bad_or_very_bad_health_per_1000 +
                   dep3_per_1000_households +
                   unshared_dwellings_per_1000,
                 data = Covid.reg)
summary(model.vif3)
vif(model.vif3)

# Final model (interpretable with low VIF)
model.finalA <- lm(deaths_per_1000 ~ age_75plus_per_1000 +
                     dep2_per_1000_households +
                     unshared_dwellings_per_1000,
                   data = Covid.reg)
summary(model.finalA)

vif(model.finalA)
sqrt(vif(model.finalA)) > 2

# Stepwise selection (confirmation)
model.final.step <- stepwise(model.finalA, direction = "forward")
summary(model.final.step)

anova(model.finalA, model.final.step, test = "F")

# Diagnostics (final model)
hist(model.finalA$residuals, main = "Histogram: final model residuals", xlab = "residuals")
rug(model.finalA$residuals)

plot(model.finalA$residuals ~ model.finalA$fitted.values,
     xlab = "fitted values", ylab = "residuals",
     main = "Residuals vs fitted (final model)")

ks.test(model.finalA$residuals, "pnorm",
        mean(model.finalA$residuals), sd(model.finalA$residuals))

# Relative importance
calc.relimp(model.finalA, type = c("lmg"), rela = TRUE)

# PCA-score regression (robustness check)
Covid.pca.reg <- cbind(Covid.reg, fit.data)

model.pca <- lm(deaths_per_1000 ~ RC1 + RC2 + RC3 + RC4, data = Covid.pca.reg)
summary(model.pca)

model.pca.step <- stepwise(model.pca, direction = "forward")
summary(model.pca.step)

anova(model.pca, model.pca.step, test = "F")

hist(model.pca.step$residuals, main = "Histogram: PCA-score model residuals", xlab = "residuals")
rug(model.pca.step$residuals)

plot(model.pca.step$residuals ~ model.pca.step$fitted.values,
     xlab = "fitted values", ylab = "residuals",
     main = "Residuals vs fitted (PCA-score model)")

ks.test(model.pca.step$residuals, "pnorm",
        mean(model.pca.step$residuals), sd(model.pca.step$residuals))


#---------------------------------------------------#
 
 