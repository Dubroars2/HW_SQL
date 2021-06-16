--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Cделайте запрос к таблице payment. 
--Пронумеруйте все продажи от 1 до N по дате продажи.


select  p.amount, p.payment_date,
	row_number() over (partition by p.customer_id order by p.payment_date)
from payment p 


--ЗАДАНИЕ №2
--Используя оконную функцию добавьте колонку с порядковым номером
--продажи для каждого покупателя,
--сортировка платежей должна быть по дате платежа.


select c.customer_id , concat_ws(', ', c.first_name, c.last_name), p.payment_date, 
	row_number () over (partition by p.customer_id order by p.payment_date)
from customer c 
join payment p on p.customer_id = c.customer_id 





--ЗАДАНИЕ №3
--Для каждого пользователя посчитайте нарастающим итогом сумму всех его платежей,
--сортировка платежей должна быть по дате платежа.

select c.customer_id , concat_ws(', ', c.first_name, c.last_name), p.payment_date, p.amount ,
	sum(p.amount) over (partition by p.customer_id order by p.payment_date)
from customer c 
join payment p on p.customer_id = c.customer_id 




--ЗАДАНИЕ №4
--Для каждого покупателя выведите данные о его последней оплате аренде.



select p.customer_id , p.amount , p.payment_date, f.description, f.title
from payment p 
join rental r on r.rental_id  = p.rental_id 
join inventory i on i.inventory_id  = r.inventory_id 
join film f on f.film_id = i.film_id 
where p.payment_date =
	(select max(p2.payment_date) 
	from payment p2 
	where p.customer_id = p2.customer_id ) 


	




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника магазина
--стоимость продажи из предыдущей строки со значением по умолчанию 0.0
--с сортировкой по дате продажи




--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (дата без учета времени)
--с сортировкой по дате продажи




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






