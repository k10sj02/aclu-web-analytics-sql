/* Write a query that returns the number of unique users who visited the
 homepage in Q1 2021 (Jan 1, 2021 – March 31, 2021).*/

SELECT 
	COUNT(DISTINCT user_id) AS uniq_users
FROM 
	page_views
WHERE 
	page = 'homepage' AND 
    page_view_date BETWEEN '2021-01-01' AND '2021-03-31';

-- Method 2: Using comparison operators

SELECT 
	COUNT(DISTINCT user_id) AS uniq_users
FROM 
	page_views
WHERE 
	page = 'homepage' AND 
    page_view_date >= '2021-01-01' AND page_view_date <= '2021-03-31';

/* We see that we have 4 unique visits to homepage that occurred between the Jan 1, 2021
and Mar 31, 2023 (Q1 2021). */


-- BETWEEN test query check

SELECT 
	*
FROM 
	page_views
WHERE 
	page_view_date BETWEEN '2021-01-01' AND '2022-03-21'
ORDER by 
	page_view_date;


/* Test if BETWEEN function is inclusive i.e. 
does it include the upper bound of data. 
It does so the above query is correct. 
Note - This is not always the case with all SQL dialects.*/
    
/* What is the % difference in the number of unique users who visited
the homepage during Q1 vs. Q2 2021 (Apr 1, 2021 – June 30, 2021)? */

WITH Q1_users AS (
    SELECT DISTINCT user_id
    FROM page_views
    WHERE page = 'homepage'
    AND page_view_date BETWEEN '2021-01-01' AND '2021-03-31'
),
Q2_users AS (
    SELECT DISTINCT user_id
    FROM page_views
    WHERE page = 'homepage'
    AND page_view_date BETWEEN '2021-04-01' AND '2021-06-30'
)
SELECT 
    (COUNT(DISTINCT Q2_users.user_id) - COUNT(DISTINCT Q1_users.user_id)) * 100.0 / COUNT(DISTINCT Q1_users.user_id) AS percentage_difference
FROM 
    Q1_users
LEFT JOIN 
    Q2_users ON 1 = 1;

-- We have a 25% increase in web traffic between Q1 and Q2. 

/* Write a query that shows revenue and average gift size by mobile device
types. Create chart(s) to visualize this data. */

SELECT
	device,
    SUM(conversion_amount) AS revenue,
    AVG(conversion_amount) AS avg_gift_size
FROM conversions
GROUP BY device
ORDER BY 
	revenue DESC,
    avg_gift_size DESC;

/* The data reveals distinct trends among user segments 
regarding revenue and average gift size. iOS users stand 
out as the highest revenue generators, amassing a total of $2066. 
Meanwhile, Windows users boast the highest average gift size, 
averaging $45 per donation, and rank second in terms of overall revenue.

Conversely, Android users occupy the bottom rung in both revenue 
and average gift size metrics. This suggests a potential correlation 
between user demographics and device preferences. 

It's plausible that younger, more affluent demographics gravitate towards 
iOS devices, fostering a culture of frequent, on-the-go donations, consequently 
driving higher revenue figures.

Conversely, older donors, typically possessing higher net worth, 
may favor Windows devices for their donation activities. 
While their contributions may occur less frequently, 
their propensity for larger donations could be attributed 
to their higher net worth and perhaps a preference for 'traditional' 
computing devices such as the desktop and laptop. 

*/

/* Write a query and create a chart to visualize number of page views by page
over time (by month) in the year 2021. */

SELECT 
    strftime('%Y', page_view_date) AS extracted_year,
    strftime('%m', page_view_date) AS extracted_month,
    page,
    COUNT(page_view_id) AS page_view_count
FROM 
    page_views
WHERE 
    strftime('%Y', page_view_date) = '2021'
GROUP BY 
	extracted_month, 
    extracted_year,
    page
ORDER BY 
	page,
    extracted_year,
    extracted_month