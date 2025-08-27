//+------------------------------------------------------------------+
//|                                        Test_Compilation.mq5     |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Test basic compilation of CDashboardController
#include <MyProjects/SuperSlopeDashboard/CDashboardController_v2.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Testing CDashboardController_v2 Compilation ===");
   
   // Test instantiation
   CDashboardController controller;
   
   Print("✓ CDashboardController instantiated successfully");
   Print("✓ Compilation test completed - no errors");
}
