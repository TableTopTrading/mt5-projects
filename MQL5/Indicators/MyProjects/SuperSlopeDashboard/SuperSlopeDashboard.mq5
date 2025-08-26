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
#include <MyProjects/SuperSlopeDashboard/CDashboardController_v2.mqh>

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
CDashboardController* dashboard_controller;  // MVC Controller instance
bool                  initialized;           // Initialization flag

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("SuperSlopeDashboard: Initializing MVC architecture...");
   
   // Create CDashboardController instance
   dashboard_controller = new CDashboardController();
   if(dashboard_controller == NULL)
   {
      Print("ERROR: Failed to create CDashboardController instance");
      return INIT_FAILED;
   }
   
   // Initialize controller with input parameters
   // Use default dashboard position (20, 50) - can be made configurable later
   if(!dashboard_controller.Initialize(SlopeMAPeriod, SlopeATRPeriod, 20, 50))
   {
      Print("ERROR: Failed to initialize CDashboardController");
      delete dashboard_controller;
      dashboard_controller = NULL;
      return INIT_FAILED;
   }
   
   // Parse symbol list and create array for controller
   string symbol_array[];
   string current_symbol = "";
   int symbol_count = 0;
   
   // Count symbols first to size array properly
   for(int i = 0; i <= StringLen(SymbolList); i++)
   {
      if(i == StringLen(SymbolList) || SymbolList[i] == ',')
      {
         if(StringLen(current_symbol) > 0)
         {
            symbol_count++;
         }
         current_symbol = "";
      }
      else if(SymbolList[i] != ' ') // Skip spaces
      {
         current_symbol += SymbolList[i];
      }
   }
   
   if(symbol_count == 0)
   {
      Print("ERROR: No symbols provided in SymbolList");
      delete dashboard_controller;
      dashboard_controller = NULL;
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Resize array and parse symbols again
   ArrayResize(symbol_array, symbol_count);
   current_symbol = "";
   int array_index = 0;
   
   for(int i = 0; i <= StringLen(SymbolList); i++)
   {
      if(i == StringLen(SymbolList) || SymbolList[i] == ',')
      {
         if(StringLen(current_symbol) > 0)
         {
            symbol_array[array_index] = current_symbol;
            array_index++;
         }
         current_symbol = "";
      }
      else if(SymbolList[i] != ' ') // Skip spaces
      {
         current_symbol += SymbolList[i];
      }
   }
   
   // Set symbols in controller
   if(!dashboard_controller.SetSymbols(symbol_array))
   {
      Print("ERROR: Failed to set symbols in CDashboardController");
      delete dashboard_controller;
      dashboard_controller = NULL;
      return INIT_FAILED;
   }
   
   // Set thresholds using input parameters
   // Map: StrongThreshold -> strong_bull, WeakThreshold -> weak_bull, -StrongThreshold -> weak_bear
   if(!dashboard_controller.SetThresholds(StrongThreshold, WeakThreshold, -StrongThreshold))
   {
      Print("ERROR: Failed to set thresholds in CDashboardController");
      delete dashboard_controller;
      dashboard_controller = NULL;
      return INIT_FAILED;
   }
   
   initialized = true;
   Print("SuperSlopeDashboard: Initialization completed successfully");
   Print("  - Symbols: ", symbol_count);
   Print("  - MA Period: ", SlopeMAPeriod);
   Print("  - ATR Period: ", SlopeATRPeriod);
   Print("  - Strong Threshold: ", StrongThreshold);
   Print("  - Weak Threshold: ", WeakThreshold);
   
   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up controller and all dashboard objects
   if(dashboard_controller != NULL)
   {
      dashboard_controller.Cleanup();
      delete dashboard_controller;
      dashboard_controller = NULL;
   }
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
   if(!initialized || dashboard_controller == NULL)
      return rates_total;

   // Let the MVC controller handle all calculations and rendering
   dashboard_controller.Update();

   return rates_total;
}
//+------------------------------------------------------------------+
