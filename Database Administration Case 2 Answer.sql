USE Sociolla

--1. Create a new job with the following detail:
USE [msdb]
GO

/****** Object:  Job [Quarterly Report]    Script Date: 11/06/2020 18:57:42 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 11/06/2020 18:57:42 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Quarterly Report', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Generate quarterly report of all transactions that occur', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'System Administrator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1]    Script Date: 11/06/2020 18:57:42 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SELECT HeaderTransaction.TransactionID,
	CustomerName,
	StaffName,
	TransactionDate,
	COUNT(DetailTransaction.ItemID) AS [Total Item],
	SUM(Quantity) AS [Total Quantity],
	SUM(Quantity*ItemPrice) AS [Total Purchases]
FROM MsItem JOIN DetailTransaction
ON MsItem.ItemID = DetailTransaction.ItemID
JOIN HeaderTransaction
ON DetailTransaction.TransactionID = HeaderTransaction.TransactionID
JOIN MsStaff 
ON HeaderTransaction.StaffID = MsStaff.StaffID
JOIN MsCustomer 
ON HeaderTransaction.CustomerID = MsCustomer.CustomerID
WHERE TransactionDate BETWEEN DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0) AND DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)) 
GROUP BY HeaderTransaction.TransactionID,
	CustomerName,
	StaffName,
	TransactionDate', 
		@database_name=N'Sociolla', 
		@output_file_name=N'D:\BINUS\SEMESTER 4\Database Administration\UAP\ReportDetails.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FirstSchedule', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=16, 
		@freq_recurrence_factor=3, 
		@active_start_date=20200611, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'bb53e18b-ae10-4a6c-ba58-b34a974cd5be'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
--QUERY:
SELECT HeaderTransaction.TransactionID,
	CustomerName,
	StaffName,
	TransactionDate,
	COUNT(DetailTransaction.ItemID) AS [Total Item],
	SUM(Quantity) AS [Total Quantity],
	SUM(Quantity*ItemPrice) AS [Total Purchases]
FROM MsItem JOIN DetailTransaction
ON MsItem.ItemID = DetailTransaction.ItemID
JOIN HeaderTransaction
ON DetailTransaction.TransactionID = HeaderTransaction.TransactionID
JOIN MsStaff 
ON HeaderTransaction.StaffID = MsStaff.StaffID
JOIN MsCustomer 
ON HeaderTransaction.CustomerID = MsCustomer.CustomerID
WHERE TransactionDate BETWEEN DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0) AND DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)) 
GROUP BY HeaderTransaction.TransactionID,
	CustomerName,
	StaffName,
	TransactionDate

--2. Create a new job with the following detail:
USE [msdb]
GO

/****** Object:  Job [Remaining Stock Report]    Script Date: 11/06/2020 19:05:29 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 11/06/2020 19:05:29 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Remaining Stock Report', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Generate a report to print out the remaining stock of every item', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'System Administrator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [StepUno]    Script Date: 11/06/2020 19:05:29 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'StepUno', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SELECT MsItem.ItemID,
	ItemName,
	ItemStock - SUM(Quantity) AS [Remaining]
FROM MsItem
JOIN DetailTransaction
ON MsItem.ItemID = DetailTransaction.ItemID
GROUP BY MsItem.ItemID,
	ItemName,
	ItemStock
', 
		@database_name=N'Sociolla', 
		@output_file_name=N'D:\BINUS\SEMESTER 4\Database Administration\UAP\RemainingStock.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'UnoSchedule', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=10, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=16, 
		@freq_recurrence_factor=2, 
		@active_start_date=20200611, 
		@active_end_date=99991231, 
		@active_start_time=223000, 
		@active_end_time=235959, 
		@schedule_uid=N'daa80705-04f5-4443-adbe-5ce2db60c131'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
--QUERY:
SELECT MsItem.ItemID,
	ItemName,
	ItemStock - SUM(Quantity) AS [Remaining]
FROM MsItem
JOIN DetailTransaction
ON MsItem.ItemID = DetailTransaction.ItemID
GROUP BY MsItem.ItemID,
	ItemName,
	ItemStock

--3. Create a stored procedure named “ValidateItem” that retrieves ItemID, ItemName, ItemStock, ItemPrice, 
--ItemBrand and ItemCategory as a parameter. There are several validations that must be made:
CREATE PROC ValidateItem(@id VARCHAR(100), @name VARCHAR(100), @stock INT, @price BIGINT, @brand VARCHAR(100), @category VARCHAR(100))
AS
	IF EXISTS(SELECT * FROM MsItem WHERE ItemID = @id AND ItemName = @name)
	BEGIN
		PRINT 'Item already exists'
	END
	ELSE IF EXISTS(SELECT * FROM MsItem WHERE ItemName = @name AND ItemID != @id)
	BEGIN
		PRINT 'This item already exists with different ID'
	END
	ELSE IF EXISTS(SELECT * FROM MsItem WHERE ItemID = @id AND ItemName != @name)
	BEGIN
		PRINT 'ID must be unique!'
	END
	ELSE IF NOT EXISTS(SELECT * FROM MsItem WHERE ItemId = @id AND ItemName = @name)
	BEGIN
		INSERT INTO MsItem(ItemID, ItemName, ItemStock, ItemPrice, ItemBrandID, ItemCategoryID)
		VALUES(@id, @name, @stock, @price, @brand, @category)
	END
EXEC ValidateItem 'IT034', 'Ki Gold Set', 23, 100000, 'IB001', 'IC001'
EXEC ValidateItem 'IT035', 'Ki Gold Set', 23, 100000, 'IB001', 'IC001'
EXEC ValidateItem 'IT034', 'Mediheal Set', 23, 100000, 'IB001', 'IC001'
EXEC ValidateItem 'IT035', 'Mediheal Set', 23, 100000, 'IB001', 'IC001'
SELECT * FROM MsItem WHERE ItemID = 'IT035'

--4. Create a stored procedure named RemoveItem that retrieves ItemID as a parameter. 
--Validate if the item doesn’t exist, print ‘Item doesn’t exist’. Then check if the item is in the Top 5 Most Selling Item 
--(obtained by taking 5 data from the sum of Quantity), print ‘Item cannot be deleted because it is in the Top 5’. 
--If the item isn’t in the Top 5 Most Selling Item, it will update the Item Stock to 0 instead.
CREATE PROC RemoveItem(@id VARCHAR(100))
AS
	IF NOT EXISTS(SELECT * FROM MsItem WHERE ItemId = @id)
	BEGIN
		PRINT 'Item doesn''t exists'
	END
	ELSE IF EXISTS(SELECT * FROM MsItem WHERE ItemID = @id)
	BEGIN
		DECLARE riCursor CURSOR FOR
		SELECT TOP 5
		MsItem.ItemID, SUM(Quantity) AS tot
		FROM MsItem JOIN DetailTransaction
		ON MsItem.ItemID = DetailTransaction.ItemID
		GROUP BY MsItem.ItemID
		ORDER BY tot DESC

		DECLARE @idTop VARCHAR(100), @sumTop INT
		DECLARE @flag INT
		SET @flag = 0

		OPEN riCursor
		FETCH NEXT FROM riCursor INTO @idTop, @sumTop
		WHILE @@FETCH_STATUS=0
			BEGIN
				IF(@id=@idTop)
				BEGIN
					SET @flag = 1
					PRINT 'Item cannot deleted because it is in the Top 5'
				END
				FETCH NEXT FROM riCursor INTO @idTop, @sumTop
			END

		IF(@flag = 0)
		BEGIN
			UPDATE MsItem
			SET ItemStock = 0
			WHERE ItemID = @id
		END

		CLOSE riCursor
		DEALLOCATE riCursor
	END
EXEC RemoveItem 'IT035'
EXEC RemoveItem 'IT001'
EXEC RemoveItem 'IT023'
SELECT * FROM MsItem WHERE ItemID = 'IT023'

--5. Create a stored procedure named DeleteItem that retrieves an Item ID as a parameter. 
--Validate if the item doesn’t exist, print ‘Item doesn’t exist’. Then check if the item has never been bought, delete the item. 
--If the item has been bought before, then print ‘Item cannot be removed’. Display after executing an Item ID that doesn’t exist:
CREATE PROC DeleteItem(@id VARCHAR(100))
AS
	IF NOT EXISTS(SELECT * FROM MsItem WHERE ItemId = @id)
	BEGIN
		PRINT 'Item doesn''t exists'
	END
	ELSE IF EXISTS(SELECT * FROM MsItem WHERE ItemID = @id)
	BEGIN
		DECLARE diCursor CURSOR FOR
		SELECT ItemID
		FROM DetailTransaction

		DECLARE @idDet VARCHAR(100)
		DECLARE @flag INT
		SET @flag = 0

		OPEN diCursor
		FETCH NEXT FROM diCursor INTO @idDet
		WHILE @@FETCH_STATUS=0
			BEGIN
				IF(@id=@idDet)
				BEGIN
					SET @flag = 1
				END
				FETCH NEXT FROM diCursor INTO @idDet
			END

		IF(@flag = 1)
		BEGIN
			PRINT 'Item cannot be removed'
		END
		ELSE IF(@flag = 0)
		BEGIN
			DELETE FROM MsItem
			WHERE ItemID = @id
		END

		CLOSE diCursor
		DEALLOCATE diCursor
	END
EXEC DeleteItem 'IT035'
EXEC DeleteItem 'IT001'
EXEC DeleteItem 'IT034'
SELECT * FROM MsItem WHERE ItemID = 'IT034'

--6. Create a trigger named InsertItemTrigger on the MsItem table that will be triggered when an Insert action occurred on the MsItem table. 
--This trigger will check whether the inserted data meets the required constraint. 
--Print out messages on the Messages tab on every error that occurred.
CREATE TRIGGER InsertItemTrigger
ON MsItem
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id VARCHAR(100), @name VARCHAR(100), @stock INT, @price BIGINT, @brand VARCHAR(100), @category VARCHAR(100)
	SELECT @id = ItemID,
		@name = ItemName,
		@stock = ItemStock,
		@price = ItemPrice,
		@brand = ItemBrandID,
		@category = ItemCategoryID
	FROM INSERTED

	DECLARE @flag INT
	SET @flag = 0

	IF EXISTS(SELECT * FROM MsItem WHERE ItemID = @id)
	BEGIN
		PRINT 'Item ID already exists'
		SET @flag = 1
	END
	ELSE IF(@id NOT LIKE 'IT[0-9][0-9][0-9]')
	BEGIN
		PRINT 'Item ID must be in the right format'
		SET @flag = 1
	END
	ELSE IF(@stock < 10)
	BEGIN
		PRINT 'Item Stock must be greater than 10'
		SET @flag = 1
	END
	ELSE IF(@brand NOT LIKE 'IB[0-9][0-9][0-9]')
	BEGIN
		PRINT 'Item Brand must be in the right format'
		SET @flag = 1
	END
	ELSE IF NOT EXISTS(SELECT * FROM MsItemBrand WHERE ItemBrandID = @brand)
	BEGIN
		PRINT @brand + ' doesn''t exists'
		SET @flag = 1
	END
	ELSE IF(@category NOT LIKE 'IC[0-9][0-9][0-9]')
	BEGIN
		PRINT 'Item Category must be in the right format'
		SET @flag = 1
	END
	ELSE IF NOT EXISTS(SELECT * FROM MsItemCategory WHERE ItemCategoryID = @category)
	BEGIN
		PRINT @category + ' doesn''t exists'
		SET @flag = 1
	END
	
	INSERT MsItem(ItemID, ItemName, ItemStock, ItemPrice, ItemBrandID, ItemCategoryID)
		SELECT ItemID, ItemName, ItemStock, ItemPrice, ItemBrandID, ItemCategoryID
		FROM inserted
		WHERE @flag = 0
END
INSERT INTO MsItem VALUES('IT035', 'Mediheal Set', 14, 300000, 'IB015', 'IC005')
SELECT * FROM MsItem WHERE ItemID = 'IT035'

--7. Create a trigger named RefundTransaction on the HeaderTransaction table that will be triggered when 
--an update action occurred on the HeaderTransaction table. An update on HeaderTransaction will only occur 
--if there’s a refund transaction. Therefore, there are some changes that need to be made:
CREATE TRIGGER RefundTransaction
ON HeaderTransaction
FOR UPDATE
AS	
	CREATE TABLE temp(
		TransactionID VARCHAR(255) PRIMARY KEY,
		CustomerID VARCHAR(255),
		StaffID VARCHAR(255),
		PaymentTypeID VARCHAR(255),
		TransactionDate DATE
	)
	INSERT INTO temp
	SELECT HeaderTransaction.TransactionID, HeaderTransaction.CustomerID, HeaderTransaction.StaffID, deleted.PaymentTypeID, deleted.TransactionDate
	FROM HeaderTransaction JOIN deleted
	ON HeaderTransaction.TransactionID = deleted.TransactionID

	BEGIN
		DECLARE rtCursor CURSOR FOR
		SELECT temp.CustomerID, 
			Quantity, 
			ItemStock, 
			HeaderTransaction.TransactionDate, 
			temp.TransactionDate, 
			HeaderTransaction.PaymentTypeID, 
			temp.PaymentTypeID,
			DetailTransaction.ItemID
		FROM MsItem JOIN DetailTransaction 
		ON MsItem.ItemID = DetailTransaction.ItemID
		JOIN HeaderTransaction
		ON DetailTransaction.TransactionID = HeaderTransaction.TransactionID
		JOIN temp
		ON HeaderTransaction.TransactionID = temp.TransactionID
		
		DECLARE @cust VARCHAR(255), @qua INT, @stk INT, @newDate DATE, @oldDate DATE, @newPay VARCHAR(255), @oldPay VARCHAR(255), @iid VARCHAR(255)
		
		OPEN rtCursor
		FETCH NEXT FROM rtCursor INTO @cust, @qua, @stk, @newDate, @oldDate, @newPay, @oldPay, @iid
			BEGIN
				PRINT 'Old Transaction'
				PRINT '======================'
				PRINT 'Payment Type: ' + @oldPay
				PRINT 'Transaction Date: ' + CONVERT(VARCHAR, @oldDate, 23)
				PRINT 'Previous Stock: ' + CAST(@stk AS VARCHAR)
				PRINT ' '

				SET @newDate = GETDATE()
				UPDATE HeaderTransaction 
				SET TransactionDate = GETDATE()
				WHERE CustomerID = @cust
				UPDATE MsItem
				SET ItemStock = @qua+@stk
				WHERE ItemID = @iid

				PRINT 'New Transaction'
				PRINT '======================'
				PRINT 'Payment Type: ' + @newPay
				PRINT 'Transaction Date: ' + CONVERT(VARCHAR, @newDate, 23)
				PRINT 'New Stock: ' + CAST(@qua+@stk AS VARCHAR)
			END
		CLOSE rtCursor
		DEALLOCATE rtCursor
	END
UPDATE HeaderTransaction SET PaymentTypeID = 'PT007' WHERE CustomerID = 'CS001'

--8. Create a stored procedure named PrintReceipt that retrieves Transaction ID as a parameter and 
--combined with a cursor to display the detail of the inserted Transaction ID. 
--Validate if the inserted Transaction ID doesn’t exist, print ‘Transaction ID doesn’t exist’.
CREATE PROC PrintReceipt(@id VARCHAR(100))
AS
	IF NOT EXISTS(SELECT * FROM HeaderTransaction WHERE TransactionID = @id)
	BEGIN
		PRINT 'Transaction ID doesn''t exists'
	END
	ELSE IF EXISTS(SELECT * FROM HeaderTransaction WHERE TransactionID = @id)
	BEGIN
		DECLARE prCursor CURSOR FOR
		SELECT CustomerName,
		TransactionDate,
		StaffName, 
		PaymentTypeName,
		ItemName,
		Quantity,
		ItemBrandName,
		ItemCategoryName,
		ItemPrice
		FROM HeaderTransaction JOIN MsStaff
		ON HeaderTransaction.StaffID = MsStaff.StaffID
		JOIN MsPaymentType 
		ON HeaderTransaction.PaymentTypeID = MsPaymentType.PaymentTypeID
		JOIN MsCustomer
		ON HeaderTransaction.CustomerID = MsCustomer.CustomerID
		JOIN DetailTransaction
		ON HeaderTransaction.TransactionID = DetailTransaction.TransactionID
		JOIN MsItem
		ON DetailTransaction.ItemID = MsItem.ItemID
		JOIN MsItemBrand
		ON MsItem.ItemBrandID = MsItemBrand.ItemBrandID
		JOIN MsItemCategory
		ON MsItem.ItemCategoryID = MsItemCategory.ItemCategoryID
		WHERE HeaderTransaction.TransactionID = @id
		
		DECLARE @cn VARCHAR(100), @td DATE, @sn VARCHAR(255), @ptn VARCHAR(255), @in VARCHAR(255), @q INT, @ibn VARCHAR(255), @icn VARCHAR(255), @ip BIGINT

		OPEN prCursor
		FETCH NEXT FROM prCursor INTO @cn, @td, @sn, @ptn, @in, @q, @ibn, @icn, @ip
		PRINT 'Hi ' + @cn
		PRINT 'Here are your shopping details'
		PRINT 'Transaction Date: ' + CONVERT(VARCHAR, @td, 107)
		PRINT 'Cashier: ' + @sn
		PRINT 'Payment: ' + @ptn
		PRINT '-------------------------------------------'
		DECLARE @totalQuantity INT, @totalPrice INT
		SET @totalQuantity = 0
		SET @totalPrice = 0

		WHILE @@FETCH_STATUS=0
		BEGIN
			PRINT 'Item: ' + @in
			PRINT 'Quantity: ' + CAST(@q AS VARCHAR)
			PRINT 'Brand: ' + @ibn
			PRINT 'Category: ' + @icn
			PRINT 'Price per item: ' + CAST(@ip AS VARCHAR)
			PRINT 'Total: ' + CAST(@ip*@q AS VARCHAR)
			PRINT '-------------------------------------------'
			SET @totalQuantity = @totalQuantity + @q
			SET @totalPrice = @totalPrice + (@ip*@q)

			FETCH NEXT FROM prCursor INTO @cn, @td, @sn, @ptn, @in, @q, @ibn, @icn, @ip
		END
		CLOSE prCursor
		PRINT 'Total Item: ' + CAST(@totalQuantity AS VARCHAR)
		PRINT 'Total Price: ' + CAST(@totalPrice AS VARCHAR)
		
		DEALLOCATE prCursor
	END
EXEC PrintReceipt 'TR025'

--9. Create a stored procedure named SearchItem that retrieves Brand as a keyword in the parameter 
--combined with a cursor to display items from the inserted Brand.
CREATE PROC SearchItem(@name VARCHAR(100))
AS
	IF(LEN(@name)<3)
	BEGIN
		PRINT 'Keyword must be longer than 3 words'
	END
	ELSE IF NOT EXISTS(SELECT * FROM MsItemBrand WHERE ItemBrandName LIKE '%'+@name+'%')
	BEGIN
		PRINT 'Brand doesn''t exist'
	END
	ELSE IF EXISTS(SELECT * FROM MsItemBrand WHERE ItemBrandName LIKE '%'+@name+'%')
	BEGIN
		DECLARE siCursor CURSOR FOR
		SELECT ItemBrandName,
		ItemID,
		ItemName,
		ItemStock,
		ItemPrice
		FROM MsItemBrand JOIN MsItem
		ON MsItemBrand.ItemBrandID = MsItem.ItemBrandID
		WHERE ItemBrandName LIKE '%'+@name+'%'

		DECLARE @ibn VARCHAR(255), @iid VARCHAR(255), @in VARCHAR(255), @is INT, @ip BIGINT

		OPEN siCursor
		FETCH NEXT FROM siCursor INTO @ibn, @iid, @in, @is, @ip
		PRINT 'Brand: ' + @ibn
		PRINT '==========================================='
		
		WHILE @@FETCH_STATUS=0
		BEGIN
			PRINT 'Item ID: ' + @iid
			PRINT 'Item Name: ' + @in
			PRINT 'Item Stock: ' + CAST(@is AS VARCHAR)
			PRINT 'Item Price: ' + CAST(@ip AS VARCHAR)
			PRINT '==========================================='
		
			FETCH NEXT FROM siCursor INTO @ibn, @iid, @in, @is, @ip
		END
		CLOSE siCursor
		DEALLOCATE siCursor
	END
EXEC SearchItem 'taph'

--10. Create a stored procedure named DisplayTransaction that retrieves starting month (in integer), ending month (in integer), 
--and year of transaction as a parameter combined with a cursor to display the details of all the transactions between 
--the starting month and ending month in the inserted year.
CREATE PROC DisplayTransaction(@start INT, @end INT, @yr INT)
AS
	IF(@end - @start > 10)
	BEGIN
		PRINT 'The maximum range is 10 months'
	END
	ELSE 
	BEGIN
		DECLARE dtCursor CURSOR FOR
		SELECT TransactionDate,
			TransactionID
		FROM HeaderTransaction
		WHERE MONTH(TransactionDate) BETWEEN @start AND @end 
		AND YEAR(TransactionDate) = @yr

		DECLARE @date DATE, @id VARCHAR(100)

		OPEN dtCursor
		FETCH NEXT FROM dtCursor INTO @date, @id
		PRINT 'Showing results from ' + DATENAME(MONTH, DATEADD(MONTH, @start, -1)) + ' ' + CAST(@yr AS VARCHAR) + ' until ' + DATENAME(MONTH, DATEADD(MONTH, @end, -1)) + ' ' + CAST(@yr AS VARCHAR) 
		WHILE @@FETCH_STATUS=0
		BEGIN
			PRINT '====================================================='
			PRINT 'Transaction ID: ' + @id
			PRINT 'Transaction Date: ' + CONVERT(VARCHAR, @date, 23)
			PRINT '====================================================='
			
			DECLARE dtCursor2 CURSOR FOR
			SELECT ItemName,
				ItemPrice,
				Quantity
			FROM DetailTransaction
			JOIN MsItem
			ON DetailTransaction.ItemID = MsItem.ItemID
			WHERE TransactionID = @id
			DECLARE @in VARCHAR(255), @ip BIGINT, @q INT

			OPEN dtCursor2
			FETCH NEXT FROM dtCursor2 INTO @in, @ip, @q

			DECLARE @count INT, @totalPrice INT
			SET @count = 1
			SET @totalPrice = 0

			WHILE @@FETCH_STATUS=0
			BEGIN
				PRINT CAST(@count AS VARCHAR) + '. ' + @in + ' - ' + CAST(@ip AS VARCHAR)
				PRINT 'Quantity: ' + CAST(@q AS VARCHAR)
				PRINT 'Total: ' + CAST(@ip*@q AS VARCHAR)
				SET @totalPrice = @totalPrice + (@ip*@q)
				SET @count = @count + 1
				FETCH NEXT FROM dtCursor2 INTO @in, @ip, @q
			END
			CLOSE dtCursor2
			PRINT 'Total Price: ' + CAST(@totalPrice AS VARCHAR)
			PRINT ' '
			DEALLOCATE dtCursor2

			FETCH NEXT FROM dtCursor INTO @date, @id
		END
		CLOSE dtCursor
		DEALLOCATE dtCursor
	END
EXEC DisplayTransaction 10,11,2019
