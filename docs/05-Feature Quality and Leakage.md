# Feature Quality Audit & Leakage

## Initial Product-Level Feature Engineering:

Product-level customer behaviour features were initially created at the `product_id` grain, including unique customers, repeat customers, total orders, total units, total revenue, and customer-based ratios.

## ML Dataset Audit:

During the feature quality and leakage audit, it was identified that these features were calculated using the complete 2021–2025 dataset. Therefore, they could contain information from future periods relative to a given prediction month, resulting in **time leakage**. Additionally, the original temporal grain did not align with the ML prediction grain of `Product + Year + Month`.

## Feature Re-engineering:

Since these features have strong business relevance for predicting future sales, they were not permanently discarded. They were re-engineered at the `Product + Year + Month` grain using only information available **up to the prediction point**.

## Final Decision:
 The original full-period product-level versions were dropped, while the newly created time-aware versions were retained for the final ML dataset.