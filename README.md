# 🛍️ Retail Data Analytics Pipeline with Snowflake & Tableau

This project demonstrates an end-to-end retail data analytics pipeline using **Python**, **Snowflake**, and **Tableau**. It involves generating synthetic retail data, building a normalized Snowflake schema, running advanced SQL analytics, and visualizing insights in Tableau.

---

## 📊 Project Overview

- **Data Generation**: Created synthetic retail data using Python, simulating realistic business scenarios
- **Schema Design**: Modeled and implemented a normalized Snowflake schema with 6 interrelated tables for efficient querying and storage
- **Data Ingestion**: Imported generated data into Snowflake using SnowSQL
- **Analytics**: Executed 25+ ad hoc SQL queries leveraging:
  - Complex joins
  - Window functions
  - Common Table Expressions (CTEs)
- **Visualization**: Integrated Snowflake with Tableau to build interactive dashboards showcasing business metrics and insights
---

## 🧾 Synthetic Data Tables

1. `Customers`
2. `Products`
3. `Stores`
4. `Date`
5. `Loyalty_programme`
6. `FactOrders`

Each table is linked via foreign keys to reflect real-world retail data relationships.

---

## 📂 Project Structure
![ERD Diagram](https://github.com/user-attachments/assets/b5539a7b-159f-4506-8e0a-5a569acba1ee)

---
🛠️ **Tech Stack**

Python: Synthetic data generation (Pandas, Faker, NumPy)

Snowflake: Cloud data warehousing, SQL analytics

SnowSQL: CLI-based data loading into Snowflake

Tableau: Data visualization and dashboarding

---

