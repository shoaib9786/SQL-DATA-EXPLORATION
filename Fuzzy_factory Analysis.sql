use mavenfuzzyfactory;
show tables;
select website_sessions.utm_content,
count(distinct website_sessions.website_session_id) as Sessions ,
count(distinct orders.order_id)as Orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as Session_to_order_convert
from website_sessions left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by utm_content
order by Sessions desc;

## bulk of website session are coming from before the date april 12 2012

select utm_source,
utm_campaign,
utm_content,http_referer,
count(distinct website_session_id) as number_of_sessions 
from  website_sessions
where created_at < '2012-04-12'
group by utm_source,
utm_campaign,
utm_content,http_referer
order by number_of_sessions desc;

## Traffic concersion rates gsearch nonbrand

select 
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_convrt_order
from website_sessions 
left join orders
on orders.website_session_id=website_sessions.website_session_id
where website_sessions.created_at < '2012-04-14'
and utm_source = 'gsearch'
and utm_campaign  ='nonbrand';

## Date functions

select
website_session_id,
created_at,
month(created_at),
year(created_at),
week(created_at)
from website_sessions
where website_session_id between 10000 and 115000;

select year(created_at)as year,
month(created_at) as month,
min(date(created_at)) as week_start,
count(distinct website_session_id) as sessions
from website_sessions
group by 1,2;

## Pivoting data with COUNT AND CASE

select
 primary_product_id,
order_id,
items_purchased,
count(distinct case when items_purchased=1 then order_id else null end ) as single_items_order,
count(distinct case when items_purchased=2 then order_id else null end) as two_items_orders
from orders
where order_id between 31000 and 32000
group by 1,2,3;

select
 primary_product_id,
count(distinct case when items_purchased=1 then order_id else null end ) as single_items_order,
count(distinct case when items_purchased=2 then order_id else null end) as two_items_orders
from orders
where order_id between 31000 and 32000
group by 1;

## Bid down gsearch nonbrand by week  before 10 may 2012

select week(created_at),
min(date(created_at)) As week_start_date,
count(distinct website_session_id) as sessions
from website_sessions
where created_at < '2012-05-10'
and utm_source='gsearch'
and utm_campaign='nonbrand'
group by 1;

## Conversion rates from session to order , by device type before may 11, 2012

select 
website_sessions.device_type,
count(distinct website_sessions.website_session_id)as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conversion_order_session
from website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id	
where website_sessions.created_at < '2012-05-11'
and website_sessions.utm_source='gsearch'
and website_sessions.utm_campaign='nonbrand'
group by 1;

## Weekly trends for both desktop and mobile gsearch nonbrands 
select 
year(created_at) as year,
week(created_at)as week ,
min(date(created_at)) as week_start,
count(distinct case when device_type ='desktop' then website_session_id else null end) as desktop_sessions,
count(distinct case when device_type='mobile' then website_session_id else null end ) as mobile_sesions,
count(distinct website_session_id) as sessions
from website_sessions
where website_sessions.created_at < '2012-06-09'
and website_sessions.created_at > '2012-04-15'
and utm_source='gsearch'
and utm_campaign='nonbrand'
group by 1,2;

## Analyzing the pageviews data and group  by url to see which pages are viewed most

