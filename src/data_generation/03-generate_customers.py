from faker import Faker
import pandas as pd
import random
from datetime import datetime, timedelta


random.seed(42)
Faker.seed(42)


fake = Faker("en_IN")


store_cities = ["Mumbai", "Pune", "Chennai", "Bangalore", "Hyderabad", "Kolkata", "Delhi"]
start_date = datetime(2021,1,1)
end_date = datetime(2025,12,31)


customer_data = []
for customer_counter in range(1, 10001):
    customer_id = f"C{customer_counter:05d}"
    gender = random.choice(["Male", "Female"])
    if gender == "Male":
        customer_name = fake.first_name_male() + " " + fake.last_name()
    else:
        customer_name = fake.first_name_female() + " " + fake.last_name()

    age_group = random.choices(["18-25", "26-40", "41-60", "61-70"],weights=[15, 47, 28, 10],k=1)[0]
    if age_group == "18-25":
        age = random.randint(18,25)
    elif age_group == "26-40":
        age = random.randint(26,40)
    elif age_group == "41-60":
        age = random.randint(41,60)
    else:
        age = random.randint(61,70)
    city = random.choice(store_cities)
    phone_number = fake.phone_number()
    membership = random.choices(["Platinum", "Gold", "Silver", "Regular", "Non Member"], weights=[5,10,20,40,25], k=1)[0]

    random_days = random.randint(0, (end_date - start_date).days)
    join_date = start_date + timedelta(days=random_days)
    join_date = join_date.strftime("%Y-%m-%d")

    customer_data.append({
        "customer_id": customer_id,
        "customer_name": customer_name,
        "age": age,
        "gender": gender,
        "city": city,
        "phone": phone_number,
        "membership": membership,
        "join_date": join_date
    })


customer_df = pd.DataFrame(customer_data)

customer_df.to_csv("../data/raw/customers.csv", index=False)
