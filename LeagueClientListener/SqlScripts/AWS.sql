IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'ABAM_Stats') 
BEGIN
CREATE DATABASE [ABAM_Stats]
END
GO
USE [ABAM_Stats]
GO
IF OBJECT_ID('MatchTeamParticipantStats')	IS NOT NULL DROP TABLE MatchTeamParticipantStats
IF OBJECT_ID('MatchTeamParticipants')		IS NOT NULL	DROP TABLE MatchTeamParticipants
IF OBJECT_ID('MatchTeams')					IS NOT NULL	DROP TABLE MatchTeams
IF OBJECT_ID('Players')						IS NOT NULL	DROP TABLE Players
IF OBJECT_ID('MatchMetaData')				IS NOT NULL DROP TABLE MatchMetaData
IF OBJECT_ID('Matches')						IS NOT NULL	DROP TABLE Matches
IF OBJECT_ID('Champions')					IS NOT NULL DROP TABLE Champions
GO
CREATE TABLE Champions
(
	ChampionID		INT				NOT NULL,
	ChampionName	VARCHAR(127)	NOT NULL,
	RawJson			NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT PK_Champions PRIMARY KEY(ChampionID)
)
GO
CREATE NONCLUSTERED INDEX NCI_Champions_ChampionName
ON Champions (ChampionName)
GO

IF OBJECT_ID('Items')		IS NOT NULL DROP TABLE Items
GO
CREATE TABLE Items
(
	ItemID			INT				NOT NULL,
	ItemName		VARCHAR(127)	NOT NULL,
	RawJson			NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT PK_Items	PRIMARY KEY(ItemID)
)
GO
INSERT INTO Items (ItemID, ItemName, RawJson) VALUES (0, 'None', N'{}')
GO
IF OBJECT_ID('RunePathRunes')		IS NOT NULL DROP TABLE RunePathRunes
GO
IF OBJECT_ID('RunePaths')			IS NOT NULL DROP TABLE RunePaths
GO
CREATE TABLE RunePaths
(
	RunePathID		INT				NOT NULL,
	RunePathName	VARCHAR(127)	NOT NULL,
	RawJson			NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT PK_RunePaths PRIMARY KEY (RunePathID)
)
GO

CREATE TABLE RunePathRunes
(
	RunePathID		INT				NOT NULL,
	RuneID			INT				NOT NULL,
	RuneName		VARCHAR(127)	NOT NULL,	
	RawJson			NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT PK_RunePathRunes PRIMARY KEY (RuneID)
)
GO

ALTER TABLE RunePathRunes	ADD CONSTRAINT RunePath_RunePathRunes_FK
FOREIGN KEY (RunePathID)	REFERENCES RunePaths (RunePathID)
GO

IF OBJECT_ID('SummonerSpells')		IS NOT NULL DROP TABLE SummonerSpells
GO
CREATE TABLE SummonerSpells
(
	SummonerSpellID		INT				NOT NULL,
	SummonerSpellName	VARCHAR(127)	NOT NULL,
	RawJson				NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT PK_SummonerSpells PRIMARY KEY (SummonerSpellID)
)
GO

IF OBJECT_ID('MatchTeamParticipantStats')	IS NOT NULL DROP TABLE MatchTeamParticipantStats
IF OBJECT_ID('MatchTeamParticipants')		IS NOT NULL	DROP TABLE MatchTeamParticipants
IF OBJECT_ID('MatchTeams')					IS NOT NULL	DROP TABLE MatchTeams
IF OBJECT_ID('Players')						IS NOT NULL	DROP TABLE Players
IF OBJECT_ID('MatchMetaData')				IS NOT NULL DROP TABLE MatchMetaData
IF OBJECT_ID('Matches')						IS NOT NULL	DROP TABLE Matches
GO

CREATE TABLE Matches
(
	MatchID				BIGINT		NOT NULL,
	DateOfMatch			DATETIME	NOT NULL,
	Duration			TIME		NOT NULL,
	GameLengthInSeconds	INT			NOT NULL,
	CONSTRAINT PK_Matches PRIMARY KEY (MatchID)
)

CREATE TABLE MatchMetaData
(	
	DbIndex			INT				NOT NULL IDENTITY,
	MatchID			BIGINT			NOT NULL,
	DateAdded		DATETIME		NOT NULL,
	RawJson			NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT PK_MatchMetaData PRIMARY KEY (DbIndex)
)

CREATE TABLE Players
(
	AccountID			BIGINT			NOT NULL,
	SummonerName		NVARCHAR(63)	NOT NULL,
	SummonerID			BIGINT			NOT NULL,
	TrackStats			BIT				NOT NULL,
	LastUpdated			DATETIME		NOT NULL,
	CONSTRAINT PK_Players PRIMARY KEY (AccountID)
)

CREATE TABLE MatchTeams
(
	MatchID				BIGINT		NOT NULL,
	TeamID				INT			NOT NULL,
	Win					BIT			NOT NULL,
	FirstBlood			BIT			NOT NULL,
	FirstTower			BIT			NOT NULL,
	FirstInhibitor		BIT			NOT NULL,
	TowerKills			INT			NOT NULL,
	InhibitorKills		INT			NOT NULL,
	CONSTRAINT PK_MatchTeams	PRIMARY KEY (MatchID, TeamID)
)

CREATE TABLE MatchTeamParticipants
(
	MatchID				BIGINT		NOT NULL,
	TeamID				INT			NOT NULL, 
	ParticipantID		INT			NOT NULL,
	AccountID			BIGINT		NOT NULL,	
	ChampionID			INT			NOT NULL,
	Spell1ID			INT			NOT NULL,
	Spell2ID			INT			NOT NULL,
	CONSTRAINT PK_MatchParticipants PRIMARY KEY (MatchID, TeamID, ParticipantID, AccountID)
)

