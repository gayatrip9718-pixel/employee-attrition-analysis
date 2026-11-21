-- Employee Attrition Analysis: SQL queries (SQLite syntax; works in DB Browser for SQLite)
-- Table: employees (one row per employee). Left = 1 if the employee left, 0 if still employed.
-- Build it first with:  python make_db.py

-- 1. Overall attrition rate
SELECT COUNT(*)                          AS headcount,
       SUM("Left")                       AS leavers,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct
FROM employees;

-- 2. Attrition by department
SELECT Department,
       COUNT(*)                          AS headcount,
       SUM("Left")                       AS leavers,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct
FROM employees
GROUP BY Department
ORDER BY attrition_pct DESC;

-- 3. Attrition by recruitment source (channels with 10+ hires)
SELECT RecruitmentSource,
       COUNT(*)                          AS hires,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct
FROM employees
GROUP BY RecruitmentSource
HAVING COUNT(*) >= 10
ORDER BY attrition_pct DESC;

-- 4. Manager ranking: teams with 14+ employees, ranked by attrition (window function)
SELECT ManagerName,
       COUNT(*)                          AS team_size,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct,
       RANK() OVER (ORDER BY AVG("Left") DESC) AS risk_rank
FROM employees
GROUP BY ManagerName
HAVING COUNT(*) >= 14
ORDER BY risk_rank;

-- 5. Attrition by performance score
SELECT PerformanceScore,
       COUNT(*)                          AS headcount,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct
FROM employees
GROUP BY PerformanceScore
ORDER BY attrition_pct DESC;

-- 6. Attrition by salary band (CASE)
SELECT CASE WHEN Salary < 55000  THEN '1. Under 55k'
            WHEN Salary < 65000  THEN '2. 55k-65k'
            WHEN Salary < 80000  THEN '3. 65k-80k'
            ELSE                      '4. 80k+' END AS salary_band,
       COUNT(*)                          AS headcount,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct
FROM employees
GROUP BY salary_band
ORDER BY salary_band;

-- 7. Average tenure (years) by outcome; active staff measured to 2019-02-28
SELECT CASE WHEN "Left" = 1 THEN 'Left' ELSE 'Still employed' END AS outcome,
       COUNT(*) AS headcount,
       ROUND(AVG((julianday(COALESCE(DateofTermination, '2019-02-28'))
                  - julianday(DateofHire)) / 365.25), 2) AS avg_tenure_years
FROM employees
GROUP BY outcome;

-- 8. Hiring cohorts: how many people hired each year have since left?
SELECT SUBSTR(DateofHire, 1, 4)          AS hire_year,
       COUNT(*)                          AS hired,
       SUM("Left")                       AS since_left,
       ROUND(100.0 * AVG("Left"), 1)     AS attrition_pct
FROM employees
GROUP BY hire_year
ORDER BY hire_year;

-- 9. Why do people leave? (leavers only)
SELECT TermReason, COUNT(*) AS leavers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_leavers
FROM employees
WHERE "Left" = 1
GROUP BY TermReason
ORDER BY leavers DESC
LIMIT 8;

-- 10. CTE: department attrition vs the company average
WITH company AS (SELECT AVG("Left") AS avg_rate FROM employees),
     dept AS (
       SELECT Department, COUNT(*) AS headcount, AVG("Left") AS rate
       FROM employees GROUP BY Department HAVING COUNT(*) >= 10)
SELECT d.Department, d.headcount,
       ROUND(100 * d.rate, 1)                         AS attrition_pct,
       ROUND(100 * (d.rate - c.avg_rate), 1)          AS pts_vs_company
FROM dept d CROSS JOIN company c
ORDER BY pts_vs_company DESC;
