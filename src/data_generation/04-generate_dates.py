import pandas as pd
from datetime import datetime, timedelta

date_data = []

start_date = datetime(2021,1,1)
end_date = datetime(2025,12,31)

current_date = start_date

while current_date <= end_date:
    date_data.append({
        "date_id": current_date.strftime("D%Y%m%d"),
        "date": current_date.strftime("%Y-%m-%d"),
        "year": current_date.year,
        "month": current_date.strftime("%B"),
        "month_number": current_date.month,
        "quarter": f"Q{((current_date.month-1)//3)+1}",
        "week_number": current_date.isocalendar().week,
        "day": current_date.strftime("%A"),
        "day_number": current_date.weekday()+1,
        "is_weekend": current_date.weekday() >= 5
    })

    current_date += timedelta(days=1)

date_df = pd.DataFrame(date_data)

date_df.to_csv("../data/raw/Dates.csv", index=False)