select pageview_url,
count(distinct website_pageview_id) as Page_view
 from website_pageviews
 where website_pageview_id < 1000
 group by 1
 order by Page_view desc;
 
 ##	To find the top entry pages and we will create temporary table 
 
 select website_session_id,
 min(website_pageview_id) as min_pageview
 from website_pageviews
 where website_pageview_id < 1000
 group by website_session_id;
 
 create temporary table first_pageview
 select website_session_id,
 min(website_pageview_id) as min_pageview
 from website_pageviews
 where website_pageview_id < 1000
 group by website_session_id;
 
 select first_pageview.website_session_id,
 website_pageviews.pageview_url as landing_page
 from first_pageview
 left join website_pageviews
 on first_pageview.min_pageview=website_pageviews.website_pageview_id;
 
 ## Most viewed website pages, ranked by session volume
 
 select pageview_url,
 count(distinct website_pageview_id) As Pageview
 from website_pageviews
 where created_at < '2012-06-09'
 group by pageview_url
 order  by 2 desc;
 
 ## A list of the top entry pages or landing pages
 
 select website_session_id,
 min(website_pageview_id) as fst_pgeview
 from website_pageviews
 where created_at < '2012-06-12'
 group by website_session_id;
 
 create temporary table first_pageviews
 select website_session_id,
 min(website_pageview_id) as fst_pgeview
 from website_pageviews
 where created_at < '2012-06-12'
 group by website_session_id;
 
 select count(first_pageviews.website_session_id) as session_hitting_page,
 website_pageviews.pageview_url as landing_page
 from first_pageviews
 left join website_pageviews
 on first_pageviews.fst_pgeview=website_pageviews.website_pageview_id
 group by website_pageviews.pageview_url;
 
 ## Landing page peformance and testing 
 # Business Context -- we want to see landing page peformance for a certain time period 
 # Step-1: find the first website_pageview_id for revelant sessions
 # step-2: identify the landing page of each session
 # step-3: counting page_views for each session to identify "bounces"
 # step-4: summarizing total sessions and bounced sessions , by landing page 
 
 # Finding the minimum website_pagviewId  associated with each session 
 
 select website_sessions.website_session_id,
 min(website_pageviews.website_pageview_id) as min_pageview
 from website_sessions inner join website_pageviews 
 on website_sessions.website_session_id=website_pageviews.website_session_id
 where website_sessions.created_at between '2014-01-01' and '2014-02-01'
 group by website_sessions.website_session_id;
 
 # Same query as a above but this time 	we are sorting 	the data set as temporary table 
 
 create temporary table first_pageview 
 select website_sessions.website_session_id,
 min(website_pageviews.website_pageview_id) as min_pageview
 from website_sessions inner join website_pageviews 
 on website_sessions.website_session_id=website_pageviews.website_session_id
 where website_sessions.created_at between '2014-01-01' and '2014-02-01'
 group by website_sessions.website_session_id;
 
 select website_pageviews.pageview_url as landing_page,
 first_pageview.website_session_id from first_pageview 
 left join website_pageviews on 
 first_pageview.min_pageview=website_pageviews.website_pageview_id;
 
 # Next we will bring in the landing page to each sessions and we will create new temporary table 
 
 create temporary table seessions_w_landing_page_demo
 select website_pageviews.pageview_url as landing_page,
 first_pageview.website_session_id from first_pageview 
 left join website_pageviews on 
 first_pageview.min_pageview=website_pageviews.website_pageview_id;
 
 # Now we will count the page_views and will join with website_pageviews
 
 select seessions_w_landing_page_demo.website_session_id,
 seessions_w_landing_page_demo.landing_page,
 count(website_pageviews.website_pageview_id) as count_of_pageviews
 from seessions_w_landing_page_demo left join website_pageviews
 on seessions_w_landing_page_demo.website_session_id = website_pageviews.website_session_id
 group by 1,2
 having count(website_pageviews.website_pageview_id)=1;

## Now creating temporary table bounced_sessions_only

create temporary table bounced_sessions_only
select seessions_w_landing_page_demo.website_session_id,
 seessions_w_landing_page_demo.landing_page,
 count(website_pageviews.website_pageview_id) as count_of_pageviews
 from seessions_w_landing_page_demo left join website_pageviews
 on seessions_w_landing_page_demo.website_session_id = website_pageviews.website_session_id
 group by 1,2
 having count(website_pageviews.website_pageview_id)=1;
 
 select seessions_w_landing_page_demo.landing_page,
 seessions_w_landing_page_demo.website_session_id,
 bounced_sessions_only.website_session_id as bounced_website_session_id
 from seessions_w_landing_page_demo  left join bounced_sessions_only
 on seessions_w_landing_page_demo.website_session_id=bounced_sessions_only.website_session_id
 order by seessions_w_landing_page_demo.website_session_id;
 
 ## Final output
 -- we will use the same query we previously ran and run a count of records 
 -- we will group by landing page and then we will add a bounce rate column  
 
select seessions_w_landing_page_demo.landing_page,
 count(distinct seessions_w_landing_page_demo.website_session_id) as Sessions,
 count(distinct bounced_sessions_only.website_session_id) as bounced_session,
 count(distinct bounced_sessions_only.website_session_id)/count(distinct seessions_w_landing_page_demo.website_session_id) as Bounce_rate
 from seessions_w_landing_page_demo  left join bounced_sessions_only
 on seessions_w_landing_page_demo.website_session_id=bounced_sessions_only.website_session_id
 group by seessions_w_landing_page_demo.landing_page;
 
 ## Analyzing the landing page test
 
 # find out when the new page/lander launched
 # finding the first website_pageview_id for revelant sessions
 # identyfying the landing page of each sessions
 # counting pageviews for each sessions to identify the bounces
 # summarizing the total sessiions and bounced sessions by lp
 
 select min(created_at) as first_created_at,
 min(website_pageview_id) as first_pageview 
 from website_pageviews
 where pageview_url='/lander-1'
 and created_at is not null;

