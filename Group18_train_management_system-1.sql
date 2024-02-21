-- DROP database
-- DROP DATABASE Train_Management_System

-- Create the database

CREATE DATABASE Train_Management_System;

-- Use the database
USE Train_Management_System;

-- Create Train table
CREATE TABLE Train (
    TrainID INT PRIMARY KEY,
    TrainName VARCHAR(255),
    DepartureTime DATETIME,
    ArrivalTime DATETIME
);

-- Create Station table
CREATE TABLE Station (
    StationID INT PRIMARY KEY,
    StationName VARCHAR(255),
    Location VARCHAR(255)
);

-- Create Passenger table
CREATE TABLE Passenger (
    PassengerID INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    ContactInfo VARCHAR(255)
);

-- Create Schedule table
CREATE TABLE Schedule (
    ScheduleID INT PRIMARY KEY,
    TrainID INT,
    StationID INT,
    DepartureTime DATETIME,
    ArrivalTime DATETIME,
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    FOREIGN KEY (StationID) REFERENCES Station(StationID)
);

-- Create Ticket table
CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY,
    PassengerID INT,
    TrainID INT,
    DepartureTime DATETIME,
    ArrivalTime DATETIME,
    Price DECIMAL(10, 2),
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID)
);

-- Create Route table
CREATE TABLE Route (
    RouteID INT PRIMARY KEY,
    TrainID INT,
    OriginStationID INT,
    DestinationStationID INT,
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    FOREIGN KEY (OriginStationID) REFERENCES Station(StationID),
    FOREIGN KEY (DestinationStationID) REFERENCES Station(StationID)
);

-- Create Staff table
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Position VARCHAR(255)
);

-- Create TrainMaintenance table
CREATE TABLE TrainMaintenance (
    MaintenanceID INT PRIMARY KEY,
    TrainID INT,
    MaintenanceType VARCHAR(255),
    MaintenanceDate DATETIME,
    Details VARCHAR(255),
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID)
);

-- Create Delays table
CREATE TABLE Delays (
    DelayID INT PRIMARY KEY,
    TrainID INT,
    DelayDuration INT,
    DelayStart DATETIME,
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID)
);

-- Create Feedback table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    PassengerID INT,
    Rating INT,
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID)
);

-- Create StationsConnection table
CREATE TABLE StationsConnection (
    ConnectionID INT PRIMARY KEY,
    StationID1 INT,
    StationID2 INT,
    FOREIGN KEY (StationID1) REFERENCES Station(StationID),
    FOREIGN KEY (StationID2) REFERENCES Station(StationID)
);

-- Create TrainStaffAssignment table
CREATE TABLE TrainStaffAssignment (
    AssignmentID INT PRIMARY KEY,
    StaffID INT,
    TrainID INT,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID)
);

--constrants
USE Train_Management_System 

ALTER TABLE Passenger 
ADD CONSTRAINT CHK_Email CHECK (ContactInfo LIKE '%@%._%');

ALTER TABLE Ticket
ADD CONSTRAINT CHK_Price CHECK (Price > 0);

ALTER TABLE Feedback
ADD CONSTRAINT CHK_Rating CHECK (Rating BETWEEN 1 AND 5);

ALTER TABLE Delays
ADD CONSTRAINT CHK_DelayDuration CHECK ((LEN(DelayDuration) = 2));

ALTER TABLE Route 
ADD CONSTRAINT CHK_RouteID CHECK ((LEN(RouteID) = 3));



--views
-- This view provides information about passengers and their tickets, including the train details.
USE Train_Management_System;

