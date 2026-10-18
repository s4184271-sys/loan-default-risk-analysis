-- View: public.loans_enriched

-- DROP VIEW public.loans_enriched;

CREATE OR REPLACE VIEW public.loans_enriched
 AS
 SELECT id,
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
            WHEN loan_status::text = ANY (ARRAY['Charged Off'::character varying, 'Default'::character varying, 'Does not meet the credit policy. Status:Charged Off'::character varying]::text[]) THEN 1
            ELSE 0
        END AS is_default,
        CASE
            WHEN annual_inc < 30000::numeric THEN '<30k'::text
            WHEN annual_inc >= 30000::numeric AND annual_inc < 60000::numeric THEN '30k-60k'::text
            WHEN annual_inc >= 60000::numeric AND annual_inc < 100000::numeric THEN '60k-100k'::text
            ELSE '100k+'::text
        END AS income_bracket,
        CASE
            WHEN dti < 15::numeric THEN 'Low (0-15%)'::text
            WHEN dti >= 15::numeric AND dti < 25::numeric THEN 'Medium (15-25%)'::text
            WHEN dti >= 25::numeric AND dti < 35::numeric THEN 'High (25-35%)'::text
            ELSE 'Very High (35%+)'::text
        END AS dti_band,
        CASE
            WHEN revol_util IS NULL THEN 'Unknown'::text
            WHEN revol_util < 20::numeric THEN 'Low (<20%)'::text
            WHEN revol_util >= 20::numeric AND revol_util < 40::numeric THEN 'Moderate (20-40%)'::text
            WHEN revol_util >= 40::numeric AND revol_util < 60::numeric THEN 'High (40-60%)'::text
            WHEN revol_util >= 60::numeric AND revol_util < 80::numeric THEN 'Very High (60-80%)'::text
            ELSE 'Extremely High (80%+)'::text
        END AS revol_util_band
   FROM loans
  WHERE loan_status::text = ANY (ARRAY['Fully Paid'::character varying, 'Charged Off'::character varying, 'Default'::character varying, 'Does not meet the credit policy. Status:Fully Paid'::character varying, 'Does not meet the credit policy. Status:Charged Off'::character varying]::text[]);

ALTER TABLE public.loans_enriched
    OWNER TO postgres;

