# ProfitLens: Retail Revenue, Product Performance & Profitability Intelligence

> **Record revenue, shrinking profit. Which products are to blame, and what should management do?**
> An end-to-end analysis of 56,046 AdventureWorks order lines using **PostgreSQL, Python (Pandas) and Power BI (DAX)**, finishing in a decision memo for the CFO.


## Dashboard Preview

![ProfitLens Dashboard](<Docs/Screenshot 2026-11-20 131234.png>)
## The headline finding

The business earned **$24.91M revenue and $10.46M gross profit (41.97% margin)** between Jan 2015 and Jun 2017. Bikes are **94.9%** of revenue, so margin problems are bike problems:

| Bike line | Revenue | Gross margin |
|---|---|---|
| Mountain | $8.58M | **45.79%** |
| Road | $11.29M | 38.70% |
| Touring | $3.77M | 37.84% |

- **Profit traps:** 9 Road SKUs (Road-150 Red, Road-250 Black/Red) bring in **$5.56M (22% of revenue)** at only 39.3% to 39.5% margin.
- **Stars:** 6 Mountain-200 SKUs bring in **$7.17M at 46.03% margin**.
- **Wider issue:** 48 bike SKUs sit below 40% margin and make up **58% of revenue**.
- **Mix drift:** Touring (37.8% margin) grew from 15% to 26% of revenue between 2016 and H1 2017.


## What I recommend (see the [CFO decision brief](ProfitLens CFO Decision Brief.docx))

1. **Reprice** the 9 Road SKUs by 5% as a 90-day pilot. Worth about **$65K/year** at the 2017 run rate (up to $278K on 2015 to 2017 volumes). Profit improves as long as unit volume falls less than about 11%.
2. **Promote and protect** Mountain-200: no discounting, supply priority, and favor Mountain over Touring in promotions.
3. **Fix or cut** Jerseys (28.4% margin) and Caps (34.0%): renegotiate supplier cost, discontinue if refused.

## Tools and skills demonstrated

| Layer | What I did |
|---|---|
| **PostgreSQL** | Star schema DDL, multi-table joins, CTEs, `DENSE_RANK()` window function, `CASE` segmentation, `COALESCE`, avoiding fact-to-fact fan-out when joining sales and returns |
| **Python** | `pd.concat` for the three yearly files, `merge` join chain, vectorized revenue/cost/profit, `groupby().agg()`, matplotlib/seaborn bubble-chart quadrant matrix |
| **Power BI** | Power Query append (Disable Load on staging queries), manual 1:\* star-schema relationships, `_Measures` table, DAX (`SUMX`, `RELATED`, `DIVIDE`), executive dashboard with country slicer and drill-down |
| **Business** | Profit-margin vs revenue segmentation, price-increase break-even logic, written recommendation for a finance audience |

## Data model

```
Customers ─┐
Products ──┼──< Fact_Sales >── Territories
           │
Products → Subcategories → Categories      Returns >── Products
```

Source: AdventureWorks sample data (Products, Subcategories, Categories, Customers, Territories, Returns, Sales 2015/2016/2017). Sales data runs **1 Jan 2015 to 30 Jun 2017**, so 2017 is a half year.

## Key DAX measures

```dax
Total Revenue = SUMX ( Fact_Sales, Fact_Sales[OrderQuantity] * RELATED ( AdventureWorks_Products[ProductPrice] ) )
Total Cost    = SUMX ( Fact_Sales, Fact_Sales[OrderQuantity] * RELATED ( AdventureWorks_Products[ProductCost] ) )
Total Profit  = [Total Revenue] - [Total Cost]
Profit Margin % = DIVIDE ( [Total Profit], [Total Revenue], 0 )
Return Rate % = DIVIDE ( SUM ( AdventureWorks_Returns[ReturnQuantity] ), [Total Units Sold], 0 )
```

## Repository structure

```
profitlens/
├── README.md
├── data/raw/                 # AdventureWorks CSV files
├── sql/
│   ├── 01_schema_ddl.sql
│   ├── 02_data_health_audit.sql
│   ├── 03_category_subcategory_margin.sql
│   ├── 04_returns_cte_analysis.sql
│   └── 05_profit_trap_detector.sql
├── notebooks/profitlens_eda.ipynb
├── powerbi/profitlens.pbix
├── images/                   # dashboard screenshots + quadrant chart
└── docs/
    ├── CFO_Decision_Brief.pdf
    └── study_guides/         # Day 1 to Day 3 notes
```

## How to reproduce

1. **SQL:** create `profitlens_db`, run `sql/01_schema_ddl.sql`, load the CSVs (use `ENCODING 'LATIN1'` for the customers file), then run the queries in order.
2. **Python:** `pip install pandas matplotlib seaborn jupyter`, open `notebooks/profitlens_eda.ipynb`, and set `DATA_DIR` to `data/raw`.
3. **Power BI:** open `powerbi/profitlens.pbix` in Power BI Desktop. If prompted, point the data source folder to `data/raw`.

## Data issues handled

- Yearly sales files stacked into one fact table (56,046 rows), reconciled across SQL, Python and Power BI.
- Quantity columns imported as text broke `SUM`; fixed by casting to whole number in Power Query.
- Income stored as text with `$` and commas: staged as `VARCHAR`, then cleaned (ELT pattern).
- Mixed date formats across yearly files; Latin-1 encoded names.

## Limitations

- Margin is **gross** (list price minus standard cost). Discounts, freight and tax are not in the data, so net operating profit may differ.
- 2017 covers six months; year comparisons use shares or annualized figures.
- The data has no price tests, so the repricing estimate is a break-even scenario, not a forecast.
- The $500K revenue and 40% margin thresholds are management-style benchmarks I chose; changing them changes which SKUs are flagged.

## About

**[Your Name]** | Data Analyst | Bengaluru, India
[LinkedIn](www.linkedin.com/in/saidivyashree-bandi) · [Email](saidivyashree.0311@gmail.com)
