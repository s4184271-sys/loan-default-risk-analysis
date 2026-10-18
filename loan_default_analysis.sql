CREATE DATABASE lendingclub;
\c lendingclub

CREATE TABLE loans (
    id BIGINT,
    loan_amnt NUMERIC,
    term VARCHAR(20),
    grade VARCHAR(5),
    sub_grade VARCHAR(5),
    purpose VARCHAR(50),
    annual_inc NUMERIC,
    dti NUMERIC,
    emp_length VARCHAR(20),
    home_ownership VARCHAR(20),
    addr_state VARCHAR(5),
    loan_status VARCHAR(60),
    issue_d VARCHAR(10),
    revol_util NUMERIC
);
\copy loans FROM 'C:/Users/SYED  MOHAMMED GHOUS/Downloads/loans_final
DROP VIEW IF EXISTS loans_enriched;

DROP VIEW IF EXISTS loans_enriched;

CREATE VIEW loans_enriched AS
SELECT
    id,
    loan_amnt,
    term,
    grade,
    sub_grade,
    purpose,
    annual_inc,
    dti,
    emp_length,
    home_ownership,
    addr_state,
    loan_status,
    issue_d,
    revol_util,

    CASE
        WHEN loan_status IN (
            'Charged Off',
            'Default',
            'Does not meet the credit policy. Status:Charged Off'
        ) THEN 1
        ELSE 0
    END AS is_default,

    CASE
        WHEN annual_inc < 30000 THEN '<30k'
        WHEN annual_inc >= 30000 AND annual_inc < 60000 THEN '30k-60k'
        WHEN annual_inc >= 60000 AND annual_inc < 100000 THEN '60k-100k'
        ELSE '100k+'
    END AS income_bracket,

    CASE
        WHEN dti < 15 THEN 'Low (0-15%)'
        WHEN dti >= 15 AND dti < 25 THEN 'Medium (15-25%)'
        WHEN dti >= 25 AND dti < 35 THEN 'High (25-35%)'
        ELSE 'Very High (35%+)'
    END AS dti_band,

    CASE
	    WHEN revol_util IS NULL THEN 'Unknown'
        WHEN revol_util < 20 THEN 'Low (<20%)'
        WHEN revol_util >= 20 AND revol_util < 40 THEN 'Moderate (20-40%)'
        WHEN revol_util >= 40 AND revol_util < 60 THEN 'High (40-60%)'
        WHEN revol_util >= 60 AND revol_util < 80 THEN 'Very High (60-80%)'
        ELSE 'Extremely High (80%+)'
    END AS revol_util_band

FROM loans
WHERE loan_status IN (
    'Fully Paid',
    'Charged Off',
    'Default',
    'Does not meet the credit policy. Status:Fully Paid',
    'Does not meet the credit policy. Status:Charged Off'
);
SELECT
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched;
SELECT
    grade,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY grade;
SELECT
    income_bracket,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY income_bracket
ORDER BY default_rate ASC;
SELECT
    dti_band,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY dti_band
ORDER BY default_rate DESC;
SELECT
    dti_band,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY dti_band
ORDER BY default_rate DESC;
WITH sub_grd AS (
    SELECT
        sub_grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY sub_grade
)
SELECT
    sub_grade,
    total_loans,
    total_defaults,
    default_rate
FROM sub_grd
WHERE default_rate > 20;
SELECT
    purpose,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY purpose
ORDER BY default_rate DESC;
SELECT
    emp_length,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY emp_length
ORDER BY default_rate DESC;
SELECT
    home_ownership,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY home_ownership
ORDER BY default_rate DESC;
SELECT
    addr_state,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY addr_state
ORDER BY default_rate DESC;
SELECT
    grade,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt
FROM loans_enriched
GROUP BY grade
ORDER BY total_loan_amnt DESC;
SELECT
    grade,count(*) as total_no_amnt,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,sum(is_default) as total_default,round(sum(is_default)*100/count(*),2)as default_rate
