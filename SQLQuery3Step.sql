USE [database]
GO

--Создать новую таблицу "WinDeals", и вывести все судебные дела, состоящие из столбцов "Решение", 
--"Дата начала", "Имя судьи", "Бонус", "Имя адвоката", где Решение судьи - выигрыш. Сделать сортировку по столбцу "Дата"
SELECT D.CourtDecision, D.Bonus, D.StartDate, J.JudgeName, L.LawyerName
	INTO dbo.WinDeals
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	WHERE D.CourtDecision = 'win'
		ORDER BY D.StartDate DESC
		SELECT* FROM WinDeals
		
		--Добавить в таблицу "WinDeals" поле "Комиссия из бонуса"
		ALTER TABLE WinDeals ADD Commision CHAR (20);
		
		SELECT* FROM WinDeals

		--- Заполнить стоблец "Комиссия' значениями, который рассчитывается по формуле: Bonus*0.1
		UPDATE WinDeals  SET Commision = Bonus*0.1 
		SELECT* FROM WinDeals

		--4.4. Обновить значения в поля "Commision" на Bonus*0.2, если Bonus>=70
		UPDATE WinDeals  SET Commision = Bonus*0.2
		WHERE Bonus >= 70
		SELECT* FROM WinDeals

		--5.1. Составить запрос на языке SQL, отображающий все поля таблицы Lawyers,опыт работы у адвоката большн либо равен 3
		SELECT*FROM Lawyers
		WHERE Experience>=3 

		--5.2. Составить запрос на языке SQL, отображающий все поля таблицы Lawyers,где цена больше 20 и меньше 45
		--Отсортировать по полю "LawyerPrice", если совпадут, то по "Experinece"
		SELECT*FROM Lawyers
		WHERE LawyerPrice > 20 AND LawyerPrice < 45
		ORDER BY LawyerPrice, Experience

		-- 5.4. Составить запрос на языке SQL, который  выведет список Адвокатов с подсчеетов общей суммы полученных бонусов 
		SELECT  L.LawyerName,
		SUM(Bonus) AS [Сумма бонусов]
		FROM Deals D
	    INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
		GROUP BY L.LawyerName

		--5.5 Создать запрос с выполнением групповой операции над данными,
		--выбранными из нескольких таблиц, с отбором определенных групп и сортировкой в обратном порядке.
		--Вывести все бонусы каждого адвоката, сумма которых, бонусы для которых составляют больше 70
		--
		SELECT  L.LawyerName,
		SUM(Bonus) AS [Сумма бонусов]
		FROM Deals D
	    INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
		GROUP BY L.LawyerName
		HAVING Sum([Bonus])>=70
		ORDER BY [Сумма бонусов] DESC

		--5.6. Разработать запрос на языке SQL, результирующая таблица которого соответствовала бы по структуре записи дочерней таблице, 
		--но коды в полях внешнего ключа заменить соответствующими им наименованиями из родительских таблиц. 
		--сортировка по дате, если дата совпадает - по бонусам.
		SELECT D.DealID, L.LawyerName, D.ProcedureID, C.ClientName, J.JudgeName, D.Sense, D.StartDate, D.EndDate, D.CourtDecision, D.Bonus
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	INNER JOIN Clients C ON D.ClientID = C.CLientID
		ORDER BY D.StartDate, D.Bonus

		--6.1. Разработать запрос на языке SQL для создания представления, на основе запроса на выборку, имеющего достаточно сложную структуру, чтобы сохранить его в виде представления.
		--сортировка по дате, если дата совпадает - по бонусам.
		USE [database]
        GO
		CREATE VIEW NewDeals AS
		 SELECT D.DealID, L.LawyerName, D.ProcedureID, C.ClientName, J.JudgeName, D.Sense, D.StartDate, D.EndDate, D.CourtDecision, D.Bonus
	FROM Deals D
	INNER JOIN Judges J ON D.JudgeID = J.JudgeID
	INNER JOIN Lawyers L ON D.LawyerID = L.LawyerID
	INNER JOIN Clients C ON D.ClientID = C.CLientID
	WHERE Month(D.StartDate) = 3
	


		


