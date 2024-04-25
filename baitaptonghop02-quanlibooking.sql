create database if not exists exam_sql_04_quanlidatphong;
use exam_sql_04_quanlidatphong;
create table if not exists Category(
	Id int primary key auto_increment,
    Name varchar(100) not null unique,
    Status tinyint default 1 check (Status in (0,1))
);
create table if not exists Room (
	Id int primary key auto_increment,
    Name varchar(150) not null ,
    Status tinyint default 1 check (Status in (0,1)),
    Price float not null check (Price >=100000),
    SalePrice float default 0 ,  # SalePrice <= Price
    CreatedDate date default (curdate()),
    CategoryId int not null,
    foreign key (CategoryId) references Category(Id)
);
create table if not exists Customer (
	Id int primary key auto_increment,
    Name varchar(150) not null,
    Email varchar(150) not null unique  check ( email like '%@%.%'),
    Phone varchar(50) not null unique,
    Address varchar(255),
    CreatedDate date default (curdate()), # >= curdate()
    Gender tinyint not null check (Gender in (0,1,2)),
    BirthDay date not null
);
create table if not exists Booking (
	Id int primary key auto_increment,
    CustomerId int not null ,
    Status tinyint default 1 check (Status in (0,1,2,3)),
    BookingDate datetime default (curdate()),
    foreign key (CustomerId) references Customer(Id)
); 
create table if not exists BookingDetail (
	BookingId int not null ,
    RoomId int not null,
    Price float not null,
    StartDate datetime not null,
    EndDate datetime not null , #check (EndDate > StartDate)
    primary key (BookingId, RoomId),
    foreign key (BookingId) references Booking(Id),
    foreign key (RoomId) references Room(Id)
);

-- drop trigger before_insert_into_room;
delimiter $$
create trigger before_insert_into_room
    before insert
    on Room
    for each row
begin
    # SalePrice <= Price
    if NEW.SalePrice >= NEW.Price then
        signal sqlstate '45000'
            set message_text = 'SalePrice không được lớn hơn Price';
    end if;
end$$
delimiter \\;

-- drop trigger before_update_into_customer;
delimiter $$
create trigger before_update_into_customer
    before update
    on Customer
    for each row
begin
    # createddate >= curdate()
    if NEW.CreatedDate < curdate() then
        signal sqlstate '45000'
            set message_text = 'CreatedDate phải >= ngày hiện tại ';
    end if;
end $$
delimiter \\;

-- drop trigger before_insert_into_bookingdetail;
delimiter $$
create trigger before_insert_into_bookingdetail
    before insert
    on BookingDetail
    for each row
begin
    #check (EndDate > StartDate)
    if NEW.EndDate < NEW.StartDate then
        signal sqlstate '45000'
            set message_text = 'EndDate phải > StartDate';
    end if;
end $$
delimiter \\;

-- 1.	Bảng Category ít nhất là 5 bản ghi dữ liệu phù hợp
insert into Category(Name)
values ('Phòng thường'),
       ('Phòng đôi'),
       ('Phòng gia đình 4 người'),
       ('Phòng vip view đẹp'),
       ('Phòng tổng thống');
-- 2.	Bảng Room Ít nhất 15 bản ghi dữ liệu phù hợp
insert into exam_sql_04_quanlidatphong.room (Name, Price, CategoryId)
value ('Phòng 101', 300000, 2),
       ('Phòng 102', 200000, 1),
       ('Phòng 103', 500000, 3),
       ('Phòng 201', 300000, 2),
       ('Phòng 202', 200000, 1),
       ('Phòng 203', 500000, 3),
       ('Phòng 301', 800000, 4),
       ('Phòng 302', 200000, 1),
       ('Phòng 303', 500000, 3),
       ('Phòng 401', 800000, 4),
       ('Phòng 402', 200000, 1),
       ('Phòng 403', 500000, 3),
       ('Phòng 501', 800000, 4),
       ('Phòng 502', 300000, 3),
       ('Phòng 601', 2000000, 5);

-- 3.	Bảng Customer ít nhất 3 bản ghi dữ liệu phù hợp
insert into customer (Name, Email, Phone, Address, Gender, BirthDay)
VALUES ('Nguyen Hai Nam','nam@gmail.com','0987657884','Cua lo',0,'1999-01-02'),('Nguyen Van Nghia','nghia@gmail.com','0987234884','Cua bien',0,'1993-04-22'),
       ('Van Thanh Trang', 'trang@gmail.com', '0987652351', 'Ha noi', 1, '2003-04-20');

