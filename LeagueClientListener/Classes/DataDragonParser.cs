using Newtonsoft.Json;
using RiotSharp.Endpoints.StaticDataEndpoint;
using RiotSharp.Endpoints.StaticDataEndpoint.Champion;
using RiotSharp.Endpoints.StaticDataEndpoint.Item;
using RiotSharp.Endpoints.StaticDataEndpoint.ReforgedRune;
using RiotSharp.Endpoints.StaticDataEndpoint.SummonerSpell;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ABAM_Stats.Classes
{
    public class DataDragonParser
    {
        private readonly string version;
        private readonly SqlConnection sqlConnection;

        public DataDragonParser(string version, string dbConnectionString)
        {
            this.version = version;
            sqlConnection = new SqlConnection(dbConnectionString);
        }

        public async Task ParseDataDragon()
        {

            var endpoint = DataDragonEndpoints.GetInstance(true);

            ChampionListStatic champions = null;
            Task GetChampions = Task.Run(async () =>
            {
                champions = await endpoint.Champions.GetAllAsync(version);
            });
            ItemListStatic items = null;
            Task GetItems = Task.Run(async () =>
            {
                items = await endpoint.Items.GetAllAsync(version);
            });
            List<ReforgedRunePathStatic> runes = null;
            Task GetRunes = Task.Run(async () =>
            {
                runes = await endpoint.ReforgedRunes.GetAllAsync(version);
            });

            SummonerSpellListStatic summonerSpells = null;
            Task GetSummonerSpells = Task.Run(async () =>
            {
                summonerSpells = await endpoint.SummonerSpells.GetAllAsync(version);
            });

            await Task.WhenAll(GetChampions, GetItems, GetRunes, GetSummonerSpells);
            Console.WriteLine("\nData successfully retrieved from Riot Data Dragon.");
            await sqlConnection.OpenAsync();
            await Task.WhenAll(AddChampsToDb(champions.Champions), AddItemsToDb(items.Items), AddRunesToDb(runes), AddSummonerSpellsToDb(summonerSpells.SummonerSpells));
            await sqlConnection.CloseAsync();

        }

        private async Task AddChampsToDb(Dictionary<string, ChampionStatic> champs)
        {
            var existingIDs = await GetIDsInDb("Champions", "ChampionID");
            var newChamps = champs.Values.Where(champ => !existingIDs.Contains(champ.Id));

            IEnumerable<string> columnNames = new string[] { "ChampionID", "ChampionName", "RawJson" };
            var values = newChamps.Select(champ => $"({champ.Id},'{champ.Name.Replace("'", "''")}', N'" +
            $"{Regex.Escape(JsonConvert.SerializeObject(champ))}')");

            Console.WriteLine($"\nFound {newChamps.Count()} new champions:\n{string.Join('\n', newChamps.Select(champ => champ.Name))}");
            string sqlText = $"INSERT INTO Champions ({string.Join(',', columnNames)}) VALUES ({string.Join(',', columnNames.Select(columnName => "@" + columnName))})";

            foreach (var champ in newChamps)
            {
                SqlCommand sqlCommand = new SqlCommand(sqlText, sqlConnection);
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.VarChar,
                    Value = champ.Name,
                    ParameterName = "@ChampionName"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.Int,
                    Value = champ.Id,
                    ParameterName = "@ChampionID"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.NVarChar,
                    Value = JsonConvert.SerializeObject(champ),
                    ParameterName = "@RawJson"
                });
                await sqlCommand.ExecuteNonQueryAsync();
            }
            
            //await InsertValuesIntoTable("Champions", columnNames, values);
        }

        private async Task AddItemsToDb(Dictionary<int, ItemStatic> items)
        {
            var existingIDs = await GetIDsInDb("Items", "ItemID");
            var newItems = items.Values.Where(item => !existingIDs.Contains(item.Id));

            IEnumerable<string> columnNames = new string[] { "ItemID", "ItemName", "RawJson" };
            var values = newItems.Select(item => $"({item.Id},'{item.Name.Replace("'", "''")}', N'" +
            $"{Regex.Escape(JsonConvert.SerializeObject(item))}')");

            Console.WriteLine($"\nFound {newItems.Count()} new items:\n{string.Join('\n', newItems.Select(item => item.Name))}");
            string sqlText = $"INSERT INTO Items ({string.Join(',', columnNames)}) VALUES ({string.Join(',', columnNames.Select(columnName => "@" + columnName))})";

            foreach (var item in newItems)
            {
                SqlCommand sqlCommand = new SqlCommand(sqlText, sqlConnection);
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.VarChar,
                    Value = item.Name,
                    ParameterName = "@ItemName"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.Int,
                    Value = item.Id,
                    ParameterName = "@ItemID"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.NVarChar,
                    Value = JsonConvert.SerializeObject(item),
                    ParameterName = "@RawJson"
                });
                await sqlCommand.ExecuteNonQueryAsync();
            }
            //await InsertValuesIntoTable("Items", columnNames, values);
        }

        private async Task AddRunesToDb(List<ReforgedRunePathStatic> runePaths)
        {
            var runes = new List<Tuple<int, ReforgedRuneStatic>>();
            foreach (var runePath in runePaths)
            {
                foreach (var slot in runePath.Slots)
                {
                    runes.AddRange(slot.Runes.Select(r => new Tuple<int, ReforgedRuneStatic>(runePath.Id, r)));
                }
            }
            #region Rune Paths (yeah this should be its own method but w/e)
            IEnumerable<string> runePathColumnNames = new string[] { "RunePathID", "RunePathName", "RawJson" };
            var existingRunePathIDs = await GetIDsInDb("RunePaths", "RunePathID");

            var newRunePaths = runePaths.Where(runePath => !existingRunePathIDs.Contains(runePath.Id));
            var runePathValues = newRunePaths.Select(runePath => $"({runePath.Id},'{runePath.Name.Replace("'", "''")}', N'" +
            $"{Regex.Escape(JsonConvert.SerializeObject(runePath))}')");

            Console.WriteLine($"\nFound {newRunePaths.Count()} new rune paths:\n{string.Join('\n', newRunePaths.Select(runePath => runePath.Name))}");
            string sqlText = $"INSERT INTO RunePaths ({string.Join(',', runePathColumnNames)}) VALUES ({string.Join(',', runePathColumnNames.Select(columnName => "@" + columnName))})";

            foreach (var runePath in newRunePaths)
            {
                SqlCommand sqlCommand = new SqlCommand(sqlText, sqlConnection);
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.VarChar,
                    Value = runePath.Name,
                    ParameterName = "@RunePathName"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.Int,
                    Value = runePath.Id,
                    ParameterName = "@RunePathID"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.NVarChar,
                    Value = JsonConvert.SerializeObject(runePath),
                    ParameterName = "@RawJson"
                });
                await sqlCommand.ExecuteNonQueryAsync();
            }
            //await InsertValuesIntoTable("RunePaths", runePathColumnNames, runePathValues);
            #endregion

            #region Runes (same^)
            IEnumerable<string> runePathRunesColumnNames = new string[] { "RunePathID", "RuneID", "RuneName", "RawJson" };
            var existingRuneIDs = await GetIDsInDb("RunePathRunes", "RuneID");

            var newRunes = runes.Where(rune => !existingRuneIDs.Contains(rune.Item2.Id));
            var runeValues = newRunes.Select(rune => $"({rune.Item1},{rune.Item2.Id},'{rune.Item2.Name.Replace("'", "''")}'," +
            $"N'{Regex.Escape(JsonConvert.SerializeObject(rune))}')");

            Console.WriteLine($"\nFound {newRunes.Count()} new runes:\n{string.Join('\n', newRunes.Select(rune => rune.Item2.Name))}");

            string sqlText2 = $"INSERT INTO RunePathRunes ({string.Join(',', runePathRunesColumnNames)}) VALUES ({string.Join(',', runePathRunesColumnNames.Select(columnName => "@" + columnName))})";

            foreach (var runeTuple in newRunes)
            {
                var rune = runeTuple.Item2;
                SqlCommand sqlCommand = new SqlCommand(sqlText2, sqlConnection);
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.VarChar,
                    Value = rune.Name,
                    ParameterName = "@RuneName"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.Int,
                    Value = runeTuple.Item1,
                    ParameterName = "@RunePathID"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.Int,
                    Value = rune.Id,
                    ParameterName = "@RuneID"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.NVarChar,
                    Value = JsonConvert.SerializeObject(rune),
                    ParameterName = "@RawJson"
                });
                await sqlCommand.ExecuteNonQueryAsync();
            }

            //await InsertValuesIntoTable("RunePathRunes", runePathRunesColumnNames, runeValues);
            #endregion
        }

        private async Task AddSummonerSpellsToDb(Dictionary<string, SummonerSpellStatic> summonerSpells)
        {
            var existingIDs = await GetIDsInDb("SummonerSpells", "SummonerSpellID");
            var newSummonerSpells = summonerSpells.Values.Where(v => !existingIDs.Contains(v.Id));

            IEnumerable<string> columnNames = new string[] { "SummonerSpellID", "SummonerSpellName", "RawJson" };

            // Sanitize the object because SQL doesn't play nice with it
            foreach (var summonerSpell in newSummonerSpells)
            {
                summonerSpell.Description = summonerSpell.SanitizedDescription;
                summonerSpell.Tooltip = summonerSpell.SanitizedTooltip;
                summonerSpell.SanitizedDescription = null;
                summonerSpell.SanitizedTooltip = null;
                summonerSpell.Modes = null;
                summonerSpell.Vars = null;
            }
            var values = newSummonerSpells.Select(summonerSpell => $"({summonerSpell.Id},'{summonerSpell.Name.Replace("'", "''")},N'" +
            $"{Regex.Escape(JsonConvert.SerializeObject(summonerSpell))}')");

            Console.WriteLine($"\nFound {newSummonerSpells.Count()} new summoner spells:\n{string.Join('\n', newSummonerSpells.Select(summonerSpell => summonerSpell.Name))}");

            string sqlText = $"INSERT INTO SummonerSpells ({string.Join(',', columnNames)}) VALUES ({string.Join(',', columnNames.Select(columnName => "@" + columnName))})";

            foreach(var summonerSpell in newSummonerSpells)
            {
                SqlCommand sqlCommand = new SqlCommand(sqlText, sqlConnection);
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.VarChar,
                    Value = summonerSpell.Name,
                    ParameterName = "@SummonerSpellName"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.Int,
                    Value = summonerSpell.Id,
                    ParameterName = "@SummonerSpellID"
                });
                sqlCommand.Parameters.Add(new SqlParameter()
                {
                    SqlDbType = SqlDbType.NVarChar,
                    Value = JsonConvert.SerializeObject(summonerSpell),
                    ParameterName = "@RawJson"
                });
                await sqlCommand.ExecuteNonQueryAsync();
            }

            //await InsertValuesIntoTable("SummonerSpells", columnNames, values);
        }

        private async Task<IEnumerable<int>> GetIDsInDb(string tableName, string columnName)
        {
            List<int> IDs = new List<int>();
            SqlCommand cmd = new SqlCommand($"SELECT {columnName} FROM {tableName}", sqlConnection);

            using (var reader = await cmd.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    IDs.Add(reader.GetInt32(0));
                }
            }

            return IDs;
        }
        [Obsolete("I cant figure out how to get SQL to play nicely with serialized Json without the use of SqlParameter")]
        private async Task InsertValuesIntoTable(string tableName, IEnumerable<string> columnNames, IEnumerable<string> values)
        {
            if (values.Any())
            {
                SqlCommand sqlCommand = new SqlCommand();
                sqlCommand.CommandText = $"INSERT INTO {tableName} ({string.Join(',', columnNames)}) VALUES {string.Join(',', values)}";
                sqlCommand.Connection = sqlConnection;
                await sqlCommand.ExecuteNonQueryAsync();
            }
        }
    }
}
