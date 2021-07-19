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

            IEnumerable<string> columnNames = new string[] { "ChampionID", "ChampionName" };
            var values = newChamps.Select(champ => $"({champ.Id},'{champ.Name.Replace("'", "''")}')");

            Console.WriteLine($"\nFound {newChamps.Count()} new champions:\n{string.Join('\n', newChamps.Select(champ => champ.Name))}");

            await InsertValuesIntoTable("Champions", columnNames, values);
        }

        private async Task AddItemsToDb(Dictionary<int, ItemStatic> items)
        {
            var existingIDs = await GetIDsInDb("Items", "ItemID");
            var newItems = items.Values.Where(item => !existingIDs.Contains(item.Id));

            IEnumerable<string> columnNames = new string[] { "ItemID", "ItemName" };
            var values = newItems.Select(item => $"({item.Id},'{item.Name.Replace("'", "''")}')");

            Console.WriteLine($"\nFound {newItems.Count()} new items:\n{string.Join('\n', newItems.Select(item => item.Name))}");

            await InsertValuesIntoTable("Items", columnNames, values);
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
            IEnumerable<string> runePathColumnNames = new string[] { "RunePathID", "RunePathName" };
            var existingRunePathIDs = await GetIDsInDb("RunePaths", "RunePathID");

            var newRunePaths = runePaths.Where(runePath => !existingRunePathIDs.Contains(runePath.Id));
            var runePathValues = newRunePaths.Select(runePath => $"({runePath.Id},'{runePath.Name.Replace("'", "''")}')");

            Console.WriteLine($"\nFound {newRunePaths.Count()} new rune paths:\n{string.Join('\n', newRunePaths.Select(runePath => runePath.Name))}");

            await InsertValuesIntoTable("RunePaths", runePathColumnNames, runePathValues);
            #endregion

            #region Runes (same^)
            IEnumerable<string> runePathRunesColumnNames = new string[] { "RunePathID", "RuneID", "RuneName" };
            var existingRuneIDs = await GetIDsInDb("RunePathRunes", "RuneID");

            var newRunes = runes.Where(rune => !existingRuneIDs.Contains(rune.Item2.Id));
            var runeValues = newRunes.Select(rune => $"({rune.Item1},{rune.Item2.Id},'{rune.Item2.Name.Replace("'", "''")}')");

            Console.WriteLine($"\nFound {newRunes.Count()} new runes:\n{string.Join('\n', newRunes.Select(rune => rune.Item2.Name))}");

            await InsertValuesIntoTable("RunePathRunes", runePathRunesColumnNames, runeValues);
            #endregion
        }

        private async Task AddSummonerSpellsToDb(Dictionary<string, SummonerSpellStatic> summonerSpells)
        {
            var existingIDs = await GetIDsInDb("SummonerSpells", "SummonerSpellID");
            var newSummonerSpells = summonerSpells.Values.Where(v => !existingIDs.Contains(v.Id));

            IEnumerable<string> columnNames = new string[] { "SummonerSpellID", "SummonerSpellName" };
            var values = newSummonerSpells.Select(v => $"({v.Id},'{v.Name.Replace("'", "''")}')");

            Console.WriteLine($"\nFound {newSummonerSpells.Count()} new summoner spells:\n{string.Join('\n', newSummonerSpells.Select(summonerSpell => summonerSpell.Name))}");

            await InsertValuesIntoTable("SummonerSpells", columnNames, values);
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
