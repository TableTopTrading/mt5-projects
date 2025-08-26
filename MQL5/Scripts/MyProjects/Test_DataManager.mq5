//+------------------------------------------------------------------+
//|                                                Test_DataManager.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Includes
#include <MyProjects/SuperSlopeDashboard/CDataManager.mqh>

//--- Script parameters
input string   TestSymbol = "EURUSD";  // Symbol to test
input int      TestMAPeriod = 20;      // MA Period for testing
input int      TestATRPeriod = 14;     // ATR Period for testing
input int      TestMaxBars = 500;      // Max bars for testing

//--- Global variables
CDataManager* g_dataManager = NULL;

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart()
{
   // Create data manager instance
   g_dataManager = new CDataManager();
   if(g_dataManager == NULL)
   {
      Alert("Failed to create CDataManager instance");
      return;
   }
   
   // Initialize with test parameters
   if(!g_dataManager.Initialize(TestMAPeriod, TestATRPeriod, TestMaxBars))
   {
      Alert("Failed to initialize CDataManager");
      delete g_dataManager;
      return;
   }
   
   // Calculate strength value
   double strength = g_dataManager.CalculateStrengthValue(TestSymbol);
   
   // Print the result
   Print("Strength value for ", TestSymbol, ": ", DoubleToString(strength, 4));
   
   // Clean up
   delete g_dataManager;
}
