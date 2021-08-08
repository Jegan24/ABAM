using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace ABAM_Stats.Classes.Json
{
    public class WhatIsMyMmrResponse
    {
        [JsonProperty(PropertyName = "ranked")]
        public Ranked Ranked { get; set; }

        [JsonProperty(PropertyName = "normal")]
        public Normal Normal { get; set; }

        [JsonProperty(PropertyName = "ARAM")]
        public ARAM ARAM { get; set; }
    }

    public class Ranked
    {
        [JsonProperty(PropertyName = "avg")]
        public double? Average { get; set; }

        [JsonProperty(PropertyName = "err")]
        public double? MarginOfError { get; set; }

        [JsonProperty(PropertyName = "warn")]
        public bool? InsufficientData { get; set; }

        [JsonProperty(PropertyName = "summary")]
        public string Summary { get; set; }

        [JsonProperty(PropertyName = "closestRank")]
        public string ClosestRank { get; set; }

        [JsonProperty(PropertyName = "percentile")]
        public double? Percentile { get; set; }

        [JsonProperty(PropertyName = "tierData")]
        public IEnumerable<TierData> TierData { get; set; }

        [JsonProperty(PropertyName = "timestamp")]
        public double? Timestamp { get; set; }

        [JsonProperty(PropertyName = "historical")]
        public IEnumerable<Historical> Historical { get; set; }

        [JsonProperty(PropertyName = "historicalTierData")]
        public IEnumerable<HistoricalTierData> HistoricalTierData { get; set; }
    }

    public class TierData
    {
        [JsonProperty(PropertyName = "name")]
        public string Name { get; set; }

        [JsonProperty(PropertyName = "avg")]
        public double? Average { get; set; }

        [JsonProperty(PropertyName = "min")]
        public double? Minimum { get; set; }

        [JsonProperty(PropertyName = "max")]
        public double? Maximum { get; set; }

    }

    public class Historical
    {
        [JsonProperty(PropertyName = "avg")]
        public double? Average { get; set; }

        [JsonProperty(PropertyName = "err")]
        public double? MarginOfError { get; set; }

        [JsonProperty(PropertyName = "warn")]
        public bool? InsufficientData { get; set; }

        [JsonProperty(PropertyName = "timestamp")]
        public double? Timestamp { get; set; }
    }

    public class HistoricalTierData
    {
        [JsonProperty(PropertyName = "name")]
        public string Name { get; set; }

        [JsonProperty(PropertyName = "avg")]
        public double? Average { get; set; }
    }

    public class Normal
    {
        [JsonProperty(PropertyName = "avg")]
        public double? Average { get; set; }

        [JsonProperty(PropertyName = "err")]
        public double? MarginOfError { get; set; }

        [JsonProperty(PropertyName = "warn")]
        public bool? InsufficientData { get; set; }

        [JsonProperty(PropertyName = "closestRank")]
        public string ClosestRank { get; set; }

        [JsonProperty(PropertyName = "percentile")]
        public double? Percentile { get; set; }

        [JsonProperty(PropertyName = "timestamp")]
        public double? Timestamp { get; set; }

        [JsonProperty(PropertyName = "historical")]
        public IEnumerable<Historical> Historical { get; set; }
    }

    public class ARAM
    {
        [JsonProperty(PropertyName = "avg")]
        public double? Average { get; set; }

        [JsonProperty(PropertyName = "err")]
        public double? MarginOfError { get; set; }

        [JsonProperty(PropertyName = "warn")]
        public bool? InsufficientData { get; set; }

        [JsonProperty(PropertyName = "closestRank")]
        public string ClosestRank { get; set; }

        [JsonProperty(PropertyName = "percentile")]
        public double? Percentile { get; set; }

        [JsonProperty(PropertyName = "timestamp")]
        public double? Timestamp { get; set; }

        [JsonProperty(PropertyName = "historical")]
        public IEnumerable<Historical> Historical { get; set; }
    }

}
