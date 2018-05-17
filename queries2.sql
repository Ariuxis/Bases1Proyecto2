# 1. #

create or replace function transactiondetails(id int, transdate date) returns void as $$
declare
vargen record;
begin
for vargen in select distinct transactiontype, cardid, transactionvalue, 
transactionpay, approvalnumber, bankcardtype, bankname from
shift natural left join shiftseller natural left join seller left join transaction using(sellerid)
natural left join bankcard natural left join bank where transdate = shiftdate and sellerid = id loop
raise notice 'Tipo de transacción: %', vargen.transactiontype;
raise notice 'ID de la tarjeta: %', vargen.cardid;
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
for vargen in select distinct transactiontype, transactiondate, 
transactionvalue, personname, stationname from person natural join user natural join seller
natural join transaction natural join station

end;
$$ language plpgsql;

select cardrecord(5);
# 4. #

# 5. #

# 6. #

# 7. #
