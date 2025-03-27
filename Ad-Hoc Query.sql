-- Ad-Hoc Querying:

-- 1.Update the store table such that all stores have the opening date on or after 1-Jan-2014, Populate random dates
select count(*) from DIMSTORE
where year(storeopeningdate)< 2014;
-- 1 65

select datediff(day,'2014-01-01','2024-12-31');
-- 4017

select dateadd(day,uniform(0,3950,random()),'2014-01-01');
-- no opening date in last 60 days

update dimstore 
set storeopeningdate = dateadd(day,uniform(0,3950,random()),'2014-01-01');
commit;
-- 2. update store table such that the stores with ID betweem 191-200 is opened in last 12 months
select* from Dimstore where storeid between 191 and 200;
select dateadd(day,uniform(0,360,random()),'2023-12-31');
update dimstore 
set storeopeningdate = dateadd(day,uniform(0,360,random()),'2023-12-31')
where storeid between 191 and 200;
commit;

-- 3.Update customer table such that all customers are atleast 18 years. If not subtract 18 years from their data of birth and update . 
select DATEADD(YEAR, -18, '2024-12-31');
-- find out how many are below 18 years
SELECT *, (2024 - year(dateofbirth) ) as AGE
FROM DimCustomer
where AGE < 18;
-- where DateOfBirth > DATEADD(YEAR, -18, '2024-12-31');
-- 3427
-- Update their data of birth
update DimCustomer 
set DateOfBirth = DATEADD(YEAR,-18,'2024-12-31')
where DateOfBirth >= DATEADD(YEAR, -18, '2024-12-31');
commit;

-- 4. Update the DateID in the order table for rows where the date precedes the store's opening date, ensuring it is replaced with a random DateID after the store's opening.
-- Identify the records with issue

select F.ORDERID,F.dateid,D.DATE,S.storeid,S.storeopeningdate from factorders F
join dimdate D on F.dateid = D.dateid
join dimstore S on F.storeid = S.storeid
where D.date < S.storeopeningdate;
-- 709
-- Identify valid date that can be entered
select F.orderid,D.date ,S.storeopeningdate,datediff(day,D.date,S.storeopeningdate) as diff
from factorders F
join dimdate D on F.dateid = D.dateid
join dimstore S on F.storeid = S.storeid
where D.date < S.storeopeningdate;
-- count 709

update factorders F
set F.dateid = r.dateid 
from (select orderid, D.dateid
from (select F.orderid,S.storeopeningdate,dateadd(day,datediff(day,S.storeopeningdate,'2024-12-31')* uniform(1,10,random())*.1,S.storeopeningdate) as new_date
from factorders F
join dimdate D on F.dateid = D.dateid
join dimstore S on F.storeid = S.storeid
where D.date < S.storeopeningdate) new
join dimdate D on new.new_date = D.date)r
where f.orderid = r.orderid;

-- 5. list customers who didnt place any order in last 30 days
select * from dimcustomer C
where customerid not in (select distinct C.customerid from dimcustomer C
join factorders F on C.customerid = F.customerid
join dimdate D on F.dateid = D.dateid
where d.date >= dateadd(month,-1,'2024-12-31'))
-- 56ms

with cust_30 as(
select distinct C.customerid from dimcustomer C
join factorders F on C.customerid = F.customerid
join dimdate D on F.dateid = D.dateid
where d.date >= dateadd(month,-1,'2024-12-31')
)
select c.* from dimcustomer C
left join cust_30 on c.customerid = cust_30.customerid
where cust_30.customerid is null;
-- 9000 customers in last 30 days took 83ms

-- 6. List the stores that was opened recently along with its sales since then
-- Find the store opened recently
--Option 1 3 layer CTE
with storerank as(
select storeid,storeopeningdate, row_number() over (order by storeopeningdate desc) as final_rank from dimstore 
),
most_recent_store as (
select storeid from storerank where final_rank = 1
),
store_amount as (
select f.storeid, sum(totalamount) as Total_Sales from factorders f 
join most_recent_store m on f.storeid = m.storeid
group by f.storeid
)
select s.*,a.Total_Sales from dimstore s
join store_amount a on s.storeid = a.storeid