CREATE TABLE MatchTeamParticipantStats
	(
	MatchID							BIGINT			NOT NULL,
	TeamID							INT				NOT NULL,
	ParticipantID					INT				NOT NULL,
	AccountID						BIGINT			NOT NULL,
	DbIndex							INT				NOT NULL IDENTITY,
	Win								BIT				NOT NULL,
	Item1ID							INT				NOT NULL,
	Item2ID							INT				NOT NULL,
	Item3ID							INT				NOT NULL,
	Item4ID							INT				NOT NULL,
	Item5ID							INT				NOT NULL,
	Item6ID							INT				NOT NULL,
	Kills							INT				NOT NULL,
	Deaths							INT				NOT NULL,
	Assists							INT				NOT NULL,
	LargestKillSpree				INT				NOT NULL,
	LargestMultiKill				INT				NOT NULL,
	KillingSprees					INT				NOT NULL,
	LongestTimeSpentLiving			INT				NOT NULL,
	DoubleKills						INT				NOT NULL,
	TripleKills						INT				NOT NULL,
	QuadraKills						INT				NOT NULL,
	PentaKills						INT				NOT NULL,
	TotalDamageDealt				INT				NOT NULL,
	PhysicalDamageDealt				INT				NOT NULL,
	MagicDamageDealt				INT				NOT NULL,
	TrueDamageDealt					INT				NOT	NULL,
	LargestCriticalStrike			INT				NOT NULL,
	TotalDamageToChampions			INT				NOT NULL,
	PhysicalDamageToChampions		INT				NOT NULL,
	MagicDamageToChampions			INT				NOT NULL,
	TrueDamageToChampions			INT				NOT NULL,
	TotalHeal						INT				NOT NULL,
	TotalUnitsHealed				INT				NOT NULL,
	DamageSelfMitigated				INT				NOT NULL,
	DamageDealtToObjectives			INT				NOT NULL,
	DamageDealtToTurrets			INT				NOT NULL,
	TimeCCingOthers					INT				NOT NULL,
	TotalDamageTaken				INT				NOT NULL,
	PhysicalDamageTaken				INT				NOT NULL,
	MagicDamageTaken				INT				NOT NULL,
	TrueDamageTaken					INT				NOT NULL,
	GoldEarned						INT				NOT NULL,
	GoldSpent						INT				NOT NULL,
	TurretKills						INT				NOT NULL,
	InhibitorKills					INT				NOT	NULL,
	TotalMinionsKilled				INT				NOT NULL,
	TotalTimeCrowdControlDealt		INT				NOT NULL,
	ChampLevel						INT				NOT NULL,
	FirstBloodKill					BIT				NOT NULL,
	FirstBloodAssist				BIT				NOT NULL,
	FirstTowerKill					BIT				NOT NULL,
	FirstTowerAssist				BIT				NOT NULL,
	FirstInihibitorKill				BIT				NOT NULL,
	FirstInhibitorAssist			BIT				NOT NULL,
	KeystoneID						INT				NOT NULL,
	KeystoneValues					NVARCHAR(1000)	NOT NULL,
	PrimaryRune1ID					INT				NOT NULL,
	PrimaryRune1Values				NVARCHAR(1000)	NOT NULL,
	PrimaryRune2ID					INT				NOT NULL,
	PrimaryRune2Values				NVARCHAR(1000)	NOT NULL,
	PrimaryRune3ID					INT				NOT NULL,
	PrimaryRune3Values				NVARCHAR(1000)	NOT NULL,
	SecondaryRune1ID				INT				NOT NULL,
	SecondaryRune1Values			NVARCHAR(1000)	NOT NULL,
	SecondaryRune2ID				INT				NOT NULL,
	SecondaryRune2Values			NVARCHAR(1000)	NOT NULL,
	PrimaryRunePathID				INT				NOT NULL,
	SecondaryRunePathID				INT				NOT NULL,
	MetaWin							BIT				NULL,
	CONSTRAINT PK_MatchTeamParticipantStats PRIMARY KEY (MatchID, TeamID, ParticipantID, AccountID, DbIndex)
)
GO

ALTER TABLE MatchMetaData ADD CONSTRAINT FK_Matches_MatchMetaData
FOREIGN KEY (MatchID) REFERENCES Matches (MatchID)

ALTER TABLE MatchTeams ADD CONSTRAINT FK_Matches_MatchTeams
FOREIGN KEY (MatchID) REFERENCES Matches (MatchID)

ALTER TABLE MatchTeamParticipants ADD CONSTRAINT FK_MatchTeams_MatchTeamParticipants
FOREIGN KEY (MatchID, TeamID) REFERENCES MatchTeams (MatchID, TeamID)

ALTER TABLE MatchTeamParticipants ADD CONSTRAINT FK_Players_MatchTeamParticipants
FOREIGN KEY (AccountID) REFERENCES Players (AccountID)

ALTER TABLE MatchTeamParticipants ADD CONSTRAINT FK_SummonerSpells_MatchTeamParticipants_Spell1
FOREIGN KEY (Spell1ID) REFERENCES SummonerSpells (SummonerSpellID)

ALTER TABLE MatchTeamParticipants ADD CONSTRAINT FK_SummonerSpells_MatchTeamParticipants_Spell2
FOREIGN KEY (Spell2ID) REFERENCES SummonerSpells (SummonerSpellID)