select website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pageview_id 
from  website_pageviews
inner join website_sessions on
website_sessions.website_session_id =website_pageviews.website_session_id
and website_sessions.created_at<'2012-07-28'
and website_pageviews.website_pageview_id > 23504
and utm_source='gsearch'
and utm_campaign='nonband'
group by website_pageviews.website_session_id;

## Demo on building coversions funnels

# Business context
-- We want to build a mini conversion funnel , from /lander-2 to cart
-- we want to know how many people reach each step , and also dropoff rates
-- for simplicity of the demo , we are looking at lander-2 traffic only
-- for simplicity of the demo, we are looking at customers who look like mr fuzzy only 

-- step 1 select all pageviews for revelant sessions
-- step -2 identify the each revelant pageviews as the specific funnel step
-- step-3 create the session level conersion funnel view
-- step 4 aggregate the data to asses funell peformance

select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
case when pageview_url='/products' then 1 else 0 end as products_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
 from website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
and website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by website_sessions.website_session_id,
website_pageviews.created_at;

  -- Using Subqueries
  
select website_session_id,
max(products_page)as product_made_it,
max(mrfuzzy_page)as mrfuzzy_made_it,
max(cart_page)as cart_made_it
from (select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
case when pageview_url='/products' then 1 else 0 end as products_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
 from website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
and website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by website_sessions.website_session_id,
website_pageviews.created_at) as pageview_level
group by website_session_id;

-- next we will turn into temporary table above queries

create temporary table session_level_made_it_flags_demo
select website_session_id,
max(products_page)as product_made_it,
max(mrfuzzy_page)as mrfuzzy_made_it,
max(cart_page)as cart_made_it
from (select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
case when pageview_url='/products' then 1 else 0 end as products_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page
 from website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
and website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by website_sessions.website_session_id,
website_pageviews.created_at) as pageview_level
group by website_session_id;

-- then this would produce the final output (part -1)

select count(distinct website_session_id) as sessions,
count(distinct case when product_made_it =1 then website_session_id else null end) as to_products,
count(distinct case when mrfuzzy_made_it =1 then website_session_id else null end) as to_mrfuzzy,
count(distinct case when cart_made_it=1 then website_session_id else null end )as to_cart
 from session_level_made_it_flags_demo;
 
 -- then we will translate those counts to click rates for the final output part 2 ( click rates )
 -- i will start with the same query we just did and show you how to calculate the rates
 
 select count(distinct website_session_id) as sessions,
count(distinct case when product_made_it =1 then website_session_id else null end)/count(distinct website_session_id) as lander_clicked_through_rate,
count(distinct case when mrfuzzy_made_it =1 then website_session_id else null end)/count(distinct case when product_made_it =1 then website_session_id else null end) as product_clicked_through_rate,
count(distinct case when cart_made_it=1 then website_session_id else null end )/count(distinct case when mrfuzzy_made_it =1 then website_session_id else null end)as mrfuzzy_clicked_trough_rate
 from session_level_made_it_flags_demo;
 
 select website_sessions.utm_content,
 count(distinct website_sessions.website_session_id) as sessions,
 count(distinct orders.order_id) as orders,
 count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as order_session_cnvrt_rate
 from website_sessions left join orders
 on website_sessions.website_session_id=orders.website_session_id
 where website_sessions.created_at between '2014-01-01' and '2014-02-01' 
 group by 1 
 order by sessions desc;
 
 -- Analyzing the direct traffic 
 select  case when http_referer is null then 'direct_type_in'
			    when http_referer ='https://www.gsearch.com' and utm_source	is null  then 'gsearch_organic'
                when http_referer= 'https://www.bsearch.com' and utm_source is null then 'b_search_organic'
                else 'other' end as CASES,
                count(distinct website_session_id) as sessions
                from website_sessions
 where website_session_id between 100000 and 115000 -- arbitrary range
