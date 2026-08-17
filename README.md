# Eniac × Magist — Brazil Market Entry Analysis

**SQL-based market and commercial analysis for a premium consumer-tech expansion decision**

This project evaluates whether **Eniac**, a premium technology retailer, should use the Brazilian marketplace **Magist** as a strategic partner for entering the Brazilian e-commerce market.

The analysis combines marketplace transaction data with external market context to answer a product/business question rather than simply report SQL outputs:

> **Does Magist offer enough demand, seller economics and operational reliability to support Eniac's premium-tech positioning in Brazil?**

## Business context

Brazil offered a large and growing e-commerce opportunity, but premium electronics faced a difficult commercial environment: high import costs, heavy taxation, currency pressure and consumer sensitivity to high ticket prices.

That makes the Magist partnership decision more nuanced than asking whether Brazil has demand. Eniac also needs to know whether the marketplace attracts enough technology buyers, whether premium technology is popular, whether sellers can earn attractive revenue, and whether delivery performance is reliable enough for a premium customer experience.

## Analysis questions

The SQL work covers four decision areas:

### 1. Marketplace scale and growth
- How many orders and products are present?
- Are orders actually delivered?
- Is marketplace demand growing over time?
- How many months of trading history are available?

### 2. Technology-market fit
- Which technology categories exist on Magist?
- What share of units sold are technology products?
- Are expensive technology products popular with customers?
- How many technology sellers operate on the marketplace?

### 3. Commercial attractiveness
- What share of marketplace revenue comes from technology?
- How much does a typical technology seller earn per month?
- How does technology-seller income compare with the marketplace average?

### 4. Operations and customer experience
- How long does delivery take on average?
- What percentage of orders arrive on time?
- Do heavier orders appear more likely to be delayed?

## Key findings

| Metric | Result |
|---|---:|
| Orders | 99,441 |
| Products | 32,951 |
| Total units sold | 112,650 |
| Tech units sold | 16,935 |
| Tech share of units sold | 15.03% |
| Customers buying expensive tech | 2.24% |
| Total seller revenue | €13.59M |
| Tech seller revenue | €1.84M |
| Tech share of seller revenue | 13.51% |
| Total sellers | 3,095 |
| Tech sellers | 477 (~15%) |
| Avg. monthly income per seller | €826.28 |
| Avg. monthly income per tech seller | €792.09 |
| Avg. delivery time | 12 days |
| Delivered on time | 89.15% |
| Delayed | 7.87% |

Additional observations:

- Around **97% of orders reached delivered status**.
- Technology products have a meaningful presence on Magist, but their **revenue share (13.51%) is below their unit share (15.03%)**.
- Only **2.24% of historical customers purchased technology products in the top 15% of the tech price distribution**, which is a weak signal for a premium-heavy assortment.
- Average monthly income for technology sellers (**€792.09**) is below the marketplace-wide seller average (**€826.28**).
- Delivery performance is reasonably strong overall, although a roughly **12-day average delivery time** may still matter for a premium customer proposition.
- Product weight did not show a strong relationship with late delivery in this analysis.
- The monthly order series shows a sharp decline after September 2018; this should be treated cautiously because the dataset snapshot may be incomplete near its end.

## Recommendation

### Do not treat Magist as a low-risk full-scale launch channel for Eniac's premium portfolio.

Magist demonstrates a functioning marketplace, substantial overall order volume and acceptable delivery reliability. However, the data provides weaker evidence for **premium technology demand and seller economics**:

- expensive technology reaches only a small fraction of customers
- technology contributes a smaller share of revenue than of units sold
- average technology-seller monthly income trails the marketplace average
- Brazil's premium electronics market carries strong price and affordability constraints

A more defensible strategy would be a **controlled market-entry pilot** rather than a broad rollout:

1. test selected technology categories with stronger local demand
2. avoid relying only on ultra-premium products
3. closely monitor conversion, average selling price, delivery experience and seller economics
4. validate whether installment/payment behavior can reduce premium-price friction
5. expand only if the pilot demonstrates sustainable premium demand

## Market context

The transactional analysis is complemented by desk research supplied during the project. Around the 2018 period:

- consumer electronics represented a major share of Brazilian e-commerce activity
- domestic marketplaces and retailers were important distribution channels
- premium imported technology was unusually expensive in Brazil relative to international markets and local purchasing power
- taxation, import costs and currency conditions contributed to the price gap
- installment payments were important for expensive consumer purchases

See [`docs/market_context.md`](docs/market_context.md) for the research notes and source links used in the project discussion.

## SQL techniques demonstrated

The analysis uses:

- joins across orders, products, sellers and category tables
- grouped aggregations
- subqueries
- common table expressions (CTEs)
- conditional logic with `CASE`
- date extraction and time-difference calculations
- percentage-of-total calculations
- window functions using `CUME_DIST()` for relative price segmentation

## Repository structure

```text
Eniac-Magist-market-analysis/
├── README.md
├── sql/
│   └── eniac_magist_analysis.sql
├── docs/
│   └── market_context.md
└── .gitignore
```

## Presentation

Project presentation:

https://docs.google.com/presentation/d/1_Vn-_oc_z6lOa_J28q7Lp6q49oJWDVAbvMtmGV1R7ak/edit

## Limitations

- The marketplace dataset covers a historical snapshot rather than current Brazilian e-commerce conditions.
- Currency symbols in the educational analysis are retained from the project work; marketplace values should be interpreted within the source dataset context rather than as a current EUR market estimate.
- The late-period decline in orders may reflect incomplete data collection near the dataset boundary.
- Premium-tech demand is approximated using the top 15% of technology-item prices rather than an external luxury-product classification.
- External market context supports interpretation but is not directly joined to the transactional dataset.

## Tools

**MySQL · SQL · Data analysis · Market research · Business analysis · Presentation**

---

### Portfolio takeaway

This project demonstrates how SQL can support a strategic market-entry decision: moving from raw marketplace transactions to a recommendation that considers **demand, premium-product fit, seller economics, operations and customer experience**.
