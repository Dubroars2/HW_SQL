SELECT table_name, constraint_name 
FROM information_schema.table_constraints tc 
where constraint_schema  = 'dvd-rental' and constraint_type = 'PRIMARY KEY'


первичный ключ = это проверка на уникальность (unique) + проверка на отсутствие пустых значений (not null) + 
index (создается для ускоренного поиска по таблицам)
Таблица = отношение 
Столбец = атрибут 
Строка = кортеж (в таблице ниже)
Настройки верхнего уровня над вашим отношением (где можно задать права доступа и т.д.) = домен

join рассматривают на кругах Эйлера, когда говорим про уникальные значения 

логический порядок 
from
on 
join 
where 
group by 
with cube or with rollup 
having 
select 
distinct 
order by


_____________________________

Вебинар 2 Алиасы = псевдонимы удобства для написания запросов

select tc.table_name, tc.constraint_name 
from information_schema.table_constraints tc 
join information_schema.key_column_usage kcu on kcu.table_name = tc.table_name 
where tc.constraint_type = 'PRIMARY KEY'


select t.actor_id
from (select a.actor_id from actor a) t
когда используется подзапрос, то мы обязаны указать алиас (t например). Снаружи а не будет, только внутри запроса своего

название_схемы.название_таблицы --from 
название_таблицы.название_столбца -- select

Задание 1. Получите атрибуты: id фильма, название, описание и год релиза из таблицы фильмы. 
Переименуйсте поля так, чтобы все они начинальсь со слова Film (FilmTitle вместо title и тп)
as для задания синонимов. as можно опустить и не писать 

-- /* */ для комментариев


select film_id, title , description , release_year 
from film f 

select film_id as Filmfil_id, title as Filmtitle, description Filmdescription, release_year Filmrelease_year
from film f 

по умолчанию postgresql все приводит к нижнему регистру 

select film_id as "Filmfil_id", title as "Filmtitle", description "Filmdescription", release_year "Год выпуска фильма"
from film f 

Задание 2. В одной из таблиц есть два атрибута:
rental_duration - длина перехода анерды
rental_rate - стоимость аренды фильма на этот промежуток времени
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
-используйте ER диаграмму, чтобы найти подходящую таблицу
-стоимость аренды в день - отношение rental_rate and rental_duration

select title, rental_rate / rental_duration  as cost_per_day
from film f 

pg_typeot - для определения тпа данных в столбцах

select title, pg_typeof(rental_duration), pg_typeof(rental_rate)  
from film f 

select title, round(rental_rate / rental_duration, 3)  as cost_per_day
from film f 

 select power(2,3) --для возведения в степень/ 1-какое число/2 какая степень

типы данных

integer, numeric, float (double precision and real)

int2 = smallint = 0-65535
int = int4 = integer = 0-4294836225 = от -2млрд до +2млрд
int8 = bigint = 0-1844561819972250625
numeric(10, 2) - особенно для финансов/ это размерность / 10 будет 10 цифр и разрядоность 2 значения после запятой
numeric = decimal
float = число с плавающей точкой 

select x,
	round (x::numeric) as num_round
	round (x::double precision) as dbl_round
from generate_series(-3.5, 3.5, 1) as x

select round(1/2) - будет 0 тк идет деление целечисленных значений 

Задание 3. Отсортируйте таблицу платежей по возрастанию суммы платежа


select title, rental_rate / rental_duration  as cost_per_day
from film f 
order by 2 asc

- второй столбец и асс по умолчанию или деск 

select title, rental_rate / rental_duration  as cost_per_day
from film f 
order by cost_per_day desc, title  - можем добавить еще один параметр/ будет по цене и потом по названию

select payment_id , amount 
from payment p 
where amount > 0
order by amount  asc


Задание 4. Вывести топ 10 самых дорогих фильмов 


select title, rental_rate / rental_duration  as cost_per_day
from film f 
order by cost_per_day desc
limit 10

Задание 5/ Начиная с 58 позиции

select title, rental_rate / rental_duration  as cost_per_day
from film f 
order by cost_per_day desc
offset 58
limit 10

Задание 6/ вывести уникальные фильмы 

select  distinct release_year 
from film f 

select  count(release_year) 
from film

Задание 5/ вывести список фильмов, имеющих рейтинг "PG-13" в виде: "Название - год выпуска"

select title, release_year, rating 
from film f 
where rating  = 'PG-13'


select concat(title, ' ', release_year), rating 
from film f 
where rating  = 'PG-13'

select concat_ws(' ', title, ' ', release_year), rating 
from film f 
where rating  = 'PG-13'

like
ilike 

select title, rating 
from film f 
where rating::text like 'PG%'

select title, rating 
from film f 
where cast(rating as text) like '%PG%' --если не знаем в начале или нет


like - регистро зависимый (большие или маленькие)
ilike - все равно на регистр 
upper or lower (приводит все к одному регистру)

char_length(узнаем длину строки)


select strpos('Hello world!', 'world')

select char_length('Hello world')

select overlay ('Hello world' placing 'Max' from 7 for 5)

select substring('Hello world' from 7 for 5)

select split_part('Hello world!', ' ', 2)  --цифра какое значение хотим вернуть 

получить айди фильмов в датах от 27 05 2005 до 28 05 2005

select customer_id , rental_date 
from rental r 
where rental_date between '2005-05-27' and '2005-05-28'
order  by rental_date desc 

формат по умолчанию 2005 05 28 00:00:00 поэтому даннные за 28 не попадают/ а только на 00

select customer_id , rental_date 
from rental r 
where rental_date::date between '2005-05-27' and '2005-05-28'
order  by rental_date desc 

в таком случае мы переводим к дате и игнорим время 

если добавлять день/ то ниже/ мы говорим/ что не строка и добавляем 1 день

select customer_id , rental_date 
from rental r 
where rental_date between '2005-05-27' and '2005-05-28'::date + interval '1 day'
order  by rental_date desc 


select '2005-05-27'::date + interval '3 weeks'

select extract (year from '2005-05-27'::date)

select date_part('hour', '2005-05-27 01:03:04'::timestamp) 

select date_trunc('year', '2005-05-27'::date) --выводит полностью дату/ год это 1 января/ месяц  это 1 мая день без учета времени

select date_part('day', now() - '2007-03-30') -- quntity days

select date_part('year', age(now(),  '2007-03-30')) --quantity year

select date_part('year', age(now(),  '2007-03-30')) * 12 +  date_part('month', age(now(),  '2007-03-30')) --месяца

select now() 

 вывести платежи после 30 04 2007

select payment_id , amount , payment_date 
from payment p 
where payment_date ::date > '2007-03-30'







