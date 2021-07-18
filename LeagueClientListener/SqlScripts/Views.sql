USE ABAM_Stats
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
	,AVG(A.TotalDamageToChampions * 1.0)					AS 'AverageDamageToChamps'
	,AVG(A.TotalDamageTaken * 1.0)							AS 'AverageTotalDamageTaken'
	,AVG(A.DamageSelfMitigated * 1.0)						AS 'AverageDamageSelfMitigated'
	,AVG(A.TotalHeal * 1.0)									AS 'AverageTotalHeal'
	,AVG(A.TotalUnitsHealed * 1.0)							AS 'AverageTotalUnitsHealed'
	,AVG(A.GoldEarned * 1.0)								AS 'AverageGoldEarned'
	,AVG(A.TotalMinionsKilled * 1.0)						AS 'AverageTotalMinionsKilled'
	,AVG(A.TurretKills * 1.0)								AS 'AverageTurretKills'
	,AVG(A.DamageDealtToTurrets * 1.0)						AS 'AverageDamageToTurrets'
	
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 
GROUP BY 
	B.SummonerName 
GO

IF OBJECT_ID('PlayerTotals') IS NOT NULL DROP VIEW PlayerTotals
GO
CREATE VIEW PlayerTotals AS
SELECT
	 B.SummonerName 
	,COUNT(A.MatchID)								AS 'GameCount'
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
	,SUM(A.TotalDamageToChampions)					AS 'TotalDamageToChamps'
	,SUM(A.TotalDamageTaken)						AS 'TotalDamageTaken'
	,SUM(A.DamageSelfMitigated)						AS 'TotalDamageSelfMitigated'
	,SUM(A.TotalHeal)								AS 'TotalTotalHeal'
	,SUM(A.TotalUnitsHealed)						AS 'TotalTotalUnitsHealed'
	,SUM(A.GoldEarned)								AS 'TotalGoldEarned'
	,SUM(A.TotalMinionsKilled)						AS 'TotalMinionsKilled'
	,SUM(A.TurretKills)								AS 'TotalTurretKills'
	,SUM(A.DamageDealtToTurrets)					AS 'TotalDamageToTurrets'
	
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 	
GROUP BY 
	B.SummonerName 
GO

SELECT * FROM PlayerAverages
SELECT * FROM PlayerTotals


IF OBJECT_ID('ChampionAverages') IS NOT NULL DROP VIEW ChampionAverages
GO
CREATE VIEW ChampionAverages AS
SELECT
	 C.ChampionName 
	,COUNT(A.MatchID)										AS 'GameCount'
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
	,AVG(A.TotalDamageToChampions * 1.0)					AS 'AverageDamageToChamps'
	,AVG(A.TotalDamageTaken * 1.0)							AS 'AverageTotalDamageTaken'
	,AVG(A.DamageSelfMitigated * 1.0)						AS 'AverageDamageSelfMitigated'
	,AVG(A.TotalHeal * 1.0)									AS 'AverageTotalHeal'
	,AVG(A.TotalUnitsHealed * 1.0)							AS 'AverageTotalUnitsHealed'
	,AVG(A.GoldEarned * 1.0)								AS 'AverageGoldEarned'
	,AVG(A.TotalMinionsKilled * 1.0)						AS 'AverageTotalMinionsKilled'
	,AVG(A.TurretKills * 1.0)								AS 'AverageTurretKills'
	,AVG(A.DamageDealtToTurrets * 1.0)						AS 'AverageDamageToTurrets'	
FROM 
	MatchTeamParticipantStats AS A 
		JOIN MatchTeamParticipants AS B
				JOIN Champions AS C
				ON B.ChampionID = C.ChampionID
		ON	A.MatchID = B.MatchID
		AND A.ParticipantID = B.ParticipantID			
GROUP BY 
	C.ChampionName
GO

IF OBJECT_ID('ChampionTotals') IS NOT NULL DROP VIEW ChampionTotals
GO
CREATE VIEW ChampionTotals AS
SELECT
	 C.ChampionName 
	,COUNT(A.MatchID)								AS 'GameCount'
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
	,SUM(A.TotalDamageToChampions)					AS 'TotalDamageToChamps'
	,SUM(A.TotalDamageTaken)						AS 'TotalDamageTaken'
	,SUM(A.DamageSelfMitigated)						AS 'TotalDamageSelfMitigated'
	,SUM(A.TotalHeal)								AS 'TotalTotalHeal'
	,SUM(A.TotalUnitsHealed)						AS 'TotalTotalUnitsHealed'
	,SUM(A.GoldEarned)								AS 'TotalGoldEarned'
	,SUM(A.TotalMinionsKilled)						AS 'TotalMinionsKilled'
	,SUM(A.TurretKills)								AS 'TotalTurretKills'
	,SUM(A.DamageDealtToTurrets)					AS 'TotalDamageToTurrets'
FROM	
	MatchTeamParticipantStats AS A 
		JOIN MatchTeamParticipants AS B
				JOIN Champions AS C
				ON B.ChampionID = C.ChampionID
		ON	A.MatchID = B.MatchID
		AND A.ParticipantID = B.ParticipantID			
GROUP BY 
	C.ChampionName
GO

SELECT * FROM ChampionAverages
SELECT * FROM ChampionTotals