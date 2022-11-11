-- ************************************** fix data quality problem

update stg.orders set postal_code=0 
where postal_code is null;

--checking
select * from stg.orders;


create schema dw;

-- ************************************** products

drop table if exists dw.products ;
CREATE TABLE dw.products
(
 product_id   varchar(15) NOT NULL,
 product_name varchar(220) NOT NULL,
 category     varchar(50) NOT NULL,
 subcategory  varchar(50) NOT NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( product_id )
);


insert into dw.products
select distinct on (product_id) product_id, product_name, category, subcategory from stg.orders;


--checking
select * from dw.products; 


-- ************************************** customers

drop table if exists dw.customers CASCADE;
CREATE TABLE dw.customers
(
 customer_id   varchar(8) NOT NULL,
 customer_name varchar(50) NOT NULL,
 segment       varchar(50) NOT NULL,
 CONSTRAINT PK_2 PRIMARY KEY ( customer_id )
);


insert into dw.customers
select distinct customer_id, customer_name, segment from stg.orders;


--checking
select * from dw.customers; 


-- ************************************** addresses

drop table if exists dw.addresses CASCADE;
CREATE TABLE dw.addresses
(
 addres_id   int4 NOT NULL,
 country     varchar(50) NOT NULL,
 city        varchar(50) NOT NULL,
 state       varchar(50) NOT NULL,
 postal_code varchar(8) NOT NULL,
 region      varchar(50) NOT NULL,
 CONSTRAINT PK_3 PRIMARY KEY ( addres_id )
);

insert into dw.addresses
select 100+row_number() over(), * from (select distinct country, city, state, postal_code, region   from stg.orders ) a;



--checking
select * from dw.addresses; 

-- ************************************** orders

drop table if exists dw.orders CASCADE;
CREATE TABLE dw.orders
(
 order_id   varchar(14) NOT NULL,
 order_date date NOT NULL,
 ship_date  date NOT NULL,
 ship_mode  varchar(14) NOT NULL,
 customer_id varchar(8) NOT NULL,
 addres_id  int4 NOT NULL,
 return     varchar(3) NULL,
 CONSTRAINT orders_pkey PRIMARY KEY ( order_id ),
 CONSTRAINT FK_1 FOREIGN KEY ( customer_id ) REFERENCES dw.customers ( customer_id ),
 CONSTRAINT FK_2 FOREIGN KEY ( addres_id ) REFERENCES dw.addresses ( addres_id )
);


insert into dw.orders								
select distinct order_id, order_date, ship_date, ship_mode, customer_id, addres_id from 
stg.orders o left join dw.addresses a on 
									o.city = a.city and									
									o.state = a.state and									
									cast (o.postal_code AS varchar(8)) = a.postal_code and
									o.region = a.region;								
					

update dw.orders SET "return" ='Yes'
WHERE order_id in (select distinct o.order_id from 
	dw.orders o right join stg.returns r on o.order_id = r.order_id);


--checking
select * from dw.orders; 

-- ************************************** "order list"

drop table if exists dw.order_list ;
CREATE TABLE dw.order_list
(
 order_id    varchar(14) NOT NULL,
 position_id int NOT NULL,
 product_id  varchar(15) NOT NULL,
 sales       numeric(9, 4) NOT NULL,
 quantity    int NOT NULL,
 discount    numeric(4, 2) NOT NULL,
 profit      numeric(21, 16) NOT NULL,
 CONSTRAINT PK_4 PRIMARY KEY ( order_id, position_id ),
 CONSTRAINT FK_3 FOREIGN KEY ( order_id ) REFERENCES dw.orders ( order_id ),
 CONSTRAINT FK_4 FOREIGN KEY ( product_id ) REFERENCES dw.products ( product_id )
);


insert into dw.order_list
select order_id, row_number() over(partition BY order_id), product_id, sales, quantity, discount, profit from stg.orders;

-- ************************************** "to_ru" ������� �������� ������ ��� ����������� ���������


drop table if exists dw.to_ru ;

CREATE TABLE dw.to_ru
(
 state varchar(50) NOT NULL,
 state_ru varchar(90) NOT NULL,
 CONSTRAINT PK_6 PRIMARY KEY ( state )
 --CONSTRAINT FK_5 FOREIGN KEY ( state ) REFERENCES dw.addresses ( state )
);

INSERT INTO dw.to_ru(state,state_ru) VALUES ('Oklahoma','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Colorado','���� ��������');
insert INTO dw.to_ru(state,state_ru) VALUES ('North Carolina','���� �������� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Mississippi','���������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Florida','���� �������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Vermont','���� �������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Delaware','���� �������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Louisiana','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Nevada','���� ������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('New York','���� ���-����');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('West Virginia','���� �������� ���������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('South Carolina','���� ����� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('New Jersey','���� ���-������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Arkansas','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('New Mexico','���� ���-�������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Missouri','�������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Connecticut','���� �����������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('South Dakota','���� ����� ������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('District of Columbia','����� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Iowa','���� �����');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Indiana','�������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Massachusetts','���� �����������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Rhode Island','���� ���-������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Ohio','���� �����');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Michigan','���� �������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Minnesota','���� ���������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Pennsylvania','����������� ������������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Washington','���� ���������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Montana','���� �������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Wisconsin','���� ���������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Kentucky','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Arizona','���� �������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Illinois','��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Virginia','���� ���������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Maryland','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Georgia','��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Utah','���� ���');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Wyoming','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('New Hampshire','���-�������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('North Dakota','���� �������� ������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Nebraska','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Maine','���� ���');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('California','���� ����������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Tennessee','���� ��������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Kansas','���� ������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Oregon','���� ������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Texas','���� �����');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Idaho','���� ������');
INSERT INTO dw.to_ru(state,state_ru) VALUES ('Alabama','���� �������');


--checking
select * from dw.to_ru; 

