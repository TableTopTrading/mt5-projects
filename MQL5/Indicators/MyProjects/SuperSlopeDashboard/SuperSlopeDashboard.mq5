//+------------------------------------------------------------------+
//|                                          SuperSlopeDashboard.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0  // No indicator plots needed for dashboard
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
   if(!dashboard_controller.Initialize(SlopeMAPeriod, SlopeATRPeriod, 20, 50))
   {
      Print("ERROR: Failed to initialize CDashboardController");
      delete dashboard_controller;
      dashboard_controller = NULL;
      return INIT_FAILED;
   }
   
   // Parse symbol list and create array for controller
   string symbol_array[];
   int symbol_count = StringSplit(SymbolList, ',', symbol_array);

   // Trim spaces from each symbol - CORRECTED
   for(int i = 0; i < symbol_count; i++)
   {
      // Correct trimming: functions modify the string in-place
      StringTrimRight(symbol_array[i]);
      StringTrimLeft(symbol_array[i]);
   }

   if(symbol_count == 0)
   {
      Print("ERROR: No symbols provided in SymbolList");
      delete dashboard_controller;
      dashboard_controller = NULL;
      return INIT_PARAMETERS_INCORRECT;
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

   dashboard_controller.Update();

   return rates_total;
}
//+------------------------------------------------------------------+