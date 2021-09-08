USE [database]
Go
--1. FUNCTION (�������) SCALAR
 --������� ���������� ���-�� ��������� � ������ �����>=����������� � �-�� ���������
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
--���������� ������� 1.
DECLARE @Experience INTEGER 
SET @Experience = 3
SELECT dbo.getCountLawyers(@Experience)[���-�� ���������]

----2.FUNCTION (�������) Inline Table-Valued 
--�������, ������� ������ ������� �� ��������� �� Windeals, ��� ����� = ������������� � �������
GO
CREATE OR ALTER FUNCTION selectWin(@month INT)
RETURNS TABLE
AS
RETURN
	SELECT *
		FROM  dbo.WinDeals W
			WHERE MONTH(W.StartDate) = @month

--���������� ������� 2.
GO
SELECT *FROM dbo.selectWin(4)

---3.FUNCTION (�������) Multi-statement table-valued 
--�������, ������� ������ ������� �� ������ Deals, �� ��������, ��� ������� = ������������� � ��������� � ����� �������� Class,
--������� ���������� �� ������ ������� Bonus � ������ ������(�������/��������) ��������� ����
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
--��������� ���������� ������� 3.
Select *From fn_Deals(4)

--4.�������� ���������, ������� �������� ���� �� ������� ���� (������)
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

--���������� ��������� � ��������
GO
EXEC ProcDeals 'win'

--5.������, ������� ��������� ���������� ����� �����
GO
Create OR ALTER TRIGGER TRForJudges
ON Judges
FOR UPDATE AS
IF UPDATE(JudgeName)
BEGIN
PRINT 'You cant update JudgeName'
ROLLBACK TRAN
END

--�������� ������ �������� ����� 5.
GO
UPDATE Judges
SET JudgeName = 'Victor'
WHERE JudgeID =1



-- �������� ���������, ������� ������� ����������� �� ������, � ������ ������, �������, ��� ���������� � ���������
Go
CREATE PROCEDURE pr_JudgSel
(@Experience int = 4)
AS
SELECT *
FROM Judges J
WHERE Experience >= @Experience

--��������
EXEC pr_JudgSel 8






--3. �������� ���������. ����� ��������, ��������� � ������� �/��� ����
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

--4. �������� ���������. ������� ��������� � ����� ������� �������
GO
CREATE OR ALTER PROCEDURE pr_proceduresForMaxServicePrice
AS
SELECT P.ProcedureID, S.ServiceName, P.Date, P.Price 
FROM Procedures P
    INNER JOIN Services S ON P.Service = S.ServiceID
WHERE P.Price = 
	(SELECT MAX(P.Price) FROM Procedures P)

Exec pr_proceduresForMaxServicePrice

--5.-- �������� ���������, ������� ������� ���������� �� ����� ������������ ������� � ����������� �� ����
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
	
	--�������, ������� ������� ������� ����� ������ �����, ��� ��������� ���� ������
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
--> �������� �� �������� �������
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