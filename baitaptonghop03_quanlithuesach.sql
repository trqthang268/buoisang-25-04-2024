create database baitaptonghop03_quanlithuesach;
use baitaptonghop03_quanlithuesach;
create table if not exists Category(
	Id int primary key auto_increment,
    Name varchar(100) not null,
    Status tinyint default 1 check (Status in (0,1))
);
create table if not exists Author(
	Id int primary key auto_increment,
    Name varchar(100) not null unique,
    TotalBook int default 0
);
create table if not exists Book(
	Id int primary key auto_increment,
    Name varchar(150) not null,
    Status tinyint default 1 check(Status in (0,1)),
    Price float not null check (Price >= 100000),
    CreatedDate date default (curdate()),
    CategoryId int not null,
    AuthorId int not null
);
alter table Book 
add foreign key (CategoryId) references Category(Id),
add foreign key (AuthorId) references Author(Id);

create table if not exists Customer(
	Id int primary key auto_increment,
    Name varchar(150) not null,
    Email varchar(150) not null unique,
    Phone varchar(50) not null unique,
    Address varchar(255),
    CreatedDate date default (curdate()),
    Gender tinyint not null check (Gender in (0,1,2)),
    BirthDay date not null
);

delimiter $$
create trigger trg_checkEmailContraint
before insert
on Customer
for each row
begin
if NEW.Email is not null and 
(NEW.Email not like '%@gmail.com' and NEW.Email not like '%@facebook.com' and NEW.Email not like '%@bachkhoa-aptech.edu.vn')
then signal sqlstate '45000'
set message_text = 'Email phải có đuôi @gmail.com, @facebook.com, @bachkhoa-aptech.edu.vn';
end if;
end $$
delimiter //;

delimiter $$
create trigger trg_checkUpdateCreatedDate
before update
on Customer
for each row
begin
if NEW.CreatedDate < curdate() 
then signal sqlstate '45000'
set message_text = 'CreatedDate phải >= ngày hiện tại';
end if;
end $$
delimiter //;

