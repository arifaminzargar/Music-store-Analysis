
/*Question Set 1*/
/*Q1.Who is the senior most employee based on job title?*/
select *
from employee
order by levels desc
limit 1;

select * from invoice;

/*2. Which countries have the most Invoices?*/
select billing_country,count(*) as c  /*count(invoice_id)*/
from invoice
group by billing_country
order by c desc;

/*3. What are top 3 values of total invoice?*/
select total
from invoice
order by total desc
limit 3;
/*Q 4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals*/

select billing_city,sum(Total) as sum_of_invoice_totals
from invoice
group by billing_city
order by sum_of_invoice_totals desc;


/*Q.5 Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money*/

select c.customer_id,c.first_name,c.last_name, sum(i.total) as money
from customer c  inner join invoice i on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by money desc
limit 1;

/*select c.customer_id,i.customer_id
from customer c left join invoice i on	c.customer_id=i.customer_id
where i.customer_id is null;*/

/*select distinct(c.customer_id), (i.customer_id)
from customer c left join invoice i on	c.customer_id=i.customer_id;*/


/*Question set 2*/
/*Q.1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
 Return your list ordered alphabetically by email starting with A*/
 #optimized
 select distinct email,first_name, last_name
 from customer c join invoice i on c.customer_id=i.invoice_id 
 join invoice_line il on il.invoice_id=i.invoice_id
 where track_id in(
 Select t.track_id
 from track t join genre g on t.genre_id=g.genre_id
WHERE g.name LIKE '%Rock%'
)
order by email;

# used multiple joins , less optimized, processing takes times as well as storing, so slow
 select distinct email,first_name, last_name
 from customer c join invoice i on c.customer_id=i.invoice_id 
 join invoice_line il on il.invoice_id=i.invoice_id
 join track t on t.track_id=il.track_id
 join genre g on t.genre_id=g.genre_id
 WHERE g.name LIKE '%Rock%'
 order by email;

/*Select t.track_id,t.genre_id,g.genre_id,g.name
 from track t join genre g on t.genre_id=g.genre_id
 where g.name like '%Rock%';*/

/*Q.2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands*/
#optimized query, less joins used
Select a.artist_id,a.name,count(t.track_id) as Total_track_count   #  or count(*),count(a.artist_id)
from track t join album al on al.album_id=t.album_id
join artist a on a.artist_id=al.artist_id
where track_id in(
 Select t.track_id
 from track t join genre g on t.genre_id=g.genre_id
WHERE g.name LIKE '%Rock%'
)
group by a.artist_id,a.name   #need to group by both artist and name so that name can be mentioned in select clause
order by Total_track_count desc
limit 10;


Select a.artist_id,a.name,count(t.track_id) as Total_track_count  #  or count(*),count(a.artist_id)
from track t join album al on al.album_id=t.album_id
join artist a on a.artist_id=al.artist_id
join genre g on g.genre_id=t.genre_id # not an optimized query as it has multiple joins which slows processing and data storing
where g.name like '%Rock%'
group by a.artist_id,a.name #need to group ny both artist and name so that name can be mentioned in select clause
order by Total_track_count desc
limit 10;



/*Select *
from track t join album2 al on al.album_id=t.album_id
join artist a on a.artist_id=al.artist_id
join genre g on g.genre_id=t.genre_id;*/

/*Q.3.Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first*/
select name,milliseconds as song_length
from track
where milliseconds >(
select avg(milliseconds) as avg_song_length #subquery makes query dynamic ,if avg value or other values  change, it adjusts
from track)
order by milliseconds desc;

select avg(milliseconds) as avg_song_length
from track;

/*# By Hardcoding
select name,milliseconds
from track
where milliseconds> 393599.2121
order by milliseconds desc;*/

/*Question Set 3 – Advance*/

