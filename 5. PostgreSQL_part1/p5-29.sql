explain analyze
select customer_id, s.address_id
from customer c
left join store s on s.store_id = c.store_id

explain analyze
select distinct customer_id, s.address_id
from customer c
left join store s on s.store_id = c.store_id

explain analyze
select c.customer_id, count(p.rental_id)
from customer c 
join payment p on p.customer_id = c.customer_id
join rental r on r.customer_id = c.customer_id
group by c.customer_id
order by c.customer_id

select count(c.customer_id)
from customer c 
join payment p on p.customer_id = c.customer_id
join rental r on r.customer_id = c.customer_id

select count(c.customer_id)
from customer c 
join payment p on p.customer_id = c.customer_id
join rental r on p.customer_id = c.customer_id and r.rental_id = p.rental_id


select count(c.customer_id)
from customer c 
group by store_id, address_id
having count(c.customer_id) > 100

select count(c.customer_id)
from customer c 
join payment p on p.customer_id = c.customer_id
group by store_id
having count(c.customer_id) > 100

select c.store_id, count(c.customer_id), p.payment_id
from customer c 
join payment p on p.customer_id = c.customer_id
group by store_id, p.payment_id
having count(c.customer_id) > 100

select pg_typeof('05/01/2021 00:00:00'::timestamp - '01/01/2021 00:00:00'::timestamp)

select pg_typeof('12:00:00'::time - '03:00:00'::time)

select '12:00:00'::time - '03:00:00'::time

select '05/01/2021 12:00:00'::date - '01/01/2021 00:00:00'::date

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE ��� WITH ROLLUP
HAVING
SELECT
OVER
DISTINCT
ORDER BY

============= Оконные функции =============

1. Вывести ФИО пользователя и название третьего фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате арнеды
* Задайте окно с использованием предложений over, partition by � order by
* Соедините с  customer
* Соедините с inventory
* Соедините с  film
* 3 фильма по порядку 


-- row_number() позваляет поставить порядковые номера


select user_name, title
from (
	select concat(c.last_name, ' ', c.first_name) as user_name, f.title, r.rental_date,
		row_number() over (partition by c.customer_id order by r.rental_date)
	from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id) t
where row_number = 3

1.1. Выведите табоицу, содержащую имена покупателей , арендованные ими фильмы и средний платеж каждого покупателя 
* Используйте таблицу customer
* Соедините с paymen
* Соедините с  rental
* Соедините с  inventory
* Соедините с  film
* avg - функция, сред значение
* адайте окно с использованием предложений over � partition by

