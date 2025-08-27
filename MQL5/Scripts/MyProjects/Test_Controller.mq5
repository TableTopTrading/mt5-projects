//+------------------------------------------------------------------+
//|                                              Test_Controller.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Include the CDashboardController
#include <MyProjects/SuperSlopeDashboard/CDashboardController.mqh>

//--- Input parameters
input int InpMAPeriod = 20;        // MA Period
input int InpATRPeriod = 14;       // ATR Period
input int InpDashboardX = 50;      // Dashboard X Position
input int InpDashboardY = 100;     // Dashboard Y Position
input int InpDisplayTime = 10;     // Display Time (seconds)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Testing CDashboardController Phase 3.2 ===");
   
   // Create controller instance
   CDashboardController controller;
   
   // Step 1: Initialize controller
   Print("Step 1: Initializing CDashboardController...");
   if(!controller.Initialize(InpMAPeriod, InpATRPeriod, InpDashboardX, InpDashboardY))
   {
      Print("ERROR: Failed to initialize CDashboardController");
      return;
   }
   Print("✓ Controller initialized successfully");
   
   // Step 2: Set up test symbols
   Print("Step 2: Setting up test symbols...");
   string test_symbols[] = {"EURUSD", "GBPUSD", "USDCHF", "USDJPY", "USDCAD", 
                           "AUDUSD", "NZDUSD", "EURJPY", "GBPJPY", "EURGBP"};
   
   if(!controller.SetSymbols(test_symbols))
   {
      Print("ERROR: Failed to set symbols");
      controller.Cleanup();
      return;
   }
   Print("✓ Symbols configured: ", controller.GetSymbolCount(), " symbols");
   
   // Step 3: Set custom thresholds for testing
   Print("Step 3: Setting strength thresholds...");
   if(!controller.SetThresholds(1.5, 0.75, -1.5))
   {
      Print("ERROR: Failed to set thresholds");
      controller.Cleanup();
      return;
   }
   Print("✓ Thresholds set: Strong Bull: 1.5, Weak Bull: 0.75, Weak Bear: -1.5");
   
   // Step 4: Test Update method (core functionality)
   Print("Step 4: Testing Update() method...");
   if(!controller.Update())
   {
      Print("ERROR: Update() method failed");
      controller.Cleanup();
      return;
   }
   Print("✓ Update() completed successfully");
   
   // Step 5: Display status information
   Print("Step 5: Controller status: ", controller.GetStatusInfo());
   
   // Step 6: Test individual symbol queries
   Print("Step 6: Testing symbol queries...");
   for(int i = 0; i < MathMin(ArraySize(test_symbols), 5); i++) // Test first 5 symbols
   {
      string symbol = test_symbols[i];
      double strength = controller.GetSymbolStrength(symbol);
      int category = controller.GetSymbolCategory(symbol);
      
      string category_name;
      switch(category)
      {
         case 0: category_name = "Strong Bull"; break;
         case 1: category_name = "Weak Bull"; break;
         case 2: category_name = "Neutral"; break;
         case 3: category_name = "Weak Bear"; break;
         case 4: category_name = "Strong Bear"; break;
         default: category_name = "Unknown"; break;
      }
      
      Print("  ", symbol, ": Strength = ", DoubleToString(strength, 3), 
            ", Category = ", category_name);
   }
   
   // Step 7: Display dashboard for specified time
   Print("Step 7: Displaying dashboard for ", InpDisplayTime, " seconds...");
   Print("✓ Dashboard should now be visible on the chart");
   
   // Wait for display time
   Sleep(InpDisplayTime * 1000);
   
   // Step 8: Test refresh functionality
   Print("Step 8: Testing Refresh() method...");
   if(!controller.Refresh())
   {
      Print("ERROR: Refresh() method failed");
   }
   else
   {
      Print("✓ Refresh() completed successfully");
   }
   
   // Wait a bit more to see refresh
   Sleep(2000);
   
   // Step 9: Clean up
   Print("Step 9: Cleaning up...");
   controller.Cleanup();
   Print("✓ Cleanup completed");
   
   Print("=== CDashboardController Phase 3.2 Test Completed Successfully ===");
   Print("Check the chart for the dashboard display during the test period.");
}
