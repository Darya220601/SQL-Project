USE [database]
Go
--1. FUNCTION (функция) SCALAR
 --Функция возвращает кол-во адвокатов с опытом работ>=переданного в к-ве параметра
GO
CREATE OR ALTER FUNCTION  getCountLawyers(@Experience INTEGER)
RETURNS INT
BEGIN
	DECLARE @LAWYERS_COUNT INT
	SELECT @LAWYERS_COUNT = COUNT(*) FROM dbo.Lawyers L
			WHERE L.Experience>=@Experience
RETURN @LAWYERS_COUNT
END

GO
--Выполнение функции 1.
DECLARE @Experience INTEGER 
SET @Experience = 3
SELECT dbo.getCountLawyers(@Experience)[Кол-во адвокатов]

----2.FUNCTION (функция) Inline Table-Valued 
--Функция, которая создаёт таблицу со столбцами из Windeals, где месяц = передаваемому в функцию
GO
CREATE OR ALTER FUNCTION selectWin(@month INT)
RETURNS TABLE
AS
RETURN
	SELECT *
		FROM  dbo.WinDeals W
			WHERE MONTH(W.StartDate) = @month

--Выполнение функции 2.
GO
SELECT *FROM dbo.selectWin(4)

---3.FUNCTION (функция) Multi-statement table-valued 
--Функция, которая создаёт таблицу на основе Deals, со строками, где Адвокат = передаваемому в параметры с новым столбцом Class,
--который определяет на основе столбца Bonus к какому классу(примиум/стандарт) относится дело
GO
CREATE OR ALTER FUNCTION fn_Deals(@LawyerID INT)
RETURNS @DEALS_CLASSIFICATION TABLE (
DealID INT PRIMARY KEY,
Lawyer  VARCHAR(40) NOT NULL,
Judge VARCHAR(40) NOT NULL,
CourtDesicion VARCHAR(40) NULL,
Bonus decimal NOT NULL,
Class VARCHAR(10) NULL
)
BEGIN
DECLARE @rowset TABLE (
DealID INT PRIMARY KEY,
Lawyer  VARCHAR(40) NOT NULL,
Judge VARCHAR(40) NOT NULL,
CourtDesicion VARCHAR(40) NULL,
Bonus decimal NOT NULL,
Class VARCHAR(40) default 'Standart' NULL)
INSERT @rowset (DealID,Lawyer,Judge, CourtDesicion,Bonus)
 SELECT D.DealID, L.LawyerName,  J.JudgeName,  D.CourtDecision, D.Bonus
	FROM Deals D
	Left JOIN Judges J ON D.JudgeID = J.JudgeID
	Left JOIN Lawyers L ON D.LawyerID = L.LawyerID
WHERE D.LawyerID = @LawyerID
UPDATE @rowset SET Class='Premium' WHERE Bonus>=70
INSERT @DEALS_CLASSIFICATION
SELECT DealID,Lawyer,Judge,CourtDesicion,Bonus,Class
FROM @rowset
RETURN
END

Go
--Результат выполнения функции 3.
Select *From fn_Deals(4)

--4.Хранимая процедура, которая выбирает Дело по Решению Суда (курсор)
GO
CREATE OR ALTER PROCEDURE ProcDeals
@Decision varchar(20)
AS
DECLARE @id varchar(10), @Lawyer varchar(40), @Judge varchar(40), @Dec varchar(40)
DECLARE myCursor CURSOR LOCAL STATIC FOR
SELECT D.DealID, L.LawyerName,  J.JudgeName,  D.CourtDecision
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
WHERE D.CourtDecision = @Decision
OPEN myCursor
FETCH NEXT FROM myCursor INTO @id, @Lawyer, @Judge, @Dec
WHILE @@FETCH_STATUS = 0
	BEGIN
	  Select @id[IdDeal], @Lawyer[LawyerName], @Judge[JudgeName], @Dec[CourtDesicion]
	  FETCH NEXT FROM myCursor INTO @id, @Lawyer, @Judge, @Dec
	END
CLOSE myCursor 
DEALLOCATE myCursor

