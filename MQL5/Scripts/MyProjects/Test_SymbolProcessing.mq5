//+------------------------------------------------------------------+
//|                                            Test_SymbolProcessing.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Includes
#include <MyProjects/SuperSlopeDashboard/CDashboardController_v2.mqh>

//--- Script parameters
input string   TestSymbolList = "EURUSD,GBPUSD,USDJPY";  // Symbols to test

//--- Global variables
CDashboardController* g_controller = NULL;

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("Testing symbol processing...");
   
   // Create controller instance
   g_controller = new CDashboardController();
   if(g_controller == NULL)
   {
      Alert("Failed to create CDashboardController instance");
      return;
   }
   
   // Initialize controller
   if(!g_controller.Initialize(7, 50, 500))
   {
      Alert("Failed to initialize CDashboardController");
      delete g_controller;
      return;
   }
   
   // Parse symbol list
   string symbol_array[];
   int symbol_count = StringSplit(TestSymbolList, ',', symbol_array);
   
   // Trim spaces from each symbol
   for(int i = 0; i < symbol_count; i++)
   {
      StringTrimRight(symbol_array[i]);
      StringTrimLeft(symbol_array[i]);
   }
   
   Print("Parsed symbols: ", symbol_count);
   for(int i = 0; i < symbol_count; i++)
   {
      Print("  Symbol ", i, ": '", symbol_array[i], "'");
   }
   
   // Set symbols in controller
   if(!g_controller.SetSymbols(symbol_array))
   {
      Alert("Failed to set symbols in controller");
      delete g_controller;
      return;
   }
   
   // Test calculation for each symbol
   Print("Testing calculations for each symbol...");
   if(!g_controller.Update())
   {
      Alert("Failed to update calculations");
   }
   
   // Clean up
   delete g_controller;
   
   Print("Symbol processing test completed");
}