-- 4.	Bảng Booking ít nhất 3 bản ghi dữ liệu phù hợp, mỗi hóa đơn đặt ít nhất 2 phòng khác nhau
insert into booking (CustomerId) values (1),(2),(3);
insert into bookingdetail (BookingId, RoomId, Price, StartDate, EndDate)
VALUES (1,9,500000,'2024-06-01','2024-06-04'),
       (1,10,800000,'2024-06-01','2024-06-04'),
       (2,6,500000,'2024-05-10','2024-05-13'),
       (2,5,200000,'2024-05-10','2024-05-13'),
       (3,11,200000,'2024-06-01','2024-06-04'),
       (3,15,2000000,'2024-06-01','2024-06-04');
       
# Yêu cầu truy vấn dữ liệu
# Yêu cầu 1 ( Sử dụng lệnh SQL để truy vấn cơ bản ):
# 1.	Lấy ra danh phòng có sắp xếp giảm dần theo Price gồm các cột sau:
# Id, Name, Price, SalePrice, Status, CategoryName, CreatedDate
select R.Id, R.Name, Price, SalePrice, R.Status, C.Name CategoryName, CreatedDate
from Room R
         join Category C on C.Id = r.CategoryId
order by Price desc;

# 2.	Lấy ra danh sách Category gồm: Id, Name, TotalRoom, Status
# (Trong đó cột Status nếu = 0, Ẩn, = 1 là Hiển thị )
select C.Id,
       C.Name,
       count(R.id)                    TotalRoom,
       case C.Status
           when 0 then 'Ẩn'
           when 1 then 'Hiển thị' end Status
from Category C
         join Room R on C.Id = R.CategoryId
group by C.id;

# 3.	Truy vấn danh sách Customer gồm: Id, Name, Email, Phone, Address,
# CreatedDate, Gender, BirthDay, Age (Age là cột suy ra từ BirthDay, Gender
# nếu = 0 là Nam, 1 là Nữ,2 là khác )
select Id,
       Name,
       Email,
       Phone,
       Address,
       CreatedDate,
       case Gender
           when 0 then 'Nam'
           when 1 then 'Nữ'
           else ' Khác' end                gender,
       BirthDay,
       year(curdate()) - year(BirthDay) as Age
from customer;

# 4.	Truy vấn xóa các sản phẩm chưa được bán
-- delete from Room where Id not in (select RoomId from bookingdetail);

# 5.	Cập nhật Cột SalePrice tăng thêm 10% cho tất cả các phòng có
# Price >= 250000
update Room
set SalePrice = 1.1 * Room.SalePrice
where id in (select RoomId.id
             from (select id
                   from room
                   where Price >= 250000) as RoomId);

# Yêu cầu 2 ( Sử dụng lệnh SQL tạo View )
# 1.	View v_getRoomInfo Lấy ra danh sách của 10 phòng có giá cao nhất
create view v_getRoomInfo as
select *
from room
order by Price desc
limit 10;
select *
from v_getRoomInfo;

# 2.	View v_getBookingList hiển thị danh sách phiếu đặt hàng gồm:
# Id, BookingDate, Status, CusName, Email, Phone,TotalAmount
# ( Trong đó cột Status nếu = 0 Chưa duyệt, = 1  Đã duyệt, = 2 Đã thanh toán, = 3 Đã hủy )
create view v_getBookingList as
select B.Id,
       B.BookingDate,
       case B.Status
           when 0 then 'Chưa duyệt'
           when 1 then 'Đã duyệt'
           when 2 then 'Đã thanh toán'
           when 3 then 'Đã hủy' end TrangThai
        ,
       C.Name                       CusName,
       C.Email,
       C.Phone,
       count(BD.BookingId)          TotalAmount
from Booking B
         join Customer C on C.Id = B.CustomerId
         join BookingDetail BD on B.Id = BD.BookingId
group by BD.BookingId;

select *
from v_getBookingList;

