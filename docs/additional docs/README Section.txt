1) **BUSINESS UNDERSTANDING

An Enterprise Sales Intelligence & Forecasting Platform for a fictional retail company (ABC Retail Corporation) using historical sales data. The platform will leverage Machine Learning to predict future sales, identify the key factors influencing sales performance, support management in making proactive business decisions, and provide interactive dashboards for business users.


2) **DATABASE DESIGN

Tables 
1) Customer -> Customer ID (Primary Key), Customer Name, Age, gender, city, Phone no, Membership, join date

2) Product -> Product ID (Primary Key), Product Name, Category, unit price

3) Sales Transaction --> Transaction ID (PK), Customer ID (FK), Store ID(FK), Product ID (FK), Transaction Date, Quanity, Unit Price, Discount (0 if no discount provided), Payment Mode (Online, Card, Cash), Final Price

4) Store --> Store ID (PK), Store Name, City, State, Country (IN in our case but still), store type


**** Relationships ****
Customer 1-->M Sales Transaction, Store 1-->M Sales Transaction, Product 1-->M Sales TRansaction


3) ** SYNTHETIC DATA GENERATION PLANNING
Customers → 7000 customer base that's it (Mid Size level)
Products → 500 products across 5 categories (grocery, electronics, sports, clothing, beauty)
Stores → Mumbai, Delhi, Chennai, Kolkata, Pune, Bangalore, Hyderabad (7 Stores)
Sales Transactions → 700000 entries from 7 stores so

Customer --> Customer ID (C00001, C00002, C00003,.....), Age (18-70), Membership (Platinum, Gold, Silver, Regular, Non Member(for those who dont have any membership but still are customers), City (Same as Stores city), join date (not older than 5 yrs coz assume all stores are opened in last 5 yrs and now ABC Retail has to scale & grow their business from past 5 yrs data whatever they have it available), 

Product --> Product ID (P0001, P00002,....), Product Name (All goods according to category, beauty will have more variety), Category (Grocery, Electronics, sports, clothing, beauty), Unit price (Electronics will be the costliest, followed by Sports, Beauty, Clothing & Grocery would be cheapest for unit price)

Sales Transaction --> Transaction ID (T0000000001, T0000000002, .....), Transaction Date (Not older than 5 yrs), Quanity (For Electronics it will be 1 or 2 like that but for groceries it can be in bulk), unit price (same as product logic), payment mode (UPI, Cash, Credit Card, Debit Card), Final Price = Calculated (Unit Price*Quantity), Discount (0-40%)

Stores --> Store ID (S01,...S07), store type (Express, Supermarket), City as mentioned 7 cities, State but obvious, Store Name (Confused pls help)


Lets keep it as 5% will be gold, 15% will be silver, 40% regular, 45% Non Member so one of the business logic or scope of the project (optional) can also be what else can be done to make those non member turn to regular & those regular turn to silver (Strategy/pLanning/Service/Variety/Diff Brand products availability) --> Customer Attrition & not predict future sales


4) ** SQL DEVELOPMENT & BUSINESS QUERIES