select concat(c.last_name, ' ', c.first_name), f.title, 
	avg(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5

select count(c.customer_id)
from customer c 
group by store_id -- 2 строки

select count(c.customer_id) over (partition by store_id)
from customer c -- 599 строк


-- демонстрация агрегатных функций
select concat(c.last_name, ' ', c.first_name), f.title, 
	avg(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id),
	min(p.amount) over (partition by c.customer_id),
	max(p.amount) over (partition by c.customer_id),
	count(p.amount) over (partition by c.customer_id),
	avg(p.amount) over (),
	sum(p.amount) over (),
	min(p.amount) over (),
	max(p.amount) over (),
	count(p.amount) over ()
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id

-- Работа функций lead и lag, замена null. Lead работает со следующими строками от текущей/ лаг с предыдущими
select concat(c.last_name, ' ', c.first_name), p.payment_date, 
	lag(p.amount) over (partition by c.customer_id order by p.payment_date),
	p.amount,
	lead(p.amount) over (partition by c.customer_id order by p.payment_date),
	(p.amount - lag(p.amount) over (partition by c.customer_id order by p.payment_date)) as delta
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5


---можем указать шаг lag(p.amount, 3) шаг 3.Насколько строк будем уходить вперед или назад
select concat(c.last_name, ' ', c.first_name), p.payment_date, 
	lag(p.amount, 3) over (partition by c.customer_id order by p.payment_date),
	p.amount,
	lead(p.amount, 3) over (partition by c.customer_id order by p.payment_date)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5

explain analyze
select concat(c.last_name, ' ', c.first_name), p.payment_date, 
	coalesce(lag(p.amount, 3) over (partition by c.customer_id order by p.payment_date), 0),
	p.amount,
	coalesce(lead(p.amount, 3) over (partition by c.customer_id order by p.payment_date), 0)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5 --1371.54

explain analyze
select concat(c.last_name, ' ', c.first_name), p.payment_date, 
	lag(p.amount, 3, 0.) over (partition by c.customer_id order by p.payment_date),
	p.amount,
	lead(p.amount, 3, 0.) over (partition by c.customer_id order by p.payment_date)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5 --1371.54

select  date_trunc('week', p.payment_date), 
	lag(sum(p.amount)) over (),
	sum(p.amount),
	lead(sum(p.amount)) over (),
	(sum(p.amount) - lag(sum(p.amount)) over ()) as delta
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
group by date_trunc('week', p.payment_date)

-- Формирование накопительного итога
select  concat(c.last_name, ' ', c.first_name), p.payment_date, p.amount,
	sum(p.amount) over (partition by c.customer_id order by p.payment_date desc)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id

select  concat(c.last_name, ' ', c.first_name), p.payment_date, p.amount,
	sum(p.amount) over (partition by c.customer_id order by p.payment_date desc)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id

select date_trunc('week', p.payment_date), sum(p.amount),
	sum(sum(p.amount)) over (order by date_trunc('week', p.payment_date))
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
group by date_trunc('week', p.payment_date)

select  c.customer_id, p.payment_date, p.amount,
	sum(p.amount) over (partition by c.customer_id order by p.payment_date rows current row)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.payment_date::date = '14/05/2007'
order by 1

select version()

select  c.customer_id, p.payment_date, p.amount,
	sum(p.amount) over (partition by c.customer_id order by p.payment_date range between '3 days' preceding and '3 days' following)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
order by 1

-- Работа с рангами и порядковыми номерами, rank, value
select concat(c.last_name, ' ', c.first_name), f.title, date_trunc('month', p.payment_date),
	row_number() over (partition by c.customer_id order by p.payment_date),
	rank() over (partition by c.customer_id order by date_trunc('month', p.payment_date)),
	dense_rank() over (partition by c.customer_id order by date_trunc('month', p.payment_date))
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5

select concat(c.last_name, ' ', c.first_name), f.title, p.amount, p.payment_date,
	first_value(p.amount) over (partition by c.customer_id order by p.payment_date),
	last_value(p.amount) over (partition by c.customer_id)
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on p.rental_id = r.rental_id
where p.amount > 5
order by c.customer_id, 2

1.2 Одним запросм ответить на два вопроса
1/ в какой из месяцев взяли в аренду фильмов больше всегоё
2/ на сколько по отношению к предыддущему месяцу (когда велась деятельность) было сдано больше/меньше фильмов

select dr, delta, max(dr) filter (where mr = cr) over (), mr, cr
from (
	select count(r.rental_id) cr, date_trunc('month', r.rental_date) dr,
		lag(count(r.rental_id)) over (order by date_trunc('month', r.rental_date)) lr,
		count(r.rental_id) - lag(count(r.rental_id)) over (order by date_trunc('month', r.rental_date)) delta,
		max(count(r.rental_id)) over () mr
	from rental r
	group by date_trunc('month', r.rental_date)) t

============= Общие табличные выражения ]сте =============

2.  При помощи CTE �Выведите таблицу со следующим содеражанием:
�Название фильма продолжительностью более 3 и к какой категории относится фильм
* Создайет CTE:
 - Используйте таблицу film
 - Отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category
 -- показать отличие работы CTE � 10 � 12 postgre

--cte просто название этой стешки/ можно любое
with cte as (
	select f.film_id, f.title
	from film f
	where f.length > 180
)
select cte.title, c.name
from cte
join film_category fc on fc.film_id = cte.film_id
join category c on c.category_id = fc.category_id

