#### Importing Libraries
import pandas as pd
import random

#### Defining Categories
grocery_products = [
    "Rice", "Wheat Flour", "Sugar", "Salt", "Cooking Oil",
    "Tea", "Coffee", "Milk", "Butter", "Cheese",
    "Bread", "Biscuits", "Noodles", "Pasta", "Honey",
    "Jam", "Ketchup", "Toor Dal", "Moong Dal", "Chana Dal",
    "Turmeric Powder", "Red Chilli Powder", "Coriander Powder", "Cumin Seeds", "Black Pepper",
    "Poha", "Oats", "Corn Flakes", "Detergent", "Toothpaste"
]

beauty_products = [
    "Shampoo", "Conditioner", "Hair Oil", "Face Wash", "Moisturizer",
    "Body Lotion", "Soap", "Hand Wash", "Toothbrush", "Mouthwash",
    "Face Cream", "Sunscreen", "Lip Balm", "Lipstick", "Compact Powder",
    "Foundation", "Eyeliner", "Mascara", "Nail Polish", "Perfume",
    "Deodorant", "Body Wash", "Face Serum", "Beard Oil", "Shaving Cream"
]

clothing_products = [
    "Men T-Shirt", "Women T-Shirt", "Men Jeans", "Women Jeans", "Formal Shirt",
    "Casual Shirt", "Kurti", "Leggings", "Track Pants", "Shorts",
    "Jacket", "Sweatshirt", "Hoodie", "Saree", "Dress",
    "Skirt", "Blazer", "Socks", "Cap", "Innerwear"
]

sports_products = [
    "Cricket Bat", "Cricket Ball", "Football", "Basketball", "Volleyball",
    "Badminton Racket", "Shuttlecock", "Tennis Racket", "Yoga Mat", "Dumbbells",
    "Skipping Rope", "Sports Shoes", "Gym Gloves", "Helmet", "Cycling Bottle",
    "Swimming Goggles", "Table Tennis Bat", "Resistance Band", "Foam Roller", "Sports Bag"
]

electronics_products = [
    "Smartphone", "Laptop", "Tablet", "Smartwatch", "Headphones",
    "Bluetooth Speaker", "Television", "Refrigerator", "Washing Machine", "Microwave Oven",
    "Air Conditioner", "Mixer Grinder", "Electric Kettle", "Vacuum Cleaner", "Printer",
    "Power Bank", "Wireless Mouse", "Keyboard", "Monitor", "Router"
]

#### Defining Variant Sizes
grocery_variant = ["Premium", "Standard", "Organic", "Economy"]

beauty_variant = ["Standard", "Premium", "Luxury"]

clothing_brands = ["Adidas", "Pepe Jeans", "Roadster", "U.S. Polo Assn.", "Tommy Hilfiger"]

sports_variant = ["Standard", "Professional", "Training"]

electronics_variant = ["Basic", "Standard", "Premium"]


#### Defining Pack Sizes
grocery_pack_size = ["500g", "1kg", "2kg", "5kg", "10kg"]
beauty_pack_size = ["100ml", "200ml", "300ml", "500ml"]
clothing_size = ["Small", "Medium", "Large", "XL", "2XL"]
sports_size = ["Small", "Medium", "Large"]
electronics_storage = ["64GB", "128GB", "256GB", "512GB"]


### Deciding Unit Prices
grocery_base_price = {"Rice": 80, "Wheat Flour": 55, "Sugar": 45, "Salt": 20, "Cooking Oil": 180, "Tea": 450, "Coffee": 600, "Milk": 65, "Butter": 550, "Cheese": 500, "Bread": 50, 
              "Biscuits": 120, "Noodles": 150, "Pasta": 180, "Honey": 450, "Jam": 220, "Ketchup": 180, "Toor Dal": 180, "Moong Dal": 160, "Chana Dal": 110, "Turmeric Powder": 250, 
              "Red Chilli Powder": 320, "Coriander Powder": 180, "Cumin Seeds": 450, "Black Pepper": 800, "Poha": 90, "Oats": 180, "Corn Flakes": 250, "Detergent": 220,
              "Toothpaste": 300}

