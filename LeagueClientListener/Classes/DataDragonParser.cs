using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RiotSharp.Endpoints.StaticDataEndpoint.Champion;
using RiotSharp.Endpoints.StaticDataEndpoint;
using System.Data.SqlClient;
using System.Data;
using RiotSharp.Endpoints.StaticDataEndpoint.Item;
using RiotSharp.Endpoints.StaticDataEndpoint.ReforgedRune;
using RiotSharp.Endpoints.StaticDataEndpoint.SummonerSpell;

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

            await sqlConnection.OpenAsync();
            await Task.WhenAll(AddChampsToDb(champions.Champions), AddItemsToDb(items.Items), AddRunesToDb(runes), AddSummonerSpellsToDb(summonerSpells.SummonerSpells));
            await sqlConnection.CloseAsync();

        }

        private async Task AddChampsToDb(Dictionary<string, ChampionStatic> champs)
        {
            var existingIDs = await GetIDsInDb("Champions", "ChampionID");
            IEnumerable<string> columnNames = new string[] { "ChampionID", "ChampionName" };
            var values =
                champs.Values
                        .Where(v => !existingIDs.Contains(v.Id))
                        .Select(v => $"({v.Id},'{v.Name.Replace("'", "''")}')");
            await InsertValuesIntoTable("Champions", columnNames, values);
        }

        private async Task AddItemsToDb(Dictionary<int, ItemStatic> items)
        {
            var existingIDs = await GetIDsInDb("Items", "ItemID");
            IEnumerable<string> columnNames = new string[] { "ItemID", "ItemName" };
            var values =
                items.Values
                        .Where(i => !existingIDs.Contains(i.Id))
                        .Select(i => $"({i.Id},'{i.Name.Replace("'","''")}')");
            await InsertValuesIntoTable("Items", columnNames, values);
        }

        private async Task AddRunesToDb(List<ReforgedRunePathStatic> runePaths)
        {
            await Task.Delay(1);

            var runes = new List<Tuple<int, ReforgedRuneStatic>>();
            foreach (var runePath in runePaths)
            {                
                foreach(var slot in runePath.Slots)
                {
                    runes.AddRange(slot.Runes.Select(r => new Tuple<int, ReforgedRuneStatic>(runePath.Id, r)));
                }
            }

            IEnumerable<string> runePathColumnNames = new string[] { "RunePathID", "RunePathName" };
            var existingRunePathIDs = await GetIDsInDb("RunePaths", "RunePathID");
            var runePathValues =
                runePaths
                    .Where(rP => !existingRunePathIDs.Contains(rP.Id))
                    .Select(rP => $"({rP.Id},'{rP.Name.Replace("'", "''")}')");
            await InsertValuesIntoTable("RunePaths", runePathColumnNames, runePathValues);

            IEnumerable<string> runePathRunesColumnNames = new string[] { "RunePathID", "RuneID", "RuneName" };
            var existingRuneIDs = await GetIDsInDb("RunePathRunes", "RuneID");
            var runeValues =
                    runes
                        .Where(r => !existingRuneIDs.Contains(r.Item2.Id))
                        .Select(r => $"({r.Item1},{r.Item2.Id},'{r.Item2.Name.Replace("'", "''")}')");
            await InsertValuesIntoTable("RunePathRunes", runePathRunesColumnNames, runeValues);
        }

        private async Task AddSummonerSpellsToDb(Dictionary<string, SummonerSpellStatic> summonerSpells)
        {
            var existingIDs = await GetIDsInDb("SummonerSpells", "SummonerSpellID");
            IEnumerable<string> columnNames = new string[] { "SummonerSpellID", "SummonerSpellName" };
            var values =
                summonerSpells.Values
                    .Where(v => !existingIDs.Contains(v.Id))
                    .Select(v => $"({v.Id},'{v.Name.Replace("'", "''")}')");
            await InsertValuesIntoTable("SummonerSpells", columnNames, values);
        }

        private async Task<IEnumerable<int>> GetIDsInDb(string tableName, string columnName)
        {
            List<int> IDs = new List<int>();
            SqlCommand cmd = new SqlCommand($"SELECT {columnName} FROM {tableName}", sqlConnection);
            
            using(var reader = await cmd.ExecuteReaderAsync())
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
