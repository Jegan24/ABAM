USE ABAM_Stats
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

SELECT * FROM Matches
SELECT * FROM MatchTeams
SELECT * FROM MatchTeamParticipants
SELECT * FROM MatchTeamParticipantStats
SELECT * FROM Players
SELECT COUNT(*), SummonerName FROM Players JOIN MatchTeamParticipants ON Players.AccountID = MatchTeamParticipants.AccountID GROUP BY SummonerName
SELECT * FROM MatchTeamParticipantStats WHERE AccountID IN (SELECT AccountID FROM Players WHERE SummonerName = 'iPooUnicorns')
SELECT * FROM MatchMetaData

-- Commented out in case calendar script hasnt been executed
-- SELECT * FROM Matches JOIN DateInfo ON CAST(Matches.DateOfMatch AS DATE) = DateInfo.Calendar_Date ORDER BY DateOfMatch DESC

SELECT
	RuneName,
	RuneID,
	PrimaryRune3Values
FROM
	MatchTeamParticipantStats AS A
	JOIN RunePathRunes AS B ON A.PrimaryRune3ID = B.RuneID


SELECT
	*
FROM
	MatchTeamParticipantStats 
WHERE
	PrimaryRune3ID = 8135 OR
	SecondaryRune2ID = 8135
