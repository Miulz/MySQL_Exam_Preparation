create database real_estate;
use real_estate;



--- Task 01

create table cities(
id int primary key auto_increment,
name varchar(60) not null unique
);

create table property_types(
id int primary key auto_increment,
type varchar(40) not null unique,
description text 
);


create table properties(
id int primary key auto_increment,
address varchar(80) not null unique,
price decimal(19, 2) not null,
area decimal(19, 2),
property_type_id int,
city_id int,
foreign key (property_type_id) references property_types(id),
foreign key (city_id) references cities(id)
);

create table agents(
id int primary key auto_increment,
first_name varchar(40) not null,
last_name varchar(40) not null,
phone varchar(20) not null unique,
email varchar(50) not null unique,
city_id int,
foreign key(city_id) references cities(id)
);


create table buyers (
id int primary key auto_increment,
first_name varchar(40) not null,
last_name varchar(40) not null,
phone varchar(20) not null unique,
email varchar(50) not null unique,
city_id int,
foreign key(city_id) references cities(id)
);


create table property_offers(
property_id int not null,
agent_id int not null,
price decimal(19, 2) not null,
offer_datetime datetime,
foreign key(property_id) references properties(id),
foreign key(agent_id) references agents(id)
);


create table property_transactions(
id int primary key auto_increment,
property_id int not null,
buyer_id int not null,
transaction_date date,
bank_name varchar(30),
iban varchar(40) unique,
is_successful boolean,
foreign key(property_id) references properties (id),
foreign key(buyer_id) references buyers (id)
);


--- Task 02 

insert into property_transactions  ( property_id, buyer_id, transaction_date, bank_name, iban, is_successful)
select po.agent_id + day(po.offer_datetime), po.agent_id + month(po.offer_datetime), date(po.offer_datetime), concat('Bank ', po.agent_id), concat('BG',po.price,po.agent_id), true 
from property_offers po
where po.agent_id <=2;


--- Task 03

update properties
set price = price - 50000
where price > 800000 or price = 800000;



SET sql_safe_updates = 0;


--- Task 04

delete from property_transactions where is_successful = 0;


--- Task 05 

select * from agents
order by city_id desc, phone desc;


--- Task 06

select property_id, agent_id, price, offer_datetime from property_offers
where offer_datetime between '2021-01-01' and '2021-12-31'
order by price asc
limit 10;


--- Task 07

select * from agents;
select * from property_types;
select * from properties;


select substring(ps.address, 1, 6) as agent_name, char_length(ps.address) * 5430 as price 
from properties ps
 left join property_offers po
on ps.id = po.property_id
where po.agent_id is null
order by agent_name desc, price desc;

--- Task 08


select * from property_transactions;

select bank_name, count(*) as count
from property_transactions
group by bank_name
having count >= 9
order by count desc, bank_name asc;


--- Task 09 


select address, area, 
case
     when area <= 100 then "small"
     when area <= 200 then "medium"
     when area <= 500 then "large"
     when area > 500 then "extra large"
     end as size
from properties
order by area asc, address desc;



--- Task 10

select * from cities;
select * from property_offers;
select * from properties;

delimiter $

create function udf_offers_from_city_name (cityName VARCHAR(50)) returns int
deterministic
begin
declare result int;
set result := (select count(*) from property_offers po
join properties ps
on po.property_id = ps.id
join cities cs
on ps.city_id = cs.id
where cs.name = cityName
 );
return result;
end$

delimiter ;



SELECT udf_offers_from_city_name('Vienna') AS 'offers_count';
SELECT udf_offers_from_city_name('Amsterdam') AS 'offers_count';


--- Task 11

delimiter $

create procedure udp_special_offer (first_name VARCHAR(50))
begin
update property_offers po
join agents a on a.id = po.agent_id
set po.price = po.price * 0.9
where a.first_name = first_name;
end$

delimiter ; 


CALL udp_special_offer('Hans');





















