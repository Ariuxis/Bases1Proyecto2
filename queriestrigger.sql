/* Pontificia Universidad Javeriana, Cali
 * Ingeniería de Sistemas y Computación
 * Gestión y Modelación de Bases de Datos
 * Andrea Timarán
 * Laura Velásquez
 * Antonio Yu
 */

# 1. #

create or replace function invalidSell() returns trigger as $$
declare
vargen record;
begin
select assignedcards, currentsales, sellerid, shiftid into vargen from 
shift natural join shiftseller natural join seller 
where new.sellerid = sellerid and shiftdate = new.transactiondate 
and new.transactiontype = 'Venta' and new.stationid = stationid;
if vargen.currentsales < vargen.assignedcards then
raise notice 'La venta ha sido exitosa.';
return new;
else
raise exception 'El vendedor % ya no puede vender más tarjetas en el turno %.', 
	vargen.sellerid, vargen.shiftid;
return null;
end if;
end;
$$ language plpgsql;

create trigger cardSale before insert on transaction
	for each row execute procedure invalidSell();

insert into transaction(transactionid, transactiontype, transactionpay, 
	transactionvalue, transactiondate, stationid, cardid, sellerid) values
	(181, 'Venta', 'Efectivo', 5000, '2017-05-15', 4, 41, 7); # Valid

insert into transaction(transactionid, transactiontype, transactionpay, 
	transactionvalue, transactiondate, stationid, cardid, sellerid) values
	(181, 'Venta', 'Efectivo', 5000, '2017-05-19', 4, 41, 7); # Invalid

# 2. #

create or replace function invalidUse() returns trigger as $$
begin
if (select cardbalance::money::numeric::integer from card where cardid = new.cardid) < 0 then
raise exception 'La tarjeta % no posee saldo suficiente.', new.cardid;
return null;
else
raise notice 'Se ha añadido exitosamente.';
return new;
end if;
end;
$$ language plpgsql;

create trigger insTransaction before insert on transaction
	for each row execute procedure invalidUse();


insert into transaction(transactionid, transactiontype, transactionvalue, 
	transactiondate, stationid, cardid) values
	(181, 'Uso', 2000, '2017-05-28', 3, 2);

# 3. #

create or replace function invalidTransaction() returns trigger as $$
declare
vargen record;
begin
if exists (select shiftid, sellerid 
from shift natural join shiftseller natural join shift 
where shiftdate = new.transactiondate and stationid = new.stationid 
and sellerid = new.sellerid and new.transactiontype in ('Venta', 'Recarga')) then
raise notice 'La transacción ha sido realizada exitosamente.';
return new;
else
raise exception 'El vendedor no tiene un turno asignado.';
return null;
end if;
end;
$$ language plpgsql;

create trigger insSale before insert on transaction
	for each row execute procedure invalidTransaction;

# 4. #

create or replace function invalidShift() returns trigger as $$
declare
newshift record;
oldshift record;
overlap boolean := true;
begin
select shiftbegin, shiftend into oldshift from
shift natural join shift seller where shiftid = new.shiftid;
for vargen in select shiftbegin, shiftend
from shift natural join shiftseller
where sellerid = new.sellerid loop
if(select (newshift.shiftbegin, newshift.shiftend) 
overlaps (oldshift.shiftbegin, oldshift.shiftend)) then
overlap := false;
exit;
else
continue;
end if;
end loop;
if(overlap) then
raise notice 'El turno ha sido añadido exitosamente.';
return new;
else
raise exception 'El vendedor tiene un turno que se sobrepone con otro.';
return null;
end;
$$ language plpgsql;

create trigger before insert or update on shiftseller
	for each row execute procedure invalidShift();