-- option 2
WITH recent_store AS (
    SELECT storeid, storeopeningdate
    FROM dimstore
    QUALIFY ROW_NUMBER() OVER (ORDER BY storeopeningdate DESC) = 1
),
store_sales AS (
    SELECT f.storeid, SUM(totalamount) AS total_sales
    FROM factorders f
    JOIN recent_store rs ON f.storeid = rs.storeid
    group by f.storeid
    )
SELECT s.*, ss.total_sales
FROM dimstore s
JOIN store_sales ss ON s.storeid = ss.storeid;

-- Option 3 
SELECT s.*,
	(SELECT SUM(f.totalamount)
	 FROM factorders f
	 WHERE f.storeid = s.storeid) AS total_sales
FROM dimstore s
QUALIFY ROW_NUMBER() OVER (ORDER BY s.storeopeningdate DESC) = 1;

-- 7. Find customers who have ordered products from more than 3 categories in the last 6 months
with six_month_product as (
select f.customerid,p.productid,p.category from factorders f 
join dimdate d on d.dateid = f.dateid
join dimproduct p on p.productid = f.productid 
where d.date >= dateadd(month,-6,'2024-12-31')
) 
select c.customerid, c.firstname,c.lastname , count (distinct smp.category)as category from dimcustomer c 
join six_month_product smp on c.customerid = smp.customerid
group by c.customerid, c.firstname,c.lastname
having count (distinct smp.category)>3
-- total 1000 customers

--8. Get montly total sales for  year 2024
select month(d.date), sum(f.totalamount) as Total_sales  from factorders f
join dimdate d on d.dateid = f.dateid
where year(d.date) =  2024
group by month(d.date)
order by month(d.date)

-- 9. Find the highest discount given on any order last year
select f.* from factorders f
join dimdate d on d.dateid = f.dateid 
where year(d.date) = 2024
qualify row_number() over(order by f.discountamount desc) = 1

-- 10. Calculate Total sales by multiplying unit price from product column with quantity ordered from factorders
select sum(f.quantityordered * p.unitprice) as Totalsales from factorders f 
join dimproduct p on p.productid = f.productid

-- 11. Show customer id of customer who has taken he maximum discount their entire lifetime
select customerid, sum(discountamount) as max_discount from factorders
group by customerid
order by sum(discountamount) desc
limit 1

-- or
select customerid, sum(discountamount) as max_discount from factorders
group by customerid
qualify row_number() over (order by sum(discountamount) desc) = 1
-- ans = 208 id 

-- 12. List customers who have placed ma orders till date
select customerid, count(orderid) as max_order from factorders
group by customerid
qualify row_number() over (order by max_order desc) = 1

-- 13. Top 3 brands based on sales
select p.brand, sum(f.totalamount) as sales from factorders f 
join dimdate d on d.dateid = f.dateid
join dimproduct p on p.productid = f.productid
where year(d.date)= 2024
group by brand
qualify row_number() over (order by sales desc) >= 3

-- 14. If we fix the discount amount to a flat 5% and the shipping cost to a flat 8%, will the sum of the new 
--total amounts (based on this new fixed logic) be greater than the current total amount we already have in the data?
select case when sum(orderamount - (orderamount*.05)-(orderamount*0.08)) > sum(totalamount) then 'yes' else 'no' end 
from factorders

-- 15. Share Number of customers and their current loyalty program status
select count(distinct c.customerid), l.LOYALTYPROGRAMID from dimcustomer c
join dimloyaltyprogram l on c.loyaltyprogramid = l.loyaltyprogramid
group by l.loyaltyprogramid

-- 16. show the region category wise total amount for the last 6 months

