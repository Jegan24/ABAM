using ABAM_Stats.Classes;
using ABAM_Stats.Classes.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace ABAM_Stats
{
    class Program
    {
        // JUST USE CONFIGURATION BUILDER ITS EASY 8======================D
        private static string connectionString = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=ABAM_Stats;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False;MultipleActiveResultSets=True;";
        static async Task Main(string[] args)
        {

            string uniqueTitle = Guid.NewGuid().ToString();
            Console.Title = uniqueTitle;
            await Task.Delay(50);
            IntPtr handle = FindWindowByCaption(IntPtr.Zero, uniqueTitle);
            SetForegroundWindow(handle);
            await Task.Delay(50);
            Console.Title = "ABAM Data";

            Console.WriteLine("Update Static Data?");
            var response = Console.ReadLine();
            if (response.StartsWith("y", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("Enter version number");
                string version = Console.ReadLine();
                var dataDragonParser = new DataDragonParser(version, connectionString);
                DateTime start = DateTime.Now;
                await dataDragonParser.ParseDataDragon();
                DateTime end = DateTime.Now;
                Console.WriteLine($"Completed in {end.Subtract(start).TotalSeconds} seconds.\n");
            }

            Console.WriteLine("Use Archived Match Data?");
            response = Console.ReadLine();
            string directory;
            if (response.StartsWith("y", StringComparison.OrdinalIgnoreCase))
            {
                directory = Path.Combine(Directory.GetCurrentDirectory(), "MatchArchive");
            }
            else
            {
                Console.WriteLine("Enter folder path:");
                directory = Console.ReadLine();
            }

            IEnumerable<MatchInfo> matches = Array.Empty<MatchInfo>();

            try
            {
                matches = await MatchFinder.GetMatchesFromDirectory(directory);
            }
            catch (Exception ex)
            {
                Console.Clear();
                Console.WriteLine("Error occured while locating directory. Display system error message?");
                Console.WriteLine($"System error message: {ex.Message}");
            }

            if (matches.Any())
            {
                Console.WriteLine($"Found {matches.Count()} JSON files. Attempting to parse and persist.");
                var matchParser = new MatchParser(connectionString);
                DateTime start = DateTime.Now;
                await matchParser.AddMatchesToDb(matches);
                DateTime end = DateTime.Now;
                Console.WriteLine($"Completed in {end.Subtract(start).TotalSeconds} seconds.");
            }
            else
            {
                Console.WriteLine("Didn't find any JSON files, try again.");
            }

        }

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", EntryPoint = "FindWindow", SetLastError = true)]
        static extern IntPtr FindWindowByCaption(IntPtr zeroOnly, string lpWindowName);
    }

}