FROM loans_enriched
GROUP BY grade
ORDER BY total_loan_amnt DESC;
select * from loans;
SELECT
    purpose,
    SUM(
        CASE
            WHEN loan_status IN (
                'Fully Paid',
                'Does not meet the credit policy. Status:Fully Paid'
            )
            THEN 1
            ELSE 0
        END
    ) AS total_fully_paid,

    SUM(
        CASE
            WHEN loan_status IN (
                'Default',
                'Charged Off',
                'Does not meet the credit policy. Status:Charged Off'
            )
            THEN 1
            ELSE 0
        END
    ) AS not_fully_paid

FROM loans
GROUP BY purpose
ORDER BY total_fully_paid DESC;
select * from loans;
SELECT
    term,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        SUM(is_default) * 100.0 / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY term
ORDER BY default_rate DESC;
SELECT
    term,
    SUM(
        CASE
            WHEN loan_status IN (
                'Fully Paid',
                'Does not meet the credit policy. Status:Fully Paid'
            )
            THEN 1
            ELSE 0
        END
    ) AS total_fully_paid,

    SUM(
        CASE
            WHEN loan_status IN (
                'Default',
                'Charged Off',
                'Does not meet the credit policy. Status:Charged Off'
            )
            THEN 1
            ELSE 0
        END
    ) AS not_fully_paid

FROM loans
GROUP BY term
ORDER BY total_fully_paid DESC;
WITH term_status AS (
    SELECT
        term,

        SUM(
            CASE
                WHEN loan_status IN (
                    'Fully Paid',
                    'Does not meet the credit policy. Status:Fully Paid'
                )
                THEN 1
                ELSE 0
            END
        ) AS total_fully_paid,

        SUM(
            CASE
                WHEN loan_status IN (
                    'Default',
                    'Charged Off',
                    'Does not meet the credit policy. Status:Charged Off'
                )
                THEN 1
                ELSE 0
            END
        ) AS not_fully_paid

    FROM loans
    GROUP BY term
)

SELECT
    term,
    total_fully_paid,
    not_fully_paid,
    ROUND(
        100.0 * not_fully_paid / total_fully_paid,
        2
    ) AS not_fully_paid_ratio
FROM term_status
ORDER BY not_fully_paid_ratio DESC;
WITH term_status AS (
    SELECT
        term,

        AVG(
            CASE
                WHEN loan_status IN (
                    'Fully Paid',
                    'Does not meet the credit policy. Status:Fully Paid'
                )
                THEN loan_amnt
            END
        ) AS total_fully_paid_avg,

        AVG(
            CASE
                WHEN loan_status IN (
                    'Default',
                    'Charged Off',
                    'Does not meet the credit policy. Status:Charged Off'
                )
                THEN loan_amnt
            END
        ) AS not_fully_paid_avg

    FROM loans
    GROUP BY term
)

SELECT
    term,
    total_fully_paid_avg,
    not_fully_paid_avg,
    not_fully_paid_avg - total_fully_paid_avg AS avg_diff
FROM term_status
ORDER BY avg_diff DESC;
SELECT COUNT(*)
FROM loans
WHERE revol_util IS NULL;
SELECT
    revol_util_band,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(100.0 * SUM(is_default) / COUNT(*), 2) AS default_rate
FROM loans_enriched
GROUP BY revol_util_band
ORDER BY default_rate DESC;
SELECT
    revol_util_band,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY revol_util_band
ORDER BY default_rate DESC;
select * from loans_enriched;
SELECT
    income_bracket,
    revol_util_band,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    income_bracket,
    revol_util_band;
SELECT
    income_bracket,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY income_bracket
ORDER BY default_rate DESC;

SELECT
    dti_band,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY dti_band
ORDER BY default_rate DESC;
SELECT
    dgrade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY dti_band,grade
ORDER BY default_rate DESC;

SELECT
    grade,
    revol_util_band,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    grade,
    revol_util_band
ORDER BY
    default_rate DESC;

SELECT
    sub_grade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    SUM(loan_amnt) AS total_loan_amnt,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    sub_grade
ORDER BY
    default_rate DESC;

SELECT
    purpose,
    grade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    purpose,
    grade
ORDER BY
    default_rate DESC;

SELECT
    emp_length,
    grade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    emp_length,
    grade
ORDER BY
    default_rate DESC;

SELECT
    home_ownership,
    income_bracket,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    home_ownership,
    income_bracket
ORDER BY
    default_rate DESC;

SELECT
    addr_state,
    grade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    addr_state,
    grade
ORDER BY
    default_rate DESC;

