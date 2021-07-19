using ABAM_Stats.Classes.Json;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ABAM_Stats.Classes
{
    public class MatchParser
    {
        private readonly SqlConnection sqlConnection;
        private List<long> matchIDsInDb;
        private List<long> accountIDsInDb;
        public MatchParser(string connectionString)
        {
            sqlConnection = new SqlConnection(connectionString);
        }

        public async Task AddMatchesToDb(IEnumerable<MatchInfo> matchInfos)
        {
            await sqlConnection.OpenAsync();

            await LoadDbMetaData();

            foreach (var matchInfo in matchInfos)
            {
                var match = matchInfo.Match;
                //var transaction = await sqlConnection.BeginTransactionAsync();
                // skip games already in db and ignore non-custom games
                if (   matchIDsInDb.Contains(match.gameId) 
                    || match.queueId != 0 
                    || string.Compare(match.gameType, "CUSTOM_GAME", StringComparison.OrdinalIgnoreCase) != 0 
                    || string.Compare(match.gameMode, "ARAM", StringComparison.OrdinalIgnoreCase) != 0)
                {
                    Console.WriteLine($"Skipping match with ID of {match.gameId}. Either it's already in the database or failed validation.");
                    continue;
                }
                Console.WriteLine($"Adding match with ID of {match.gameId}");
                await AddMatchToDb(matchInfo);
                foreach (var player in match.participantIdentities.Select(p => p.player))
                {
                    if (!accountIDsInDb.Contains(player.accountId))
                    {
                        Console.WriteLine($"Found new summoner: {player.summonerName}");
                        await AddPlayerToDb(player);
                        accountIDsInDb.Add(player.accountId);
                    }
                }
                foreach (var team in match.teams)
                {
                    await AddMatchTeamToDb(match.gameId, team);
                }
                foreach (var participant in match.participants)
                {
                    var accountId = match.participantIdentities.First(pI => participant.participantId == pI.participantId).player.accountId;
                    await AddParticipantToDb(match.gameId, accountId, participant);
                }

                //await transaction.CommitAsync();
            }
            
            await sqlConnection.CloseAsync();
        }
        private async Task LoadDbMetaData()
        {
            matchIDsInDb = new List<long>(await GetIDsInDb("Matches", "MatchID"));
            accountIDsInDb = new List<long>(await GetIDsInDb("Players", "AccountID"));
        }

        private async Task AddPlayerToDb(Player player)
        {
            SqlCommand sqlCommand = new SqlCommand();

            sqlCommand.CommandText =
                $"INSERT INTO Players (AccountID, SummonerName, SummonerID, TrackStats) " +
                $"VALUES ({player.accountId}, '{player.summonerName}', {player.summonerId}, 1)";
            sqlCommand.Connection = sqlConnection;

            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task AddMatchToDb(MatchInfo matchInfo)
        {
            var match = matchInfo.Match;
            SqlCommand sqlCommand = new SqlCommand();
            var date = new DateTime(1970, 1, 1).AddTicks(match.gameCreation * 10000);
            var duration = TimeSpan.FromSeconds(match.gameDuration);
            sqlCommand.CommandText =
                $"INSERT INTO Matches (MatchID, DateOfMatch, Duration, GameLengthInSeconds) " +
                $"VALUES ({match.gameId},'{date}', '{duration}', {match.gameDuration})";
            sqlCommand.Connection = sqlConnection;

            await sqlCommand.ExecuteNonQueryAsync();
            
            sqlCommand = new SqlCommand();
            sqlCommand.CommandText =
                $"INSERT INTO MatchMetaData (MatchID, DateAdded, RawJson)" +
                $"VALUES ({match.gameId}, GETDATE(), N'{matchInfo.Json}')";
            sqlCommand.Connection = sqlConnection;
            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task AddMatchTeamToDb(long matchID, Team team)
        {
            SqlCommand sqlCommand = new SqlCommand();

            sqlCommand.CommandText =
                $"INSERT INTO MatchTeams (MatchID, TeamID, Win, FirstBlood, FirstTower, FirstInhibitor, TowerKills, InhibitorKills) " +
                $"VALUES (" +
                $"          {matchID}," +
                $"          {team.teamId}, " +
                $"          {(team.win == "Win" ? 1 : 0)}," +
                $"          {(team.firstBlood ? 1 : 0)}," +
                $"          {(team.firstTower ? 1 : 0)}," +
                $"          {(team.firstInhibitor ? 1 : 0)}," +
                $"          {team.towerKills}," +
                $"          {team.inhibitorKills})";
            sqlCommand.Connection = sqlConnection;

            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task AddParticipantToDb(long matchID, long accountID, Participant participant)
        {
            SqlCommand sqlCommand = new SqlCommand();

            sqlCommand.CommandText =
                $"INSERT INTO MatchTeamParticipants (MatchID, TeamID, ParticipantID, AccountID, ChampionID, Spell1ID, Spell2ID) " +
                $"VALUES (" +
                $"          {matchID}," +
                $"          {participant.teamId}," +
                $"          {participant.participantId}," +
                $"          {accountID}," +
                $"          {participant.championId}," +
                $"          {participant.spell1Id}," +
                $"          {participant.spell2Id})";
            sqlCommand.Connection = sqlConnection;

            await sqlCommand.ExecuteNonQueryAsync();

            sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlConnection;
            var stats = participant.stats;
            sqlCommand.CommandText = $@"
                INSERT INTO MatchTeamParticipantStats 	(
                                                            MatchID, 
                                                            TeamID, 
                                                            ParticipantID,
	                                                        AccountID,
	                                                        Win,
	                                                        Item1ID,
	                                                        Item2ID,
	                                                        Item3ID,
	                                                        Item4ID,
	                                                        Item5ID,
	                                                        Item6ID,
	                                                        Kills,
	                                                        Deaths,
	                                                        Assists,
	                                                        LargestKillSpree,
	                                                        LargestMultiKill,
	                                                        KillingSprees,
	                                                        LongestTimeSpentLiving,
	                                                        DoubleKills,
	                                                        TripleKills,
	                                                        QuadraKills,
	                                                        PentaKills,
	                                                        TotalDamageDealt,
	                                                        PhysicalDamageDealt,
	                                                        MagicDamageDealt,
	                                                        TrueDamageDealt,
	                                                        LargestCriticalStrike,
	                                                        TotalDamageToChampions,
	                                                        PhysicalDamageToChampions,
	                                                        MagicDamageToChampions,
	                                                        TrueDamageToChampions,
	                                                        TotalHeal,
	                                                        TotalUnitsHealed,
	                                                        DamageSelfMitigated,
	                                                        DamageDealtToObjectives,
	                                                        DamageDealtToTurrets,
	                                                        TimeCCingOthers,
	                                                        TotalDamageTaken,
	                                                        PhysicalDamageTaken,
	                                                        MagicDamageTaken,
	                                                        TrueDamageTaken,
	                                                        GoldEarned,
	                                                        GoldSpent,
	                                                        TurretKills,
	                                                        InhibitorKills,
	                                                        TotalMinionsKilled,
	                                                        TotalTimeCrowdControlDealt,
	                                                        ChampLevel,
	                                                        FirstBloodKill,
	                                                        FirstBloodAssist,
	                                                        FirstTowerKill,
	                                                        FirstTowerAssist,
	                                                        FirstInihibitorKill,
	                                                        FirstInhibitorAssist,
	                                                        KeystoneID,
	                                                        PrimaryRune1ID,
	                                                        PrimaryRune2ID,
	                                                        PrimaryRune3ID,
	                                                        SecondaryRune1ID,
	                                                        SecondaryRune2ID,
	                                                        PrimaryRunePathID,
	                                                        SecondaryRunePathID,
	                                                        MetaWin)
            VALUES (                                                            
                                                            {matchID}, 
                                                            {participant.teamId}, 
                                                            {participant.participantId},
	                                                        {accountID},
	                                                        {(stats.win ? 1 : 0)},
	                                                        {stats.item0},
	                                                        {stats.item1},
	                                                        {stats.item2},
	                                                        {stats.item3},
	                                                        {stats.item4},
	                                                        {stats.item5},
	                                                        {stats.kills},
	                                                        {stats.deaths},
	                                                        {stats.assists},
	                                                        {stats.largestKillingSpree},
	                                                        {stats.largestMultiKill},
	                                                        {stats.killingSprees},
	                                                        {stats.longestTimeSpentLiving},
	                                                        {stats.doubleKills},
	                                                        {stats.tripleKills},
	                                                        {stats.quadraKills},
	                                                        {stats.pentaKills},
	                                                        {stats.totalDamageDealt},
	                                                        {stats.physicalDamageDealt},
	                                                        {stats.magicDamageDealt},
	                                                        {stats.trueDamageDealt},
	                                                        {stats.largestCriticalStrike},
	                                                        {stats.totalDamageDealtToChampions},
	                                                        {stats.physicalDamageDealtToChampions},
	                                                        {stats.magicDamageDealtToChampions},
	                                                        {stats.trueDamageDealtToChampions},
	                                                        {stats.totalHeal},
	                                                        {stats.totalUnitsHealed},
	                                                        {stats.damageSelfMitigated},
	                                                        {stats.damageDealtToObjectives},
	                                                        {stats.damageDealtToTurrets},
	                                                        {stats.timeCCingOthers},
	                                                        {stats.totalDamageTaken},
	                                                        {stats.physicalDamageTaken},
	                                                        {stats.magicalDamageTaken},
	                                                        {stats.trueDamageTaken},
	                                                        {stats.goldEarned},
	                                                        {stats.goldSpent},
	                                                        {stats.turretKills},
	                                                        {stats.inhibitorKills},
	                                                        {stats.totalMinionsKilled},
	                                                        {stats.totalTimeCrowdControlDealt},
	                                                        {stats.champLevel},
	                                                        {(stats.firstBloodKill ? 1 : 0)},
	                                                        {(stats.firstBloodAssist ? 1 : 0)},
	                                                        {(stats.firstTowerKill ? 1 : 0)},
	                                                        {(stats.firstTowerAssist ? 1 : 0)},
	                                                        {(stats.firstInhibitorKill ? 1 : 0)},
	                                                        {(stats.firstInhibitorAssist ? 1 : 0)},
	                                                        {stats.perk0},
	                                                        {stats.perk1},
	                                                        {stats.perk2},
	                                                        {stats.perk3},
	                                                        {stats.perk4},
	                                                        {stats.perk5},
	                                                        {stats.perkPrimaryStyle},
	                                                        {stats.perkSubStyle},
	                                                        null
)                                
";
            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task<IEnumerable<long>> GetIDsInDb(string tableName, string columnName)
        {
            List<long> IDs = new List<long>();
            SqlCommand cmd = new SqlCommand($"SELECT {columnName} FROM {tableName}", sqlConnection);

            using (var reader = await cmd.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    IDs.Add(reader.GetInt64(0));
                }
            }

            return IDs;
        }
    }
}
