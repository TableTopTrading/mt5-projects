//+------------------------------------------------------------------+
//|                                          SuperSlopeDashboard.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property indicator_chart_window
#property strict

// Include files
#include <Arrays\ArrayString.mqh>
#include <MyProjects\SuperSlope Includes\CSuperSlope.mqh>

//--- Input Parameters
input group "Calculation Parameters"
input int    SlopeMAPeriod    = 7;       // Slope MA Period
input int    SlopeATRPeriod   = 50;      // Slope ATR Period
input int    MaxBarsCalculate = 500;     // Max Bars to Calculate (0 = all)

input group "Dashboard Thresholds"
input double StrongThreshold  = 1.0;     // Strong Trend Threshold
input double WeakThreshold    = 0.5;     // Weak Trend Threshold

input group "Symbol List"
input string SymbolList       = "EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,USDCAD,NZDUSD"; // Symbols (comma-separated)

//--- Global Variables
CArrayString* symbols;        // Array to hold symbol list
CSuperSlope*  slopeCalc;     // Slope calculator instance
int          symbolCount;     // Number of symbols to monitor
bool         initialized;     // Initialization flag

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize the symbol array
   symbols = new CArrayString();
   string currentSymbol = "";
   
   // Parse the symbol list
   for(int i = 0; i < StringLen(SymbolList); i++)
   {
      if(SymbolList[i] == ',')
      {
         if(currentSymbol != "")
         {
            symbols.Add(currentSymbol);
            currentSymbol = "";
         }
      }
      else if(i == StringLen(SymbolList) - 1)
      {
         currentSymbol += SymbolList[i];
         symbols.Add(currentSymbol);
      }
      else
      {
         currentSymbol += SymbolList[i];
      }
   }
   
   symbolCount = symbols.Total();
   if(symbolCount == 0)
   {
      Print("Error: No symbols provided in SymbolList");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Initialize the slope calculator
   slopeCalc = new CSuperSlope();
   if(!slopeCalc.Initialize(SlopeMAPeriod, SlopeATRPeriod, MaxBarsCalculate))
   {
      Print("Error: Failed to initialize slope calculator");
      return INIT_FAILED;
   }
   
   initialized = true;
   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up objects
   if(symbols != NULL)
   {
      delete symbols;
      symbols = NULL;
   }
   
   if(slopeCalc != NULL)
   {
      delete slopeCalc;
      slopeCalc = NULL;
   }
   
   // Remove all created objects
   ObjectsDeleteAll(0, "SuperSlopeDash_");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
{
   if(!initialized || symbols == NULL || slopeCalc == NULL)
      return rates_total;
      
   // Arrays to hold categorized symbols
   string strongBull[];   ArrayResize(strongBull, symbolCount);
   string weakBull[];     ArrayResize(weakBull, symbolCount);
   string neutral[];      ArrayResize(neutral, symbolCount);
   string weakBear[];     ArrayResize(weakBear, symbolCount);
   string strongBear[];   ArrayResize(strongBear, symbolCount);
   
   int strongBullCount = 0;
   int weakBullCount = 0;
   int neutralCount = 0;
   int weakBearCount = 0;
   int strongBearCount = 0;
   
   // Calculate and categorize each symbol
   for(int i = 0; i < symbolCount; i++)
   {
      string symbol = symbols.At(i);
      double slopeValue = slopeCalc.Calculate(symbol);
      
      // Categorize based on slope value
      if(slopeValue >= StrongThreshold)
         strongBull[strongBullCount++] = symbol;
      else if(slopeValue >= WeakThreshold)
         weakBull[weakBullCount++] = symbol;
      else if(slopeValue > -WeakThreshold)
         neutral[neutralCount++] = symbol;
      else if(slopeValue > -StrongThreshold)
         weakBear[weakBearCount++] = symbol;
      else
         strongBear[strongBearCount++] = symbol;
   }
   
   // TODO: Add dashboard rendering code here
   // This will be implemented in the CRenderer class
   
   return rates_total;
}
//+------------------------------------------------------------------+
