/* Pontificia Universidad Javeriana, Cali
 * Ingeniería de Sistemas y Computación
 * Gestión y Modelación de Bases de Datos
 * Andrea Timarán
 * Laura Velásquez
 * Antonio Yu
 */

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

with months as
(select distinct to_char(transactiondate,'Month') as month, 
	personname, sum(transactionvalue) as total 
	from transaction natural join seller natural join person
	where date_part('year', transactiondate) = 2017 group by month, personname)

select months.month, months.personname, months.total 
from (select month, max(total) as maxtotal from months group by month) as query
inner join months on months.month = query.month and months.total = query.maxtotal 
order by month desc;

# 6. #

with shiftcount as
(select distinct personname, shiftid, 
	count(transactiontype) over(partition by personname, shiftid) as counttotal 
	from person natural join seller natural join shiftseller 
	natural join shift join transaction using(sellerid)
	order by shiftid, personname),
	avgseller as (select personname, avg(counttotal) as avgcount from shiftcount group by personname)

	select personname, shiftid, counttotal as selleravg,
	(select avg(avgcount) from avgseller) as avg 
	from shiftcount join avgseller using(personname) 
	where counttotal < (select avg(avgcount) from avgseller);

# 7. #