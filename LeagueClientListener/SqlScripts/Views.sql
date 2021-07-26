﻿USE ABAM_Stats
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
	,AVG((A.Kills * 1.0 + A.Assists * 1.0)/
		CASE
			WHEN A.Deaths = 0
			THEN 1
			ELSE A.Deaths 
		END * 1.0)	AS 'AverageKDA'
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
	/ SUM(
		CASE
			WHEN A.Deaths = 0
			THEN 1
			ELSE A.Deaths 
		END * 1.0)									AS 'OverallKDA'
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
	,AVG((A.Kills * 1.0 + A.Assists * 1.0)/
		CASE
			WHEN A.Deaths = 0
			THEN 1
			ELSE A.Deaths 
		END * 1.0)	AS 'AverageKDA'
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
	/ SUM(
		CASE
			WHEN A.Deaths = 0
			THEN 1
			ELSE A.Deaths 
		END * 1.0)									AS 'OverallKDA'
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
	,AVG((A.Kills * 1.0 + A.Assists * 1.0)/
		CASE
			WHEN A.Deaths = 0
			THEN 1
			ELSE A.Deaths 
		END * 1.0)	AS 'AverageKDA'
	,AVG(A.LargestKillSpree * 1.0)							AS 'AverageLargestKillSpree'
	,AVG(A.LargestMultiKill * 1.0)							AS 'AverageLargestMultiKill'
	,AVG(A.DoubleKills	* 1.0)								AS 'AverageDoubleKills'
	,AVG(A.TripleKills	* 1.0)								AS 'AverageTripleKills'
	,AVG(A.QuadraKills	* 1.0)								AS 'AverageQuadraKills'
	,AVG(A.PentaKills	* 1.0)								AS 'AveragePentaKills'
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
	/ SUM(
		CASE
			WHEN A.Deaths = 0
			THEN 1
			ELSE A.Deaths 
		END * 1.0)									AS 'OverallKDA'
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

