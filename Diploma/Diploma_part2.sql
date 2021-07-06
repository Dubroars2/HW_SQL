
1. В каких городах больше одного аэропорта?

--Через агрегатную функцию нахожу кол-во аэрапортов и после через фильтр оставляю только те, где больше 1 аэрапрта 

select a.city , count(a.airport_code) as count_airports
from airports a 
group by a.city 
having count(a.airport_code) > 1
order by count_airports desc 


2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
-- Подзапрос

select distinct f.departure_airport
from flights f
where f.aircraft_code = (
	select a.aircraft_code
	from aircrafts a 
	order by a."range" desc limit 1)



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

select b.book_ref, b.book_date ,bp.boarding_no 
from bookings b 
left join tickets t on t.book_ref = b.book_ref 
left join boarding_passes bp on bp.ticket_no = t.ticket_no 
where bp.boarding_no is null




 5. Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из 
каждого аэропорта на каждый день.
Т.е. в этом столбце должна отражаться накопительная сумма - 
сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.
-- Оконная функция
-- Подзапросы или cte

Минус 25 баллов.
Потеряли почти все данные, почему в запросе только вылетевшие рейсы? Должны быть и те, которые уже долетели.
Накопление должно быть по каждому аэропорту на каждый день, сейчас по каждому аэропорту за все время глобально. Внимательней к группировке в оконной функции.




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
	where f.status = 'Departed' or f.status = 'Arrived'
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
	sum (cte_general.seat_boarding) over (
	partition by cte_general.departure_airport,  date_part('day', cte_general.actual_departure) order by cte_general.actual_departure)
from cte_general
left join cte_seats cs on cs.aircraft_code = cte_general.aircraft_code




	
6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.


Минус 5 баллов.
В результате должны быть проценты, а не дробные значения.

select   f.aircraft_code,
	concat( round(count(f.flight_no) / sum(count(f.flight_no)) over (),2) *100, '%') as share_of_total
from flights f 
where f.status = 'Departed' or f.status = 'Arrived'   
group by f.aircraft_code 


7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
-- CTE

Минус 15 баллов.
Не логично сравнивать минимальную стоимость эконома с минимальной стоимостью бизнеса, что бы найти, где эконом был дороже бизнеса.
Из результата нужно убрать избыточность, должен быть уникальный список городов.


--Таких городов нет


with CTE_business as (
	select distinct  f.flight_no , f.departure_airport , f.arrival_airport ,  tf.amount as amount_business
	from ticket_flights tf 
	join flights f on f.flight_id = tf.flight_id
	where tf.fare_conditions  = 'Business')
select distinct   a.city
from ticket_flights tf 
join flights f on f.flight_id = tf.flight_id
join CTE_business b on b.flight_no = f.flight_no 
join bookings.airports a on a.airport_code  = f.arrival_airport 
where tf.amount - b.amount_business > 0






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
		
	
	
	