SELECT
    CASE
        WHEN loan_amnt < 10000 THEN '<10k'
        WHEN loan_amnt < 25000 THEN '10k-25k'
        WHEN loan_amnt < 50000 THEN '25k-50k'
        ELSE '50k+'
    END AS loan_amnt_band,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    loan_amnt_band
ORDER BY
    default_rate DESC;

SELECT
    CASE
        WHEN loan_amnt < 10000 THEN '<10k'
        WHEN loan_amnt < 25000 THEN '10k-25k'
        WHEN loan_amnt < 50000 THEN '25k-50k'
        ELSE '50k+'
    END AS loan_amnt_band,
    grade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    loan_amnt_band,
    grade
ORDER BY
    default_rate DESC;

SELECT
    term,
    grade,
    COUNT(*) AS total_loans,
    AVG(annual_inc) AS avg_annual_income,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    term,
    grade
ORDER BY
    default_rate DESC;

WITH loan_sub AS (
    SELECT
        sub_grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        sub_grade
)
SELECT
    sub_grade,
    total_loans,
    total_defaults,
    default_rate
FROM loan_sub
WHERE total_loans > 10000
    AND default_rate > 20
ORDER BY
    default_rate DESC;

WITH loan_income_dti AS (
    SELECT
        income_bracket,
        dti_band,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        AVG(loan_amnt) AS avg_loan_amnt,
        AVG(annual_inc) AS avg_annual_income,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        income_bracket,
        dti_band
)
SELECT
    income_bracket,
    dti_band,
    total_loans,
    total_defaults,
    default_rate,
    avg_loan_amnt,
    avg_annual_income
FROM loan_income_dti
WHERE total_loans > 10000
    AND default_rate > 20
ORDER BY
    default_rate DESC;

WITH loan_income_grade AS (
    SELECT
        income_bracket,
        grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        AVG(dti) AS avg_dti,
        AVG(loan_amnt) AS avg_loan_amnt,
        AVG(annual_inc) AS avg_annual_income,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        income_bracket,
        grade
)
SELECT
    income_bracket,
    grade,
    total_loans,
    total_defaults,
    default_rate,
    avg_loan_amnt,
    avg_annual_income,
    avg_dti
FROM loan_income_grade
WHERE total_loans > 20000
    AND default_rate > 20
    AND avg_dti > 20
ORDER BY
    default_rate DESC;

WITH grade_revol_util_band AS (
    SELECT
        grade,
        revol_util_band,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        AVG(dti) AS avg_dti,
        AVG(loan_amnt) AS avg_loan_amnt,
        AVG(annual_inc) AS avg_annual_income,
        AVG(revol_util) AS avg_revol_util,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        grade,
        revol_util_band
)
SELECT
    grade,
    revol_util_band,
    total_loans,
    total_defaults,
    default_rate,
    avg_loan_amnt,
    avg_annual_income,
    avg_dti,
    avg_revol_util
FROM grade_revol_util_band
WHERE total_loans > 20000
    AND default_rate > 20
    AND avg_dti > 20
    AND avg_revol_util > 50
ORDER BY
    default_rate DESC;

SELECT
    income_bracket,
    dti_band,
    revol_util_band,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(annual_inc) AS avg_annual_income,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    income_bracket,
    dti_band,
    revol_util_band
HAVING COUNT(*) > 5000
    AND 100.0 * SUM(is_default) / COUNT(*) > 20
ORDER BY
    default_rate DESC;

SELECT
    purpose,
    term,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    AVG(loan_amnt) AS avg_loan_amnt,
    AVG(annual_inc) AS avg_annual_income,
    AVG(dti) AS avg_dti,
    AVG(revol_util) AS avg_revol_util,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate
FROM loans_enriched
GROUP BY
    purpose,
    term
HAVING COUNT(*) > 5000
ORDER BY
    default_rate DESC;

WITH sub_grade_stats AS (
    SELECT
        sub_grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        AVG(loan_amnt) AS avg_loan_amnt,
        AVG(annual_inc) AS avg_annual_income,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        sub_grade
    HAVING COUNT(*) > 5000
)
SELECT
    sub_grade,
    total_loans,
    total_defaults,
    avg_loan_amnt,
    avg_annual_income,
    default_rate,
    DENSE_RANK() OVER (
        ORDER BY default_rate DESC
    ) AS sub_grade_rank
