Answer 1
select distinct market from dim_customer where customer = 'Atliq Exclusive' and region = 'APAC';

Answer 2
with cte_2020 as (select product_code, count(distinct product_code) as unique_product_2020 from fact_sales_monthly where fiscal_year = 2020),
cte_2021 as (select product_code, count(distinct product_code) as unique_product_2021 from fact_sales_monthly where fiscal_year = 2021)
select unique_product_2020, unique_product_2021,concat(round((unique_product_2021 - unique_product_2020)*100/unique_product_2020,2),' ','%')
 as percentage_change 
from cte_2020 join cte_2021
on cte_2020.product_code = cte_2021.product_code;
 
 Answer 3
 select segment, count(distinct product_code) as product_count from dim_product group by segment order by product_count desc;
 
 Answer 4
 with cte_2020 as (select segment, count(distinct fact_sales_monthly.product_code) as product_count_2020 from dim_product 
 join fact_sales_monthly on dim_product.product_code = fact_sales_monthly.product_code where fiscal_year = 2020 group by segment),
 cte_2021 as (select segment, count(distinct fact_sales_monthly.product_code) as product_count_2021 from dim_product 
 join fact_sales_monthly on dim_product.product_code = fact_sales_monthly.product_code where fiscal_year = 2021 group by segment)
 select cte_2020.segment, product_count_2020, product_count_2021, (product_count_2021 - product_count_2020)
 as difference 
 from cte_2020 join cte_2021
 on cte_2020.segment = cte_2021.segment order by difference desc;
 
 Answer 5
 select dim_product.product_code, dim_product.product, manufacturing_cost from dim_product 
 join fact_manufacturing_cost
 on dim_product.product_code = fact_manufacturing_cost.product_code 
 where manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)
 or manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost) order by manufacturing_cost desc;
 
 Answer 6
  select dim_customer.customer_code, customer, concat(round((avg(fact_pre_invoice_deductions.pre_invoice_discount_pct))*100,2),' ','%')
 as average_discount_percentage from dim_customer
 join fact_pre_invoice_deductions
 on fact_pre_invoice_deductions.customer_code = dim_customer.customer_code where market = 'India' and
 fiscal_year = 2021 group by customer order by pre_invoice_discount_pct desc limit 5;
 
Answer 7
select monthname(date) as month, year(date) as year, concat(round(sum(sold_quantity*gross_price)/1000000,2),' ','M') as
gross_sales_amount_in_millions from fact_sales_monthly
join fact_gross_price on fact_sales_monthly.product_code = fact_gross_price.product_code
join dim_customer on
dim_customer.customer_code = fact_sales_monthly.customer_code
where dim_customer.customer = 'Atliq Exclusive'
group by month, year order by year;

Answer 8
Select 
      case 
          when month(date)  in  (9,10,11) then 'Q1'
          when month(date) in  (12,1,2) then 'Q2'
          when month(date) in (3,4,5) then 'Q3'
          when month(date) in (6,7,8) then 'Q4'
      end as Quarter, 
       concat(round(SUM(sold_quantity)/1000000,2),' ','M') AS total_sold_quantity_in_millions
from fact_sales_monthly
where fiscal_year = 2020
group by quarter
limit 4;

Answer 9
with cte as (Select channel, concat(round((sum(sold_quantity * gross_price))/1000000,2),' ','M') as gross_sales_in_millions from fact_gross_price 
join fact_sales_monthly 
on fact_sales_monthly.product_code = fact_gross_price.product_code 
join dim_customer
on dim_customer.customer_code = fact_sales_monthly.customer_code
where fact_sales_monthly.fiscal_year = 2021
group by channel order by gross_sales_in_millions desc)
select channel, gross_sales_in_millions, concat(round((gross_sales_in_millions/sum(gross_sales_in_millions) over()*100),2),' ','%')
as percentage from cte;

Answer 10
with cte as (select division, dim_product.product_code, concat(product," ","(",variant,")") as product,
 sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly
join dim_product
on dim_product.product_code = fact_sales_monthly.product_code where fiscal_year = 2021 group by division, dim_product.product_code, product),
cte1 as (select *, dense_rank() over (partition by division order by total_sold_quantity desc) as rank_order from cte)
select * from cte1 where rank_order <= 3;