--  and utm_source is null 
 group by CASES
 order by sessions desc;
 
 -- Site traffic breakdown 
 select website_session_id, created_at,
 case 
 when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search' 
 when utm_campaign ='nonbrand' then 'paid_nonbrand'
 when utm_campaign='brand' then 'paid_brand'
 when utm_source is null and http_referer is null then 'direct_type'
 end as channel_type,
 utm_source,
 utm_campaign,
 http_referer 
 from website_sessions
 where created_at <'2012-12-23';
 
 select website_session_id, created_at,
 case 
 when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search' 
 when utm_campaign ='nonbrand' then 'paid_nonbrand'
 when utm_campaign='brand' then 'paid_brand'
 when utm_source is null and http_referer is null then 'direct_type'
 end as channel_type
 from website_sessions
 where created_at <'2012-12-23';
 
 -- Using Subqueries
 
 select year(created_at) as years,
        month(created_at)as months,
 count(distinct case when channel_type='paid_nonbrand' then website_session_id else null end) as nonbrand,
 count(distinct case when channel_type='paid_brand' then website_session_id else null end) as brand,
 count(distinct case when channel_type='paid_brand' then website_session_id else null end)/
 count(distinct case when channel_type='paid_nonbrand' then website_session_id else null end) as nonbrand_pct_brand,
 count(distinct case when channel_type = 'organic_search' then website_session_id else null end ) as organic,
  count(distinct case when channel_type = 'organic_search' then website_session_id else null end )/
  count(distinct case when channel_type='paid_nonbrand' then website_session_id else null end) as organic_nonbrand_pct,
  count(distinct case when channel_type='direct_type' then website_session_id else null end) as direct_type,
 count(distinct case when channel_type='direct_type' then website_session_id else null end) /
  count(distinct case when channel_type='paid_nonbrand' then website_session_id else null end) as direct_nonbrand_pct
 from ( select website_session_id, created_at,
 case 
 when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search' 
 when utm_campaign ='nonbrand' then 'paid_nonbrand'
 when utm_campaign='brand' then 'paid_brand'
 when utm_source is null and http_referer is null then 'direct_type'
 end as channel_type
 from website_sessions
 where created_at <'2012-12-23') as channel_session
 group by 1,2;
 
 -- Analyzing the business patterns and seasonality
 
 select website_session_id,
 created_at,
 hour(created_at) as hr,
 weekday(created_at) as week_day,
 case when  weekday(created_at)=0 then 'Monday'
      when  weekday(created_at) = 1 then 'Tuesday'
      when  weekday(created_at) = 2 then 'Wednesday'
      when  weekday(created_at) = 3 then 'thursday'
      when  weekday(created_at) = 4 then 'Friday'
      else 'other' end as clean_week_day,
      quarter(created_at) as Qtr,
      month(created_at) as Months,
      date(created_at) as dt,
      week(created_at) as wk
 from website_sessions
 where website_session_id between 150000 and 155000;-- arbitrary
 
 -- Analyzing product sales and product launches
 
select primary_product_id,
count(order_id) as orders ,
sum(price_usd) as Revenue,
sum(price_usd-cogs_usd) as Margin,
avg(price_usd) as Average_revenue
from orders
where order_id between 10000 and 11000 -- arbitrary
group by 1
order by 2 desc;

-- pull monthly trends to date for number of sales, total revenue, and the total margin genrated ?

select year(created_at) as yr,
month(created_at) as months,
count(order_id) as number_of_sales,
sum(price_usd) as total_revenue,
sum(price_usd-cogs_usd) as total_margin from orders
where created_at < '2013-01-04'
 group by 1,2;
 
 -- Monthly order volume , overall conversion rates, revenue per session, and a breakdown of sales by product 
 
 select year(website_sessions.created_at) as yr,
 Month(website_sessions.created_at) as months,
 count(distinct website_sessions.website_session_id) as sessions,
 count(distinct orders.order_id) as orders,
 count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conversion_rate,
 sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as revenue_per_sessions,
 count(distinct case when primary_product_id=1 then order_id else null end ) as product_1,
  count(distinct case when primary_product_id=2 then order_id else null end ) as product_2
  from website_sessions left join orders on
  website_sessions.website_session_id=orders.website_session_id
 where website_sessions.created_at <'2013-04-05'
 and website_sessions.created_at > '2012-04-01'
 group by 1,2;
 
 -- PRODUCT LEVEL WEBSITE ANALYSIS