ALTER TABLE MatchTeamParticipants ADD CONSTRAINT FK_Champions_MatchTeamParticipants
FOREIGN KEY (ChampionID) REFERENCES Champions (ChampionID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_MatchTeamParticpants_MatchTeamParticipantStats
FOREIGN KEY (MatchID, TeamID, ParticipantID, AccountID) REFERENCES MatchTeamParticipants(MatchID, TeamID, ParticipantID, AccountID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_Items_MatchTeamParticipantStats_Item1
FOREIGN KEY (Item1ID) REFERENCES Items (ItemID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_Items_MatchTeamParticipantStats_Item2
FOREIGN KEY (Item2ID) REFERENCES Items (ItemID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_Items_MatchTeamParticipantStats_Item3
FOREIGN KEY (Item3ID) REFERENCES Items (ItemID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_Items_MatchTeamParticipantStats_Item4
FOREIGN KEY (Item4ID) REFERENCES Items (ItemID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_Items_MatchTeamParticipantStats_Item5
FOREIGN KEY (Item5ID) REFERENCES Items (ItemID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_Items_MatchTeamParticipantStats_Item6
FOREIGN KEY (Item6ID) REFERENCES Items (ItemID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePathRunes_MatchTeamParticipantStats_Keystone
FOREIGN KEY (KeystoneID) REFERENCES RunePathRunes (RuneID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePathRunes_MatchTeamParticipantStats_Primary1
FOREIGN KEY (PrimaryRune1ID) REFERENCES RunePathRunes (RuneID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePathRunes_MatchTeamParticipantStats_Primary2
FOREIGN KEY (PrimaryRune2ID) REFERENCES RunePathRunes (RuneID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePathRunes_MatchTeamParticipantStats_Primary3
FOREIGN KEY (PrimaryRune3ID) REFERENCES RunePathRunes (RuneID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePathRunes_MatchTeamParticipantStats_Secondary1
FOREIGN KEY (SecondaryRune1ID) REFERENCES RunePathRunes (RuneID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePathRunes_MatchTeamParticipantStats_Secondary2
FOREIGN KEY (SecondaryRune2ID) REFERENCES RunePathRunes (RuneID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePaths_MatchTeamParticipantStats_Primary
FOREIGN KEY (PrimaryRunePathID)	REFERENCES RunePaths (RunePathID)

ALTER TABLE MatchTeamParticipantStats ADD CONSTRAINT FK_RunePaths_MatchTeamParticipantStats_Secondary
FOREIGN KEY (SecondaryRunePathID)	REFERENCES RunePaths (RunePathID)
GO

CREATE NONCLUSTERED INDEX NCI_Matches_DateOfMatch ON Matches (DateOfMatch DESC)
GO
CREATE NONCLUSTERED INDEX NCI_Players_SummonerName ON Players (SummonerName ASC)
GO

GO

IF EXISTS (SELECT * FROM sys.tables WHERE tables.name = 'DateInfo')
BEGIN
	DROP TABLE dbo.DateInfo;
END
GO

-- Create DateInfo table, using minimal data types and reusable creation script.
CREATE TABLE dbo.DateInfo
(	Calendar_Date DATE NOT NULL CONSTRAINT PK_DateInfo PRIMARY KEY CLUSTERED, -- The date addressed in this row.
	Calendar_Date_String VARCHAR(10) NOT NULL, -- The VARCHAR formatted date, such as 07/03/2017
	Calendar_Month TINYINT NOT NULL, -- Number from 1-12
	Calendar_Day TINYINT NOT NULL, -- Number from 1 through 31
	Calendar_Year SMALLINT NOT NULL, -- Current year, eg: 2017, 2025, 1984.
	Calendar_Quarter TINYINT NOT NULL, -- 1-4, indicates quarter within the current year.
	Day_Name VARCHAR(9) NOT NULL, -- Name of the day of the week, Sunday...Saturday
	Day_of_Week TINYINT NOT NULL, -- Number from 1-7 (1 = Sunday)
	Day_of_Week_in_Month TINYINT NOT NULL, -- Number from 1-5, indicates for example that it's the Nth saturday of the month.
	Day_of_Week_in_Year TINYINT NOT NULL, -- Number from 1-53, indicates for example that it's the Nth saturday of the year.
	Day_of_Week_in_Quarter TINYINT NOT NULL, -- Number from 1-13, indicates for example that it's the Nth saturday of the quarter.
	Day_of_Quarter TINYINT NOT NULL, -- Number from 1-92, indicates the day # in the quarter.
	Day_of_Year SMALLINT NOT NULL, -- Number from 1-366
	Week_of_Month TINYINT NOT NULL, -- Number from 1-6, indicates the number of week within the current month.
	Week_of_Quarter TINYINT NOT NULL, -- Number from 1-14, indicates the number of week within the current quarter.
	Week_of_Year TINYINT NOT NULL, -- Number from 1-53, indicates the number of week within the current year.
	Month_Name VARCHAR(9) NOT NULL, -- January-December
	First_Date_of_Week DATE NOT NULL, -- Date of the first day of this week.
	Last_Date_of_Week DATE NOT NULL, -- Date of the last day of this week.
	First_Date_of_Month DATE NOT NULL, -- Date of the first day of this month.
	Last_Date_of_Month DATE NOT NULL, -- Date of the last day of this month.
	First_Date_of_Quarter DATE NOT NULL, -- Date of the first day of this quarter.
	Last_Date_of_Quarter DATE NOT NULL, -- Date of the last day of this quarter.
	First_Date_of_Year DATE NOT NULL, -- Date of the first day of this year.
	Last_Date_of_Year DATE NOT NULL, -- Date of the last day of this year.
	Is_Holiday BIT NOT NULL, -- 1 if a holiday
	Is_Holiday_Season BIT NOT NULL, -- 1 if part of a holiday season
	Holiday_Name VARCHAR(50) NULL, -- Name of holiday, if Is_Holiday = 1
	Holiday_Season_Name VARCHAR(50) NULL, -- Name of holiday season, if Is_Holiday_Season = 1
	Is_Weekday BIT NOT NULL, -- 1 if Monday-->Friday, 0 for Saturday/Sunday
	Is_Business_Day BIT NOT NULL, -- 1 if a workday, otherwise 0.
	Previous_Business_Day DATE NULL, -- Previous date that is a work day
	Next_Business_Day DATE NULL, -- Next date that is a work day
	Is_Leap_Year BIT NOT NULL, -- 1 if current year is a leap year.
	Days_in_Month TINYINT NOT NULL -- Number of days in the current month.
);
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE procedures.name = 'Populate_DateInfo')
BEGIN
	DROP PROCEDURE dbo.Populate_DateInfo;
END
GO

CREATE PROCEDURE dbo.Populate_DateInfo
	@Start_Date DATE, -- Start of date range to process
	@End_Date DATE -- End of date range to process
AS
BEGIN
	SET NOCOUNT ON;

	IF @Start_Date IS NULL OR @End_Date IS NULL
	BEGIN
		SELECT 'Start and end dates MUST be provided in order for this stored procedure to work.';
		RETURN;
	END

	IF @Start_Date > @End_Date
	BEGIN
		SELECT 'Start date must be less than or equal to the end date.';
		RETURN;
	END

	-- Remove all old data for the date range provided.
	DELETE FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;
	-- These variables dirrectly correspond to columns in DateInfo
	DECLARE @Date_Counter DATE = @Start_Date;
	DECLARE @Calendar_Date_String VARCHAR(10);
	DECLARE @Calendar_Month TINYINT;
	DECLARE @Calendar_Day TINYINT;
	DECLARE @Calendar_Year SMALLINT;
	DECLARE @Calendar_Quarter TINYINT;
	DECLARE @Day_Name VARCHAR(9);
	DECLARE @Day_of_Week TINYINT;
	DECLARE @Day_of_Week_in_Month TINYINT;
	DECLARE @Day_of_Week_in_Year TINYINT;
	DECLARE @Day_of_Week_in_Quarter TINYINT;
	DECLARE @Day_of_Quarter TINYINT;
	DECLARE @Day_of_Year SMALLINT;
	DECLARE @Week_of_Month TINYINT;
	DECLARE @Week_of_Quarter TINYINT;
	DECLARE @Week_of_Year TINYINT;
	DECLARE @Month_Name VARCHAR(9);
	DECLARE @First_Date_of_Week DATE;
	DECLARE @Last_Date_of_Week DATE;
	DECLARE @First_Date_of_Month DATE;
	DECLARE @Last_Date_of_Month DATE;
	DECLARE @First_Date_of_Quarter DATE;
	DECLARE @Last_Date_of_Quarter DATE;
	DECLARE @First_Date_of_Year DATE;
	DECLARE @Last_Date_of_Year DATE;
	DECLARE @Is_Holiday BIT;
	DECLARE @Is_Holiday_Season BIT;
	DECLARE @Holiday_Name VARCHAR(50);
	DECLARE @Holiday_Season_Name VARCHAR(50);
	DECLARE @Is_Weekday BIT;
	DECLARE @Is_Business_Day BIT;
	DECLARE @Is_Leap_Year BIT;
	DECLARE @Days_in_Month TINYINT;

	WHILE @Date_Counter <= @End_Date
	BEGIN
		SELECT @Calendar_Month = DATEPART(MONTH, @Date_Counter);
		SELECT @Calendar_Day = DATEPART(DAY, @Date_Counter);
		SELECT @Calendar_Year = DATEPART(YEAR, @Date_Counter);
		SELECT @Calendar_Quarter = DATEPART(QUARTER, @Date_Counter);
		SELECT @Calendar_Date_String = CAST(@Calendar_Month AS VARCHAR(10)) + '/' + CAST(@Calendar_Day AS VARCHAR(10)) + '/' + CAST(@Calendar_Year AS VARCHAR(10));
		SELECT @Day_of_Week = DATEPART(WEEKDAY, @Date_Counter);
		SELECT @Is_Weekday = CASE
								WHEN @Day_of_Week IN (1, 7)
									THEN 0
								ELSE 1
							 END;
		SELECT @Is_Business_Day = @Is_Weekday;
		SELECT @Day_Name = CASE @Day_of_Week
								WHEN 1 THEN 'Sunday'
								WHEN 2 THEN 'Monday'
								WHEN 3 THEN 'Tuesday'
								WHEN 4 THEN 'Wednesday'
								WHEN 5 THEN 'Thursday'
								WHEN 6 THEN 'Friday'
								WHEN 7 THEN 'Saturday'
							END;
		SELECT @Day_of_Quarter = DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0 , @Date_Counter), 0), @Date_Counter) + 1;
		SELECT @Day_of_Year = DATEPART(DAYOFYEAR, @Date_Counter);
		SELECT @Week_of_Month = DATEDIFF(WEEK, DATEADD(WEEK, DATEDIFF(WEEK, 0, DATEADD(MONTH, DATEDIFF(MONTH, 0, @Date_Counter), 0)), 0), @Date_Counter ) + 1;
		SELECT @Week_of_Quarter = DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @Date_Counter), 0), @Date_Counter)/7 + 1;
		SELECT @Week_of_Year = DATEPART(WEEK, @Date_Counter);
		SELECT @Month_Name = CASE @Calendar_Month
								WHEN 1 THEN 'January'
								WHEN 2 THEN 'February'
								WHEN 3 THEN 'March'
								WHEN 4 THEN 'April'
								WHEN 5 THEN 'May'
								WHEN 6 THEN 'June'
								WHEN 7 THEN 'July'
								WHEN 8 THEN 'August'
								WHEN 9 THEN 'September'
								WHEN 10 THEN 'October'
								WHEN 11 THEN 'November'
								WHEN 12 THEN 'December'
							END;

		SELECT @First_Date_of_Week = DATEADD(DAY, -1 * @Day_of_Week + 1, @Date_Counter);
		SELECT @Last_Date_of_Week = DATEADD(DAY, 1 * (7 - @Day_of_Week), @Date_Counter);
		SELECT @First_Date_of_Month = DATEADD(DAY, -1 * DATEPART(DAY, @Date_Counter) + 1, @Date_Counter);
		SELECT @Last_Date_of_Month = EOMONTH(@Date_Counter);
		SELECT @First_Date_of_Quarter = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @Date_Counter), 0);
		SELECT @Last_Date_of_Quarter = DATEADD (DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @Date_Counter) + 1, 0));
		SELECT @First_Date_of_Year = DATEADD(YEAR, DATEDIFF(YEAR, 0, @Date_Counter), 0);
		SELECT @Last_Date_of_Year = DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @Date_Counter) + 1, 0));
		SELECT @Day_of_Week_in_Month = (@Calendar_Day + 6) / 7;
		SELECT @Day_of_Week_in_Year = (@Day_of_Year + 6) / 7;
		SELECT @Day_of_Week_in_Quarter = (@Day_of_Quarter + 6) / 7;
		SELECT @Is_Leap_Year = CASE
									WHEN @Calendar_Year % 4 <> 0 THEN 0
									WHEN @Calendar_Year % 100 <> 0 THEN 1
									WHEN @Calendar_Year % 400 <> 0 THEN 0
									ELSE 1
							   END;

		SELECT @Days_in_Month = CASE
									WHEN @Calendar_Month IN (4, 6, 9, 11) THEN 30
									WHEN @Calendar_Month IN (1, 3, 5, 7, 8, 10, 12) THEN 31
									WHEN @Calendar_Month = 2 AND @Is_Leap_Year = 1 THEN 29
									ELSE 28
								END;

		INSERT INTO dbo.DateInfo
			(Calendar_Date, Calendar_Date_String, Calendar_Month, Calendar_Day, Calendar_Year, Calendar_Quarter, Day_Name, Day_of_Week, Day_of_Week_in_Month,
				Day_of_Week_in_Year, Day_of_Week_in_Quarter, Day_of_Quarter, Day_of_Year, Week_of_Month, Week_of_Quarter, Week_of_Year, Month_Name,
				First_Date_of_Week, Last_Date_of_Week, First_Date_of_Month, Last_Date_of_Month, First_Date_of_Quarter, Last_Date_of_Quarter, First_Date_of_Year,
				Last_Date_of_Year, Is_Holiday, Is_Holiday_Season, Holiday_Name, Holiday_Season_Name, Is_Weekday, Is_Business_Day, Previous_Business_Day, Next_Business_Day,
				Is_Leap_Year, Days_in_Month)
		SELECT
			@Date_Counter AS Calendar_Date,
			@Calendar_Date_String AS Calendar_Date_String,
			@Calendar_Month AS Calendar_Month,
			@Calendar_Day AS Calendar_Day,
			@Calendar_Year AS Calendar_Year,
			@Calendar_Quarter AS Calendar_Quarter,
			@Day_Name AS Day_Name,
			@Day_of_Week AS Day_of_Week,
			@Day_of_Week_in_Month AS Day_of_Week_in_Month,
			@Day_of_Week_in_Year AS Day_of_Week_in_Year,
			@Day_of_Week_in_Quarter AS Day_of_Week_in_Quarter,
			@Day_of_Quarter AS Day_of_Quarter,
			@Day_of_Year AS Day_of_Year,
			@Week_of_Month AS Week_of_Month,
			@Week_of_Quarter AS Week_of_Quarter,
			@Week_of_Year AS Week_of_Year,
			@Month_Name AS Month_Name,
			@First_Date_of_Week AS First_Date_of_Week,
			@Last_Date_of_Week AS Last_Date_of_Week,
			@First_Date_of_Month AS First_Date_of_Month,
			@Last_Date_of_Month AS Last_Date_of_Month,
			@First_Date_of_Quarter AS First_Date_of_Quarter,
			@Last_Date_of_Quarter AS Last_Date_of_Quarter,
			@First_Date_of_Year AS First_Date_of_Year,
			@Last_Date_of_Year AS Last_Date_of_Year,
			0 AS Is_Holiday,
			0 AS Is_Holiday_Season,
			NULL AS Holiday_Name,
			NULL AS Holiday_Season_Name,
			@Is_Weekday AS Is_Weekday,
			@Is_Business_Day AS Is_Business_Day, -- Will be populated with weekends to start.
			NULL AS Previous_Business_Day,
			NULL AS Next_Business_Day,
			@Is_Leap_Year AS Is_Leap_Year,
			@Days_in_Month AS Days_in_Month

		SELECT @Date_Counter = DATEADD(DAY, 1, @Date_Counter);
	END

	-- Holiday Calculations, which are based on CommerceHub holidays.  Is_Business_Day is determined based on Federal holidays only.

	-- New Year's Day: 1st of January
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'New Year''s Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 1
	AND DateInfo.Calendar_Day = 1
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Martin Luther King, Jr. Day: 3rd Monday in January, beginning in 1983
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Martin Luther King, Jr. Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 1
	AND DateInfo.Day_of_Week = 2
	AND DateInfo.Day_of_Week_in_Month = 3
	AND DateInfo.Calendar_Year >= 1983
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- President's Day: 3rd Monday in February
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'President''s Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 2
	AND DateInfo.Day_of_Week = 2
	AND DateInfo.Day_of_Week_in_Month = 3
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Valentine's Day: 14th of February
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Valentine''s Day'
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 2
	AND DateInfo.Calendar_Day = 14
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Saint Patrick's Day: 17th of March
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Saint Patrick''s Day'
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 3
	AND DateInfo.Calendar_Day = 17
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Mother's Day: 2nd Sunday in May
		UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Mother''s Day'
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 5
	AND DateInfo.Day_of_Week = 1
	AND DateInfo.Day_of_Week_in_Month = 2
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Memorial Day: Last Monday in May
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Memorial Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 5
	AND DateInfo.Day_of_Week = 2
	AND DateInfo.Day_of_Week_in_Month = (SELECT MAX(DateInfo_Memorial_Day_Check.Day_of_Week_in_Month) FROM dbo.DateInfo DateInfo_Memorial_Day_Check WHERE DateInfo_Memorial_Day_Check.Calendar_Month = DateInfo.Calendar_Month
																									  AND DateInfo_Memorial_Day_Check.Day_of_Week = DateInfo.Day_of_Week
																									  AND DateInfo_Memorial_Day_Check.Calendar_Year = DateInfo.Calendar_Year)
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Father's Day: 3rd Sunday in June
		UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Father''s Day'
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 6
	AND DateInfo.Day_of_Week = 1
	AND DateInfo.Day_of_Week_in_Month = 3
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Independence Day (USA): 4th of July
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Independence Day (USA)',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 7
	AND DateInfo.Calendar_Day = 4
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Labor Day: 1st Monday in September
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Labor Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 9
	AND DateInfo.Day_of_Week = 2
	AND DateInfo.Day_of_Week_in_Month = 1
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Columbus Day: 2nd Monday in October
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Columbus Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 10
	AND DateInfo.Day_of_Week = 2
	AND DateInfo.Day_of_Week_in_Month = 2
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Halloween: 31st of October
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Halloween'
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 10
	AND DateInfo.Calendar_Day = 31
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Veteran's Day: 11th of November
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Veteran''s Day',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 11
	AND DateInfo.Calendar_Day = 11
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Thanksgiving: 4th Thursday in November
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Thanksgiving',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 11
	AND DateInfo.Day_of_Week = 5
	AND DateInfo.Day_of_Week_in_Month = 4
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Election Day (USA): 1st Tuesday after November 1st, only in even-numbered years.  Always in the range of November 2-8.
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Election Day (USA)'
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 11
	AND DateInfo.Day_of_Week = 3
	AND DateInfo.Calendar_Day BETWEEN 2 AND 8
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Christmas: 25th of December
	UPDATE DateInfo
		SET Is_Holiday = 1,
			Holiday_Name = 'Christmas',
			Is_Business_Day = 0
	FROM dbo.DateInfo
	WHERE DateInfo.Calendar_Month = 12
	AND DateInfo.Calendar_Day = 25
	AND DateInfo.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Merge weekday and holiday data into our data set to determine business days over the time span specified in the parameters.
	-- Previous Business Day
	WITH CTE_Business_Days AS (
		SELECT
			Business_Days.Calendar_Date
		FROM dbo.DateInfo Business_Days
		WHERE Business_Days.Is_Business_Day = 1
	)
	UPDATE DateInfo_Current
		SET Previous_Business_Day = CTE_Business_Days.Calendar_Date
	FROM dbo.DateInfo DateInfo_Current
	INNER JOIN CTE_Business_Days
	ON CTE_Business_Days.Calendar_Date = (SELECT MAX(Previous_Business_Day.Calendar_Date) FROM CTE_Business_Days Previous_Business_Day
										  WHERE Previous_Business_Day.Calendar_Date < DateInfo_Current.Calendar_Date)
	WHERE DateInfo_Current.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Next Business Day
	WITH CTE_Business_Days AS (
		SELECT
			Business_Days.Calendar_Date
		FROM dbo.DateInfo Business_Days
		WHERE Business_Days.Is_Business_Day = 1
	)
	UPDATE DateInfo_Current
		SET Next_Business_Day = CTE_Business_Days.Calendar_Date
	FROM dbo.DateInfo DateInfo_Current
	INNER JOIN CTE_Business_Days
	ON CTE_Business_Days.Calendar_Date = (SELECT MIN(Next_Business_Day.Calendar_Date) FROM CTE_Business_Days Next_Business_Day
										  WHERE Next_Business_Day.Calendar_Date > DateInfo_Current.Calendar_Date)
	WHERE DateInfo_Current.Calendar_Date BETWEEN @Start_Date AND @End_Date;

	-- Define holiday seasons, if needed.

	/*	We will assume that the Christmas holiday season runs from Thanksgiving until Christmas.  Holiday seasons in general can be customized
		in order to account for different holidays and a variety of business needs, such as times of year in which systems are under an
		unusually heavy load.	*/
	WITH CTE_Thanksgiving AS (
		SELECT
			DateInfo.Calendar_Date AS Thanksgiving_Date
		FROM dbo.DateInfo
		WHERE DateInfo.Holiday_Name = 'Thanksgiving'
	)
	UPDATE DateInfo
		SET Is_Holiday_Season = 1
	FROM dbo.DateInfo
	INNER JOIN CTE_Thanksgiving
	ON DATEPART(YEAR, CTE_Thanksgiving.Thanksgiving_Date) = DATEPART(YEAR, DateInfo.Calendar_Date)
	WHERE (DateInfo.Calendar_Month = 11 AND DateInfo.Calendar_Date >= CTE_Thanksgiving.Thanksgiving_Date)
	OR (DateInfo.Calendar_Month = 12 AND DateInfo.Calendar_Day < 25);