grocery_pack_multiplier = {"500g": 0.55, "1kg": 1.00, "2kg": 1.95, "5kg": 4.75, "10kg": 9.3}

grocery_variant_multiplier = {"Economy": 0.9, "Standard": 1.00, "Premium": 1.20, "Organic": 1.35}


beauty_base_price = {"Shampoo": 220, "Conditioner": 240, "Hair Oil": 180, "Face Wash": 250, "Moisturizer": 350, "Body Lotion": 300, "Soap": 60, "Hand Wash": 120, "Toothbrush": 80,
                     "Mouthwash": 180, "Face Cream": 400, "Sunscreen": 450, "Lip Balm": 150, "Lipstick": 550, "Compact Powder": 450, "Foundation": 700, "Eyeliner": 300,
                     "Mascara": 450, "Nail Polish": 180, "Perfume": 1200, "Deodorant": 250, "Body Wash": 280, "Face Serum": 850, "Beard Oil": 350, "Shaving Cream": 220}

beauty_volume_multiplier = {"100ml": 1.00, "200ml": 1.95, "300ml": 2.80,"500ml": 4.80}

beauty_variant_multiplier = {"Standard": 1.00, "Premium": 1.3, "Luxury": 1.6}


clothing_base_price = {"Men T-Shirt": 800, "Women T-Shirt": 750, "Men Jeans": 1800, "Women Jeans": 1700, "Formal Shirt": 1500, "Casual Shirt": 1200, "Kurti": 1000,"Leggings": 600,
                       "Track Pants": 1200, "Shorts": 700, "Jacket": 3000, "Sweatshirt": 1800, "Hoodie": 2200, "Saree": 2500, "Dress": 2000, "Skirt": 1200, "Blazer": 3500,
                       "Socks": 250, "Cap": 500, "Innerwear": 400}

clothing_size_multiplier = {"Small": 1.00, "Medium": 1.00, "Large": 1.05, "XL": 1.10,"2XL": 1.15}

clothing_brand_multiplier = {"Roadster": 1.00, "Pepe Jeans": 1.15, "Adidas": 1.25, "U.S. Polo Assn.": 1.35, "Tommy Hilfiger": 1.50}


sports_base_price = {"Cricket Bat": 1800, "Cricket Ball": 250, "Football": 900, "Basketball": 1200, "Volleyball": 800, "Badminton Racket": 1500, "Shuttlecock": 400, 
                     "Tennis Racket": 2500, "Yoga Mat": 700, "Dumbbells": 1500, "Skipping Rope": 300, "Sports Shoes": 3500, "Gym Gloves": 600, "Helmet": 1800, 
                     "Cycling Bottle": 400, "Swimming Goggles": 900, "Table Tennis Bat": 1200, "Resistance Band": 500, "Foam Roller": 1000, "Sports Bag": 1500}

sports_size_multiplier = {"Small": 1.00,"Medium": 1.10,"Large": 1.20}

sports_variant_multiplier = {"Standard": 1.00,"Training": 1.15,"Professional": 1.35}


electronics_base_price = {"Smartphone": 18000,"Laptop": 55000,"Tablet": 25000,"Smartwatch": 12000,"Headphones": 3000,"Bluetooth Speaker": 4000,"Television": 35000,
                          "Refrigerator": 30000,"Washing Machine": 28000,"Microwave Oven": 12000,"Air Conditioner": 42000,"Mixer Grinder": 3500,"Electric Kettle": 1800,
                          "Vacuum Cleaner": 9000,"Printer": 8500,"Power Bank": 1500,"Wireless Mouse": 900,"Keyboard": 1200,"Monitor": 14000,"Router": 2500}


electronics_storage_multiplier = {"64GB": 1.00,"128GB": 1.20,"256GB": 1.45,"512GB": 1.80}

electronics_variant_multiplier = {"Basic": 1.00,"Standard": 1.20,"Premium": 1.50}


