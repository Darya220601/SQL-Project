USE [database]
GO

--������� ����� ������� "WinDeals", � ������� ��� �������� ����, ��������� �� �������� "�������", 
--"���� ������", "��� �����", "�����", "��� ��������", ��� ������� ����� - �������. ������� ���������� �� ������� "����"
SELECT D.CourtDecision, D.Bonus, D.StartDate, J.JudgeName, L.LawyerName
	INTO dbo.WinDeals
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	WHERE D.CourtDecision = 'win'
		ORDER BY D.StartDate DESC
		SELECT* FROM WinDeals
		
		--�������� � ������� "WinDeals" ���� "�������� �� ������"
		ALTER TABLE WinDeals ADD Commision CHAR (20);
		
		SELECT* FROM WinDeals

		--- ��������� ������� "��������' ����������, ������� �������������� �� �������: Bonus*0.1
		UPDATE WinDeals  SET Commision = Bonus*0.1 
		SELECT* FROM WinDeals

		--4.4. �������� �������� � ���� "Commision" �� Bonus*0.2, ���� Bonus>=70
		UPDATE WinDeals  SET Commision = Bonus*0.2
		WHERE Bonus >= 70
		SELECT* FROM WinDeals

		--5.1. ��������� ������ �� ����� SQL, ������������ ��� ���� ������� Lawyers,���� ������ � �������� ������ ���� ����� 3
		SELECT*FROM Lawyers
		WHERE Experience>=3 

		--5.2. ��������� ������ �� ����� SQL, ������������ ��� ���� ������� Lawyers,��� ���� ������ 20 � ������ 45
		--������������� �� ���� "LawyerPrice", ���� ��������, �� �� "Experinece"
		SELECT*FROM Lawyers
		WHERE LawyerPrice > 20 AND LawyerPrice < 45
		ORDER BY LawyerPrice, Experience

		-- 5.4. ��������� ������ �� ����� SQL, �������  ������� ������ ��������� � ���������� ����� ����� ���������� ������� 
		SELECT  L.LawyerName,
		SUM(Bonus) AS [����� �������]
		FROM Deals D
	    INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
		GROUP BY L.LawyerName

		--5.5 ������� ������ � ����������� ��������� �������� ��� �������,
		--���������� �� ���������� ������, � ������� ������������ ����� � ����������� � �������� �������.
		--������� ��� ������ ������� ��������, ����� �������, ������ ��� ������� ���������� ������ 70
		--
		SELECT  L.LawyerName,
		SUM(Bonus) AS [����� �������]
		FROM Deals D
	    INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
		GROUP BY L.LawyerName
		HAVING Sum([Bonus])>=70
		ORDER BY [����� �������] DESC

		--5.6. ����������� ������ �� ����� SQL, �������������� ������� �������� ��������������� �� �� ��������� ������ �������� �������, 
		--�� ���� � ����� �������� ����� �������� ���������������� �� �������������� �� ������������ ������. 
		--���������� �� ����, ���� ���� ��������� - �� �������.
		SELECT D.DealID, L.LawyerName, D.ProcedureID, C.ClientName, J.JudgeName, D.Sense, D.StartDate, D.EndDate, D.CourtDecision, D.Bonus
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	INNER JOIN Clients C ON D.ClientID = C.CLientID
		ORDER BY D.StartDate, D.Bonus

		--6.1. ����������� ������ �� ����� SQL ��� �������� �������������, �� ������ ������� �� �������, �������� ���������� ������� ���������, ����� ��������� ��� � ���� �������������.
		--���������� �� ����, ���� ���� ��������� - �� �������.
		USE [database]
        GO
		CREATE VIEW NewDeals AS
		 SELECT D.DealID, L.LawyerName, D.ProcedureID, C.ClientName, J.JudgeName, D.Sense, D.StartDate, D.EndDate, D.CourtDecision, D.Bonus
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	INNER JOIN Clients C ON D.ClientID = C.CLientID
	WHERE Month(D.StartDate) = 3
	


		


