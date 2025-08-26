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

//--- Global renderer instance
CRenderer* g_renderer = NULL;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Test_Renderer.mq5 Starting ===");
   
   // Create and initialize renderer
   g_renderer = new CRenderer();
   if(g_renderer == NULL)
   {
      Print("ERROR: Failed to create CRenderer instance");
      return;
   }
   
   // Initialize renderer with test parameters
   if(!g_renderer.Initialize(StartX, StartY))
   {
      Print("ERROR: Failed to initialize CRenderer");
      delete g_renderer;
      g_renderer = NULL;
      return;
   }
   
   Print("✓ CRenderer created and initialized successfully");
   
   // Set custom colors for visual testing
   g_renderer.SetColors(clrLime, clrGreen, clrYellow, clrOrange, clrRed);
   g_renderer.SetDimensions(120, 25);  // Column width, Row height
   
   // Draw dashboard headers first
   g_renderer.DrawDashboardHeaders();
   Print("✓ Dashboard headers drawn");
   
   // Create test data arrays for each strength category
   CreateAndDisplayTestData();
   
   Print("=== Test_Renderer.mq5 Completed Successfully ===");
   Print("Visual Test: Check chart for dashboard with 5 columns and test symbols");
   Print("Expected: Headers (Strong Bull, Weak Bull, Neutral, Weak Bear, Strong Bear)");
   Print("Expected: Test symbols in appropriate columns with values");
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
   
   // Additional validation
   if(g_renderer.ObjectsExist())
   {
      int object_count = g_renderer.GetObjectCount();
      Print("✓ Dashboard objects created successfully. Total objects: ", object_count);
   }
   else
   {
      Print("⚠ WARNING: Dashboard objects not detected");
   }
}

//+------------------------------------------------------------------+
//| Script deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("=== Test_Renderer.mq5 Cleanup Starting ===");
   
   if(g_renderer != NULL)
   {
      // Clean up all dashboard objects
      g_renderer.DeleteAllObjects();
      Print("✓ Dashboard objects deleted");
      
      // Delete renderer instance
      delete g_renderer;
      g_renderer = NULL;
      Print("✓ CRenderer instance deleted");
   }
   
   // Force chart redraw
   ChartRedraw(0);
   
   Print("=== Test_Renderer.mq5 Cleanup Completed ===");
   
   // Log cleanup reason
   string reason_text = "";
   switch(reason)
   {
      case REASON_PROGRAM:     reason_text = "Script finished normally"; break;
      case REASON_REMOVE:      reason_text = "Script removed from chart"; break;
      case REASON_RECOMPILE:   reason_text = "Script recompiled"; break;
      case REASON_CHARTCHANGE: reason_text = "Chart period/symbol changed"; break;
      case REASON_CHARTCLOSE:  reason_text = "Chart closed"; break;
      default:                 reason_text = "Unknown reason: " + IntegerToString(reason); break;
   }
   Print("Cleanup reason: ", reason_text);
}
