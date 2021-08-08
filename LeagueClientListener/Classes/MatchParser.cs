using ABAM_Stats.Classes.Json;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
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
        private List<PlayerInfo> playersInfo;
        private Match currentMatch;
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
                currentMatch = matchInfo.Match;
                //var transaction = await sqlConnection.BeginTransactionAsync();
                // skip games already in db and ignore non-custom games                
                if (matchIDsInDb.Contains(currentMatch.gameId))
                {
                    Console.WriteLine($"Skipping match with ID of {currentMatch.gameId}. It's already in the database.");
                    continue;
                }
                else if (currentMatch.queueId != 0
                    || string.Compare(currentMatch.gameType, "CUSTOM_GAME", StringComparison.OrdinalIgnoreCase) != 0
                    || string.Compare(currentMatch.gameMode, "ARAM", StringComparison.OrdinalIgnoreCase) != 0
                    || matchInfo.Match.participantIdentities.Where(pI => !string.IsNullOrEmpty(pI?.player?.summonerName)).Count() != 10)
                {
                    Console.WriteLine($"Skipping match with ID of {currentMatch.gameId}. It failed validation.");
                    continue;
                }
                Console.WriteLine($"Adding match with ID of {currentMatch.gameId}");
                await AddMatchToDb(matchInfo);
                foreach (var player in currentMatch.participantIdentities.Select(p => p.player))
                {
                    var playerInfo = playersInfo.FirstOrDefault(p => p.AccountID == player.accountId);
                    if (playerInfo != null)
                    {
                        var matchDate = GetDateTimeOfMatch(currentMatch);
                        if (playerInfo.SummonerName != player.summonerName && playerInfo.LastUpdated < matchDate)
                        {
                            await UpdatePlayerInfo(player);
                            var newPlayerInfo = playerInfo with { SummonerName = player.summonerName, LastUpdated = GetDateTimeOfMatch(currentMatch) };
                            playersInfo.Remove(playerInfo);
                            playersInfo.Add(newPlayerInfo);
                            Console.WriteLine($"Summoner: {playerInfo.SummonerName} changed their name to: {player.summonerName}");
                        }
                    }
                    else if (!accountIDsInDb.Contains(player.accountId))
                    {
                        Console.WriteLine($"Found new summoner: {player.summonerName}");
                        await AddPlayerToDb(player);
                        accountIDsInDb.Add(player.accountId);
                    }
                }
                foreach (var team in currentMatch.teams)
                {
                    await AddMatchTeamToDb(currentMatch.gameId, team);
                }
                foreach (var participant in currentMatch.participants)
                {
                    var accountId = currentMatch.participantIdentities.First(pI => participant.participantId == pI.participantId).player.accountId;
                    await AddParticipantToDb(currentMatch.gameId, accountId, participant);
                }

                //await transaction.CommitAsync();
            }

            await sqlConnection.CloseAsync();
        }

        private async Task UpdatePlayerInfo(Player player)
        {
            SqlCommand sqlCommand = new SqlCommand();
            sqlCommand.Connection = sqlConnection;
            sqlCommand.CommandText = $"UPDATE Players SET SummonerName = N'{player.summonerName}', LastUpdated = '{GetDateTimeOfMatch(currentMatch)}' WHERE AccountID = {player.accountId}";
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();
            //playersInfo = new List<PlayerInfo>(await GetPlayerNamesAndIDs());
        }

        private async Task LoadDbMetaData()
        {
            matchIDsInDb = new List<long>(await GetIDsInDb("Matches", "MatchID"));
            accountIDsInDb = new List<long>(await GetIDsInDb("Players", "AccountID"));
            playersInfo = new List<PlayerInfo>(await GetPlayerNamesAndIDs());
        }

        private async Task AddPlayerToDb(Player player)
        {


            string commandText =
                $"INSERT INTO Players (AccountID, SummonerName, SummonerID, TrackStats, LastUpdated) " +
                $"VALUES ({player.accountId}, N'{player.summonerName}', {player.summonerId}, 1, '{GetDateTimeOfMatch(currentMatch)}')";
            SqlCommand sqlCommand = new SqlCommand(commandText, sqlConnection);
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task AddMatchToDb(MatchInfo matchInfo)
        {
            var match = matchInfo.Match;
            SqlCommand sqlCommand = new SqlCommand();
            var date = GetDateTimeOfMatch(match);
            var duration = TimeSpan.FromSeconds(match.gameDuration);
            sqlCommand.CommandText =
                $"INSERT INTO Matches (MatchID, DateOfMatch, Duration, GameLengthInSeconds) " +
                $"VALUES ({match.gameId},'{date}', '{duration}', {match.gameDuration})";
            sqlCommand.Connection = sqlConnection;
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();

            sqlCommand = new SqlCommand();
            sqlCommand.CommandText =
                $"INSERT INTO MatchMetaData (MatchID, DateAdded, RawJson)" +
                $"VALUES ({match.gameId}, GETDATE(), N'{matchInfo.Json}')";
            sqlCommand.Connection = sqlConnection;
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task AddMatchTeamToDb(long matchID, Team team)
        {

            string commandText =
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
            SqlCommand sqlCommand = new SqlCommand(commandText, sqlConnection);
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task AddParticipantToDb(long matchID, long accountID, Participant participant)
        {

            string commandText =
                $"INSERT INTO MatchTeamParticipants (MatchID, TeamID, ParticipantID, AccountID, ChampionID, Spell1ID, Spell2ID) " +
                $"VALUES (" +
                $"          {matchID}," +
                $"          {participant.teamId}," +
                $"          {participant.participantId}," +
                $"          {accountID}," +
                $"          {participant.championId}," +
                $"          {participant.spell1Id}," +
                $"          {participant.spell2Id})";
            SqlCommand sqlCommand = new SqlCommand(commandText, sqlConnection);
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();


            var stats = participant.stats;
            commandText = $@"
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
                                                            KeystoneValues,
	                                                        PrimaryRune1ID,
                                                            PrimaryRune1Values,
	                                                        PrimaryRune2ID,
                                                            PrimaryRune2Values,
	                                                        PrimaryRune3ID,
                                                            PrimaryRune3Values,
	                                                        SecondaryRune1ID,
                                                            SecondaryRune1Values,
	                                                        SecondaryRune2ID,
                                                            SecondaryRune2Values,
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
                                                            @KeystoneValues,
	                                                        {stats.perk1},
                                                            @PrimaryRune1Values,
	                                                        {stats.perk2},
                                                            @PrimaryRune2Values,
	                                                        {stats.perk3},
                                                            @PrimaryRune3Values,
	                                                        {stats.perk4},
                                                            @SecondRune1Values,
	                                                        {stats.perk5},
                                                            @SecondaryRune2Values,
	                                                        {stats.perkPrimaryStyle},
	                                                        {stats.perkSubStyle},
	                                                        null
)                                
";
            sqlCommand = new SqlCommand(commandText, sqlConnection);
            sqlCommand.Parameters.Add(new SqlParameter()
            {
                ParameterName = "@KeystoneValues",
                Value = JsonConvert.SerializeObject(new { Value1 = stats.perk0Var1, Value2 = stats.perk0Var2, Value3 = stats.perk0Var3 }),
                SqlDbType = SqlDbType.NVarChar
            });
            sqlCommand.Parameters.Add(new SqlParameter()
            {
                ParameterName = "@PrimaryRune1Values",
                Value = JsonConvert.SerializeObject(new { Value1 = stats.perk1Var1, Value2 = stats.perk1Var2, Value3 = stats.perk1Var3 }),
                SqlDbType = SqlDbType.NVarChar
            });
            sqlCommand.Parameters.Add(new SqlParameter()
            {
                ParameterName = "@PrimaryRune2Values",
                Value = JsonConvert.SerializeObject(new { Value1 = stats.perk2Var1, Value2 = stats.perk2Var2, Value3 = stats.perk2Var3 }),
                SqlDbType = SqlDbType.NVarChar
            });
            sqlCommand.Parameters.Add(new SqlParameter()
            {
                ParameterName = "@PrimaryRune3Values",
                Value = JsonConvert.SerializeObject(new { Value1 = stats.perk3Var1, Value2 = stats.perk3Var2, Value3 = stats.perk3Var3 }),
                SqlDbType = SqlDbType.NVarChar
            });
            sqlCommand.Parameters.Add(new SqlParameter()
            {
                ParameterName = "@SecondRune1Values",
                Value = JsonConvert.SerializeObject(new { Value1 = stats.perk4Var1, Value2 = stats.perk4Var2, Value3 = stats.perk4Var3 }),
                SqlDbType = SqlDbType.NVarChar
            });
            sqlCommand.Parameters.Add(new SqlParameter()
            {
                ParameterName = "@SecondaryRune2Values",
                Value = JsonConvert.SerializeObject(new { Value1 = stats.perk5Var1, Value2 = stats.perk5Var2, Value3 = stats.perk5Var3 }),
                SqlDbType = SqlDbType.NVarChar
            });
            await EnsureConnectionIsOpen();
            await sqlCommand.ExecuteNonQueryAsync();
        }

        private async Task<IEnumerable<long>> GetIDsInDb(string tableName, string columnName)
        {
            List<long> IDs = new List<long>();
            SqlCommand cmd = new SqlCommand($"SELECT {columnName} FROM {tableName}", sqlConnection);
            await EnsureConnectionIsOpen();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    IDs.Add(reader.GetInt64(0));
                }
            }

            return IDs;
        }

        private async Task<IEnumerable<PlayerInfo>> GetPlayerNamesAndIDs()
        {
            var output = new List<PlayerInfo>();
            SqlCommand cmd = new SqlCommand($"SELECT AccountID, SummonerName, LastUpdated FROM Players", sqlConnection);
            await EnsureConnectionIsOpen();
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    long id = reader.GetInt64(reader.GetOrdinal("AccountID"));
                    string name = reader.GetString(reader.GetOrdinal("SummonerName"));
                    DateTime lastUpdated = reader.GetDateTime(reader.GetOrdinal("LastUpdated"));
                    output.Add(new PlayerInfo() { SummonerName = name, AccountID = id, LastUpdated = lastUpdated });
                }
            }

            return output;
        }
        public async Task UpdateMMR()
        {
            var players = await GetPlayerNamesAndIDs();

            foreach (var player in players)
            {
                Console.WriteLine($"Getting MMR for: {player.SummonerName}");
                try
                {
                    var mmrResponse = await WhatIsMyMMR.GetMMR(player.SummonerName);
                    if (mmrResponse?.ARAM?.Average != null)
                    {
                        Console.WriteLine($"{player.SummonerName} has an MMR of {mmrResponse.ARAM.Average.Value} which is approximately {mmrResponse.ARAM.ClosestRank}.");
                        await SetMMR(player, mmrResponse.ARAM);
                    }                    
                    else 
                    {
                        Console.WriteLine("Response did not contain ARAM data.");
                    }

                }
                catch (Exception ex)
                {
                    Console.WriteLine("Unexpected error occured:");
                    Console.WriteLine(ex.Message);
                }
                await Task.Delay(TimeSpan.FromSeconds(2));
            }
        }
        private async Task SetMMR(PlayerInfo player, ARAM aram)
        {
            SqlCommand cmd = new SqlCommand("UpdateMMR", sqlConnection)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.Add(new SqlParameter("@AccountID", player.AccountID));
            cmd.Parameters.Add(new SqlParameter("@MMR", Convert.ToInt32(aram.Average)));
            cmd.Parameters.Add(new SqlParameter("@Rank", aram.ClosestRank));
            await EnsureConnectionIsOpen();
            await cmd.ExecuteNonQueryAsync();
        }
        private async Task EnsureConnectionIsOpen()
        {
            if (sqlConnection.State != ConnectionState.Open)
            {
                await sqlConnection.OpenAsync();
            }
        }
        private static DateTime GetDateTimeOfMatch(Match match)
        {
            return new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Local).AddTicks(match.gameCreation * 10000);
        }
        private record PlayerInfo
        {
            public long AccountID { get; init; }
            public string SummonerName { get; init; }
            public DateTime LastUpdated { get; init; }
        }
    }
}