select website_session_id, 
pageview_url from website_pageviews
where created_at between '2013-02-01' and '2013-03-01';

select
website_pageviews.pageview_url,
count(distinct website_pageviews.website_session_id) as sessions ,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_pageviews.website_session_id) as session_to_order_conversion_rate
 from website_pageviews left join orders
 on website_pageviews.website_session_id=orders.website_session_id
where website_pageviews.created_at between '2013-02-01' and '2013-03-01'
and website_pageviews.pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')
group by 1
order  by 2 desc;

-- PRODUCT PATHING ANALYSIS

-- STEP 1- FIND THE REVELANT /PRODUCTS PAGEVIEWS WITH WEBSESSION_ID 
-- STEP_2 - FIND THE NEXT PAGVIEW ID THAT OCCURS AFTER THE PRODUCT PAGVIEW
-- STEP-3 - FIND THE PAGE_VIEW_URL ASSOCIATED WITH ANY APPLICABLE NEXT PAGVIEW_ID
-- STEP-4- SUMMARIZE THE DATA AND ANALYZE THE PRE VS POST PERIODS

-- Step-1 THE REVELANT /PRODUCTS PAGEVIEWS WITH WEBSESSION_ID

create temporary table product_pageviews
select website_session_id,
pageview_url,
created_at,
case when created_at < '2013-01-06' then 'A.pre_product_2' 
     when created_at >+ '2013-01-06' then 'B.post_product_2'
     else 'uhh_check_logic' end as Time_period from website_pageviews
where created_at <'2013-04-06' -- date of request
and  created_at > '2012-10-06' 
and pageview_url = '/products';

-- Step-2-  THE NEXT PAGVIEW ID THAT OCCURS AFTER THE PRODUCT PAGVIEW
-- create temporary table session_next_w_pageview
select product_pageviews.website_session_id,
 product_pageviews.Time_period,
 min(website_pageviews.website_pageview_id) as min_nextpage_view_id
 from product_pageviews left join website_pageviews
 on website_pageviews.website_session_id= product_pageviews.website_session_id
 and website_pageviews.website_pageview_id >  product_pageviews.website_session_id
 group by 1,2;
 
 -- Step-3 Find the Page_view_url associtaed with next_pagview_id
 
 select session_next_w_pageview.website_session_id,
 session_next_w_pageview.Time_period,
 website_pageviews.pageview_url as next_pageview_url
 from session_next_w_pageview left join website_pageviews
 on website_pageviews.website_session_id=session_next_w_pageview.website_session_id
 group by 1,2;
 
 -- product conversion funnel
 -- conversion funnels from each product page to conversion 
 -- comparison between the two conversion funnels , for all website traffic 
 
 -- Step- select all pagviews for revelant sessions
 -- step 2 figure out which pagview url to look for 
 -- step-3 pull all pageviews and identify the funnels steps
 -- step -4 create the session-level conversion funnel view
 -- step-5 aggregate the data to asses the funnel peformance
 
 
 -- step-1 finding the pagviews for revelenat sesions
  create temporary table sessions_seeing_product_page
 select website_session_id,
 website_pageview_id,
 pageview_url as product_page_seen
 from website_pageviews 
 where  created_at < '2013-04-10'
 and created_at > '2013-01-06' 
 and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear');
 
 -- Step-2 finding the right page_view_url to build funnels
 
 select distinct website_pageviews.pageview_url
 from sessions_seeing_product_page left join website_pageviews
 on website_pageviews.website_session_id=sessions_seeing_product_page.website_session_id
 and website_pageviews.website_pageview_id > sessions_seeing_product_page.website_pageview_id;
 
-- step 3 we will look the inner query first to look over the pageview-levels results
-- then turn it in to a subquery and make it the summary with the flags

