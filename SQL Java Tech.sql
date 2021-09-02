--Obtain all orders for the customer named Cisnerous. (Assume you don't know his customer no. (cnum)).
select a.CNAME, b.ONUM, a.CNUM, b.CNUM  from CUST AS a 
inner join ORDERS as b
on a.CNUM = b.CNUM
where a.CNAME = 'Cisnerous'

--Produce the names and rating of all customers who have above average orders.
select a.CNAME, a.RATING, b.AMT from CUST as a
inner join ORDERS as b
on a.CNUM = b.CNUM
where b.AMT > (select AVG(AMT) from ORDERS)

--Find total amount in orders for each salesperson for whom this total is greater than the amount of the largest order in the table.
with TotalData(Total, SNAME) AS 
(select SUM(a.AMT) AS Total, b.SNAME AS SNAME from ORDERS as a
inner join SALESPEOPLE as b
on a.SNUM = b.SNUM
group by b.SNAME)

select Total, SNAME from TotalData where (Total > (select max(AMT) from ORDERS))

--Find all customers with order on 3rd Oct.
select a.CNAME, b.ODATE, a.CNUM from CUST AS a 
inner join ORDERS as b
on a.CNUM = b.CNUM
where b.ODATE = '1994-10-03'

--Find names and numbers of all salesperson who have more than one customer.
Select SNAME, SNUM from SALESPEOPLE
where SNUM in ( select SNUM from CUST
group by SNUM having count(SNUM) > 1 );

--Check if the correct salesperson was credited with each sale.
Select ONUM, a.CNUM, a.SNUM, b.SNUM from ORDERS a, CUST b
where a.CNUM = b.CNUM and a.SNUM != b.SNUM;

--Find all orders with above average amounts for their customers.
select ONUM, CNUM, AMT from ORDERS a where AMT > (  select avg(AMT)
from orders b where a.CNUM = b.CNUM group by CNUM);


--Find the sums of the amounts from order table grouped by date, eliminating all those dates where the sum was 
--not at least 2000 above the maximum amount.
select ODATE,sum(AMT) from ORDERS a group by ODATE
having sum(AMT) > (select max(AMT) from ORDERS b
where a.ODATE=b.ODATE group by ODATE)


--Find all salespeople who have customers in their cities who they don't service. ( Both way using Join and Correlated subquery.)
select distinct CNAME from CUST a,SALESPEOPLE b where a.CITY=b.CITY and a.SNUM!=b.SNUM
select cname from CUST where CNAME in (select CNAME from CUST a, SALESPEOPLE b where a.CITY=b.CITY and a.SNUM!=b.SNUM) 

--Extract cnum,cname and city from customer table if and only if one or more of the customers in the table are located in San Jose.
 Select * from CUST where 2 < (select count(*) from cust where city = 'San Jose');

 --Find salespeople no. who have multiple customers.
Select SNUM from CUST group by SNUM having count(*) > 1

--Find salespeople number, name and city who have multiple customers.
 select SNUM,SNAME,CITY from SALESPEOPLE where SNUM in (select SNUM FROM CUST group by SNUM having COUNT(*) > 1)

--Find salespeople who serve only one customer.
Select SNUM from CUST group by SNUM having count(*) = 1

--Extract rows of all salespeople with more than one current order.
select SNUM,count(ONUM) FROM ORDERS GROUP BY SNUM HAVING COUNT(SNUM) > 1

--Find all salespeople who have customers with a rating of 300. (use EXISTS)
Select a.snum from salespeople a
where exists ( select b.snum from cust b
where b.rating = 300 and a.snum = b.snum)

--Find all salespeople who have customers with a rating of 300. (use Join).
Select a.snum from salespeople a, cust b
where b.rating = 300 and a.snum = b.snum

--Select all salespeople with customers located in their cities who are not assigned to them. (use EXISTS).
select snum,sname from SALESPEOPLE where exists (select cnum from cust where salespeople.CITY=CUST.CITY and SALESPEOPLE.SNUM!=CUST.SNUM) 

--Extract from customers table every customer assigned the a salesperson 
--who currently has at least one other customer ( besides the customer being selected) with orders in order table.
Select a.cnum, max(c.cname) from orders a, cust c 
where a.cnum = c.cnum group by a.cnum,a.snum having count(*) < ( select count(*)
from orders b where a.snum = b.snum) order by a.cnum;

--Find salespeople with customers located in their cities ( using both ANY and IN).
select SNAME from SALESPEOPLE where SNUM in (select SNUM from CUST where SALESPEOPLE.CITY=CUST.CITY and SALESPEOPLE.SNUM=CUST.SNUM)
select SNAME from SALESPEOPLE where SNUM = ANY (select SNUM from CUST where SALESPEOPLE.CITY=CUST.CITY and SALESPEOPLE.SNUM=CUST.SNUM)

--Find all salespeople for whom there are customers that follow them in alphabetical order. (Using ANY and EXISTS)
Select sname from salespeople where sname < any ( select cname
from cust where salespeople.snum = cust.snum);

Select sname from salespeople where exists ( select cname
from cust where salespeople.snum = cust.snum and
salespeople.sname < cust.cname);

--Select customers who have a greater rating than any customer in rome.
select cnum from CUST where CITY='rome' and RATING > (select max(rating) from CUST where CITY!= 'rome')

--Select all orders that had amounts that were greater that atleast one of the orders from Oct 6th.
select onum,AMT,odate from ORDERS where ODATE!='06-oct-94' and AMT > (select min(amt) from ORDERS where ODATE='06-oct-94') 

--Find all orders with amounts smaller than any amount for a customer in San Jose. (Both using ANY and without ANY)
select onum,amt from ORDERS  where AMT < (select max(amt) from ORDERS,cust where ORDERS.SNUM=CUST.SNUM and CITY='san jose')


--Find all salespeople who have no customers located in their city. ( Both using ANY and ALL)
Select sname from salespeople where snum in ( select snum
from cust where salespeople.city != cust.city and
salespeople.snum = cust.snum);

--Find all orders for amounts greater than any for the customers in London.
select onum,amt from ORDERS where amt > any (select amt from ORDERS,CUST where ORDERS.CNUM=CUST.CNUM and CUST.CITY='London')

--Find all salespeople and customers located in london.
select sname,cname from SALESPEOPLE,CUST where SALESPEOPLE.CITY='london' and cust.CITY='london' and CUST.SNUM=SALESPEOPLE.SNUM

--List all of the salespeople and indicate those who don't have customers in their cities as well as those who do have.
Select snum, city, 'Customer Present' from salespeople a
where exists ( select snum from cust where a.snum = cust.snum and
a.city = cust.city) UNION select snum, city, 'Customer Not Present' from salespeople a
where exists ( select snum from cust c where a.snum = c.snum and a.city != c.city and
c.snum not in ( select snum from cust where a.snum = cust.snum and a.city = cust.city));

--Create a union of two queries that shows the names, cities and ratings of all customers. 
--Those with a rating of 200 or greater will also have the words 'High Rating', while the others will have the words 'Low Rating'.
Select cname, city, rating, 'Higher Rating' from cust where rating >= 200
UNION Select cname, city, rating, 'Lower Rating' from cust where rating < 200;

--Produce all the salesperson in London who had at least one customer there.
Select snum, sname from salespeople where snum in ( select snum
from cust where cust.snum = salespeople.snum and
cust.city = 'London') and city = 'London';

--Produce all the salesperson in London who did not have customers there.
Select snum, sname from salespeople
where snum in ( select snum from cust where cust.snum = salespeople.snum and
cust.city = 'London') and city = 'London';

--We want to see salespeople matched to their customers without excluding those salesperson
--who were not currently assigned to any customers. (User OUTER join and UNION)
Select sname, cname from cust, salespeople
where cust.snum = salespeople.snum UNION select distinct sname, 'No Customer'
from cust, salespeople where 0 = ( select count(*)
from cust where cust.snum = salespeople.snum);