--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select c.customer_id , concat_ws(', ', c.first_name, c.last_name) as "Name", a.address , c2.country, c3.city
from customer c 
left join address a on a.address_id = c.address_id 
left join city c3 on c3.city_id  = a.city_id 	
left join country c2 on c2.country_id  = c3.country_id 



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select c.store_id, count(c.customer_id) as count_customer
from customer c 
group by c.store_id 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select c.store_id, count(c.customer_id) as count_customer
from customer c 
group by c.store_id 
having count(c.customer_id) > 300



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.



select concat_ws(', ', s.first_name,s.last_name ) as name_staff, c.city
from staff s 
left join address a on a.address_id = s.address_id
left join city c on c.city_id = a.city_id 
where s.store_id  in (
	select c.store_id
	from customer c 
	group by c.store_id 
	having count(c.customer_id) > 300)






--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов


	


select r.customer_id, count(1) as film_count 
from inventory i 
join rental r on r.inventory_id  = i.inventory_id 
group by r.customer_id
order by film_count asc limit 5



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма




select r.customer_id, count(i.film_id) as film_count, round(sum(p.amount),0) as total_payment, min(p.amount) as min_payment, max(p.amount) max_payment
from inventory i 
join rental r on r.inventory_id  = i.inventory_id 
join payment p  on p.rental_id  = r.rental_id 
group by r.customer_id
order by film_count asc 



--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 

select c.city, c2.city 
from city c 
cross join city c2 
where c.city <> c2.city 

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 

select r.customer_id, avg( (r.return_date::date - r.rental_date::date))
from rental r 
group by r.customer_id 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.





--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".