select  sessions_seeing_product_page.website_session_id,
sessions_seeing_product_page.product_page_seen,
case when website_pageviews.pageview_url='/cart' then 1 else 0 end as cart,
case when website_pageviews.pageview_url='/shipping' then 1 else 0 end as shipping,
case when website_pageviews.pageview_url='/billing-2' then 1 else 0 end as billing,
case when website_pageviews.pageview_url='/thank-you-for-your-order' then 1 else 0 end as thank_you
 from sessions_seeing_product_page left join website_pageviews
 on website_pageviews.website_session_id=sessions_seeing_product_page.website_session_id
 and website_pageviews.website_pageview_id > sessions_seeing_product_page.website_pageview_id
 order by   sessions_seeing_product_page.website_session_id,website_pageviews.created_at;
 
 -- now we will use subquery method 
 -- create temporary table session_product_level_flags
 select website_session_id,
 case 
 when product_page_seen='/the-original-mr-fuzzy' then 'mrfuzzy' 
 when product_page_seen='/the-forever-love-bear' then 'lovebear'
 else 'check' end as product_seen,
 max(cart) as cart_made_it,
 max(shipping) as shipping_made_it,
 max(billing) as billing_made_it,
 max(thank_you) as thank_you_made_it
 from 
 (select  sessions_seeing_product_page.website_session_id,
sessions_seeing_product_page.product_page_seen,
case when website_pageviews.pageview_url='/cart' then 1 else 0 end as cart,
case when website_pageviews.pageview_url='/shipping' then 1 else 0 end as shipping,
case when website_pageviews.pageview_url='/billing-2' then 1 else 0 end as billing,
case when website_pageviews.pageview_url='/thank-you-for-your-order' then 1 else 0 end as thank_you
 from sessions_seeing_product_page left join website_pageviews
 on website_pageviews.website_session_id=sessions_seeing_product_page.website_session_id
 and website_pageviews.website_pageview_id > sessions_seeing_product_page.website_pageview_id
 order by   sessions_seeing_product_page.website_session_id,website_pageviews.created_at) as page_view_level
 group by website_session_id,product_seen;
 
 -- final output part-1
 
 select product_seen,
 count(distinct website_session_id) as sessions,
 count( case when cart_made_it = 1 then website_session_id else null end) as to_cart,
 count( case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
 count( case when billing_made_it = 1 then website_session_id else null end) as to_billing,
 count( case when thank_you_made_it = 1 then website_session_id else null end) as to_thank_you
from  session_product_level_flags 
group by 1;
 
-- Cross selling products 

select orders.order_id,
orders.primary_product_id,
order_items.product_id   as cross_sell_products from orders
left join order_items on order_items.order_id  =orders.order_id 
and order_items.is_primary_item = 0  -- cross sell products
where orders.order_id between 10000 and 11000;  -- arbiratary


select 
orders.primary_product_id,
count(distinct orders.order_id) as orders ,
count(distinct case when order_items.product_id=1 then orders.order_id else null end )  as x_sell_product1,
count(distinct case when order_items.product_id=2 then orders.order_id else null end ) as x_sell_product2,
count(distinct case when order_items.product_id=3 then orders.order_id else null end ) as x_sell_product3
from orders
left join order_items on order_items.order_id  =orders.order_id 
and order_items.is_primary_item = 0  -- cross sell products
where orders.order_id between 10000 and 11000  -- arbiratary
group by 1;

-- Product portfolio expansion 
-- Recent product launch (Birthday Bear) 
-- pre-post analysis comparing the month before  vs month after 
-- session to order conversion rate 
-- average order value 
-- products per order 
-- revenue per session

select 
      case 
      when website_sessions.created_at < '2013-12-12' then 'A.pre_birthday_bear'
      when website_sessions.created_at >= '2013-12-12' then 'B.post_birthday_bear'
      else 'check_logic' end as time_period,
      count(distinct website_sessions.website_session_id) as sesssions,
      count(distinct orders.order_id) as orders,
      count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as ordr_session_conversion_rate,
      sum(orders.price_usd) as total_revenue,
      sum(orders.items_purchased) as product_purchased,
      sum(orders.price_usd)/count(distinct orders.order_id) as Average_order_value,
	  sum(orders.items_purchased)/count(distinct orders.order_id) as product_per_order,
      sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as revenue_per_sessions
      from website_sessions left join orders
      on website_sessions.website_session_id=orders.website_session_id
      where website_sessions.created_at between '2013-11-12' and '2014-01-12'
      group by 1;
      
-- Product refund analysis 

select order_items.order_id,
       order_items.order_item_id,
       order_items.price_usd,
       order_item_refunds.order_item_id,
       order_item_refunds.order_item_refund_id as Refund_order_item_id,
       order_item_refunds.refund_amount_usd
       from order_items left join order_item_refunds
       on order_items.order_item_id= order_item_refunds.order_item_id
       where order_items.order_id in (3849,32049,27061)
       ;
      
     -- Pull Monthly product refund rates 
     -- By product 
     -- confirm our quality our issues are now fixed
     
     select year(order_items.created_at),
            month(order_items.created_at),
     count(distinct case  when product_id=1 then order_items.order_item_id else null end) as product_1 ,
	 count(distinct case when product_id =1 then order_item_refunds.order_item_id else null end ) / 
      count(distinct case  when product_id=1 then order_items.order_item_id else null end) as product1_refund_rate ,
      count(distinct case  when product_id=2 then order_items.order_item_id else null end) as product_2,
      count(distinct case when product_id =2 then order_item_refunds.order_item_id else null end )/
      count(distinct case  when product_id=2 then order_items.order_item_id else null end) as product2_refund_rate,
      count(distinct case  when product_id=3 then order_items.order_item_id else null end) as product_3,
      count(distinct case when product_id =3 then order_item_refunds.order_item_id else null end )/
      count(distinct case  when product_id=3 then order_items.order_item_id else null end) as product3_refund_rate ,
      count(distinct case  when product_id=4 then order_items.order_item_id else null end) as product_4 ,
      count(distinct case when product_id =4 then order_item_refunds.order_item_id else null end )/
      count(distinct case  when product_id=4 then order_items.order_item_id else null end) as product4_refund_rate 
      from order_items left join order_item_refunds on 
      order_items.order_item_id=order_item_refunds.order_item_id
      where order_items.created_at < '2014-10-15'
      group by 1,2;
      
      -- Identifying the repeat visitors 
      -- Pull data on how many of our website  visitors come back from another sessions 
      
     -- create temporary table sessions_w_repeats
      select new_sessions.user_id,
             new_sessions.website_session_id as new_session_id,
             website_sessions.website_session_id as repeat_session_id
		from (
      select user_id,
      website_session_id
      from website_sessions
      where created_at  < '2014-11-01'-- the date of assignment
      and created_at >= '2014-01-01' -- prescribed date range in assignment
      and is_repeat_session =0 -- new_session_only 
      ) as new_sessions
      left join website_sessions
      on new_sessions.user_id=website_sessions.user_id
      and website_sessions.is_repeat_session=1
      and website_sessions.website_session_id > new_sessions.website_session_id
      and website_sessions.created_at < '2014-11-01'
      and website_sessions.created_at >= '2014-01-01'
      ;
      
      
 select repeat_sessions,
       count(distinct user_id) as users
  from (     
 select user_id,
 count(distinct new_session_id) as new_sessions,
 count(distinct repeat_session_id) as repeat_sessions
 from sessions_w_repeats	
 group by 1
 order by 3 desc 
 ) as level_up_sessions
 group by 1;
 
 -- Deeper dive on Repeat
 -- minimum,maximum and average time between first and secon session for customer who do come back 
 
--- create temporary table sessions_w_repeats_for_time_diff
 select new_sessions.user_id,
        new_sessions.website_session_id as new_session_id,
        new_sessions.created_at as new_session_created_at,
        website_sessions.website_session_id as repeat_session_id,
        website_sessions.created_at as repeat_session_created_at
        from (
 select user_id,
 website_session_id,
 created_at from website_sessions
 where created_at < '2014-11-03'
 and created_at >= '2014-01-01'
 and is_repeat_session= 0
 ) as new_sessions
 left join website_sessions
 on new_sessions.user_id=website_sessions.user_id
 and website_sessions.website_session_id > new_sessions.website_session_id
 and website_sessions.is_repeat_session=1
 and website_sessions.created_at < '2014-11-03'
 and website_sessions.created_at >='2014-01-01'
 ;
 
 create temporary table first_second_session
 select user_id,
 datediff(second_session_created_at,new_session_created_at) as days_first_to_second_sessions
 from (
 select user_id,
        new_session_id,
        new_session_created_at,
        min(repeat_session_id) as second_session_id,
        min(repeat_session_created_at) as second_session_created_at
        from sessions_w_repeats_for_time_diff
        where repeat_session_id is not null
        group by 1,2,3
        ) as first_second;
        
        select* from first_second_session;
 
 select avg(days_first_to_second_sessions) as avg_days_first_to_second_sessions,
        max(days_first_to_second_sessions) as max_days_first_to_second_sessions,
        min(days_first_to_second_sessions) as min_days_first_to_second_sessions
        from first_second_session;
 