import os
import pandas as pd
import matplotlib.pyplot as plt

# Step 1: Ensure visualizations directory exists
os.makedirs('visualizations', exist_ok=True)

# Step 2: Load raw CSV data directly
orders = pd.read_csv('data/orders.csv')
customers = pd.read_csv('data/customers.csv')
products = pd.read_csv('data/products.csv')

# Step 3: Clean and preprocess data (matching Part 2 pipeline)
orders['payment_method'] = orders['payment_method'].astype(str).str.strip().str.upper()

dedup_cols = ['customer_id', 'product_id', 'order_date', 'quantity', 'discount_pct', 'payment_method', 'rating', 'returned']
orders_clean = orders.drop_duplicates(subset=dedup_cols, keep='first').copy()

# Merge tables and calculate order_value
df = orders_clean.merge(products, on='product_id').merge(customers, on='customer_id')
df['discount_pct'] = df['discount_pct'].fillna(0)
df['order_value'] = df['quantity'] * df['price'] * (1 - df['discount_pct'] / 100)

# Flag quantity outliers (Task 6 IQR logic)
Q1 = df['quantity'].quantile(0.25)
Q3 = df['quantity'].quantile(0.75)
IQR = Q3 - Q1
df['is_outlier'] = df['quantity'] > (Q3 + 1.5 * IQR)

# -------------------------------------------------------------
# Chart 1: return_rate_by_payment.png
# -------------------------------------------------------------
plt.figure(figsize=(8, 5))
pm_returns = (df.groupby('payment_method')['returned'].mean() * 100).sort_values(ascending=False)
bars = plt.bar(pm_returns.index, pm_returns.values, color=['#e74c3c', '#3498db', '#2ecc71'])

# Add percentage labels on top of each bar
for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width() / 2, yval + 1, f"{yval:.1f}%", ha='center', va='bottom', fontweight='bold')

plt.title("COD Returns at 44.4% — 3x Card")
plt.xlabel("Payment Method")
plt.ylabel("Return Rate (%)")
plt.ylim(0, 55)
plt.tight_layout()
plt.savefig('visualizations/return_rate_by_payment.png')
plt.close()

# -------------------------------------------------------------
# Chart 2: monthly_revenue_trend.png (Outlier-Corrected)
# -------------------------------------------------------------
df['order_date'] = pd.to_datetime(df['order_date'])
df['year_month'] = df['order_date'].dt.to_period('M').astype(str)

# Filter out the 2 outlier orders from Task 6
monthly_clean = df[~df['is_outlier']].groupby('year_month')['order_value'].sum()

plt.figure(figsize=(10, 5))
plt.plot(monthly_clean.index, monthly_clean.values, marker='o', color='#2b5c8f', linewidth=2, markersize=6)

plt.title("Outlier-Corrected Monthly Revenue Trend — March is Peak Month")
plt.xlabel("Month")
plt.ylabel("Revenue (₹)")
plt.grid(True, linestyle='--', alpha=0.6)
plt.tight_layout()
plt.savefig('visualizations/monthly_revenue_trend.png')
plt.close()

print("Task 11 Complete: Both visualizations successfully saved to visualizations/ folder!")
