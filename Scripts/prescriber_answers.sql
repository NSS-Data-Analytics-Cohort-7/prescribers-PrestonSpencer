/* 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
ANSWER: NPI = 1881634483 ; Total claims = 99,707 */

SELECT npi, SUM(total_claim_count) AS total_claim
FROM prescription 
GROUP BY npi
ORDER BY total_claim DESC; 

/* 1. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims. 
ANSWER: Bruce Pendley, Family Practice, 99,707 claims */

SELECT pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.specialty_description, SUM(pn.total_claim_count) AS total_claim
FROM prescriber AS pr
INNER JOIN prescription AS pn
ON pr.npi = pn.npi
GROUP BY pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.specialty_description
ORDER BY total_claim DESC; 

/* 2. a. Which specialty had the most total number of claims (totaled over all drugs)?
ANSWER: Family Practice, 9,752,347 claims */

SELECT pr.specialty_description, SUM(pn.total_claim_count) AS total_claim
FROM prescriber AS pr
INNER JOIN prescription AS pn
ON pr.npi = pn.npi
GROUP BY pr.specialty_description
ORDER BY total_claim DESC; 

/* b. Which specialty had the most total number of claims for opioids?
ANSWER: Nurse Practitioner, 9,551 claims */

SELECT pr.specialty_description, SUM(pn.total_claim_count) AS total_claim, COUNT(d.opioid_drug_flag) AS total_opioid 
FROM prescriber AS pr
INNER JOIN prescription AS pn
ON pr.npi = pn.npi
INNER JOIN drug AS d
ON pn.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY pr.specialty_description
ORDER BY total_opioid DESC, total_claim; 

/* c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids? */

/* 3. a. Which drug (generic_name) had the highest total drug cost?
ANSWER: Insulin, $104,264,066.35 */

SELECT d.generic_name, SUM(p.total_drug_cost) AS total_cost
FROM drug AS d
INNER JOIN prescription AS p
ON d.drug_name = p.drug_name
GROUP BY d.generic_name
ORDER BY total_cost DESC; 

/* b. Which drug (generic_name) has the hightest total cost per day? 
*Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works. 
ANSWER: ASFOTASE ALFA, $4,659.20*/

SELECT d.generic_name, ROUND((p.total_drug_cost/p.total_30_day_fill_count)/30,2) AS day_cost
FROM drug AS d
INNER JOIN prescription AS p
ON d.drug_name = p.drug_name
GROUP BY d.generic_name, p.total_drug_cost, p.total_30_day_fill_count
ORDER BY day_cost DESC; 

SELECT d.generic_name, ROUND(p.total_drug_cost/p.total_day_supply,2) AS day_cost
FROM drug AS d
INNER JOIN prescription AS p
ON d.drug_name = p.drug_name
GROUP BY d.generic_name, p.total_drug_cost, p.total_day_supply
ORDER BY day_cost DESC; 

/* 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
ANSWER: */

SELECT drug_name,
    CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither' END AS drug_type
FROM drug; 

/* b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
ANSWER: 
Neither - $2,972,698,710.23
Opioid - $105,080,626.37
Antibiotic - $38,435,121.26 */

SELECT CAST(sum(total_cost) AS MONEY), drug_type
FROM
    (SELECT drug_name, total_drug_cost AS total_cost,
    CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
    WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither' END AS drug_type
    FROM drug 
    INNER JOIN prescription 
    USING (drug_name)) AS sub
GROUP BY drug_type;

/* 5. a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee. 
ANSWER: 10  */

SELECT COUNT(cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%, TN';

SELECT DISTINCT cbsaname
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN';
                           
/* b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population. 
ANSWER: 
Largest - Nashville-Davidson-Murfreesboro-Franklin, TN - 1,830,410
Smallest - Morristown, TN - 116,352 */

SELECT c.cbsaname, SUM(p.population) AS total_pop
FROM population AS p
INNER JOIN fips_county AS f
ON p.fipscounty = f.fipscounty
INNER JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
GROUP BY c.cbsaname
ORDER BY total_pop DESC;                           

SELECT *
FROM population;
                           
/* c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population. */

SELECT *
FROM cbsa AS c
LEFT JOIN fips_county AS f
ON                            
                           