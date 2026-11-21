# Employee Attrition Analysis & Prediction

Why do employees leave, and can we flag who is at risk? An end-to-end analysis of HR data using Python and SQL.

## Business question
33% of employees in this dataset have left. Where is attrition concentrated, what drives it, and what should HR do about it?

## Data
`HRDataset_v14.csv`: a public synthetic HR dataset (311 employees, 36 columns). Source: Kaggle "Human Resources Data Set" (add the link and check its license before publishing). Target: `Termd` (1 = left).

## Tools
Python (pandas, scikit-learn, matplotlib, seaborn), SQL (SQLite), [Power BI / Tableau Public: add if built]

## Key findings
- **Overall attrition: 33.4%** (104 of 311 employees).
- **Production** has the highest attrition among large departments (40%) and is 67% of headcount.
- **Recruitment channel matters:** Google Search hires left at 61% and Diversity Job Fair at 55%, versus 16% for Employee Referrals and 8% for the company website.
- **Managers differ widely:** from about 7% to 62% attrition across teams of 14+ people.
- **Lower pay, higher attrition:** 40.5% under $55k vs 27.6% at $80k+.
- **The 2011 hiring cohort** is an outlier: 71% of the 83 people hired that year have left.
- Engagement and satisfaction survey scores barely differ between leavers and stayers, so they are weak early-warning signals here.

## Model
Logistic Regression, Random Forest, and Gradient Boosting were compared with 5-fold stratified cross-validation against a "nobody leaves" baseline.
- Best ROC-AUC: **~0.70**; recall on leavers: **~65%**; precision: **~47%**.
- Test accuracy (~64%) is slightly below the 66.5% baseline, so the model is a **modest ranking tool, not an accurate predictor**. With 311 rows this is expected.
- Outcome-leaking columns (termination date, status, reason, tenure) and protected attributes (gender, race, marital status, age, citizenship) were excluded.

## Recommendations
1. Review teams with 50%+ attrition (exit interviews, workload, pay).
2. Shift recruiting toward referrals and the company website; review ROI of the weakest channels.
3. Focus retention efforts on Production.
4. Collect more data (more employees, timestamped surveys, exit interviews) before using any model for individual decisions.

## Limitations
Small, synthetic dataset; results may not generalize. Manager and recruitment-source effects are descriptive, not proof of cause.

## Repository contents
| File | Description |
|---|---|
| `Employee_Attrition_Analysis.ipynb` | Cleaning, EDA, modelling, recommendations |
| `attrition_queries.sql` | 10 SQL queries (aggregations, window functions, CTE) |
| `make_db.py` | Builds the SQLite database from the CSV |
| `HRDataset_v14.csv` | Dataset |

## How to run
```bash
pip install pandas numpy scikit-learn matplotlib seaborn jupyter
jupyter notebook Employee_Attrition_Analysis.ipynb
python make_db.py   # then open hr.db in DB Browser for SQLite and run attrition_queries.sql
```

## Dashboard
[Add screenshot or Tableau Public link here]
