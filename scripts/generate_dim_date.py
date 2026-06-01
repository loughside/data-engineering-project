
import pandas as pd

dates = pd.date_range(start='2024-08-01', end='2025-05-31', freq='D')

df = pd.DataFrame({
    'date': dates.strftime('%Y-%m-%d'),
    'date_uk': dates.strftime('%d/%m/%Y'),
    'day_of_month': dates.day,
    'day_name': dates.strftime('%A'),
    'month_number': dates.month,
    'month_name': dates.strftime('%B'),
    'year': dates.year,
    'end_of_month': dates + pd.offsets.MonthEnd(0),
    'is_weekend': dates.dayofweek.isin([5, 6]).astype(int)
})

df['end_of_month'] = df['end_of_month'].dt.strftime('%Y-%m-%d')

df.to_csv('transform/seeds/dim_date.csv', index=False)
print(f"Generated {len(df)} rows")

