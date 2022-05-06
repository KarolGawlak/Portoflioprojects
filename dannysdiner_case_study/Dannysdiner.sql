-- 1. What is the total amount each customer spent at the restaurant?
Select SUM(price) AS TotalAmount, customer_id
from sales Join menu ON (sales.product_id=menu.product_id)
group by customer_id;

-- 2. How many days has each customer visited the restaurant?
Select Count(Distinct(sales.order_date)) AS Visits, customer_id
From sales
Group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
Select customer_id,  MIN(sales.order_date) AS dateorder, sales.product_id
from sales Join menu ON (sales.product_id=menu.product_id)
group by customer_id, sales.product_id
order by dateorder;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
Select TOP 1 (count(sales.product_id)), menu.product_name
from sales join menu ON (sales.product_id=menu.product_id)
Group by menu.product_name
order by count(sales.product_id) desc;

-- 5.Which item was the most popular for each customer?
With most_popular AS 
(
Select (count(s.product_id)) as productcount, m.product_name, customer_id,
DENSE_RANK() OVER(PARTITION BY s.customer_id
Order BY COUNT(s.customer_id) DESC) AS rank
from sales AS s 
join menu AS m ON (s.product_id=m.product_id)
Group by m.product_name, customer_id
)
SELECT product_name
,customer_id
,productcount
FROM most_popular AS mp
where rank=1;
-- 6. Which item was purchased first by the customer after they became a member?
WITH membersdate AS
(SELECT s.customer_id
,m.join_date
,s.order_date
,s.product_id,
       DENSE_RANK() OVER(PARTITION BY s.customer_id 
		order by s.order_date) AS rank            
    FROM Sales s
	Join members m ON (s.customer_id=m.customer_id)
	Where s.order_date>=m.join_date
	)
	Select md.customer_id, md.order_date, me.product_name
	From membersdate as md
	Join menu as me ON (md.product_id=me.product_id)
	where rank=1;

--7. Which item was purchased just before the customer became a member?

WITH membersdate AS
(SELECT s.customer_id
,m.join_date
,s.order_date
,s.product_id,
       DENSE_RANK() OVER(PARTITION BY s.customer_id 
		order by s.order_date DESC) AS rank            
    FROM Sales s
	Join members m ON (s.customer_id=m.customer_id)
	Where s.order_date<m.join_date
	)
	Select md.customer_id, md.order_date, me.product_name
	From membersdate as md
	Join menu as me ON (md.product_id=me.product_id)
	where rank=1;

-- 8. What is the total items and amount spent for each member before they became a member?
Select SUM(price) AS TotalAmount, sales.customer_id, join_date
from sales Join menu ON (sales.product_id=menu.product_id)
Join members ON (sales.customer_id=members.customer_id)
Where order_date<join_date
group by sales.customer_id, join_date;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
-- — how many points would each customer have?
Select customer_id, 10*SUM(
Case 
WHEN product_name='sushi' THEN price*2 
WHEN product_name='curry' THEN price*1 
WHEN product_name='ramen' THEN price*1 
END) as points
FROM sales Join menu ON (sales.product_id=menu.product_id)
GROUP by customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
WITH dates_cte AS 
(
   SELECT *, 
      DATEADD(DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM members AS m
)
Select d.customer_id, SUM(
Case 
WHEN product_name='sushi' THEN price*2*10 
WHEN order_date between d.join_date AND d.valid_date THEN price*2*10 
ELSE 10*m.price
END) as points
FROM dates_cte AS d
JOIN sales AS s
   ON d.customer_id = s.customer_id
JOIN menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id;