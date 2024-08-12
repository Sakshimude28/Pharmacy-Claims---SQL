#Q1.
use Pharmacy;
SELECT drug_name, COUNT(*) as prescription_count
FROM fact_claims
JOIN dim_drug ON fact_claims.drug_ndc = dim_drug.drug_ndc
GROUP BY drug_name;


#Q.2 This query uses a CASE statement to categorize members into two age groups: 'age 65+' and '< 65'.
#It counts total prescriptions, unique members, and sums up the copays for each age group.
SELECT 
  CASE 
    WHEN dim_member.member_age >= 65 THEN 'age 65+'
    ELSE '< 65'
  END as age_group,
  COUNT(*) as total_prescriptions,
  COUNT(DISTINCT fact_claims.member_id) as unique_members,
  SUM(copay1 + copay2 + copay3) as total_copay
FROM fact_claims
JOIN dim_member ON fact_claims.member_id = dim_member.member_id
GROUP BY age_group;


#Q.3 This query uses SQL window functions.
#It calculates the most recent prescription fill date and the insurance payment for that prescription for each member.
#It joins all three tables (fact_claims, dim_member, dim_drug) to provide comprehensive details.
#because of unsurity which of the fill_date columns (fill_date1, fill_date2, fill_date3) contains the most recent date and they 
#could all potentially hold that value, I have used the GREATEST function 
#to determine the most recent date across these columns for each row.
SELECT 
  fact_claims.member_id, 
  dim_member.member_first_name, 
  dim_member.member_last_name, 
  dim_drug.drug_name, 
  GREATEST(
    IFNULL(fact_claims.fill_date1, '1000-01-01'), 
    IFNULL(fact_claims.fill_date2, '1000-01-01'), 
    IFNULL(fact_claims.fill_date3, '1000-01-01')
  ) as most_recent_fill_date,
  FIRST_VALUE(fact_claims.insurancepaid1) OVER (
    PARTITION BY fact_claims.member_id 
    ORDER BY GREATEST(
      IFNULL(fact_claims.fill_date1, '1000-01-01'), 
      IFNULL(fact_claims.fill_date2, '1000-01-01'), 
      IFNULL(fact_claims.fill_date3, '1000-01-01')
    ) DESC
  ) as most_recent_insurance_paid
FROM fact_claims
JOIN dim_member ON fact_claims.member_id = dim_member.member_id
JOIN dim_drug ON fact_claims.drug_ndc = dim_drug.drug_ndc;

