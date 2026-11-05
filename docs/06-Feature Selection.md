# Feature Selection

Correlation analysis was first used to identify redundant predictors. Since several temporal features have high correlation but capture different time horizons, we avoided removing them solely based on correlation. For final feature selection, we chose a wrapper approach because it evaluates subsets of features based on actual model performance, allowing us to determine whether combinations of temporal, price, promotion, product, and other features improve predictive performance.

