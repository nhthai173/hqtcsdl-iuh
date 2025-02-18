USE AdventureWorks2008R2
-- 1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau: 
    CREATE TABLE MyDepartment (
        DepID SMALLINT NOT NULL PRIMARY KEY,
        DepName NVARCHAR(50),
        GrpName NVARCHAR(50)
    )

    CREATE TABLE MyEmployee (
        EmpID INT NOT NULL PRIMARY KEY,
        FrstName NVARCHAR(50),
        MidName NVARCHAR(50),
        LstName NVARCHAR(50),
        DepID SMALLINT NOT NULL FOREIGN KEY REFERENCES MyDepartment(DepID)
    )

ALTER TABLE MyEmployee DROP CONSTRAINT FK_MyEmployee_DepID;
DROP TABLE MyDepartment;




-- 2)	Dùng 	lệnh 	insert 	<TableName1> 	select 	<fieldList> 	from 
-- <TableName2>  chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ bảng [HumanResources].[Department]. 
    INSERT INTO MyDepartment (DepID, DepName, GrpName)
    SELECT HumanResources.Department.DepartmentID, HumanResources.Department.Name, HumanResources.Department.GroupName 
    FROM HumanResources.Department

-- 3)	Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee 
--      lấy dữ liệu từ 2 bảng  [Person].[Person] và  [HumanResources].[EmployeeDepartmentHistory] 
    INSERT INTO MyEmployee(EmpID,FrstName,MidName,LstName,DepID)
    SELECT TOP 20 Person.Person.BusinessEntityID,Person.Person.FirstName,Person.Person.MiddleName,Person.Person.LastName,HumanResources.EmployeeDepartmentHistory.DepartmentID
    FROM Person.Person
    JOIN HumanResources.EmployeeDepartmentHistory ON Person.Person.BusinessEntityID = HumanResources.EmployeeDepartmentHistory.BusinessEntityID
    
-- 4)	Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1, có thực hiện được không? Vì sao? 
    DELETE FROM MyDepartment WHERE MyDepartment.DepID = 1
    -- không thể xóa được vì có ràng buộc khóa ngoại với bảng MyEmployee

-- 5)	Thêm một default constraint vào field DepID trong bảng MyEmployee, với giá trị mặc định là 1. 
    ALTER TABLE MyDepartment 
    ADD CONSTRAINT DF_MyDepartment_DepID DEFAULT 1 FOR DepID

-- 6)	Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau: 
--      insert into MyEmployee (EmpID, FrstName, MidName, LstName) values(1, 'Nguyen','Nhat','Nam'). 
--      Quan sát giá trị trong field depID của record mới thêm. 
    INSERT INTO MyEmployee (EmpID, FrstName, MidName, LstName) VALUES (1, 'Phat', 'Phu', 'Thai')
    -- không thể chèn vô được vì lỗi ràng buộc khóa ngoại , trường DepID không được chỉ định
    SELECT * FROM MyEmployee

-- 7)	Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại 
--      DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on delete set default. 
    ALTER TABLE MyEmployee
    DROP CONSTRAINT FK_MyEmployee_DepID

    ALTER TABLE MyEmployee
    ADD CONSTRAINT FK_MyEmployee_DepID FOREIGN KEY (DepID) REFERENCES MyDepartment(DepID) ON DELETE SET DEFAULT

-- 8)	Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả trong hai bảng MyEmployee và MyDepartment
    DELETE FROM MyDepartment WHERE DepID = 7

    -- không thể xóa do lỗi từ 
    -- Msg 547, Level 16, State 0, Line 75
    -- The DELETE statement conflicted with the FOREIGN KEY constraint "FK_MyEmployee_DepID". The conflict occurred in database "AdventureWorks2008R2", table "dbo.MyDepartment", column 'DepID'.
    -- The statement has been terminated.

    -- Completion time: 2025-02-01T21:58:42.4140247+07:00
    -- nên thay vì dùng on delete set default thì dùng on delete cascade


    ALTER TABLE MyEmployee
    DROP CONSTRAINT FK_MyEmployee_DepID

    ALTER TABLE MyEmployee
    ADD CONSTRAINT FK_MyEmployee_DepID FOREIGN KEY (DepID) REFERENCES MyDepartment(DepID) ON DELETE CASCADE

    DELETE FROM MyDepartment WHERE DepID = 7
    SELECT * FROM MyEmployee
    SELECT * FROM MyDepartment

  
-- 9)	Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete cascade và on update cascade 
    ALTER TABLE MyEmployee
    DROP CONSTRAINT FK_MyEmployee_DepID

    ALTER TABLE MyEmployee
    ADD CONSTRAINT FK_MyEmployee_DepID FOREIGN KEY (DepID) REFERENCES MyDepartment(DepID) ON DELETE CASCADE ON UPDATE CASCADE

-- 10)	Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có thực hiện được không? 
    DELETE FROM MyDepartment WHERE DepID = 3
    --khong the xoa duoc vi co rang buoc khoa ngoai voi bang MyEmployee


-- 11)	Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho phép nhận thêm những Department thuộc group Manufacturing 
    ALTER TABLE MyDepartment
    ADD CONSTRAINT GrpName_CHECK
    CHECK (GrpName = 'Manufacturing')

-- 12)	Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột 
-- BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60 
    ALTER TABLE HumanResources.Employee
    ADD CONSTRAINT CK_HR_EmployeeAge
    CHECK (DATEDIFF(YEAR, BirthDate, GETDATE()) >=  18 AND DATEDIFF(YEAR, BirthDate, GETDATE()) <= 60)
