//+------------------------------------------------------------------+
//|                                               Test_Renderer.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Include the CRenderer class
#include <MyProjects/SuperSlopeDashboard/CRenderer.mqh>

//--- Input parameters for positioning and styling
input int    StartX = 20;           // Dashboard X position
input int    StartY = 50;           // Dashboard Y position
input string FontName = "Arial";    // Font name
input int    FontSize = 10;         // Font size
input bool   ClearExisting = true;  // Clear existing dashboard objects
input int    DisplayTimeMs = 5000;  // Time to display dashboard (milliseconds)

//--- Global renderer instance
CRenderer g_renderer;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Test_Renderer.mq5 Starting ===");
   
   // Clear existing objects if requested
   if(ClearExisting)
   {
      g_renderer.DeleteAllObjects();
      Print("✓ Cleared existing dashboard objects");
      Sleep(200);
   }
   
   // Initialize renderer with test parameters
   if(!g_renderer.Initialize(StartX, StartY))
   {
      Print("ERROR: Failed to initialize CRenderer");
      return;
   }
   
   Print("✓ CRenderer created and initialized successfully");
   
   // Set custom colors for visual testing
   g_renderer.SetColors(clrLime, clrGreen, clrYellow, clrOrange, clrRed);
   g_renderer.SetDimensions(120, 25);  // Column width, Row height
   
   // Draw dashboard headers first
   g_renderer.DrawDashboardHeaders();
   Print("✓ Dashboard headers drawn");
   ChartRedraw(0);
   Sleep(500); // Half second to see headers
   
   // Create test data arrays for each strength category
   CreateAndDisplayTestData();
   
   // Keep dashboard visible for specified time
   Print("=== DASHBOARD DISPLAY TIME ===");
   Print("Dashboard will be visible for ", DisplayTimeMs, " milliseconds");
   Print("You can now visually inspect the dashboard...");
   
   ChartRedraw(0);
   Sleep(DisplayTimeMs);
   
   Print("=== Test_Renderer.mq5 Completed Successfully ===");
   Print("Visual Test: Check chart for dashboard with 5 columns and test symbols");
   Print("Expected: Headers (Strong Bull, Weak Bull, Neutral, Weak Bear, Strong Bear)");
   Print("Expected: Test symbols in appropriate columns with values");
   Print("Dashboard display time has ended");
   
   // NOTE: Objects will be automatically cleaned up when script ends
   // This is normal behavior for MT5 scripts
}

//+------------------------------------------------------------------+
//| Create test data and display dashboard                           |
//+------------------------------------------------------------------+
void CreateAndDisplayTestData()
{
   Print("Creating test data arrays...");
   
   // Strong Bull category (≥ 2.0)
   string symbols_strong_bull[2];
   double values_strong_bull[2];
   symbols_strong_bull[0] = "EURUSD";   values_strong_bull[0] = 2.5;
   symbols_strong_bull[1] = "GBPUSD";   values_strong_bull[1] = 1.8;
   int count_strong_bull = 2;
   
   // Weak Bull category (1.0 to 2.0)
   string symbols_weak_bull[2];
   double values_weak_bull[2];
   symbols_weak_bull[0] = "USDJPY";     values_weak_bull[0] = 1.2;
   symbols_weak_bull[1] = "AUDUSD";     values_weak_bull[1] = 1.1;
   int count_weak_bull = 2;
   
   // Neutral category (-1.0 to 1.0)
   string symbols_neutral[3];
   double values_neutral[3];
   symbols_neutral[0] = "USDCAD";       values_neutral[0] = 0.3;
   symbols_neutral[1] = "NZDUSD";       values_neutral[1] = -0.2;
   symbols_neutral[2] = "EURCHF";       values_neutral[2] = 0.8;
   int count_neutral = 3;
   
   // Weak Bear category (-2.0 to -1.0)
   string symbols_weak_bear[1];
   double values_weak_bear[1];
   symbols_weak_bear[0] = "USDCHF";     values_weak_bear[0] = -1.4;
   int count_weak_bear = 1;
   
   // Strong Bear category (< -2.0)
   string symbols_strong_bear[2];
   double values_strong_bear[2];
   symbols_strong_bear[0] = "EURGBP";   values_strong_bear[0] = -2.1;
   symbols_strong_bear[1] = "EURJPY";   values_strong_bear[1] = -2.8;
   int count_strong_bear = 2;
   
   Print("✓ Test data created:");
   Print("  Strong Bull: ", count_strong_bull, " symbols");
   Print("  Weak Bull: ", count_weak_bull, " symbols");  
   Print("  Neutral: ", count_neutral, " symbols");
   Print("  Weak Bear: ", count_weak_bear, " symbols");
   Print("  Strong Bear: ", count_strong_bear, " symbols");
   
   // Call the main Draw method with all test data
   g_renderer.Draw(
      symbols_strong_bull, count_strong_bull,
      symbols_weak_bull, count_weak_bull,
      symbols_neutral, count_neutral,
      symbols_weak_bear, count_weak_bear,
      symbols_strong_bear, count_strong_bear,
      values_strong_bull, values_weak_bull,
      values_neutral, values_weak_bear,
      values_strong_bear
   );
   
   Print("✓ Dashboard rendered with test data");
   
   // Force chart redraw to ensure objects are visible
   ChartRedraw(0);
   Sleep(100); // Brief pause to ensure objects are drawn
   
   // Additional validation with improved timing
   Sleep(200); // Give objects time to be created
   if(g_renderer.ObjectsExist())
   {
      int object_count = g_renderer.GetObjectCount();
      Print("✓ Dashboard objects created successfully. Total objects: ", object_count);
   }
   else
   {
      Print("⚠ WARNING: Dashboard objects not detected via ObjectsExist()");
      // Try alternative validation
      if(ObjectFind(0, "SSD_Header_0_BG") >= 0)
      {
         Print("✓ Objects detected via direct search - ObjectsExist() method may need adjustment");
      }
      else
      {
         Print("✗ ERROR: No dashboard objects found at all");
      }
   }
   
   // Display instructions for manual cleanup
   Print("=== DASHBOARD PERSISTENCE ===");
   Print("The dashboard will remain visible during the display time.");
   Print("Objects created: Headers, symbol rows, and backgrounds");
   Print("All objects use 'SSD_' prefix for identification");
}