explain analyse

with cte as (
	select f.film_id, f.title
	from film f
	where f.length > 180
)
select cte.title, c.name
from cte
join film_category fc on fc.film_id = cte.film_id
join category c on c.category_id = fc.category_id

select version()

-- 10 ������ 89.39
-- 12 ������ 87.11

2.1. Выведите фильм, с категорией начинающейся с буквы "C"
* Создайте CTE:
 -используйте таблицу category
 - отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

with cte_1 as (
	select f.film_id, f.title
	from film f
), cte_2 as (
	select fc.film_id, fc.category_id 
	from film_category fc
), cte_3 as (
	select c.category_id, c.name
	from category c
	where name ilike 'c%')
select cte_1.title, cte_3.name
from cte_1
join cte_2 on cte_2.film_id = cte_1.film_id
join cte_3 on cte_3.category_id = cte_2.category_id

 ============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии(т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсиваня часть опираться на данные с предыдущей итерации и иметь условие остановка
 + Напишите запрос кCTE

with recursive r as (
	-- стартовая часть 
	select 1 as i, 1 as factorial
	union 
	-- рекурсивная часть
	select i + 1 as i, factorial * (i + 1) as factorial
	from r
	where i < 10
)
select *
from r

create table geo ( 
	id int primary key, 
	parent_id int references geo(id), 
	name varchar(1000) );

insert into geo (id, parent_id, name)
values 
	(1, null, 'Планета земля'),
	(2, 1, 'Континент Евразия'),
	(3, 1, 'Континент Северная Америка'),
	(4, 2, 'Европа'),
	(5, 4, 'Россия'),
	(6, 4, 'Германия'),
	(7, 5, 'Москва'),
	(8, 5, 'Ростов'),
	(9, 6, 'Берлин');

select * from geo g order by id

with recursive r(a, b, c) as (
	-- ��������� �����
	select g.id, g.parent_id, g."name", 1 as level
	from geo g
	where id = 5
	union 
	-- ����������� �����
	select geo.id, geo.parent_id, geo.name, level + 1 as level 
	from r
	join geo on geo.parent_id = r.a
)
select *
from r

with recursive r(a, b, c) as (
	-- ��������� �����
	select g.id, g.parent_id, g."name", 1 as level
	from geo g
	where id = 5
	union 
	-- ����������� �����
	select geo.id, geo.parent_id, geo.name, level + 1 as level 
	from r
	join geo on geo.id = r.b
)
select *
from r
where level < 4 

3.2 Работа с рядами

explain analyze
with recursive r as (
	-- ��������� �����
	select date('01/01/2021') as x
	union 
	-- ����������� �����
	select x + 1 as x
	from r
	where x < '02/02/2021'
)
select *
from r --3.57

explain analyze
select generate_series(date('01/01/2021'), date('02/02/2021'), interval '1 day') --5.02

======== Тестовое задание =========

Работа с рядами:

create table test (
	date_event timestamp,
	field varchar(50),
	old_value varchar(50),
	new_value varchar(50)
)

insert into test (date_event, field, old_value, new_value)
values
('2017-08-05', 'val', 'ABC', '800'),
('2017-07-26', 'pin', '', '10-AA'),
('2017-07-21', 'pin', '300-L', ''),
('2017-07-26', 'con', 'CC800', 'null'),
('2017-08-11', 'pin', 'EKH', 'ABC-500'),
('2017-08-16', 'val', '990055', '100')

select * from test order by date(date_event)

В данной таблице хранят информацию "статуса" для каждого типа поля (field ). 
То есть, есть поле pin, на 21.07.2017 было изменено значение,соответственно новое значение (new_value ) стало '' (пуста строчка) и старое 
(old_value), записано '300-L'.
Старое 26.07.2017 изменили значение с  '' (пустая строчка) на '10-AA'.И так по разным полям в разные даты ыбли какие-то изменения значений.

Задача: составить запрос таким образом, что бы в новой результирующей таблице был календарь изменения значений для каждогполя. 
�Всего три столбца: дата, поле, текущий статус.
То есть для каждого поля будет отображение каждого дня с отображением текущего статуса. 
К примеру, для поля pin на 21.07.2017 статус будет  '' (пустая строчка), на 22.07.2017 -  '' (������ ������). � �.�. �� 26.07.2017, ��� ������ ������ '10-AA'

Решение должно быть универсальным для любого SQL, не только под PostgreSQL ;)

