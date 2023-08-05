---------------------------- Triggers ----------------------------
-- (Wayne)
-- Trigger to prevent item refund after 3 days and to delete relevant records of transaction if not referenced
USE [APU Sports Equipment]
CREATE OR ALTER TRIGGER MemberRefundItem
ON [Transaction_Details]
INSTEAD OF 
DELETE
AS
BEGIN
    DECLARE @transactiondate DATE, @transactionid INT, @transactiondetailsid INT,
			@quantity_in_stock INT, @quantity_ordered INT, @equipmentid INT
    
    SELECT @transactionid = Transaction_ID,
           @transactiondetailsid = Transaction_Details_ID,
		   @quantity_ordered = Quantity,
		   @equipmentid = Equipment_ID
    FROM DELETED
    
    SELECT @transactiondate = Transaction_Date
    FROM [Transaction]
    WHERE Transaction_ID = @transactionid

	SELECT @quantity_in_stock = Stock_Quantity
    FROM Equipment
    WHERE Equipment_ID = @equipmentid
    
    IF DATEDIFF(DAY, @transactiondate, GETDATE()) > 4
    BEGIN
        PRINT 'Can only refund items within 3 days.'
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM [Transaction_Details] WHERE Transaction_ID = @transactionid AND Transaction_Details_ID <> @transactiondetailsid)
        BEGIN
            DELETE FROM [Transaction_Details]
            WHERE Transaction_Details_ID = @transactiondetailsid	
            UPDATE Equipment
            SET Stock_Quantity = Stock_Quantity + @quantity_ordered
            WHERE Equipment_ID = @equipmentid
        END
        ELSE
        BEGIN
            DELETE FROM [Transaction_Details]
            WHERE Transaction_Details_ID = @transactiondetailsid
            DELETE FROM [Transaction]
            WHERE Transaction_ID = @transactionid
			UPDATE Equipment
            SET Stock_Quantity = Stock_Quantity + @quantity_ordered
            WHERE Equipment_ID = @equipmentid
        END
    END
END

CREATE OR ALTER TRIGGER UpdateEncryptedICPassportNo
ON [Member]
INSTEAD OF
UPDATE
AS
BEGIN
    DECLARE @Member_ID INT;
    DECLARE @NewICPassportNo VARCHAR(50);
    DECLARE @EncryptedICPassportNo VARBINARY(MAX);

    -- Get the updated values from the 'inserted'
    SELECT @Member_ID = [Member_ID], @NewICPassportNo = [IC/Passport_No]
    FROM inserted;

    -- Encrypt the 'IC/Passport_No' value
    SET @EncryptedICPassportNo = EncryptByAsymKey(AsymKey_ID('AsymKey1'), @NewICPassportNo);

    -- Update the 'Encrypted_IC_Passport_No' column in the 'Member' table
    UPDATE [Member]
    SET [IC/Passport_No] = @EncryptedICPassportNo
    WHERE [Member_ID] = @Member_ID;
END;


-- Prevent Deletion of Member Data
CREATE OR ALTER TRIGGER PreventMemberDeletion
ON [Member]
FOR DELETE
AS
BEGIN
	ROLLBACK;
	PRINT 'Delete of Member Data is prohibited unless this trigger is disabled.'
END



-- (VLIMMA)
-- Validate Quantity &
-- Trigger for member purchasing item accessing transaction_details only, automatically insert values 
-- into transaction table and assign respective foreign key
CREATE OR ALTER TRIGGER [ValidateStockQuantity]
ON [Transaction_Details]
INSTEAD OF INSERT
AS 
BEGIN
    DECLARE @quantity_in_stock INT, @quantity_ordered INT, 
            @equipmentid VARCHAR(50), @transactionid INT,
            @memberid INT

    -- Create a cursor to loop through the rows in the Inserted table
    DECLARE cur_Inserted CURSOR FOR
    SELECT Transaction_ID, Equipment_ID, Quantity, USER_NAME()
    FROM Inserted

    OPEN cur_Inserted
    FETCH NEXT FROM cur_Inserted INTO @transactionid, @equipmentid, @quantity_ordered, @memberid

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @quantity_in_stock = Stock_Quantity
        FROM Equipment
        WHERE Equipment_ID = @equipmentid

        IF @quantity_in_stock >= @quantity_ordered
        BEGIN
            -- Insert into the [Transaction] table with the current Member_ID
            INSERT INTO [Transaction] ([Transaction_Date], [Member_ID])
            VALUES (GETDATE(), @memberid)

            -- Get the newly generated Transaction_ID
            SET @transactionid = SCOPE_IDENTITY();

            -- Insert into the [Transaction_Details] table with the generated Transaction_ID
            INSERT INTO [Transaction_Details] (Transaction_ID, Equipment_ID, Quantity)
            VALUES (@transactionid, @equipmentid, @quantity_ordered)

            -- Update Equipment table with the new stock quantity
            UPDATE Equipment
            SET Stock_Quantity = Stock_Quantity - @quantity_ordered
            WHERE Equipment_ID = @equipmentid
        END
        ELSE
        BEGIN
            PRINT 'Equipment of: ' + @equipmentid + ' is not enough. Transaction is Rejected.'
            PRINT 'Currently there is only ' + CONVERT(VARCHAR, @quantity_in_stock) + ' units of equipment'
        END

        FETCH NEXT FROM cur_Inserted INTO @transactionid, @equipmentid, @quantity_ordered, @memberid
    END

    CLOSE cur_Inserted
    DEALLOCATE cur_Inserted
END

CREATE OR ALTER TRIGGER [UpdateValidateStockQuantity]
ON [Transaction_Details]
INSTEAD OF 
UPDATE
AS 
BEGIN
    DECLARE @quantity_in_stock INT, @quantity_ordered INT, 
            @equipmentid VARCHAR(50), @transaction_details_id INT,
            @difference INT,
            @updated_quantity INT

    SELECT @transaction_details_id = Transaction_Details_ID,
           @equipmentid = Equipment_ID, 
            @updated_quantity = Quantity
    FROM Inserted

    SELECT @quantity_ordered = Quantity
    FROM DELETED

    SET @difference = @updated_quantity - @quantity_ordered

    SELECT @quantity_in_stock = Stock_Quantity
    FROM Equipment
    WHERE Equipment_ID = @equipmentid

    IF @quantity_in_stock >= @updated_quantity
    BEGIN
        UPDATE Equipment
        SET Stock_Quantity = Stock_Quantity - @difference
        WHERE Equipment_ID = @equipmentid

        UPDATE [Transaction_Details]
        set Quantity = @updated_quantity
        WHERE [Transaction_Details_ID] = @transaction_details_id

    END
    ELSE
    BEGIN
        PRINT 'Equipment of: ' + @equipmentid + ' is not enough. Transaction is Rejected.'
        PRINT 'Currently there is only ' + CONVERT(VARCHAR, @quantity_in_stock) + ' units of equipment'
    END
END

-- Avoid accidentally Table deletion
CREATE OR ALTER TRIGGER [Deletion Trigger] 
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'You must disable Trigger [Deletion Trigger] to drop tables!'
    ROLLBACK;
END