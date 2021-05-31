select f.title , l."name" 
from film f 
inner join "language" l on l.language_id = f.language_id 

select f.title, a.last_name 
from actor a 
left join film_actor fa on fa.actor_id  = a.actor_id 
left join film f on f.film_id  = fa.film_id 



select sum(amount) from payment p 

select 
count(customer_id) as count,
count(distinct customer_id ) as count_distinct
from payment p 

select avg(amount) from payment p 

select string_agg(title, ',') --в одну строчку все 
from film f 
where film_id  < 3

select customer_id ,
count(payment_id) as activity
from payment p 
group by customer_id 
order by activity
desc limit 5

select customer_id , date_trunc('month', payment_date) as payment_date,
count(payment_id) as activity
from payment p 
group by 1,2
order by activity
desc limit 5


select customer_id , avg(amount) as avg_amount 
from payment p 
group by customer_id 
having avg(amount) > 5 -- фильтр/ то есть отсавляет только тех/ у кого средний чек больше 5
limit 5

список фильмов где снимались больше 10 актеров

select f.title , count( fa.actor_id), f.description 
from film f 
inner join film_actor fa on fa.film_id  = f.film_id
group by f.film_id 
having count(fa.actor_id) > 10  
limit 5

select customer_id , sum(amount),
	case 
		when sum(amount) > 200 then 'Good user'
		when sum(amount) < 200 then 'bad user'
		else 'Average user'
	end 
from payment p 
group by customer_id 
order by sum(amount) desc 
limit 5

from payment p 
