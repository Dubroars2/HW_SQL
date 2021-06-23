
1. В каких городах больше одного аэропорта?

--Через агрегатную функцию нахожу кол-во аэрапортов и после через фильтр оставляю только те, где больше 1 аэрапрта 

select a.city , count(a.airport_code) as count_airports
from airports a 
group by a.city 
having count(a.airport_code) > 1
order by count_airports desc 


2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
-- Подзапрос


select distinct  f.departure_airport ,
f.actual_arrival::timestamp -f.actual_departure::timestamp  as diff 
from flights f 
where f.aircraft_code in (
		with cte_max_dur as(
		select f.aircraft_code, 
		max(f.actual_arrival::timestamp -f.actual_departure::timestamp)  as diff 
		from flights f 
		where f.status = 'Arrived'
		group by f.aircraft_code 
		order by diff desc
	)
		select cte_max_dur.aircraft_code
		from cte_max_dur
	)  
and f.actual_arrival::timestamp -f.actual_departure::timestamp in (
		with cte_max_dur as(
		select f.aircraft_code, 
		max(f.actual_arrival::timestamp -f.actual_departure::timestamp)  as diff 
		from flights f 
		where f.status = 'Arrived'
		group by f.aircraft_code 
		order by diff desc
	)
		select cte_max_dur.diff
		from cte_max_dur)
and f.status = 'Arrived'
order by diff desc
	


3. Вывести 10 рейсов с максимальным временем задержки вылета 
-- Оператор LIMIT

select f.flight_no , 
f.actual_departure::timestamp - f.scheduled_departure::timestamp as time_delay
from flights f 
where f.actual_departure is not null
order by time_delay desc
limit 10


4. Были ли брони, по которым не были получены посадочные талоны?
--Верный тип JOIN

--Ответ: Да, были

select b.book_ref, bp.boarding_no 
from bookings b 
left join tickets t on t.book_ref  = b.book_ref 
left join ticket_flights tf on tf.ticket_no  = t.ticket_no 
left join boarding_passes bp on bp.flight_id  = tf.flight_id and bp.ticket_no  = tf.ticket_no 
order by bp.boarding_no desc 

 5. Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из 
каждого аэропорта на каждый день.
Т.е. в этом столбце должна отражаться накопительная сумма - 
сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
-- Оконная функция
-- Подзапросы или cte

	
1. Сделал СТЕ для подсчета занятых мест. 
2. Сделал еще одно СТЕ для нахождения всего мест в самолете 
3. Расчитал % свободных мест (тотал - занятые места)
4. Накопительным итогом вывел, сколько пассажиров улетело из аэропорта за один день


explain analyse 

with cte_general as(
	select  f.flight_no , count( bp.seat_no) as seat_boarding, 
	f.aircraft_code, 
	f.actual_departure,
	f.departure_airport 
	from flights f 
	left join ticket_flights tf on tf.flight_id = f.flight_id 
	left join boarding_passes bp on bp.flight_id  = tf.flight_id and bp.ticket_no  = tf.ticket_no 
	left join aircrafts a on a.aircraft_code  = f.aircraft_code 
	where f.status = 'Departed'
	group by f.flight_id), 
		cte_seats as(
		select  a.aircraft_code ,  count(s.seat_no) as total_seats
		from aircrafts a  
		left join seats s on s.aircraft_code  = a.aircraft_code 
		group by a.aircraft_code )	
select 
cte_general.actual_departure,
cte_general.departure_airport,
cte_general.flight_no,
cte_general.seat_boarding,
total_seats - cte_general.seat_boarding as free_seats,
concat(round((total_seats - cte_general.seat_boarding) / total_seats::numeric , 2)*100, '%') 
as free_share_of_total,
	sum (cte_general.seat_boarding) over (partition by cte_general.departure_airport order by cte_general.actual_departure)
from cte_general
left join cte_seats cs on cs.aircraft_code = cte_general.aircraft_code


	
6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.
-- Подзапрос
-- Оператор ROUND

а) Вывел все типы самолетов
б) Добавил кол-во полетов (полеты = кол-во рейсов, которые состоялись)
в) Нашел долю. Поделил кол-во рейсов данной модели на общее кол-во рейсво через оконную функцию 

select   f.aircraft_code,
	round(count(f.flight_no) / sum(count(f.flight_no)) over (),2)  as share_of_total
from flights f 
where f.status = 'Departed' or f.status = 'Arrived'   
group by f.aircraft_code 


7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
-- CTE

--Ответ нет, таких городов нет

1. Делаю СТЕ и нахожу минимальную цену для бизнес класса в рамках перелета
2. Делаю СТЕ и нахожу минимальную цену для эконом класса в рамках перелета
3. Вывожу и джойню сте для бизнес класс и эконом, чтобы получить минимальные суммы за перелет по этим категориям
4. Делаю фильтр, если минимальная сумма за перелет за бизнес больше мин суммы эконом

	with cte_business as (
	select distinct a.city as city_arrival, b.city as city_departure, tf.amount, tf.fare_conditions, f.flight_no , f.flight_id ,
		min(tf.amount) over (partition by f.flight_id) as min_business
	from flights f 
	left join ticket_flights tf on tf.flight_id = f.flight_id 
	left join airports a on a.airport_code  = f.arrival_airport 
	left join airports b on b.airport_code  = f.departure_airport 
	where tf.fare_conditions = 'Business' ),
cte_economy as (
	select  distinct a.city as city_arrival, b.city as city_departure, tf.amount, tf.fare_conditions, f.flight_no ,
		min(tf.amount) over (partition by f.flight_id) as min_economy
	from flights f 
	left join ticket_flights tf on tf.flight_id = f.flight_id 
	left join airports a on a.airport_code  = f.arrival_airport 
	left join airports b on b.airport_code  = f.departure_airport 
	where  tf.fare_conditions = 'Economy' )
select bs.flight_no, bs.city_arrival, bs.city_departure, bs.fare_conditions,  bs.min_business, e.min_economy
	from cte_business bs
join cte_economy e on e.flight_no = bs.flight_no
where bs.min_business < e.min_economy
	

8. Между какими городами нет прямых рейсов?
 - Декартово произведение в предложении FROM
- Самостоятельно созданные представления
- Оператор EXCEPT

/* 
не могу разобраться, почему не работает. Я отдельным представлением сделал уникальный список городов, куда летали рейсы. 
Далее вывел уникальный список городов откуда летали рейсы и куда из таблицы полеты + сделал кросс джоин на список из представления.
Моя логика следующая: если нет совпадения по город отправления - город прибытия (из моего представления) и город отправления - город прибытия из таблицы полеты,
то это как раз наш случай, где нет прямого рейса. Скажите, пожалуйста, моя логика рабочая? Запутался немного в коде, не отрабатывает(((
*/


drop view to_list

create view to_list as 
select  distinct  a.city as to_airport
from flights f
join airports a on a.airport_code = f.arrival_airport 
join airports a2 on a2.airport_code = f.departure_airport 


	select distinct  a2.city as from_airport, a.city as to_airport, to_list.to_airport
	from flights f
	join airports a on a.airport_code = f.arrival_airport 
	join airports a2 on a2.airport_code = f.departure_airport 
	cross join to_list
	where concat(a2.city,to_list.to_airport) not in 
		(select distinct concat(a2.city,a.city) 
		from flights f
		join airports a on a.airport_code = f.arrival_airport 
		join airports a2 on a2.airport_code = f.departure_airport )
		
	
	
	