--Выполнение процедуры с курсором
GO
EXEC ProcDeals 'win'

--5.Тригер, который запрещает обновление имени судьи
GO
Create OR ALTER TRIGGER TRForJudges
ON Judges
FOR UPDATE AS
IF UPDATE(JudgeName)
BEGIN
PRINT 'You cant update JudgeName'
ROLLBACK TRAN
END

--Проверка работы триггера пункт 5.
GO
UPDATE Judges
SET JudgeName = 'Victor'
WHERE JudgeID =1



-- Хранимая процедура, которая выводит информаацию по судьям, с опытом работы, большим, чем переданный в параметры
Go
CREATE PROCEDURE pr_JudgSel
(@Experience int = 4)
AS
SELECT *
FROM Judges J
WHERE Experience >= @Experience

--Проверка
EXEC pr_JudgSel 8






--3. Хранимая процедура. Выбор процедур, связанных с услугой и/или Цене
GO
CREATE OR ALTER PROCEDURE pr_proceduresForService
@Service VARCHAR(20) = 'litigation',
@Price Money = NULL
AS
IF @Service IS NOT NULL
BEGIN
IF @Price IS NOT NULL
SELECT P.ProcedureID, S.ServiceName, P.Date, P.Price 
FROM Procedures P
    INNER JOIN Services S ON P.Service = S.ServiceID
WHERE S.ServiceName = @Service AND P.Price>=@Price
ELSE
SELECT P.ProcedureID, S.ServiceName, P.Date, P.Price 
FROM Procedures P
    INNER JOIN Services S ON P.Service = S.ServiceID
WHERE S.ServiceName = @Service
END
ELSE
IF @Price IS NOT NULL
SELECT P.ProcedureID, S.ServiceName, P.Date, P.Price 
FROM Procedures P
    INNER JOIN Services S ON P.Service = S.ServiceID
WHERE P.Price>=@Price

Exec pr_proceduresForService
Exec pr_proceduresForService

--4. Хранимая процедура. Выводит процедуры с самой дорогой услугой
GO
CREATE OR ALTER PROCEDURE pr_proceduresForMaxServicePrice
AS
SELECT P.ProcedureID, S.ServiceName, P.Date, P.Price 
FROM Procedures P
    INNER JOIN Services S ON P.Service = S.ServiceID
WHERE P.Price = 
	(SELECT MAX(P.Price) FROM Procedures P)

Exec pr_proceduresForMaxServicePrice

--5.-- Хранимая процедура, которая выводит ннформацию по делам определённого клиента с сортировкой по дате
GO
CREATE OR ALTER PROCEDURE pr_ClientsDeals
@Client VARCHAR(40) = 'Verushkina Olga'
AS
SELECT D.DealID, C.ClientName, L.LawyerName,  J.JudgeName, D.Sense, D.StartDate, D.EndDate, D.CourtDecision, D.Bonus
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	INNER JOIN Clients C ON D.ClientID = C.CLientID
	WHERE C.ClientName = @Client
	ORDER BY D.StartDate

	EXEC pr_ClientsDeals
	
	--Триггер, который выводит разницу между ценами услуг, при изменении цены услуги
	GO
	Create OR ALTER TRIGGER TRForserviceWithCursos
ON Services
FOR UPDATE AS
IF UPDATE(ServicePrice)
BEGIN
	DECLARE MyCursor CURSOR 
	FOR SELECT ServiceName, ServicePrice
	FROM Services ORDER BY ServicePrice DESC
OPEN MyCursor
DECLARE @Name varchar(50), @Price money, @PrevPrice money
FETCH NEXT FROM MyCursor INTO @Name, @Price
WHILE @@FETCH_STATUS = 0
	BEGIN
--> действия со строками курсора
	  SELECT @Name[Service], @Price[Price], @PrevPrice - @Price[PreviousPrice]
	  SET @PrevPrice = @Price
	  FETCH NEXT FROM MyCursor INTO @Name, @Price
	END
CLOSE MyCursor 
DEALLOCATE MyCursor
END

GO
UPDATE Services
SET ServicePrice = 120
WHERE ServicePrice =1