select version()

explain analyze --8 000 000
select
	gs::date as change_date,
	fields.field as field_name,
	case 
		when (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event = gs::date) is not null 
			then (
				select new_value 
				from test t 
				where t.field = fields.field and t.date_event = gs::date)
		else (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event < gs::date 
			order by date_event desc 
			limit 1) 
	end as field_value
from 
	generate_series((select min(date(date_event)) from test), (select max(date(date_event)) from test), interval '1 day') as gs, 
	(select distinct field from test) as fields
order by 
	field_name, change_date
	
explain analyze --93 000	
select
	distinct field, gs, first_value(new_value) over (partition by value_partition)
from
	(select
		t2.*,
		t3.new_value,
		sum(case when t3.new_value is null then 0 else 1 end) over (order by t2.field, t2.gs) as value_partition
	from
		(select
			field,
			generate_series((select min(date_event)::date from test), (select max(date_event)::date from test), interval '1 day')::date as gs
		from test) as t2
	left join test t3 on t2.field = t3.field and t2.gs = t3.date_event::date) t4
order by 
	field, gs

explain analyze --2616
with recursive r(a, b, c) as (
    select temp_t.i, temp_t.field, t.new_value
    from 
	    (select min(date(t.date_event)) as i, f.field
	    from test t, (select distinct field from test) as f
	    group by f.field) as temp_t
    left join test t on temp_t.i = t.date_event and temp_t.field = t.field
    union all
    select a + 1, b, 
    	case 
    		when t.new_value is null then c
    		else t.new_value
		end
    from r  
    left join test t on t.date_event = a + 1 and b = t.field
    where a < (select max(date(date_event)) from test)
)    
SELECT *
FROM r
order by b, a

explain analyze --476
with recursive r as (
 	--��������� ����� ��������
 	 	select
 	     	min(t.date_event) as c_date
		   ,max(t.date_event) as max_date
	from test t
	union
	-- ����������� �����
	select
	     r.c_date+ INTERVAL '1 day' as c_date
	    ,r.max_date
	from r
	where r.c_date < r.max_date
 ),
t as (select t.field
		, t.new_value
		, t.date_event
		, case when lead(t.date_event) over (partition by t.field order by t.date_event) is null
			   then max(t.date_event) over ()
			   else lead(t.date_event) over (partition by t.field order by t.date_event)- INTERVAL '1 day'
		  end	  
			   as next_date
		, min (t.date_event) over () as min_date
		, max(t.date_event) over () as max_date	  
from (
select t1.date_event
		,t1.field
		,t1.new_value
		,t1.old_value
from test t1
union all
select distinct min (t2.date_event) over () as date_event --������ ��������� ����
		,t2.field
		,null as new_value
		,null as old_value
from test t2) t
)
select r.c_date, t.field , t.new_value
from r
join t on r.c_date between t.date_event and t.next_date
order by t.field,r.c_date

������� 1. � ������� ������� ������� �������� ��� ������� ���������� �������� ��������� ������� �� ���������� ������ 
�� ��������� �� ��������� 0.0 � ����������� �� ���� �������

������� 2. � ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ���� 2007 ���� � ����������� 
������ �� ������� ���������� � �� ������ ���� ������� (���� ��� ����� �������) � ����������� �� ���� �������

������� 3. ��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
�   	����������, ������������ ���������� ���������� �������
�   	����������, ������������ ������� �� ����� ������� �����
�   	����������, ������� ��������� ��������� �����