FROM sub_grade_stats
ORDER BY
    sub_grade_rank;

select * from loans_enriched;

WITH term_rank_status AS (
    SELECT
	term,grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        AVG(loan_amnt) AS avg_loan_amnt,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched group by term,grade having count(*)>=10000
)
SELECT
term,grade,
    total_loans,
    total_defaults,
     avg_loan_amnt,
    default_rate,
    DENSE_RANK() OVER ( partition by term
        ORDER BY default_rate DESC
    ) AS term_rank
FROM term_rank_status  order by term,term_rank ;

WITH grade_status AS (
    SELECT
        grade,
        purpose,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        AVG(loan_amnt) AS avg_loan_amnt,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        grade,
        purpose
    HAVING COUNT(*) >= 10000
)
SELECT
    grade,
    purpose,
    total_loans,
    total_defaults,
    avg_loan_amnt,
    default_rate,
    DENSE_RANK() OVER (
        PARTITION BY grade
        ORDER BY default_rate DESC
    ) AS purpose_rank
FROM grade_rank_status
ORDER BY
    grade,
    purpose_rank;

WITH overall_stats AS (
    SELECT
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS overall_default_rate
    FROM loans_enriched
),
grade_stats AS (
    SELECT
        grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        grade
)
SELECT
    g.grade,
    g.total_loans,
    g.total_defaults,
    g.default_rate,
    o.overall_default_rate,
    ROUND(
        g.default_rate - o.overall_default_rate,
        2
    ) AS difference_from_overall,
    CASE
        WHEN g.default_rate > o.overall_default_rate
            THEN 'Above Overall Risk'
        WHEN g.default_rate < o.overall_default_rate
            THEN 'Below Overall Risk'
        ELSE 'Equal to Overall Risk'
    END AS risk_label
FROM grade_stats AS g
CROSS JOIN overall_stats AS o
ORDER BY
    g.default_rate DESC;

WITH grade_contribution AS (
    SELECT
        grade,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        grade
)
SELECT
    grade,
    total_loans,
    total_defaults,
    default_rate,
    ROUND(
        100.0 * total_defaults
        / SUM(total_defaults) OVER (),
        2
    ) AS percent_contribution
FROM grade_contribution
ORDER BY
    percent_contribution DESC;

WITH month_default AS (
    SELECT
        DATE_TRUNC('month',to_date( issue_d,'Mon-yyyy')) AS month,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        DATE_TRUNC('month', to_date(issue_d,'Mon-yyyy'))
)
SELECT
    month,
    total_loans,
    total_defaults,
    default_rate,
    LAG(default_rate) OVER (
        ORDER BY month
    ) AS previous_month_default_rate,
    ROUND(
        default_rate
        - LAG(default_rate) OVER (
            ORDER BY month
        ),
        2
    ) AS default_rate_change
FROM month_default
ORDER BY
    month;

select * from loans_enriched;
WITH year_default AS (
    SELECT
        DATE_TRUNC('year',to_date(  issue_d,'Mon-yyyy')) AS year,
        COUNT(*) AS total_loans,
        SUM(is_default) AS total_defaults,
        ROUND(
            100.0 * SUM(is_default) / COUNT(*),
            2
        ) AS default_rate
    FROM loans_enriched
    GROUP BY
        DATE_TRUNC('year',to_date(issue_d,'Mon-yyyy'))
)
SELECT
    year,
    total_loans,
    total_defaults,
    default_rate,
    LAG(default_rate) OVER (
        ORDER BY year
    ) AS previous_year_default_rate,
    ROUND(
        default_rate
        - LAG(default_rate) OVER (
            ORDER BY year
        ),
        2
    ) AS default_rate_change
FROM year_default
ORDER BY
    year;

select * from loans_enriched;
SELECT
    purpose,
    COUNT(*) AS total_loans,
    SUM(is_default) AS total_defaults,
    ROUND(
        100.0 * SUM(is_default) / COUNT(*),
        2
    ) AS default_rate,
FROM loans_enriched
GROUP BY purpose
ORDER BY default_rate DESC;

ALTER USER postgres WITH PASSWORD 'YourNewPassword123!';

ALTER USER postgres WITH PASSWORD 'Ghouse@2026';

	

