USE ABAM_Stats
GO

IF OBJECT_ID('Champions')	IS NOT NULL DROP TABLE Champions
GO
CREATE TABLE Champions
(
	ChampionID		INT			NOT NULL,
	ChampionName	VARCHAR(127)	NOT NULL,
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
	CONSTRAINT PK_Items	PRIMARY KEY(ItemID)y
)
GO
INSERT INTO Items (ItemID, ItemName) VALUES (0, 'None')
GO
IF OBJECT_ID('RunePathRunes')		IS NOT NULL DROP TABLE RunePathRunes
GO
IF OBJECT_ID('RunePaths')	IS NOT NULL DROP TABLE RunePaths
GO
CREATE TABLE RunePaths
(
	RunePathID		INT				NOT NULL,
	RunePathName	VARCHAR(127)	NOT NULL,
	CONSTRAINT PK_RunePaths PRIMARY KEY (RunePathID)
)
GO

CREATE TABLE RunePathRunes
(
	RunePathID		INT				NOT NULL,
	RuneID			INT				NOT NULL,
	RuneName		VARCHAR(127)	NOT NULL,	
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
	CONSTRAINT PK_SummonerSpells PRIMARY KEY (SummonerSpellID)
)
GO
SELECT * FROM Champions ORDER BY ChampionName ASC
SELECT * FROM Items
SELECT * FROM RunePaths
SELECT * FROM RunePathRunes
SELECT * FROM SummonerSpells