-- Exploratory Data Analysis (EDA) Summary

-- How many unique pages do we have? 

SELECT DISTINCT(page)
FROM page_views;

-- We see that there are 4 different pages shown: homepage, blog, issues, and news

-- What is the date span/timeline of the data recorded? 

SELECT DISTINCT(page_view_date)
FROM page_views
ORDER by page_view_date;

-- Dates run from 2020-03-30 to 2022-03-21, a total of seven quarters.

-- How many unique users do we have across the mentioned period?

SELECT COUNT(DISTINCT user_id) As no_of_users
FROM page_views;

-- We have 100 unique users over period covered in database.

-- How many page views occurred over the period? 

SELECT COUNT(page_view_id) AS page_view_count
FROM page_views;

-- We have 149 page views over period covered in database.

-- What were the most popular pages by number of visits? 

SELECT 
	page,
    COUNT(page_view_id) AS page_visits
FROM page_views
GROUP BY 
	page
ORDER BY page_visits DESC

-- We see that the issues page is the most popular (unsurprisingly!) followed by the homepage. 

-- What were the most popular pages by device segment? 

WITH device_page_segment AS (
    SELECT 
        t1.page,
        t2.device,
        COUNT(t1.page_view_id) AS page_visits
    FROM page_views t1
    INNER JOIN conversions t2 ON t1.page_view_id = t2.page_view_id
  -- we use an inner join because not every user that visited the website donated.
  -- we want to return users that appear in both tables.
    GROUP BY 
        t1.page,
        t2.device
)

SELECT
    page,
    device,
    MAX(page_visits) AS top_page
FROM 
    device_page_segment
GROUP BY 
    device
ORDER BY
	top_page DESC;
    
-- Method 2: Using ROWNUM() Window Function

WITH device_page_segment AS (
    SELECT 
        t1.page,
        t2.device,
        COUNT(t1.page_view_id) AS page_visits,
        ROW_NUMBER() OVER(PARTITION BY t2.device ORDER BY COUNT(t1.page_view_id) DESC) AS row_num
    FROM page_views t1
    INNER JOIN conversions t2 ON t1.page_view_id = t2.page_view_id
    GROUP BY 
        t1.page,
        t2.device
)

SELECT
    page,
    device,
    page_visits
FROM 
    device_page_segment
WHERE 
    row_num = 1
ORDER BY
	page_visits;

/* We see that iOS users are most likely to visit the issues page. 
This may correlate to this younger demographic more active on viral issues. 
Windows users may be older, more traditional and more loyal to the ACLU so
more likely to follow the organization's blog rather than trending topics.*/


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

-- What pages do we get the most referrals from? 

SELECT
    DISTINCT (referrer),
    COUNT(referrer) As no_of_referrals
FROM page_views
GROUP BY 
    referrer
ORDER BY
	no_of_referrals DESC;
    
/* Most referrals came from Google with 97 referrals so we should make sure have a strong SEO presence to 
drive engagement. In addition, twitter and facebook were the channels that came after
Google with 16 and 14 referrals respectively. Unsurprisingly due to their lesser popularity, 
Bing and Yahoo trailed these websites. However, I find it interesting that Instagram had the least
referrals with 7 URL conversions given that it is popular among youth and is owned Facebook, a 
website we get our third-largest share of referrals. This may be because the platform skews towards 
aspirational lifestyle and micro-blogging/influencer content and less towards politics and advocacy. 
However, this trend has changed in recent times as the website matures and the social media space 
becomes more consolidated with the decline of Twitter and Facebook. Maybe we can pilot an Instagram 
engagement strategy targeting youth using politically active influencers. */
   
-- Who are our most generous donors? 

SELECT
	t2.user_id,
    SUM(t1.conversion_amount) AS donor_lifetime_value
FROM 
	conversions t1
LEFT JOIN 
	page_views t2 ON t1.page_view_id = t2.page_view_id
GROUP BY 
	t2.user_id
ORDER BY
	donor_lifetime_value DESC;
    
/* Donor 164904200849 has donated the most to the ACLU with $260. Ensure that
we identify active donors and ensure that we keep them involved and
engaged with the organization by decreasing churn. Create user personas for top donors. 
E.g. what do our top 10 have in common? What is driving their behavior? 
How do we keep them involved? */

-- What is the most popular day for page visits?

SELECT 
    strftime('%w', page_view_date) AS day_of_week,
    COUNT(page_view_id) AS page_view_count
FROM 
    page_views
GROUP BY 
    day_of_week
ORDER BY 
    page_view_count DESC
LIMIT 1;

/* Fridays are the most popular day for visiting the ACLU website. Unsurprising given that 
this is the start of the leisurely weekend. We can make sure to most our most actionable 
content on these days to boost awareness around topical issues. */

-- What is the most popular day for donating to the ACLU? 
	
SELECT 
    strftime('%w', t2.page_view_date) AS day_of_week,
    COUNT(t1.donation_id) AS donation_count
FROM 
	conversions t1
LEFT JOIN 
	page_views t2 ON t1.page_view_id = t2.page_view_id
GROUP BY 
    day_of_week
ORDER BY 
    donation_count DESC
LIMIT 1;

/* Fridays are also the most popular day for donating to the ACLU. Unsurprising given that 
this is the start of the leisurely weekend. We can make sure to most our most actionable 
content on these days to boost awareness around topical issues. */
