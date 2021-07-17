USE ABAM_Stats
GO

CREATE TABLE Matches
(
	MatchID			BIGINT		NOT NULL,
	DateOfMatch		DATETIME	NOT NULL,
	CONSTRAINT PK_Matches PRIMARY KEY (MatchID)
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
	CONSTRAINT PK_MatchParticipants PRIMARY KEY (MatchID, TeamID, ParticipantID)
)