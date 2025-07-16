-- DATA CLEANING
-- create year & month column
/*
UPDATE complaints
SET received_month = EXTRACT(MONTH FROM date_received);

UPDATE complaints
SET received_year = EXTRACT(YEAR FROM date_received);
*/

-- create product_cleaned column
/*
	UPDATE complaints
	SET product_cleaned = product;
	
	SELECT DISTINCT product_cleaned 
	FROM complaints;
*/

-- update product type
/*
UPDATE complaints 
SET product_cleaned = 'Credit reporting, repair, or other'
WHERE product_cleaned IN (
		'Credit reporting, credit repair services, or other personal consumer reports', 'Credit reporting'
	);

UPDATE complaints 
SET product_cleaned = 'Credit card or prepaid card'
WHERE product_cleaned IN (
		'Credit card', 'Prepaid card'
	);

UPDATE complaints
SET product_cleaned = 'Money transfer, virtual currency, or money service'
WHERE product_cleaned IN (
		'Money transfers', 'Virtual currency'
	);

UPDATE complaints
SET product_cleaned = 'Payday loan, title loan, or personal loan'
WHERE product_cleaned = 'Payday loan';


UPDATE complaints
SET consumer_disputed = 'Unknown'
WHERE consumer_disputed = 'N/A';
*/

-- overall performance

SELECT COUNT(DISTINCT product_cleaned) AS complaints, 
	   COUNT(DISTINCT issue) AS issue, 
	   COUNT(DISTINCT company) AS company,
	   (
		 SELECT COUNT(*)
		 FROM complaints
		 WHERE timely_response = 'Yes'
	   ) AS Yes_timely_response,
	   (
		 SELECT COUNT(*)
		 FROM complaints
		 WHERE timely_response = 'No'
	   ) AS No_timely_response,
	   (
		 SELECT COUNT(*)
		 FROM complaints
		 WHERE consumer_disputed = 'Yes'
	   ) AS consumer_disputed,
	   (
		 SELECT product
		 FROM complaints
		 GROUP BY product
		 ORDER BY COUNT(*) DESC
		 LIMIT 1
	   ) AS most_complained_product 
FROM complaints;



-- Which product categories receive the highest number of consumer complaints?
/*
SELECT product_cleaned, 
	   issue_count,
	   MAX(company_response_to_consumer) AS most_common_response
FROM 
	(
	  SELECT product_cleaned, company_response_to_consumer, 
	  		 COUNT(issue) AS issue_count,
			 RANK() OVER(PARTITION BY product_cleaned ORDER BY COUNT(*) DESC ) AS rnk
	  FROM complaints
	  GROUP BY product_cleaned, company_response_to_consumer
	) ranked
WHERE rnk = 1
GROUP BY product_cleaned, issue_count
ORDER BY issue_count ;
*/

-- Which complaint products are most likely to be disputed or left without a company response?
/*
// no_disputed_on_time_response
SELECT 
  product_cleaned,
  ROUND(100.0 * SUM(CASE WHEN consumer_disputed = 'No' THEN 1 ELSE 0 END) / COUNT(*),1) AS percent_disputed,
  ROUND(100.0 * SUM(CASE WHEN timely_response = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),1) AS percent_untimely_response
FROM complaints
GROUP BY product_cleaned
ORDER BY percent_disputed DESC;

// disputed_no_timely_response
SELECT 
  product_cleaned,
  ROUND(100.0 * SUM(CASE WHEN consumer_disputed = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),1) AS percent_disputed,
  ROUND(100.0 * SUM(CASE WHEN timely_response = 'No' THEN 1 ELSE 0 END) / COUNT(*),1) AS percent_untimely_response
FROM complaints
GROUP BY product_cleaned
ORDER BY percent_disputed DESC;
*/

-- Which Products Are Most Disputed and Poorly Handled?
/*
SELECT 
    product_cleaned, 
    ROUND((meet_number * 1.0 / total_number) * 100, 2) AS meet_rate_percentage
FROM (
    SELECT 
        product_cleaned,
        COUNT(*) FILTER (WHERE consumer_disputed = 'No' AND
                         timely_response = 'Yes' AND
                         company_response_to_consumer <> 'Untimely response') AS meet_number,
        COUNT(*) AS total_number
    FROM complaints
    GROUP BY product_cleaned
) AS sub
ORDER BY meet_rate_percentage DESC;
*/

-- What Are the Yearly Trends of Complaints?
/*
SELECT received_year, product_cleaned,
		count(issue) AS issue_count
		
FROM complaints
GROUP BY received_year, product_cleaned,
ORDER BY issue_count DESC;
*/



