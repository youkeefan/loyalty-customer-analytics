
import csv
import random
from datetime import date, timedelta
from pathlib import Path

# Reproducible simulated data
random.seed(42)

OUTPUT_DIR = Path("data/raw")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

START_DATE = date(2025, 1, 1)
END_DATE = date(2026, 10, 31)


def random_date():
    days = (END_DATE - START_DATE).days
    return START_DATE + timedelta(days=random.randint(0, days))


# --------------------------------------------------
# 1. Generate Customers
# --------------------------------------------------

customers = []

tiers = ["Bronze", "Silver", "Gold", "Platinum"]

for i in range(1, 5001):
    customers.append({
        "customer_id": f"C{i:05d}",
        "signup_date": random_date().isoformat(),
        "loyalty_tier": random.choices(
            tiers, weights=[50, 25, 15, 10]
        )[0],
        "customer_status": random.choices(
            ["Active", "Inactive"], weights=[85, 15]
        )[0]
    })

with open(OUTPUT_DIR / "customers.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=customers[0].keys())
    writer.writeheader()
    writer.writerows(customers)


# --------------------------------------------------
# 2. Generate Transactions
# --------------------------------------------------

transactions = []

for i in range(1, 50001):
    customer = random.choice(customers)
    spend = round(random.uniform(20, 1000), 2)

    transactions.append({
        "transaction_id": f"T{i:06d}",
        "customer_id": customer["customer_id"],
        "transaction_date": random_date().isoformat(),
        "spend": spend,
        "points_earned": int(spend)
    })

with open(OUTPUT_DIR / "transactions.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=transactions[0].keys())
    writer.writeheader()
    writer.writerows(transactions)


# --------------------------------------------------
# 3. Generate Points Ledger
# --------------------------------------------------

ledger = []
ledger_id = 1

# Points earned: one entry per transaction
for transaction in transactions:
    ledger.append({
        "ledger_id": f"L{ledger_id:07d}",
        "customer_id": transaction["customer_id"],
        "transaction_id": transaction["transaction_id"],
        "activity_date": transaction["transaction_date"],
        "activity_type": "EARN",
        "points_change": transaction["points_earned"]
    })
    ledger_id += 1


# Points redeemed: one entry per transaction
for transaction in transactions:
    ledger.append({
        "ledger_id": f"L{ledger_id:07d}",
        "customer_id": transaction["customer_id"],
        "transaction_id": "",
        "activity_date": random_date().isoformat(),
        "activity_type": "REDEEM",
        "points_change": -random.randint(10, 100)
    })
    ledger_id += 1

with open(OUTPUT_DIR / "points_ledger.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=ledger[0].keys())
    writer.writeheader()
    writer.writerows(ledger)


# --------------------------------------------------
# 4. Print Results
# --------------------------------------------------

print("Data generation completed successfully!")

for filename in [
    "customers.csv",
    "transactions.csv",
    "points_ledger.csv"
]:
    path = OUTPUT_DIR / filename
    with open(path, newline="") as f:
        row_count = sum(1 for _ in f) - 1

    print(f"{filename}: {row_count:,} records")

print(f"\nTotal records: {len(customers) + len(transactions) + len(ledger):,}")

# --------------------------------------------------
# 5. Basic Data Validation
# --------------------------------------------------

print("\n--- Data Validation ---")

assert len(customers) == 5000
assert len(transactions) == 50000
assert len(ledger) == 100000

customer_ids = {c["customer_id"] for c in customers}

assert all(
    t["customer_id"] in customer_ids
    for t in transactions
)

assert all(
    p["customer_id"] in customer_ids
    for p in ledger
)

print("Customer ID validation: PASSED")
print("Record count validation: PASSED")
print("All basic checks passed!")