-- Drop the view if it exists
IF OBJECT_ID('dbo.PassengerTicketsView', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.PassengerTicketsView;
END;
-- This view provides information about passengers and their tickets, including the train details.
-- Use dynamic SQL to create the view
EXEC('
    CREATE VIEW PassengerTicketsView AS
    SELECT
        T.TicketID,
        P.FirstName,
        P.LastName,
        P.ContactInfo,
        T.DepartureTime AS TicketDepartureTime,
        T.ArrivalTime AS TicketArrivalTime,
        T.Price,
        TR.TrainName
    FROM
        Ticket T
        JOIN Passenger P ON T.PassengerID = P.PassengerID
        JOIN Train TR ON T.TrainID = TR.TrainID;
');



-- This view displays details about train maintenance activities, including the train details.
USE Train_Management_System;

-- Drop the view if it exists
IF OBJECT_ID('dbo.MaintenanceDetailsView', 'V') IS NOT NULL
BEGIN
    EXEC('DROP VIEW dbo.MaintenanceDetailsView;');
END;

-- Use dynamic SQL to create the view
EXEC('
    CREATE VIEW MaintenanceDetailsView AS
    SELECT
        TM.MaintenanceID,
        TR.TrainName,
        TM.MaintenanceType,
        TM.MaintenanceDate,
        TM.Details
    FROM
        TrainMaintenance TM
        JOIN Train TR ON TM.TrainID = TR.TrainID;
');



-- This view summarizes information about train delays, including the delay duration and affected train details.
USE Train_Management_System;

-- Drop the view if it exists
IF OBJECT_ID('dbo.DelaySummaryView', 'V') IS NOT NULL
BEGIN
    EXEC('DROP VIEW dbo.DelaySummaryView;');
END;

-- Use dynamic SQL to create the view
EXEC('
    CREATE VIEW DelaySummaryView AS
    SELECT
        D.DelayID,
        TR.TrainName,
        D.DelayDuration,
        D.DelayStart
    FROM
        Delays D
        JOIN Train TR ON D.TrainID = TR.TrainID;
');


-- This view shows the schedule details for each train, including the associated stations and departure/arrival times. 
USE Train_Management_System;

-- Drop the view if it exists
IF OBJECT_ID('dbo.TrainScheduleView', 'V') IS NOT NULL
BEGIN
    EXEC('DROP VIEW dbo.TrainScheduleView;');
END;

-- Use dynamic SQL to create the view
EXEC('
    CREATE VIEW TrainScheduleView AS
    SELECT
        t.TrainID,
        t.TrainName,
        s.StationName,
        s.Location,
        sc.DepartureTime AS StationDepartureTime,
        sc.ArrivalTime AS StationArrivalTime
    FROM
        Train t
        JOIN Schedule sc ON t.TrainID = sc.TrainID
        JOIN Station s ON sc.StationID = s.StationID;
');


   
   
   
   
SELECT * FROM PassengerTicketsView;

SELECT * FROM MaintenanceDetailsView;

SELECT * FROM DelaySummaryView;

SELECT * FROM TrainScheduleView;


--functions

USE Train_Management_System;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Train' AND COLUMN_NAME = 'JourneyDuration')
BEGIN
    ALTER TABLE Train
    DROP COLUMN JourneyDuration;
END
ALTER TABLE Train
ADD JourneyDuration AS DATEDIFF(MINUTE, DepartureTime, ArrivalTime);



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Staff' AND COLUMN_NAME = 'FullName')
BEGIN
    ALTER TABLE Staff
    DROP COLUMN FullName;
END
ALTER TABLE Staff
ADD FullName AS (FirstName + ' ' + LastName) PERSISTED;



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TrainMaintenance' AND COLUMN_NAME = 'MaintenanceDuration')
BEGIN
    ALTER TABLE TrainMaintenance
    DROP COLUMN FullName;
END
ALTER TABLE TrainMaintenance
ADD MaintenanceDuration AS DATEDIFF(MINUTE, MaintenanceDate, GETDATE());



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Delays' AND COLUMN_NAME = 'DelayEnd')
BEGIN
    ALTER TABLE Delays
    DROP COLUMN DelayEnd;
END
ALTER TABLE Delays
ADD DelayEnd AS DATEADD(MINUTE, DelayDuration, DelayStart) PERSISTED;


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Feedback' AND COLUMN_NAME = 'FeedbackCategory')
BEGIN
    ALTER TABLE Feedback
    DROP COLUMN FeedbackCategory;
END
ALTER TABLE Feedback
ADD FeedbackCategory AS CASE WHEN Rating >= 4 THEN 'Positive' ELSE 'Negative' END;


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TrainStaffAssignment' AND COLUMN_NAME = 'AssignmentStatus')
BEGIN
    ALTER TABLE TrainStaffAssignment
    DROP COLUMN AssignmentStatus;
END
ALTER TABLE TrainStaffAssignment
ADD AssignmentStatus AS CASE WHEN AssignmentDate IS NULL THEN 'Pending' ELSE 'Completed' END



--insert data into the tables 

USE Train_Management_System;


-- Insert data into Train table
INSERT INTO Train (TrainID, TrainName, DepartureTime, ArrivalTime)
VALUES 
    (1, 'Express1', '2023-12-03 08:00:00', '2023-12-03 12:00:00'),
    (2, 'Local2', '2023-12-03 09:30:00', '2023-12-03 11:30:00'),
    (3, 'Express3', '2023-12-03 12:00:00', '2023-12-03 16:00:00'),
    (4, 'Local4', '2023-12-03 15:00:00', '2023-12-03 17:30:00'),
    (5, 'Express5', '2023-12-03 18:00:00', '2023-12-03 22:00:00');

-- Insert data into Station table
INSERT INTO Station (StationID, StationName, Location)
VALUES 
    (1, 'Station A', 'City A'),
    (2, 'Station B', 'City B'),
    (3, 'Station C', 'City C'),
    (4, 'Station D', 'City D'),
    (5, 'Station E', 'City E');

-- Insert data into Passenger table
INSERT INTO Passenger (PassengerID, FirstName, LastName, ContactInfo)
VALUES 
    (1, 'John', 'Doe', 'john.doe@email.com'),
    (2, 'Jane', 'Smith', 'jane.smith@email.com'),
    (3, 'Bob', 'Johnson', 'bob.johnson@email.com'),
    (4, 'Alice', 'Williams', 'alice.williams@email.com'),
    (5, 'Charlie', 'Brown', 'charlie.brown@email.com');

-- Insert data into Schedule table
INSERT INTO Schedule (ScheduleID, TrainID, StationID, DepartureTime, ArrivalTime)
VALUES 
    (1, 1, 1, '2023-12-03 08:00:00', '2023-12-03 08:30:00'),
    (2, 1, 2, '2023-12-03 09:00:00', '2023-12-03 09:30:00'),
    (3, 2, 2, '2023-12-03 09:30:00', '2023-12-03 10:00:00'),
    (4, 3, 3, '2023-12-03 12:00:00', '2023-12-03 13:00:00'),
    (5, 3, 4, '2023-12-03 13:30:00', '2023-12-03 14:00:00');

-- Insert data into Ticket table
INSERT INTO Ticket (TicketID, PassengerID, TrainID, DepartureTime, ArrivalTime, Price)
VALUES 
    (1, 1, 1, '2023-12-03 08:00:00', '2023-12-03 09:00:00', 15.00),
    (2, 2, 2, '2023-12-03 09:30:00', '2023-12-03 10:30:00', 10.50),
    (3, 3, 3, '2023-12-03 12:00:00', '2023-12-03 13:00:00', 20.00),
    (4, 4, 4, '2023-12-03 15:00:00', '2023-12-03 16:00:00', 18.75),
    (5, 5, 5, '2023-12-03 18:00:00', '2023-12-03 19:30:00', 25.50);


-- Insert data into Route table
INSERT INTO Route (RouteID, TrainID, OriginStationID, DestinationStationID)
VALUES 
    (1, 1, 1, 5),
    (2, 2, 2, 4),
    (3, 3, 3, 4),
    (4, 4, 1, 3),
    (5, 5, 2, 5);

-- Insert data into Staff table
INSERT INTO Staff (StaffID, FirstName, LastName, Position)
VALUES 
    (1, 'Michael', 'Johnson', 'Conductor'),
    (2, 'Emily', 'Davis', 'Ticket Checker'),
    (3, 'David', 'Smith', 'Train Driver'),
    (4, 'Jennifer', 'Brown', 'Station Manager'),
    (5, 'Daniel', 'Wilson', 'Maintenance Crew');

-- Insert data into TrainMaintenance table
INSERT INTO TrainMaintenance (MaintenanceID, TrainID, MaintenanceType, MaintenanceDate, Details)
VALUES 
    (1, 1, 'Routine Check', '2023-12-02 10:00:00', 'Check engine and brakes'),
    (2, 2, 'Emergency Repair', '2023-12-03 14:30:00', 'Fixing electrical issue'),
    (3, 3, 'Regular Maintenance', '2023-12-01 12:00:00', 'Inspecting and oil change'),
    (4, 4, 'Major Overhaul', '2023-11-30 08:00:00', 'Replacing old components'),
    (5, 5, 'Routine Check', '2023-12-02 09:00:00', 'Greasing moving parts');

-- Insert data into Delays table
INSERT INTO Delays (DelayID, TrainID, DelayDuration, DelayStart)
VALUES 
    (1, 1, 15, '2023-12-03 08:30:00'),
    (2, 2, 30, '2023-12-03 09:45:00'),
    (3, 3, 45, '2023-12-03 13:30:00'),
    (4, 4, 20, '2023-12-03 15:30:00'),
    (5, 5, 10, '2023-12-03 18:30:00');

-- Insert data into Feedback table
INSERT INTO Feedback (FeedbackID, PassengerID, Rating)
VALUES 
    (1, 1, 4),
    (2, 2, 5),
    (3, 3, 3),
    (4, 4, 4),
    (5, 5, 5);

-- Insert data into StationsConnection table
INSERT INTO StationsConnection (ConnectionID, StationID1, StationID2)
VALUES 
    (1, 1, 2),
    (2, 2, 3),
    (3, 3, 4),
    (4, 4, 5),
    (5, 5, 1);

-- Insert data into TrainStaffAssignment table
INSERT INTO TrainStaffAssignment (AssignmentID, StaffID, TrainID)
VALUES 
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 4),
    (5, 5, 5);


   -- Insert data into Train table
INSERT INTO Train (TrainID, TrainName, DepartureTime, ArrivalTime) VALUES
(6, 'Express 101', '2023-12-05 08:00:00', '2023-12-05 12:00:00'),
(7, 'Local 202', '2023-12-05 10:30:00', '2023-12-05 14:30:00'),
(8, 'Rapid 303', '2023-12-05 13:15:00', '2023-12-05 17:30:00'),
(9, 'Superfast 404', '2023-12-05 16:45:00', '2023-12-05 21:00:00'),
(10, 'Shuttle 505', '2023-12-05 19:30:00', '2023-12-05 23:00:00');

-- Insert data into Station table
INSERT INTO Station (StationID, StationName, Location) VALUES
(6, 'Central Station', 'City A'),
(7, 'North Station', 'City B'),
(8, 'South Station', 'City C'),
(9, 'East Station', 'City D'),
(10, 'West Station', 'City E');

-- Insert data into Passenger table
INSERT INTO Passenger (PassengerID, FirstName, LastName, ContactInfo) VALUES
(6, 'John', 'Doe', 'john.doe@example.com'),
(7, 'Jane', 'Smith', 'jane.smith@example.com'),
(8, 'Bob', 'Johnson', 'bob.johnson@example.com'),
(9, 'Alice', 'Williams', 'alice.williams@example.com'),
(10, 'Charlie', 'Brown', 'charlie.brown@example.com');

-- Insert data into Schedule table
INSERT INTO Schedule (ScheduleID, TrainID, StationID, DepartureTime, ArrivalTime) VALUES
(6, 6, 6, '2023-12-05 08:00:00', '2023-12-05 09:30:00'),
(7, 6, 7, '2023-12-05 09:45:00', '2023-12-05 11:15:00'),
(8, 6, 8, '2023-12-05 11:30:00', '2023-12-05 12:00:00'),
(9, 7, 6, '2023-12-05 10:30:00', '2023-12-05 12:00:00'),
(10, 7, 7, '2023-12-05 12:15:00', '2023-12-05 13:45:00');

-- Insert data into Ticket table
INSERT INTO Ticket (TicketID, PassengerID, TrainID, DepartureTime, ArrivalTime, Price) VALUES
(6, 6, 6, '2023-12-05 08:00:00', '2023-12-05 12:00:00', 25.50),
(7, 7, 7, '2023-12-05 10:30:00', '2023-12-05 14:30:00', 30.75),
(8, 8, 8, '2023-12-05 13:15:00', '2023-12-05 17:30:00', 40.00),
(9, 9, 9, '2023-12-05 16:45:00', '2023-12-05 21:00:00', 35.25),
(10, 10, 10, '2023-12-05 19:30:00', '2023-12-05 23:00:00', 28.50);



--adding data to verify


 USE Train_Management_System;

-- Insert data into Route table
INSERT INTO Route (RouteID, TrainID, OriginStationID, DestinationStationID) VALUES
(100, 6, 6, 8),
(111, 7, 7, 9),
(122, 8, 8, 10),
(133, 9, 9, 6),
(144, 10, 10, 7);

-- Insert data into Staff table
INSERT INTO Staff (StaffID, FirstName, LastName, Position) VALUES
(6, 'Emily', 'Jones', 'Conductor'),
(7, 'Michael', 'Clark', 'Ticket Agent'),
(8, 'Amanda', 'Miller', 'Train Operator'),
(9, 'Daniel', 'Taylor', 'Station Manager'),
(10, 'Sophia', 'Lee', 'Maintenance Technician');


-- Insert data into TrainMaintenance table
INSERT INTO TrainMaintenance (MaintenanceID, TrainID, MaintenanceType, MaintenanceDate, Details) VALUES
(6, 6, 'Regular Inspection', '2023-12-05 14:00:00', 'Routine checkup and maintenance'),
(7, 7, 'Emergency Repair', '2023-12-05 16:30:00', 'Fixed brake issue'),
(8, 8, 'Scheduled Maintenance', '2023-12-05 18:45:00', 'Replaced engine components'),
(9, 9, 'Minor Repairs', '2023-12-05 22:15:00', 'Repaired electrical wiring'),
(10, 10, 'Major Overhaul', '2023-12-06 01:00:00', 'Complete refurbishment of the train');

-- Insert data into Delays table
INSERT INTO Delays (DelayID, TrainID, DelayDuration, DelayStart) VALUES
(6, 6, 30, '2023-12-05 10:00:00'),
(7, 7, 45, '2023-12-05 13:00:00'),
(8, 8, 20, '2023-12-05 15:30:00'),
(9, 9, 60, '2023-12-05 18:45:00'),
(10, 10, 15, '2023-12-05 21:45:00');

-- Insert data into Feedback table
INSERT INTO Feedback (FeedbackID, PassengerID, Rating) VALUES
(6, 6, 4),
(7, 7, 5),
(8, 8, 3),
(9, 9, 4),
(10, 10, 5);

-- Insert data into StationsConnection table
INSERT INTO StationsConnection (ConnectionID, StationID1, StationID2) VALUES
(6, 6, 7),
(7, 7, 8),
(8, 8, 9),
(9, 9, 10),
(10, 10, 6);

-- Insert data into TrainStaffAssignment table
INSERT INTO TrainStaffAssignment (AssignmentID, StaffID, TrainID) VALUES
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10);

--modifying data based on functions

USE Train_Management_System;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-12-03 10:00:00' WHERE AssignmentID = 1;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-12-03 11:30:00' WHERE AssignmentID = 2;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-12-03 14:00:00' WHERE AssignmentID = 3;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-11-03 10:00:00' WHERE AssignmentID = 6;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-11-03 11:30:00' WHERE AssignmentID = 7;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-11-03 14:00:00' WHERE AssignmentID = 8;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-11-03 16:30:00' WHERE AssignmentID = 9;

UPDATE TrainStaffAssignment
SET AssignmentDate = '2023-11-03 19:00:00' WHERE AssignmentID = 10;

--modifying data based on constraints

UPDATE Route SET RouteID = 200 WHERE RouteID = 1;
UPDATE Route SET RouteID = 293 WHERE RouteID = 2;
UPDATE Route SET RouteID = 322 WHERE RouteID = 3;
UPDATE Route SET RouteID = 124 WHERE RouteID = 4;
UPDATE Route SET RouteID = 928 WHERE RouteID = 5;



--encryption


CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'DMDD@123';

CREATE CERTIFICATE PassengerEncryptCertificate WITH SUBJECT = 'Passenger Email Certificate';

-- Create the Symmetric Key using AES_256 algorithm
CREATE SYMMETRIC KEY PassengerEmailKey WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE PassengerEncryptCertificate;

-- Add Encrypted Columns to the Passenger table for Email in ContactInfo
ALTER TABLE Passenger
ADD email_encrypted VARBINARY(MAX)

-- Encrypt the Username columns
OPEN SYMMETRIC KEY PassengerEmailKey
DECRYPTION BY CERTIFICATE PassengerEncryptCertificate;

UPDATE Passenger
SET 
    email_encrypted = EncryptByKey(Key_GUID('PassengerEmailKey'), ContactInfo)

CLOSE SYMMETRIC KEY PassengerEmailKey;

-- Decrypt and View the Data
OPEN SYMMETRIC KEY PassengerEmailKey
DECRYPTION BY CERTIFICATE PassengerEncryptCertificate;

SELECT 
    PassengerID, 
    FirstName, 
    CONVERT(VARCHAR, DecryptByKey(email_encrypted)) AS email_decrypted
FROM
    Passenger;

CLOSE SYMMETRIC KEY PassengerEmailKey;

SELECT * FROM Passenger;