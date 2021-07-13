using System;
using System.Threading.Tasks;
using PoniLCU;

namespace LeagueClientListener
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("Neato let's try to find some ABAM data!");

            await RunTime.Instance.Run();
        }
        
    }

    class RunTime
    {
        public readonly LeagueClient Client;
        private static RunTime runTime;
        private RunTime()
        {
            Client = new LeagueClient();
        }

        public static RunTime Instance
        {
            get
            {
                if(runTime == null)
                {
                    runTime = new RunTime();
                }
                return runTime;
            }
        }

        public async Task Run()
        {
            while (true)
            {
                while (!Client.IsConnected)
                {
                    await Task.Delay(100);
                }
                Subscribe();
                
            }
        }

        private void Subscribe()
        {
            Client.Subscribe("", Test);
        }

        private void Test(OnWebsocketEventArgs eventArgs)
        {

        }
    }

}
