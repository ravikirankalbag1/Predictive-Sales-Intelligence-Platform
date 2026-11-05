#### Importing Libraries
import pandas as pd
import random
import numpy as np
from tqdm import tqdm


#### Importing Datasets
customers_df = pd.read_csv("../data/raw/customers.csv")
products_df = pd.read_csv("../data/raw/products.csv")
store_df = pd.read_csv("../data/raw/store.csv")
dates_df = pd.read_csv("../data/raw/Dates.csv")


#### Printing Dimension 
print(customers_df.shape)
print(products_df.shape)
print(store_df.shape)
print(dates_df.shape)


#### Initializing Seeding
random.seed(42)


#### Forming a pool of IDS
customer_ids = customers_df["customer_id"].tolist()

product_ids = products_df["product_id"].tolist()

store_ids = store_df["store_id"].tolist()

date_ids = dates_df["date_id"].tolist()


#### Initializing payment modes
payment_modes = ["UPI", "Debit Card", "Credit Card", "Cash"]


#### Creating a dictionary of product ID, Category & Unit Price to use
product_category_map = dict(
    zip(products_df["product_id"], products_df["category"])
)

product_price_map = dict(
    zip(products_df["product_id"], products_df["unit_price"])
)


### Logic for Generating 700000 Data Records
### Corrected it & added order_id into it
sales_data = []
transaction_counter = 1
order_counter = 1
current_order_end = 0
for sales_counter in range(1, 700001):
    transaction_id = f"T{sales_counter:09d}"

    if transaction_counter > current_order_end:
                order_id = f"O{order_counter:09d}"
                order_size = random.choices([1, 2, 3, 4], weights=[45, 35, 15, 5])[0]
                current_order_end = min(
                    transaction_counter + order_size - 1,
                    700000
                )
        
                # These attributes remain fixed for the complete order.
                order_customer_id = random.choice(customer_ids)
                order_store_id = random.choice(store_ids)
                order_date_id = random.choice(date_ids)
                order_payment_mode = random.choices(
                    ["UPI", "Debit Card", "Credit Card", "Cash"],
                    weights=[24, 28, 38, 10]
                )[0]
        
                order_counter += 1

    product_id = random.choice(product_ids)
    customer_id = order_customer_id
    store_id = order_store_id
    date_id = order_date_id
    payment_mode = order_payment_mode


    category = product_category_map[product_id]
    if category == "Grocery":
        quantity = random.randint(1,10)
    elif category == "Beauty":
        quantity = random.randint(1,5)
    elif category == "Clothing":
        quantity = random.randint(1,4)
    elif category == "Sports":
        quantity = random.randint(1,3)
    else:
        quantity = random.randint(1,2)

    unit_price = product_price_map[product_id]

    if category == "Grocery":
        discount = random.randint(0,10)
    elif category == "Beauty":
        discount = random.randint(5,15)
    elif category == "Clothing":
        discount = random.randint(10,30)
    elif category == "Sports":
        discount = random.randint(5,20)
    else:
        discount = random.randint(0,15)

    gross_price = unit_price * quantity
    discount_amount = round(gross_price* (discount/100),2)
    final_price = round(gross_price - discount_amount,2)

    sales_data.append({
        "transaction_id": transaction_id,
        "order_id": order_id,
        "date_id": date_id,
        "quantity": quantity,
        "unit_price": unit_price,
        "discount": discount,
        "payment_mode": payment_mode,
        "final_price": final_price,
        "customer_id": customer_id,
        "store_id": store_id,
        "product_id": product_id
    })
    transaction_counter +=1

### Storing in a DataFrame
sales_df = pd.DataFrame(sales_data)


#### Storing generated sales data into CSV
sales_df.to_csv("../data/raw/sales_transaction.csv", index=False)
