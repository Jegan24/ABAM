using System;
using System.Collections.Generic;
using ABAM_Stats.Classes.Json;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

namespace ABAM_Stats.Classes
{
    /// <summary>
    /// Utility class for getting all json match files and returning them as an <see cref="IEnumerable{T}"/> where T is a <see cref="Match"/>
    /// </summary>
    public static class MatchFinder
    {
        public static async Task<IEnumerable<MatchInfo>> GetMatchesFromDirectory(string directory)
        {
            var contents = new List<string>();
            var matches = new List<MatchInfo>();
            var fileNames = Directory.GetFiles(directory);
            foreach (var fileName in fileNames)
            {
                using (StreamReader reader = new StreamReader(fileName))
                {
                    var content = await reader.ReadToEndAsync();
                    contents.Add(content);
                }
            }
            foreach (var content in contents)
            {
                try
                {
                    matches.Add(new MatchInfo()
                    {
                        Match = JsonConvert.DeserializeObject<Match>(content),
                        Json = content
                    });
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
            }
            return matches;
        }
    }
}
