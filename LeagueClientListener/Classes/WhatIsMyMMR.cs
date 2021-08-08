using ABAM_Stats.Classes.Json;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace ABAM_Stats.Classes
{
    public static class WhatIsMyMMR
    {
        private const string endpoint = "https://na.whatismymmr.com/api/v1/summoner?name=";
        private static HttpClient client;
        public static async Task<WhatIsMyMmrResponse> GetMMR(string summonerName)
        {
            client = new HttpClient();
            try
            {
                Console.WriteLine($"Sending request to WhatIsMyMMR {DateTime.Now:hh:mm:ss}");
                var response = await client.GetAsync(endpoint + Uri.EscapeDataString(summonerName));
                response.EnsureSuccessStatusCode();
                Console.WriteLine("Response received successfully");
                string responseBody = await response.Content.ReadAsStringAsync();
                client.Dispose();
                return JsonConvert.DeserializeObject<WhatIsMyMmrResponse>(responseBody);
            }
            catch (HttpRequestException requestException)
            {
                Console.WriteLine($"Response did not indicate success: {requestException.StatusCode}");                
                Console.WriteLine(requestException.Message);
            }
            catch(Exception ex)
            {
                Console.WriteLine("Unexpected exception:");
                Console.WriteLine(ex.Message);
            }
            return null;
        }
    }
}
