USE ABAM_Stats
GO
SELECT TOP 10 
	B.SummonerName, 
	MAX(A.Kills) AS 'Kills' 
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 
GROUP BY 
	B.SummonerName 
ORDER BY 
	MAX(A.Kills) DESC

SELECT
	B.SummonerName, 
	AVG(A.Kills * 1.0)	AS 'AverageKillsPerGame',
	COUNT(*)			AS 'GameCount'
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 
	JOIN (
		SELECT 
			AccountID,
			COUNT(*) AS 'GameCount'
		FROM
			MatchTeamParticipantStats
		GROUP BY
			AccountID
	) AS C
	ON A.AccountID = C.AccountID
WHERE
	C.GameCount > 5
GROUP BY 
	B.SummonerName 
ORDER BY 
	AVG(A.Kills) DESC

SELECT
	B.SummonerName, 
	AVG(A.TotalDamageToChampions * 1.0)	AS 'AverageDamageToChampsPerGame',
	COUNT(*)			AS 'GameCount'
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 
	JOIN (
		SELECT 
			AccountID,
			COUNT(*) AS 'GameCount'
		FROM
			MatchTeamParticipantStats
		GROUP BY
			AccountID
	) AS C
	ON A.AccountID = C.AccountID
WHERE
	C.GameCount > 5
GROUP BY 
	B.SummonerName 
ORDER BY 
	AVG(A.TotalDamageToChampions * 1.0) DESC

SELECT 
	B.SummonerName, 
	SUM(A.Kills * 1.0 + A.Kills * 1.0) / SUM(A.Deaths * 1.0) AS 'KDA',
	COUNT(*) AS 'GameCount'
FROM 
	MatchTeamParticipantStats AS A 
	JOIN TrackedPlayers B 
	ON A.AccountID = B.AccountID 
	JOIN (
		SELECT 
			AccountID,
			COUNT(*) AS 'GameCount'
		FROM
			MatchTeamParticipantStats
		GROUP BY
			AccountID
	) AS C
	ON A.AccountID = C.AccountID
WHERE
	C.GameCount > 5
GROUP BY 
	B.SummonerName 
ORDER BY 
	SUM(A.Kills * 1.0 + A.Kills * 1.0) / SUM(A.Deaths * 1.0) DESC


SELECT
	MatchID,
	TeamID,
	SUM(Kills)			AS	'TotalKills',
	SUM(GoldEarned)		AS	'TotalTeamGold'
FROM
	MatchTeamParticipantStats
GROUP BY
	MatchID,
	TeamID

SELECT TOP 25
	C.ChampionName,
	AVG(A.Kills) AS 'AverageKillsPerGame',
	COUNT(A.Kills) AS 'GamesPlayed'
FROM
	MatchTeamParticipantStats AS A
		JOIN MatchTeamParticipants AS B
		ON	A.ParticipantID = B.ParticipantID
		AND	A.MatchID		= B.MatchID
			RIGHT JOIN Champions AS C
			ON B.ChampionID = C.ChampionID
GROUP BY
	C.ChampionName
ORDER BY
	AVG(A.Kills) DESC

SELECT
	AVG(CAST(Win AS DECIMAL)) AS 'WinRate',
	TeamID
FROM
	MatchTeams
GROUP BY
	TeamID
