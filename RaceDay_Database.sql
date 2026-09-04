-- =============================================
-- RaceDay - Event Management System
-- Complete Database Script (9 Entities)
-- Author: Rifumo - 2026
-- =============================================

-- 1. Users Table
CREATE TABLE [Users] (
    [UserId] INT IDENTITY(1,1) PRIMARY KEY,
    [Email] NVARCHAR(255) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(255) NOT NULL,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [Role] NVARCHAR(20) NOT NULL CHECK ([Role] IN ('Organiser', 'Participant')),
    [ProfileImageUrl] NVARCHAR(500) NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO
CREATE INDEX IX_Users_Email ON [Users]([Email]);
GO

-- 2. OrganiserProfiles Table
CREATE TABLE [OrganiserProfiles] (
    [OrganiserId] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL UNIQUE,
    [CompanyName] NVARCHAR(255) NULL,
    [ContactPhone] NVARCHAR(20) NOT NULL,
    [Website] NVARCHAR(255) NULL,
    [Bio] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_OrganiserProfiles_Users FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]) ON DELETE CASCADE
);
GO

-- 3. Events Table
CREATE TABLE [Events] (
    [EventId] INT IDENTITY(1,1) PRIMARY KEY,
    [OrganiserId] INT NOT NULL,
    [Name] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [Location] NVARCHAR(255) NOT NULL,
    [LocationCoordinates] NVARCHAR(100) NULL,
    [EventDate] DATETIME2 NOT NULL,
    [RegistrationDeadline] DATETIME2 NOT NULL,
    [RouteInfo] NVARCHAR(MAX) NULL,
    [WeatherInfo] NVARCHAR(MAX) NULL,
    [MaxParticipants] INT NULL,
    [Status] NVARCHAR(20) NOT NULL CHECK ([Status] IN ('Draft', 'Open', 'Closed', 'Cancelled', 'Completed')) DEFAULT 'Draft',
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Events_OrganiserProfiles FOREIGN KEY ([OrganiserId]) REFERENCES [OrganiserProfiles]([OrganiserId]) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Events_OrganiserId ON [Events]([OrganiserId]);
CREATE INDEX IX_Events_EventDate ON [Events]([EventDate]);
CREATE INDEX IX_Events_Status ON [Events]([Status]);
GO

-- 4. Categories Table
CREATE TABLE [Categories] (
    [CategoryId] INT IDENTITY(1,1) PRIMARY KEY,
    [EventId] INT NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [EntryFee] DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    [MinAge] INT NULL,
    [MaxAge] INT NULL,
    [GenderRestriction] NVARCHAR(10) NULL CHECK ([GenderRestriction] IN ('Male', 'Female', 'All')) DEFAULT 'All',
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Categories_Events FOREIGN KEY ([EventId]) REFERENCES [Events]([EventId]) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Categories_EventId ON [Categories]([EventId]);
GO

-- 5. Enrolments Table
CREATE TABLE [Enrolments] (
    [EnrolmentId] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL,
    [CategoryId] INT NOT NULL,
    [Status] NVARCHAR(20) NOT NULL CHECK ([Status] IN ('Pending', 'Confirmed', 'Completed', 'Cancelled')) DEFAULT 'Pending',
    [RaceNumber] INT NULL,
    [FinishTime] TIME NULL,
    [OverallPosition] INT NULL,
    [CategoryPosition] INT NULL,
    [PersonalBest] DECIMAL(10, 2) NULL,
    [EnrolmentDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY ([CategoryId]) REFERENCES [Categories]([CategoryId]) ON DELETE CASCADE,
    CONSTRAINT UQ_Enrolment_User_Category UNIQUE ([UserId], [CategoryId])
);
GO
CREATE INDEX IX_Enrolments_UserId ON [Enrolments]([UserId]);
CREATE INDEX IX_Enrolments_CategoryId ON [Enrolments]([CategoryId]);
CREATE INDEX IX_Enrolments_Status ON [Enrolments]([Status]);
GO

-- 6. Payments Table
CREATE TABLE [Payments] (
    [PaymentId] INT IDENTITY(1,1) PRIMARY KEY,
    [EnrolmentId] INT NOT NULL UNIQUE,
    [Amount] DECIMAL(18, 2) NOT NULL,
    [PaymentMethod] NVARCHAR(50) NOT NULL CHECK ([PaymentMethod] IN ('Credit Card', 'Debit Card', 'EFT', 'Cash', 'Mobile Wallet')),
    [TransactionId] NVARCHAR(100) NULL,
    [Status] NVARCHAR(20) NOT NULL CHECK ([Status] IN ('Pending', 'Completed', 'Failed', 'Refunded')) DEFAULT 'Pending',
    [PaymentDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Payments_Enrolments FOREIGN KEY ([EnrolmentId]) REFERENCES [Enrolments]([EnrolmentId]) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Payments_EnrolmentId ON [Payments]([EnrolmentId]);
CREATE INDEX IX_Payments_Status ON [Payments]([Status]);
GO

-- 7. EventSponsors Table
CREATE TABLE [EventSponsors] (
    [SponsorId] INT IDENTITY(1,1) PRIMARY KEY,
    [EventId] INT NOT NULL,
    [SponsorName] NVARCHAR(255) NOT NULL,
    [SponsorLogoUrl] NVARCHAR(500) NULL,
    [SponsorWebsite] NVARCHAR(255) NULL,
    [SponsorLevel] NVARCHAR(50) CHECK ([SponsorLevel] IN ('Platinum', 'Gold', 'Silver', 'Bronze', 'Partner')) DEFAULT 'Partner',
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_EventSponsors_Events FOREIGN KEY ([EventId]) REFERENCES [Events]([EventId]) ON DELETE CASCADE
);
GO
CREATE INDEX IX_EventSponsors_EventId ON [EventSponsors]([EventId]);
GO

-- 8. Notifications Table
CREATE TABLE [Notifications] (
    [NotificationId] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL,
    [Type] NVARCHAR(50) NOT NULL CHECK ([Type] IN ('Event_Update', 'Result_Published', 'Registration_Reminder', 'Payment_Confirmation', 'System_Alert', 'Promotion')),
    [Subject] NVARCHAR(255) NOT NULL,
    [Message] NVARCHAR(MAX) NOT NULL,
    [Status] NVARCHAR(20) NOT NULL CHECK ([Status] IN ('Unread', 'Read')) DEFAULT 'Unread',
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [ReadAt] DATETIME2 NULL,
    CONSTRAINT FK_Notifications_Users FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Notifications_UserId ON [Notifications]([UserId]);
CREATE INDEX IX_Notifications_Status ON [Notifications]([Status]);
CREATE INDEX IX_Notifications_CreatedAt ON [Notifications]([CreatedAt]);
GO

-- 9. EventImages Table
CREATE TABLE [EventImages] (
    [ImageId] INT IDENTITY(1,1) PRIMARY KEY,
    [EventId] INT NOT NULL,
    [ImageUrl] NVARCHAR(500) NOT NULL,
    [ImageCaption] NVARCHAR(255) NULL,
    [ImageType] NVARCHAR(20) NOT NULL CHECK ([ImageType] IN ('Cover', 'Gallery', 'Route', 'Venue')),
    [DisplayOrder] INT NOT NULL DEFAULT 0,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_EventImages_Events FOREIGN KEY ([EventId]) REFERENCES [Events]([EventId]) ON DELETE CASCADE
);
GO
CREATE INDEX IX_EventImages_EventId ON [EventImages]([EventId]);
CREATE INDEX IX_EventImages_DisplayOrder ON [EventImages]([DisplayOrder]);
GO

-- =============================================
-- SEED DATA
-- =============================================
INSERT INTO [Users] ([Email], [PasswordHash], [FirstName], [LastName], [Role], [ProfileImageUrl], [PhoneNumber])
VALUES
    ('john.organiser@raceday.co.za', 'hashed_password_1', 'John', 'Doe', 'Organiser', 'https://racedaystorage.blob.core.windows.net/profiles/john.jpg', '+2712345678'),
    ('jane.organiser@raceday.co.za', 'hashed_password_2', 'Jane', 'Smith', 'Organiser', 'https://racedaystorage.blob.core.windows.net/profiles/jane.jpg', '+2787654321'),
    ('mike.runner@gmail.com', 'hashed_password_3', 'Mike', 'Johnson', 'Participant', 'https://racedaystorage.blob.core.windows.net/profiles/mike.jpg', '+2798765432'),
    ('sarah.walker@gmail.com', 'hashed_password_4', 'Sarah', 'Williams', 'Participant', 'https://racedaystorage.blob.core.windows.net/profiles/sarah.jpg', '+2734567890');
GO

INSERT INTO [OrganiserProfiles] ([UserId], [CompanyName], [ContactPhone], [Website], [Bio])
VALUES
    (1, 'Cape Town Events Co.', '+2712345678', 'https://ctevents.co.za', 'Organising world-class events in Cape Town since 2010'),
    (2, 'Durban Sports Management', '+2787654321', 'https://durban.sport', 'Professional sports event management in KwaZulu-Natal');
GO

DECLARE @OrganiserId1 INT = (SELECT OrganiserId FROM OrganiserProfiles WHERE UserId = 1);
DECLARE @OrganiserId2 INT = (SELECT OrganiserId FROM OrganiserProfiles WHERE UserId = 2);

INSERT INTO [Events] ([OrganiserId], [Name], [Description], [Location], [LocationCoordinates], [EventDate], [RegistrationDeadline], [RouteInfo], [WeatherInfo], [MaxParticipants], [Status])
VALUES
    (@OrganiserId1, 'Cape Town Cycle Tour 2026', 'The worlds largest timed cycle race around the Cape Peninsula', 'Cape Town, South Africa', '-33.9249,18.4241', '2026-03-14 06:00:00', '2026-03-01 23:59:59', 'https://racedaystorage.blob.core.windows.net/routes/ctct2026.gpx', 'Expected sunny, 15-22°C, light winds', 35000, 'Open'),
    (@OrganiserId1, 'Two Oceans Marathon 2026', 'The ultimate 56km ultra-marathon with stunning coastal views', 'Cape Town, South Africa', '-34.0333,18.4500', '2026-04-04 05:30:00', '2026-03-20 23:59:59', 'https://racedaystorage.blob.core.windows.net/routes/twoceans2026.gpx', 'Partly cloudy, 12-18°C, mild winds', 16000, 'Open'),
    (@OrganiserId2, 'Comrades Marathon 2026', 'The ultimate human race - 87km between Durban and Pietermaritzburg', 'Durban to Pietermaritzburg, South Africa', '-29.8587,31.0218', '2026-06-14 05:30:00', '2026-05-31 23:59:59', 'https://racedaystorage.blob.core.windows.net/routes/comrades2026.gpx', 'Cool morning, 8-15°C, high humidity', 25000, 'Draft');
GO

-- Insert Categories
DECLARE @EventId1 INT = (SELECT EventId FROM Events WHERE Name = 'Cape Town Cycle Tour 2026');
DECLARE @EventId2 INT = (SELECT EventId FROM Events WHERE Name = 'Two Oceans Marathon 2026');
DECLARE @EventId3 INT = (SELECT EventId FROM Events WHERE Name = 'Comrades Marathon 2026');

INSERT INTO [Categories] ([EventId], [Name], [Description], [EntryFee], [MinAge], [MaxAge], [GenderRestriction])
VALUES
    (@EventId1, '42km Run', 'Full marathon distance (42.2km)', 250.00, 18, NULL, 'All'),
    (@EventId1, '21km Run', 'Half marathon distance', 150.00, 16, NULL, 'All'),
    (@EventId1, '10km Walk', 'Fun walk for all ages', 80.00, 8, NULL, 'All'),
    (@EventId2, '56km Ultra', 'Ultra-marathon (56km)', 500.00, 21, NULL, 'All'),
    (@EventId2, '21km Half', 'Half marathon', 200.00, 16, NULL, 'All'),
    (@EventId3, '87km Ultra', 'Full Comrades distance (87km)', 750.00, 25, NULL, 'All');
GO

-- Insert Sample Enrolments
DECLARE @Participant1 INT = (SELECT UserId FROM Users WHERE Email = 'mike.runner@gmail.com');
DECLARE @Participant2 INT = (SELECT UserId FROM Users WHERE Email = 'sarah.walker@gmail.com');
DECLARE @Category1 INT = (SELECT CategoryId FROM Categories WHERE Name = '42km Run');
DECLARE @Category2 INT = (SELECT CategoryId FROM Categories WHERE Name = '21km Run');
DECLARE @Category3 INT = (SELECT CategoryId FROM Categories WHERE Name = '56km Ultra');

INSERT INTO [Enrolments] ([UserId], [CategoryId], [Status], [RaceNumber], [EnrolmentDate])
VALUES
    (@Participant1, @Category1, 'Confirmed', 12845, '2026-02-01 10:30:00'),
    (@Participant1, @Category3, 'Pending', NULL, '2026-03-01 14:15:00'),
    (@Participant2, @Category2, 'Confirmed', 23891, '2026-02-15 09:00:00');
GO