/* Q.1.Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent*/
# Here we first find the best selling artist using CTE and then find how much money has been spent on that artist by the customers
With best_selling_artist AS(
select a.artist_id,a.name,sum(il.unit_price*il.quantity) as total_sales #customer spending on the best selling artist
from invoice_line il join track t on il.track_id=t.track_id join album al on al.album_id=t.album_id join artist a on a.artist_id=al.artist_id
group by 1,2
order by 3 desc
limit 1)
select c.customer_id,c.first_name,c.last_name,bsa.name,sum(il.unit_price*il.quantity) as amount_spent
from customer c join invoice i on c.customer_id = i.customer_id join invoice_line il on il.invoice_id=i.invoice_id join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;
 /*Customer spending across all artists
select c.customer_id,first_name,c.last_name,a.name,sum(il.unit_price*il.quantity) as total_sales
from customer c join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join album al on al.album_id=t.album_id
join artist a on a.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc;*/


/*Q.2.We want to find out the most popular music Genre for each country.We determine the most popular genre as the genre with the highest amount of purchases. 
      Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.*/

   
    with popular_genre as (
    select c.country,g.name,g.genre_id,count(il.quantity) as purchases, 
    row_number() over(partition by c.country order by count(il.quantity) desc) as row_no
    from customer c join invoice i on c.customer_id=i.customer_id
    join invoice_line il on il.invoice_id=i.invoice_id
    join track t on t.track_id=il.track_id
    join genre g on g.genre_id=t.genre_id
    group by 1,2,3
    order by 1 asc,4 desc)
    
    
    
    select * from popular_genre 
    where row_no <=1; # choosing the popular genre from each country, country comes once based on highest purchases so only rowno 1 comes
    
    # 2nd Method using Recursive (2nd query dependent on first query, syntax similar to CTE)
    with recursive sales_per_country As (
    select c.country,g.name,g.genre_id,count(*) as purchases
    from customer c join invoice i on c.customer_id=i.customer_id
    join invoice_line il on il.invoice_id=i.invoice_id
    join track t on t.track_id=il.track_id
    join genre g on g.genre_id=t.genre_id
    group by 1,2,3
    order by 1 asc,4 desc),
    
    max_genre_per_country As(Select max(purchases) as max_genre_no, country   # returns fewer rows say  ten for maxm purchases for a country
    from sales_per_country
    group by 2
    order by 2)
    
    select sales_per_country.* # select everything from sales_per_country
    from sales_per_country 
    join max_genre_per_country  on sales_per_country.country=max_genre_per_country.country
    where sales_per_country.purchases=max_genre_per_country.max_genre_no;
    
    /*3. Write a query that determines the customer that has spent the most on music for each country. 
    Write a query that returns the country along with the top customer and how much they spent. 
    For countries where the top amount spent is shared, provide all customers who spent this amount*/
    # using CTE, more optimized and easy
    with customer_with_country as(
    select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(i.total) as total_spending,
    row_number() over(partition by billing_country order by sum(total) desc) as row_no
    from customer c join invoice i on c.customer_id=i.customer_id
    group by 1,2,3,4
    order by 4 asc,5 desc)
    select * from customer_with_country  # we get just one value i.e highest total from each country with the customer
	where row_no <=1;  # for best practice
    
    

# using recursive

with recursive customer_with_country As(
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(i.total) as total_spend
from customer c join invoice i on c.customer_id=i.customer_id
group by 1,2,3,4
order by 1,5 desc),

customer_max_spending as( 
select billing_country,max(total_spend) as max_spend
from customer_with_country
group by 1)  # get one maximum/highest value(max spend) for a country

select cc.customer_id,cc.first_name,cc.last_name,cc.billing_country,cc.total_spend  #customer_with_country.*> everything from customer_with_country
from customer_with_country cc join customer_max_spending cms on cc.billing_country=cms.billing_country
where cc.total_spend=cms.max_spend
order by 4; #can order by 5 also ,countries won't repeat now here
