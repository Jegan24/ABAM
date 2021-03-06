USE ABAM_Stats
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
SELECT * FROM Champions ORDER BY ChampionName ASC
SELECT * FROM Items
SELECT * FROM RunePaths
SELECT * FROM RunePathRunes
SELECT * FROM SummonerSpells