using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using RiotSharp;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using ABAM.Models;

namespace ABAM.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }
        public async Task ApiTests()
        {
            var api = RiotSharp.RiotApi.GetDevelopmentInstance("");
            var match = await api.Match.GetMatchAsync(RiotSharp.Misc.Region.Na, 1234);       
            foreach(var participant in match.Participants)
            {
                var id = participant.ParticipantId;
            }
        }
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
