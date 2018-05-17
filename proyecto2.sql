create table if not exists city (
	citycode smallint primary key,
	cityname varchar(15) not null,
	check(citycode >= 0 and citycode <= 9999)
);

create table if not exists bank (
	bankid smallint primary key,
	bankname varchar(25) not null,
	check(bankid >= 0 and bankid <= 9999)
);

create table if not exists station (
	stationid smallint primary key,
	stationname varchar(25) not null,
	check(stationid >= 0 and stationid <= 9999)
);

create table if not exists bankcard (
	bankcardid smallint primary key,
	bankcardtype varchar(25) not null,
	bankid smallint references bank(bankid) not null,
	check(bankcardid >= 0 and bankcardid <= 9999),
	check(bankid >= 0 and bankid <= 9999),
	check(bankcardtype = 'Debito' or bankcardtype = 'Credito')
);

create table if not exists person (
	personid smallint primary key,
	personname varchar(25) not null,
	persontelephone int,
	persongender char(2),
	personaddress varchar(40),
	personemail varchar(40),
	citycode smallint references city(citycode) not null,
	check(personid >= 0 and personid <= 9999),
	check(citycode >= 0 and citycode <= 9999),
	check(persongender = 'M' or persongender = 'F'),
	check(persontelephone >= 100000000 and persontelephone <= 999999999)
);

create table if not exists users (
	userid smallint primary key,
	personid smallint references person(personid) not null,
	check(userid >= 0 and userid <= 9999),
	check(personid >= 0 and personid <= 9999)
);

create table if not exists card (
	cardid smallint primary key,
	cardtype varchar(15) not null,
	userid smallint references users(userid),
	cardbalance money not null default 0,
	check(cardid >= 0 and cardid <= 9999),
	check(userid >= 0 and userid <= 9999),
	check(cardtype = 'Personalizada' or cardtype = 'Anonima'
		or cardtype = 'No recargable')
);

create table if not exists shift(
	shiftid smallint primary key,
	shiftdate date not null,
	shiftbegin time without time zone not null,
	shiftend time without time zone not null,
	stationid smallint references station(stationid) not null,
	check(shiftid >= 0 and shiftid <= 9999),
	check(stationid >= 0 and stationid <= 9999)
);

create table if not exists seller (
	sellerid smallint primary key,
	personid smallint references person(personid) not null,
	sellershift varchar(30) not null,
	check(sellerid >= 0 and sellerid <= 9999),
	check(personid >= 0 and personid <= 9999),
	check(sellershift = 'Tiempo completo' or sellershift = 'Medio tiempo' or
		sellershift = '1/4 de tiempo' or sellershift = '3/4 de tiempo')
);

create table if not exists shiftseller (
	shiftid smallint references shift(shiftid),
	sellerid smallint references seller(sellerid),
	check(shiftid >= 0 and shiftid <= 9999),
	check(sellerid >= 0 and sellerid <= 9999),
	primary key(shiftid, sellerid)
);

create table if not exists transaction (
	transactionid smallint primary key,
	transactiontype varchar(15) not null,
	transactionpay varchar(15),
	transactionvalue money not null,
	transactiondate date not null,
	stationid smallint references station(stationid),
	approvalnumber int,
	bankcardid smallint references bankcard(bankcardid),
	cardid smallint references card(cardid) not null,
	sellerid smallint references seller(sellerid),
	check(transactionid >= 0 and transactionid <= 9999),
	check(cardid >= 0 and cardid <= 9999),
	check(sellerid >= 0 and sellerid <= 9999),
	check(approvalnumber >= 100000 and approvalnumber <= 999999),
	check(bankcardid >= 0 and bankcardid <= 9999),
	check(stationid >= 0 and stationid <= 9999),
	check(transactionpay = 'Efectivo' or transactionpay = 'Tarjeta'),
	check(transactiontype = 'Recarga' or transactiontype = 'Uso'
		or transactiontype = 'Venta')
);