### Defining Cost Price Ranges (Limitation 1 Addressed)
# cost_price is generated as a percentage of unit_price.
# Different categories have different typical gross-margin structures.
cost_price_margin_range = {
    "Grocery": (0.75, 0.90),
    "Beauty": (0.55, 0.75),
    "Clothing": (0.45, 0.70),
    "Sports": (0.55, 0.75),
    "Electronics": (0.70, 0.90)
}



### Defining Data Records
product_data = []
product_counter = 1

#### Grocery
for product in grocery_products:
    for variant in grocery_variant:
        for pack_size in grocery_pack_size:
            product_id = f"P{product_counter:04d}"
            product_name = f"{variant} {product} {pack_size}"

            unit_price = grocery_base_price[product] * grocery_pack_multiplier[pack_size] * grocery_variant_multiplier[variant]
            unit_price = round(unit_price, 2)
            cost_ratio = random.uniform(*cost_price_margin_range["Grocery"])
            cost_price = round(unit_price * cost_ratio, 2)

            product_data.append({
                "product_id": product_id,
                "product_name": product_name,
                "category": "Grocery",
                "unit_price": unit_price,
                "cost_price": cost_price
            })

            product_counter +=1


#### Beauty
for product in beauty_products:
    for variant in beauty_variant:
        for pack_size in beauty_pack_size:
            product_id = f"P{product_counter:04d}"
            product_name = f"{variant} {product} {pack_size}"
            unit_price = (beauty_base_price[product] * beauty_volume_multiplier[pack_size] * beauty_variant_multiplier[variant])

            unit_price = round(unit_price,2)
            cost_ratio = random.uniform(*cost_price_margin_range["Beauty"])
            cost_price = round(unit_price * cost_ratio, 2)

            product_data.append({
                "product_id": product_id,
                "product_name": product_name,
                "category": "Beauty",
                "unit_price": unit_price,
                "cost_price": cost_price
            })

            product_counter +=1


#### Clothing
for product in clothing_products:
    for brand in clothing_brands:
        for size in clothing_size:
            product_id = f"P{product_counter:04d}"
            product_name = f"{brand} {product} {size}"
            unit_price = (clothing_base_price[product]* clothing_brand_multiplier[brand]* clothing_size_multiplier[size])

            unit_price = round(unit_price,2)
            cost_ratio = random.uniform(*cost_price_margin_range["Clothing"])
            cost_price = round(unit_price * cost_ratio, 2)

            product_data.append({
                "product_id": product_id,
                "product_name": product_name,
                "category": "Clothing",
                "unit_price": unit_price,
                "cost_price": cost_price
            })

            product_counter +=1


#### Sports
for product in sports_products:
    for variant in sports_variant:
        for size in sports_size:
            product_id = f"P{product_counter:04d}"
            product_name = f"{variant} {product} {size}"
            unit_price = (sports_base_price[product] * sports_variant_multiplier[variant] * sports_size_multiplier[size])

            unit_price = round(unit_price,2)
            cost_ratio = random.uniform(*cost_price_margin_range["Sports"])
            cost_price = round(unit_price * cost_ratio, 2)

            product_data.append({
                "product_id": product_id,
                "product_name": product_name,
                "category": "Sports",
                "unit_price": unit_price,
                "cost_price": cost_price
            })

            product_counter +=1


#### Electronics
for product in electronics_products:
    for variant in electronics_variant:
        for storage in electronics_storage:
            product_id = f"P{product_counter:04d}"
            product_name = f"{product} {variant} {storage}"
            unit_price = (electronics_base_price[product] * electronics_storage_multiplier[storage] * electronics_variant_multiplier[variant])

            unit_price = round(unit_price,2)
            cost_ratio = random.uniform(*cost_price_margin_range["Electronics"])
            cost_price = round(unit_price * cost_ratio, 2)

            product_data.append({
                "product_id": product_id,
                "product_name": product_name,
                "category": "Electronics",
                "unit_price": unit_price,
                "cost_price": cost_price
            })

            product_counter +=1


product_df = pd.DataFrame(product_data)
product_df.to_csv("../data/raw/products.csv", index=False)
