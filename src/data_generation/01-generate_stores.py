import pandas as pd

store = {
    "store_id": ["S01", "S02", "S03", "S04", "S05", "S06","S07"],
    "store_name": ["ABC Mumbai Central", "ABC Delhi Central", "ABC Chennai Central", "ABC Kolkata Central", "ABC Pune Central", "ABC Bangalore Central", "ABC Hyderabad Central"],
    "city": ["Mumbai", "Delhi", "Chennai", "Kolkata", "Pune", "Bangalore", "Hyderabad"],
    "state": ["Maharashtra", "Delhi", "Tamil Nadu", "West Bengal", "Maharashtra", "Karnataka", "Telangana"],
    "country": ["India"]* 7,
    "store_type": ["Supermarket", "Supermarket", "Supermarket", "Express", "Express", "Supermarket", "Supermarket"]
}

store_df = pd.DataFrame.from_dict(store)

store_df.to_csv("../data/raw/store.csv", index=False)