select sum(f.totalamount),s.region,p.category from factorders f
join dimdate d on d.dateid = f.dateid
join dimproduct p on p.productid = f.productid
join dimstore s on s.storeid = f.storeid
where d.date >= dateadd(month,-6,'2024-12-31')
group by s.region, p.category

-- 17 Show top 5 products based on quantity ordered in last 5 years
with basedata as (
select  p.productID, sum(f.quantityordered) as salesqty,rank() over (order by salesqty desc) as rank from factorders f
join dimdate d on d.dateid = f.dateid
join dimproduct p on p.productid = f.productid
where d.date >= dateadd(year,-5,'2024-12-31')
group by p.productID
qualify rank <= 5
)
select b.*,p.productname from basedata b
join dimproduct p on b.productID = p.productID
order by b.rank 
-- 18. List the total amount for each loyalty program tier since 2023

with basedata as (
select  c.loyaltyprogramid, sum(f.totalamount) as sales,from factorders f
join dimdate d on d.dateid = f.dateid
join dimcustomer c on c.customerid = f.customerid
where year(d.date) >= 2023
group by c.loyaltyprogramid
)
select b.*,l.programname from basedata b
join dimloyaltyprogram l on b.loyaltyprogramid = l.loyaltyprogramid
order by b.sales desc

-- 19. Calcuate revenue generate by each manager in june 2024
select  s.Managername, sum(f.totalamount) as sales,from factorders f
join dimdate d on d.dateid = f.dateid
join dimstore s on s.storeid = f.storeid
where year(d.date)=2024 and month (d.date) = 6
group by s.Managername

-- 20. List the average order amount per store along with store name and type for year 2024
select  s.storename,s.storetype, avg(f.orderamount) as orders,from factorders f
join dimdate d on d.dateid = f.dateid
join dimstore s on s.storeid = f.storeid
where d.year=2024 
group by s.storename,s.storetype

--QUERYING CSV FILES IN STAGE
-- 21 Query data from customer csv file
-- select $column name or number
select $1,$2,$3
from
-- write the folder name with correct case. this is case sensitive
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimCustomer/DimCustomerdata.csv
(File_format=> 'SOURCE_FILE_FORMAT')

-- 22 aggregate data from customer csv file

select count($1)
from
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimCustomer/DimCustomerdata.csv
(File_format=> 'SOURCE_FILE_FORMAT')

-- 23 Filterdata from Dimcustomerdata where  customer DOB after Jan 1st 2000
-- we cannot use Select * here beacuse the file in stage are unstructured
select $1,$2,$3,$4,$5
from
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimCustomer/DimCustomerdata.csv
(File_format=> 'SOURCE_FILE_FORMAT')
where $4 >='2000-01-01'

-- 24 show customer name with their loyalty program joining csv files from stage
with customerdata as (
select $1 as Firstname, $11 as loyaltyprogramid
from
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimCustomer/DimCustomerdata.csv
(File_format=> 'SOURCE_FILE_FORMAT')
),
loyaltydata as (
select $1 as loyaltyprogramid, $3 as programtier
from
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimLoyaltyInfo/DimLoyaltyInfo.csv
(File_format=> 'SOURCE_FILE_FORMAT')
)
select Firstname, programtier from customerdata c 
join loyaltydata l on c.loyaltyprogramid = l.loyaltyprogramid

-- 25 show number of custoers under each program tier

with customerdata as (
select $1 as Firstname, $11 as loyaltyprogramid
from
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimCustomer/DimCustomerdata.csv
(File_format=> 'SOURCE_FILE_FORMAT')
),
loyaltydata as (
select $1 as loyaltyprogramid, $3 as programtier
from
@RETAIL_DB.RETAIL_DB_SCHEMA.RETAIL_STAGE/DimLoyaltyInfo/DimLoyaltyInfo.csv
(File_format=> 'SOURCE_FILE_FORMAT')
)
select count(Firstname), programtier from customerdata c 
join loyaltydata l on c.loyaltyprogramid = l.loyaltyprogramid
group by programtier


