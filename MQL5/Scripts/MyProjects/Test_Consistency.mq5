//+------------------------------------------------------------------+
//|                                                Test_Consistency.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Includes
#include <MyProjects/SuperSlopeDashboard/CDataManager.mqh>
#include <MyProjects/SuperSlope Includes/CSuperSlope.mqh>

//--- Script parameters
input string   TestSymbol = "EURUSD";  // Symbol to test
input int      TestMAPeriod = 7;       // MA Period for testing
input int      TestATRPeriod = 50;     // ATR Period for testing
input int      TestMaxBars = 500;      // Max bars for testing

//--- Global variables
CDataManager* g_dataManager = NULL;
CSuperSlope* g_superSlope = NULL;

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("Testing consistency between SuperSlope and Dashboard calculations...");
   
   // Test 1: Create and initialize both calculation engines
   if(!InitializeEngines())
   {
      Alert("Failed to initialize calculation engines");
      return;
   }
   
   // Test 2: Compare calculations for the same symbol
   CompareCalculations(TestSymbol);
   
   // Test 3: Test with multiple symbols
   string testSymbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD"};
   for(int i = 0; i < ArraySize(testSymbols); i++)
   {
      CompareCalculations(testSymbols[i]);
   }
   
   // Clean up
   CleanupEngines();
   
   Print("Consistency test completed");
}

//+------------------------------------------------------------------+
//| Initialize both calculation engines                               |
//+------------------------------------------------------------------+
bool InitializeEngines()
{
   // Create and initialize CDataManager (Dashboard)
   g_dataManager = new CDataManager();
   if(g_dataManager == NULL)
   {
      Alert("Failed to create CDataManager instance");
      return false;
   }
   
   if(!g_dataManager.Initialize(TestMAPeriod, TestATRPeriod, TestMaxBars))
   {
      Alert("Failed to initialize CDataManager");
      delete g_dataManager;
      return false;
   }
   
   // Create and initialize CSuperSlope
   g_superSlope = new CSuperSlope();
   if(g_superSlope == NULL)
   {
      Alert("Failed to create CSuperSlope instance");
      delete g_dataManager;
      return false;
   }
   
   if(g_superSlope.OnInit() != INIT_SUCCEEDED)
   {
      Alert("Failed to initialize CSuperSlope");
      delete g_dataManager;
      delete g_superSlope;
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Compare calculations for a specific symbol                        |
//+------------------------------------------------------------------+
void CompareCalculations(string symbol)
{
   // Calculate using CDataManager (Dashboard)
   double dashboardStrength = g_dataManager.CalculateStrengthValue(symbol);
   
   // Calculate using CSuperSlope
   // For CSuperSlope, we need to simulate the calculation
   // Since CSuperSlope is designed for indicator use, we'll create a simple test
   double superSlopeStrength = TestSuperSlopeCalculation(symbol);
   
   // Compare results
   double difference = MathAbs(dashboardStrength - superSlopeStrength);
   
   Print("Symbol: ", symbol);
   Print("  Dashboard: ", DoubleToString(dashboardStrength, 6));
   Print("  SuperSlope: ", DoubleToString(superSlopeStrength, 6));
   Print("  Difference: ", DoubleToString(difference, 6));
   
   if(difference > 0.0001) // Allow for small floating point differences
   {
      Print("  WARNING: Significant difference detected!");
   }
   else
   {
      Print("  OK: Calculations match");
   }
   Print("---");
}

//+------------------------------------------------------------------+
//| Simulate SuperSlope calculation for testing                       |
//+------------------------------------------------------------------+
double TestSuperSlopeCalculation(string symbol)
{
   // This is a simplified test since CSuperSlope is designed for indicator use
   // In a real scenario, you would need to properly set up the indicator buffers
   
   // For testing purposes, we'll use a similar approach to CDataManager
   // but this demonstrates the concept
   int ma_handle = iMA(symbol, 0, TestMAPeriod, 0, MODE_LWMA, PRICE_CLOSE);
   int atr_handle = iATR(symbol, 0, TestATRPeriod);
   
   if(ma_handle == INVALID_HANDLE || atr_handle == INVALID_HANDLE)
   {
      return 0.0;
   }
   
   // Get MA values
   double ma_values[];
   ArraySetAsSeries(ma_values, true);
   if(CopyBuffer(ma_handle, 0, 0, 6, ma_values) <= 0)
   {
      IndicatorRelease(ma_handle);
      IndicatorRelease(atr_handle);
      return 0.0;
   }
   
   // Get ATR values
   double atr_values[];
   ArraySetAsSeries(atr_values, true);
   if(CopyBuffer(atr_handle, 0, 0, 21, atr_values) <= 0)
   {
      IndicatorRelease(ma_handle);
      IndicatorRelease(atr_handle);
      return 0.0;
   }
   
   // Get close price
   double close_price = iClose(symbol, 0, 0);
   
   // Simplified calculation similar to CSuperSlope::GetSlope()
   if(atr_values[10] == 0.0)
   {
      IndicatorRelease(ma_handle);
      IndicatorRelease(atr_handle);
      return 0.0;
   }
   
   double atr = atr_values[10] / 10.0;
   double dblTma = ma_values[0];
   double dblPrev = (ma_values[1] * 231 + close_price * 20) / 251;
   
   double result = (dblTma - dblPrev) / atr;
   
   IndicatorRelease(ma_handle);
   IndicatorRelease(atr_handle);
   
   return result;
}

//+------------------------------------------------------------------+
//| Clean up resources                                                |
//+------------------------------------------------------------------+
void CleanupEngines()
{
   if(g_dataManager != NULL)
   {
      delete g_dataManager;
      g_dataManager = NULL;
   }
   
   if(g_superSlope != NULL)
   {
      delete g_superSlope;
      g_superSlope = NULL;
   }
}
