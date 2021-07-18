using ABAM_Stats.Classes;
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace ABAM_Stats
{
    class Program
    {
        // JUST USE CONFIGURATION BUILDER ITS EASY 8======================D
        private static string connectionString = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=ABAM_Stats;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False;MultipleActiveResultSets=True;";
        static async Task Main(string[] args)
        {

            Console.WriteLine("Update Static Data?");
            var response = Console.ReadLine();
            if (response.StartsWith("y", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("Enter version number");
                string version = Console.ReadLine();
                var dataDragonParser = new DataDragonParser(version, connectionString);
                await dataDragonParser.ParseDataDragon();
            }
            string directory = Path.Combine(Directory.GetCurrentDirectory(), "MatchArchive");
            Console.Write(string.Join('\n', Directory.GetFiles(directory)));
            var matches = await MatchFinder.GetMatchesFromDirectory(directory);
            if (matches.Any())
            {
                var matchParser = new MatchParser(connectionString);
                await matchParser.AddMatchesToDb(matches);
            }

        }
    }

}
