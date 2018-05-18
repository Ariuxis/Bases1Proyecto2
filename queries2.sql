# 1. #

create or replace function transactiondetails(id int, transdate date) returns void as $$
declare
vargen record;
begin
for vargen in select distinct transactiontype, cardid, transactionvalue, 
transactionpay, approvalnumber, bankcardtype, bankname from
shift natural left join shiftseller natural left join seller left join transaction using(sellerid)
natural left join bankcard natural left join bank where transdate = shiftdate and sellerid = id loop
raise notice 'ID de la tarjeta: %', vargen.cardid;
raise notice 'Tipo de transacción: %', vargen.transactiontype;
raise notice 'Valor de la transacción: %', vargen.transactionvalue;
raise notice 'Tipo de pago de la transacción: %', vargen.transactionpay;
raise notice 'Numero de aprobación: %', vargen.approvalnumber;
raise notice 'Tipo de tarjeta bancaria: %', vargen.bankcardtype;
raise notice 'Nombre de entidad bancaria: %', vargen.bankname;
raise notice '';
end loop;
end;
$$ language plpgsql;

select transactiondetails(3, '2017-05-20');

# 2. #

create function daysales(salesdate date) returns void as $$
declare
vargen record;
begin
for vargen in select distinct sellerid, personname, sum(transactionvalue) as total from
shift natural join shiftseller natural join seller natural join person join transaction using(sellerid)
where transactiontype in ('Venta', 'Recarga') and salesdate = shiftdate and transactionpay = 'Efectivo'
group by sellerid, personname loop
raise notice 'El vendedor % con ID % recibió el día % un total de % en efectivo.',
vargen.personname, vargen.sellerid, salesdate, vargen.total;
end loop;
end;
$$ language plpgsql;

select daysales('2017-05-20');

# 3. #

create function cardrecord(id int) returns void as $$
declare
vargen record;
begin
for vargen in select distinct cardid, transactiontype, 
transactiondate, transactionvalue, personname, stationname 
from transaction natural left join seller natural left join person
natural left join station natural left join card natural left join users
where userid = id order by cardid, transactiondate loop
raise notice 'ID de la tarjeta: %', vargen.cardid;
raise notice 'Tipo de transacción: %', vargen.transactiontype;
raise notice 'Fecha de la transacción: %', vargen.transactiondate;
raise notice 'Valor de la transacción: %', vargen.transactionvalue;
raise notice 'Nombre del vendedor: %', vargen.personname;
raise notice 'Nombre de la estación: %', vargen.stationname;
raise notice '';
end loop;
end;
$$ language plpgsql;

select cardrecord(5);
# 4. #

with ranking as
(select distinct stationname, sum(transactionvalue) over(partition by stationname) as total
from transaction natural join station where date_part('year', transactiondate) = 2017)
select row_number() over(order by total desc) as posicion, * from ranking;

# 5. #

select distinct date_part('month', transactionvalue), personname, sum(transactionvalue) as total from 
transaction natural join seller where date_part('year', transactionvalue) = 2017;

SELECT date_trunc('month', transactiondate) AS month, sum(transactionvalue) as total
FROM transaction
GROUP BY month;


select distinct personname, sum(transactionvalue) over(partition by personname) as total
from transaction natural join seller natural join person 
where date_part('year', transactiondate) = 2017 and
transactiontype in ('Venta', 'Recarga');

select to_char(transactiondate,'Month') as month, personname, 
sum(transactionvalue) over(partition by personname)as total
from transaction natural join seller
group by month;

with months as
(select distinct to_char(transactiondate,'Month') as month, 
	personname, sum(transactionvalue) as total 
from transaction natural join seller natural join person
where date_part('year', transactiondate) = 2017 group by month, personname
order by month desc, total desc)
select month, personname, total from 
(select month, personname, max(total) from months group by month, personname) as t;

select personname, sum(transactionvalue) as total
 from person natural join seller natural join transaction
 where personname = 'Adams Meynell' and date_part('month', transactiondate) = 8
 group by personname;

# 6. #

# 7. #