END
GO

-- Populate DateInfo with lots of data.
EXEC dbo.Populate_DateInfo
	@Start_Date = '1/1/2015', -- Start of date range to process
	@End_Date = '1/1/2030';	  -- End of date range to process
GO


GO
IF OBJECT_ID('TrackedPlayers') IS NOT NULL DROP VIEW TrackedPlayers
GO
CREATE VIEW TrackedPlayers AS SELECT * FROM Players WHERE TrackStats = 1
GO

IF OBJECT_ID('PlayerAverages') IS NOT NULL DROP VIEW PlayerAverages
GO
CREATE VIEW PlayerAverages AS
SELECT
	 B.SummonerName 
	,COUNT(A.MatchID)										AS 'GameCount'
	,CAST(CAST(AVG(CAST(CAST(
	 Duration AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)	AS 'AverageDuration'
	,AVG(A.Kills * 1.0)										AS 'AverageKills'
	,AVG(A.Deaths * 1.0)									AS 'AverageDeaths'
	,AVG(A.Assists * 1.0)									AS 'AverageAssists'
	,AVG((A.Kills * 1.0 + A.Assists * 1.0)/ A.Deaths * 1.0)	AS 'AverageKDA'
	,AVG(A.LargestKillSpree * 1.0)							AS 'AverageLargestKillSpree'
	,AVG(A.LargestMultiKill * 1.0)							AS 'AverageLargestMultiKill'
	,AVG(A.DoubleKills * 1.0)								AS 'AverageDoubleKills'
	,AVG(A.TripleKills * 1.0)								AS 'AverageTripleKills'
	,AVG(A.QuadraKills * 1.0)								AS 'AverageQuadraKills'
	,AVG(A.PentaKills * 1.0)								AS 'AveragePentaKills'
	,AVG(A.DoubleKills	* 2.0)								
	+AVG(A.TripleKills	* 3.0)								
	+AVG(A.QuadraKills	* 4.0)								
	+AVG(A.PentaKills	* 5.0)								AS 'AverageMultiKillScore'
	,AVG(A.TotalDamageToChampions * 1.0)					AS 'AverageDamageToChamps'
	,AVG(A.TotalDamageTaken * 1.0)							AS 'AverageTotalDamageTaken'
	,AVG(A.DamageSelfMitigated * 1.0)						AS 'AverageDamageSelfMitigated'
	,AVG(A.TotalHeal * 1.0)									AS 'AverageTotalHeal'
	,AVG(A.GoldEarned * 1.0)								AS 'AverageGoldEarned'
	,AVG(A.TotalMinionsKilled * 1.0)						AS 'AverageTotalMinionsKilled'
	,AVG(A.TurretKills * 1.0)								AS 'AverageTurretKills'
	,AVG(A.DamageDealtToTurrets * 1.0)						AS 'AverageDamageToTurrets'
	
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 
	JOIN Matches C
	ON A.MatchID = C.MatchID
GROUP BY 
	B.SummonerName 
GO

IF OBJECT_ID('PlayerTotals') IS NOT NULL DROP VIEW PlayerTotals
GO
CREATE VIEW PlayerTotals AS
SELECT
	 B.SummonerName 
	,COUNT(A.MatchID)								AS 'GameCount'
	,SUM(GameLengthInSeconds)						AS 'TotalTimePlayedInSeconds'
	,SUM(A.Kills)									AS 'TotalKills'
	,SUM(A.Deaths)									AS 'TotalDeaths'
	,SUM(A.Assists)									AS 'TotalAssists'
	,(SUM(A.Kills * 1.0) + SUM(A.Assists * 1.0))
	/ SUM(A.Deaths * 1.0)							AS 'OverallKDA'
	,MAX(A.LargestKillSpree)						AS 'MaxKillSpree'
	,MAX(A.LargestMultiKill)						AS 'MaxMultiKill'
	,SUM(A.DoubleKills)								AS 'TotalDoubleKills'
	,SUM(A.TripleKills)								AS 'TotalTripleKills'
	,SUM(A.QuadraKills)								AS 'TotalQuadraKills'
	,SUM(A.PentaKills)								AS 'TotalPentaKills'
	,SUM(A.PentaKills)	* 5 
	+SUM(A.QuadraKills)	* 4
	+SUM(A.TripleKills)	* 3
	+SUM(A.DoubleKills)	* 2								AS 'MultiKillScore'
	,SUM(A.TotalDamageToChampions)					AS 'TotalDamageToChamps'
	,SUM(A.TotalDamageTaken)						AS 'TotalDamageTaken'
	,SUM(A.DamageSelfMitigated)						AS 'TotalDamageSelfMitigated'
	,SUM(A.TotalHeal)								AS 'TotalHeal'
	,SUM(A.GoldEarned)								AS 'TotalGoldEarned'
	,SUM(A.TotalMinionsKilled)						AS 'TotalMinionsKilled'
	,SUM(A.TurretKills)								AS 'TotalTurretKills'
	,SUM(A.DamageDealtToTurrets)					AS 'TotalDamageToTurrets'
	
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID
	JOIN Matches C
	ON A.MatchID = C.MatchID

GROUP BY 
	B.SummonerName 
GO

IF OBJECT_ID('ChampionAverages') IS NOT NULL DROP VIEW ChampionAverages
GO
CREATE VIEW ChampionAverages AS
SELECT
	 C.ChampionName 
	,COUNT(A.MatchID)										AS 'GameCount'
	,CAST(CAST(AVG(CAST(CAST(
	 Duration AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)	AS 'AverageDuration'
	,AVG(A.Kills * 1.0)										AS 'AverageKills'
	,AVG(A.Deaths * 1.0)									AS 'AverageDeaths'
	,AVG(A.Assists * 1.0)									AS 'AverageAssists'
	,AVG((A.Kills * 1.0 + A.Assists * 1.0)/ A.Deaths * 1.0)	AS 'AverageKDA'
	,AVG(A.LargestKillSpree * 1.0)							AS 'AverageLargestKillSpree'
	,AVG(A.LargestMultiKill * 1.0)							AS 'AverageLargestMultiKill'
	,AVG(A.DoubleKills * 1.0)								AS 'AverageDoubleKills'
	,AVG(A.TripleKills * 1.0)								AS 'AverageTripleKills'
	,AVG(A.QuadraKills * 1.0)								AS 'AverageQuadraKills'
	,AVG(A.PentaKills * 1.0)								AS 'AveragePentaKills'
	,AVG(A.DoubleKills	* 2.0)								
	+AVG(A.TripleKills	* 3.0)								
	+AVG(A.QuadraKills	* 4.0)								
	+AVG(A.PentaKills	* 5.0)								AS 'AverageMultiKillScore'
	,AVG(A.TotalDamageToChampions * 1.0)					AS 'AverageDamageToChamps'
	,AVG(A.TotalDamageTaken * 1.0)							AS 'AverageTotalDamageTaken'
	,AVG(A.DamageSelfMitigated * 1.0)						AS 'AverageDamageSelfMitigated'
	,AVG(A.TotalHeal * 1.0)									AS 'AverageTotalHeal'
	,AVG(A.GoldEarned * 1.0)								AS 'AverageGoldEarned'
	,AVG(A.TotalMinionsKilled * 1.0)						AS 'AverageTotalMinionsKilled'
	,AVG(A.TurretKills * 1.0)								AS 'AverageTurretKills'
	,AVG(A.DamageDealtToTurrets * 1.0)						AS 'AverageDamageToTurrets'	
FROM	
	Champions AS C
	LEFT JOIN MatchTeamParticipants AS B		
		JOIN MatchTeamParticipantStats AS A
			JOIN Matches D
			ON A.MatchID = D.MatchID
		ON A.MatchID = B.MatchID AND A.ParticipantID = B.ParticipantID
	ON C.ChampionID = B.ChampionID
GROUP BY 
	C.ChampionName
GO

IF OBJECT_ID('ChampionTotals') IS NOT NULL DROP VIEW ChampionTotals
GO
CREATE VIEW ChampionTotals AS
SELECT
	 C.ChampionName 
	,COUNT(A.MatchID)									AS 'GameCount'
	,SUM(GameLengthInSeconds)							AS 'TotalTimePlayedInSeconds'
	,SUM(A.Kills)										AS 'TotalKills'
	,SUM(A.Deaths)										AS 'TotalDeaths'
	,SUM(A.Assists)										AS 'TotalAssists'
	,(SUM(A.Kills * 1.0) + SUM(A.Assists * 1.0))
	/ SUM(A.Deaths * 1.0)								AS 'OverallKDA'
	,MAX(A.LargestKillSpree)							AS 'MaxKillSpree'
	,MAX(A.LargestMultiKill)							AS 'MaxMultiKill'
	,SUM(A.DoubleKills)									AS 'TotalDoubleKills'
	,SUM(A.TripleKills)									AS 'TotalTripleKills'
	,SUM(A.QuadraKills)									AS 'TotalQuadraKills'
	,SUM(A.PentaKills)									AS 'TotalPentaKills'
	,SUM(A.PentaKills)	* 5 
	+SUM(A.QuadraKills)	* 4
	+SUM(A.TripleKills)	* 3
	+SUM(A.DoubleKills)	* 2								AS 'MultiKillScore'
	,SUM(A.TotalDamageToChampions)						AS 'TotalDamageToChamps'
	,SUM(A.TotalDamageTaken)							AS 'TotalDamageTaken'
	,SUM(A.DamageSelfMitigated)							AS 'TotalDamageSelfMitigated'
	,SUM(A.TotalHeal)									AS 'TotalHeal'
	,SUM(A.GoldEarned)									AS 'TotalGoldEarned'
	,SUM(A.TotalMinionsKilled)							AS 'TotalMinionsKilled'
	,SUM(A.TurretKills)									AS 'TotalTurretKills'
	,SUM(A.DamageDealtToTurrets)						AS 'TotalDamageToTurrets'
FROM	
	Champions AS C
	LEFT JOIN MatchTeamParticipants AS B		
		JOIN MatchTeamParticipantStats AS A
			JOIN Matches D
			ON A.MatchID = D.MatchID
		ON A.MatchID = B.MatchID AND A.ParticipantID = B.ParticipantID
	ON C.ChampionID = B.ChampionID
GROUP BY 
	C.ChampionName
GO	

IF OBJECT_ID('TeamTotals') IS NOT NULL DROP VIEW TeamTotals
GO
CREATE VIEW TeamTotals AS	
SELECT
	 A.TeamID
	,A.MatchID
	,SUM(A.TotalMinionsKilled)			AS	'TeamTotalMinionsKilled'
	,SUM(A.TotalDamageToChampions)		AS	'TeamTotalDamageToChampions'
FROM
	Champions AS C
	LEFT JOIN MatchTeamParticipants AS B		
		JOIN MatchTeamParticipantStats AS A
			JOIN Matches D
			ON A.MatchID = D.MatchID
		ON A.MatchID = B.MatchID AND A.ParticipantID = B.ParticipantID
		ON C.ChampionID = B.ChampionID
GROUP BY
	A.TeamID,
	A.MatchID
GO

IF OBJECT_ID('PlayerAveragesByChampion') IS NOT NULL DROP VIEW PlayerAveragesByChampion
GO
CREATE VIEW PlayerAveragesByChampion AS
SELECT
	 F.SummonerName
	,C.ChampionName
	,COUNT(A.MatchID)										AS 'GameCount'
	,CAST(CAST(AVG(CAST(CAST(
	 Duration AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)	AS 'AverageDuration'
	,AVG(A.Kills * 1.0)										AS 'AverageKills'
	,AVG(A.Deaths * 1.0)									AS 'AverageDeaths'
	,AVG(A.Assists * 1.0)									AS 'AverageAssists'
	,AVG((A.Kills * 1.0 + A.Assists * 1.0)/ A.Deaths * 1.0)	AS 'AverageKDA'
	,AVG(A.LargestKillSpree * 1.0)							AS 'AverageLargestKillSpree'
	,AVG(A.LargestMultiKill * 1.0)							AS 'AverageLargestMultiKill'
	,AVG(A.DoubleKills	* 1.0)								AS 'AverageDoubleKills'
	,AVG(A.TripleKills	* 1.0)								AS 'AverageTripleKills'
	,AVG(A.QuadraKills	* 1.0)								AS 'AverageQuadraKills'
	,AVG(A.PentaKills	* 5.0)								AS 'AveragePentaKills'
	,AVG(A.DoubleKills	* 2.0)								
	+AVG(A.TripleKills	* 3.0)								
	+AVG(A.QuadraKills	* 4.0)								
	+AVG(A.PentaKills	* 5.0)								AS 'AverageMultiKillScore'
	,AVG(A.TotalDamageToChampions * 1.0)					AS 'AverageDamageToChamps'
	,AVG((A.TotalDamageToChampions * 1.0)
		/(D.GameLengthInSeconds * 1.0))						AS 'AverageDamagePerSecond'
	,AVG((A.TotalDamageToChampions * 1.0)
		/(D.GameLengthInSeconds / 60.0))					AS 'AverageDamagePerMinute'
	,AVG(A.TotalDamageTaken * 1.0)							AS 'AverageTotalDamageTaken'
	,AVG(A.DamageSelfMitigated * 1.0)						AS 'AverageDamageSelfMitigated'
	,AVG(A.TotalHeal * 1.0)									AS 'AverageTotalHeal'
	,AVG(A.GoldEarned * 1.0)								AS 'AverageGoldEarned'
	,AVG(A.TotalMinionsKilled * 1.0)						AS 'AverageTotalMinionsKilled'
	,AVG(E.TeamTotalMinionsKilled * 1.0)					AS 'AverageTeamTotalMinionsKilled'
	,AVG(A.TurretKills * 1.0)								AS 'AverageTurretKills'
	,AVG(A.DamageDealtToTurrets * 1.0)						AS 'AverageDamageToTurrets'	
FROM	
	Champions AS C
	JOIN MatchTeamParticipants AS B		
		JOIN Players AS F 
		ON B.AccountID = F.AccountID
		JOIN MatchTeamParticipantStats AS A
			JOIN Matches D
			ON A.MatchID = D.MatchID
			JOIN TeamTotals AS E
			ON A.MatchID = E.MatchID AND A.TeamID = E.TeamID			
			
		ON A.MatchID = B.MatchID AND A.ParticipantID = B.ParticipantID
	ON C.ChampionID = B.ChampionID
GROUP BY 
	F.SummonerName, C.ChampionName
GO

IF OBJECT_ID('PlayerTotalsByChampion') IS NOT NULL DROP VIEW PlayerTotalsByChampion
GO
CREATE VIEW PlayerTotalsByChampion AS
SELECT
	 F.SummonerName
	,C.ChampionName
	,COUNT(A.MatchID)								AS 'GameCount'
	,SUM(GameLengthInSeconds)						AS 'TotalTimePlayedInSeconds'
	,SUM(A.Kills)									AS 'TotalKills'
	,SUM(A.Deaths)									AS 'TotalDeaths'
	,SUM(A.Assists)									AS 'TotalAssists'
	,(SUM(A.Kills * 1.0) + SUM(A.Assists * 1.0))
	/ SUM(A.Deaths * 1.0)							AS 'OverallKDA'
	,MAX(A.LargestKillSpree)						AS 'MaxKillSpree'
	,MAX(A.LargestMultiKill)						AS 'MaxMultiKill'
	,SUM(A.DoubleKills)								AS 'TotalDoubleKills'
	,SUM(A.TripleKills)								AS 'TotalTripleKills'
	,SUM(A.QuadraKills)								AS 'TotalQuadraKills'
	,SUM(A.PentaKills)								AS 'TotalPentaKills'
	,SUM(A.PentaKills)	* 5 
	+SUM(A.QuadraKills)	* 4
	+SUM(A.TripleKills)	* 3
	+SUM(A.DoubleKills)	* 2							AS 'MultiKillScore'
	,SUM(A.TotalDamageToChampions)					AS 'TotalDamageToChamps'
	,SUM(A.PhysicalDamageToChampions)				AS 'TotalPhysicalDamageToChamps'
	,SUM(A.MagicDamageToChampions)					AS 'TotalMagicDamageToChamps'
	,SUM(A.TrueDamageToChampions)					AS 'TotalTrueDamageToChamps'
	,SUM(A.TotalDamageTaken)						AS 'TotalDamageTaken'
	,SUM(A.DamageSelfMitigated)						AS 'TotalDamageSelfMitigated'
	,SUM(A.TotalHeal)								AS 'TotalHeal'
	,SUM(A.GoldEarned)								AS 'TotalGoldEarned'
	,SUM(A.TotalMinionsKilled)						AS 'TotalMinionsKilled'
	,SUM(E.TeamTotalMinionsKilled * 1.0)			AS 'TotalMinionsKilledByTeam'
	,SUM(A.TurretKills)								AS 'TotalTurretKills'
	,SUM(A.DamageDealtToTurrets)					AS 'TotalDamageToTurrets'

FROM	
	Champions AS C
	JOIN MatchTeamParticipants AS B		
		JOIN Players AS F 
		ON B.AccountID = F.AccountID
		JOIN MatchTeamParticipantStats AS A
			JOIN Matches D
			ON A.MatchID = D.MatchID
			JOIN TeamTotals AS E
			ON A.MatchID = E.MatchID AND A.TeamID = E.TeamID			
			
		ON A.MatchID = B.MatchID AND A.ParticipantID = B.ParticipantID
	ON C.ChampionID = B.ChampionID
GROUP BY 
	F.SummonerName, C.ChampionName
GO

-- CREATE LOGIN abamreader WITH PASSWORD = 'abam'; CREATE USER abamreader FOR LOGIN abamreader; GRANT SELECT ON SCHEMA :: dbo TO abamreader WITH GRANT OPTION;  