# Yêu cầu 3 ( Sử dụng lệnh SQL tạo thủ tục Stored Procedure )
# 1.	Thủ tục addRoomInfo thực hiện thêm mới Room, khi gọi thủ
# tục truyền đầy đủ các giá trị của bảng Room ( Trừ cột tự động tăng )
delimiter //
create procedure addRoomInfo(
     Name_IN varchar(150),  Status_IN tinyint,  Price_IN float,  SalePrice_IN float,  CreatedDate_IN date,
     CategoryId_IN int)
begin
    insert into room(Name, Status, Price, SalePrice, CreatedDate, CategoryId)
        value (Name_IN, Status_IN,Price_IN,SalePrice_IN,CreatedDate_IN,CategoryId_IN);
end //;

call addRoomInfo('Phòng pro',1,200000,170000, '2024-04-04',3);
# 2.	Thủ tục getBookingByCustomerId hiển thị danh sách phieus
# đặt phòng của khách hàng theo Id khách hàng gồm: Id, BookingDate, Status,
# TotalAmount (Trong đó cột Status nếu = 0 Chưa duyệt, = 1  Đã duyệt,
# = 2 Đã thanh toán, = 3 Đã hủy), Khi gọi thủ tục truyền vào id cảu khách hàng
delimiter //
create procedure getBookingByCustomerId(CustomerId_IN int)
begin
    select C.Id, B.BookingDate, case B.Status
                                    when 0 then 'Chưa duyệt'
                                    when 1 then 'Đã duyệt'
                                    when 2 then 'Đã thanh toán'
                                    when 3 then 'Đã hủy' end TrangThai
         , count(BD.BookingId) as TotalAmount
        from booking B join BookingDetail BD on B.Id = BD.BookingId
        join Customer C on C.Id = B.CustomerId
        where C.Id = CustomerId_IN
    group by B.Id, B.BookingDate, B.Status;
    end ;
# drop procedure getBookingByCustomerId;
call getBookingByCustomerId(1);

# 3.	Thủ tục getRoomPaginate lấy ra danh sách phòng có phân trang gồm:
# Id, Name, Price, SalePrice, Khi gọi thủ tuc truyền vào limit và page
delimiter //
create procedure getRoomPaginate(Page_IN int,limit_IN int)
begin
    declare off_set int;
    set off_set = limit_IN * Page_IN;
    select Id, Name, Price, SalePrice
        from room
            limit off_set,limit_IN;
end;
delimiter //

call getRoomPaginate(1,4);

# Yêu cầu 4 ( Sử dụng lệnh SQL tạo Trigger )
# 1.	Tạo trigger tr_Check_Price_Value sao cho khi thêm hoặc sửa phòng
# Room nếu nếu giá trị của cột Price > 5000000 thì tự động chuyển về 5000000
# và in ra thông báo ‘Giá phòng lớn nhất 5 triệu’
delimiter $$
create trigger tr_Check_Price_Value_before_insert
    before insert
    on Room
    for each row
    begin
        if NEW.Price > 5000000
            then set NEW.Price = 5000000;
            signal sqlstate '45000' set message_text = 'Giá phòng lớn nhất là 5 trịu';
        end if;
    end $$;

delimiter $$
create trigger tr_Check_Price_Value_before_update
    before update
    on Room
    for each row
begin
    if NEW.Price > 5000000
    then set NEW.Price = 5000000;
    signal sqlstate '45000' set message_text = 'Giá phòng lớn nhất là 5 trịu';
    end if;
end $$
;
insert into Room (Name, Price, CategoryId) VALUE ('Phòng 801',7000000,4);

# 2.	Tạo trigger tr_check_Room_NotAllow khi thực hiện đặt pòng,
# nếu ngày đến (StartDate) và ngày đi (EndDate) của đơn hiện tại mà
# phòng đã có người đặt rồi thì báo lỗi “Phòng này đã có người đặt
# trong thời gian này, vui lòng chọn thời gian khác”
delimiter $$
create trigger tr_check_Room_NotAllow
    before insert
    on BookingDetail
    for each row
    begin
        if day(StartDate) = day(NEW.StartDate) and DAY(EndDate) = DAY(NEW.EndDate) and RoomId = NEW.RoomId
            then
            signal sqlstate '45000' set message_text = 'Phòng này đã có người đặt';
        end if;
    end $$
    
-- INSERT INTO BookingDetail (bookingId, roomId, price, StartDate, EndDate) VALUES(1, 9, 150000.00, '2024-06-01', '2024-06-04');