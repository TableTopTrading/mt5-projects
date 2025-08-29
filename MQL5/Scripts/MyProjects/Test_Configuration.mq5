//+------------------------------------------------------------------+
//|                                                Test_Configuration.mq5 |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://ttt.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://ttt.com"
#property version   "1.00"
#property strict

#include <MyProjects\EquityCurve\CEquityCurveController.mqh>

CEquityCurveController controller;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== Testing Configuration File Support ===");
    
    // Initialize controller
    if(!controller.Initialize())
    {
        Print("Failed to initialize controller");
        return;
    }
    
    // Test 1: Save configuration
    Print("\n1. Testing SaveConfiguration...");
    if(TestSaveConfiguration())
    {
        Print("✓ SaveConfiguration test passed");
    }
    else
    {
        Print("✗ SaveConfiguration test failed");
    }
    
    // Test 2: Load configuration
    Print("\n2. Testing LoadConfiguration...");
    if(TestLoadConfiguration())
    {
        Print("✓ LoadConfiguration test passed");
    }
    else
    {
        Print("✗ LoadConfiguration test failed");
    }
    
    // Test 3: Reload configuration
    Print("\n3. Testing ReloadConfiguration...");
    if(TestReloadConfiguration())
    {
        Print("✓ ReloadConfiguration test passed");
    }
    else
    {
        Print("✗ ReloadConfiguration test failed");
    }
    
    // Test 4: Test with different values
    Print("\n4. Testing with different values...");
    if(TestDifferentValues())
    {
        Print("✓ Different values test passed");
    }
    else
    {
        Print("✗ Different values test failed");
    }
    
    Print("\n=== Configuration Tests Completed ===");
}

//+------------------------------------------------------------------+
//| Test saving configuration                                        |
//+------------------------------------------------------------------+
bool TestSaveConfiguration()
{
    string test_symbol_list = "EURUSD,GBPUSD,USDJPY,AUDUSD";
    double test_strong_threshold = 0.75;
    double test_weak_threshold = 0.25;
    double test_position_size = 0.15;
    int test_update_frequency = 30;
    
    bool result = controller.SaveConfiguration(test_symbol_list, test_strong_threshold,
                                              test_weak_threshold, test_position_size,
                                              test_update_frequency);
    
    if(result)
    {
        Print("Configuration saved successfully with values:");
        Print("  SymbolList: " + test_symbol_list);
        Print("  StrongThreshold: " + DoubleToString(test_strong_threshold, 2));
        Print("  WeakThreshold: " + DoubleToString(test_weak_threshold, 2));
        Print("  PositionSize: " + DoubleToString(test_position_size, 2));
        Print("  UpdateFrequency: " + IntegerToString(test_update_frequency));
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Test loading configuration                                       |
//+------------------------------------------------------------------+
bool TestLoadConfiguration()
{
    string loaded_symbol_list;
    double loaded_strong_threshold;
    double loaded_weak_threshold;
    double loaded_position_size;
    int loaded_update_frequency;
    
    bool result = controller.LoadConfiguration(loaded_symbol_list, loaded_strong_threshold,
                                              loaded_weak_threshold, loaded_position_size,
                                              loaded_update_frequency);
    
    if(result)
    {
        Print("Configuration loaded successfully:");
        Print("  SymbolList: " + loaded_symbol_list);
        Print("  StrongThreshold: " + DoubleToString(loaded_strong_threshold, 2));
        Print("  WeakThreshold: " + DoubleToString(loaded_weak_threshold, 2));
        Print("  PositionSize: " + DoubleToString(loaded_position_size, 2));
        Print("  UpdateFrequency: " + IntegerToString(loaded_update_frequency));
        
        // Verify loaded values match expected values
        if(loaded_symbol_list == "EURUSD,GBPUSD,USDJPY,AUDUSD" &&
           loaded_strong_threshold == 0.75 &&
           loaded_weak_threshold == 0.25 &&
           loaded_position_size == 0.15 &&
           loaded_update_frequency == 30)
        {
            return true;
        }
        else
        {
            Print("ERROR: Loaded values don't match expected values");
            return false;
        }
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Test reloading configuration                                     |
//+------------------------------------------------------------------+
bool TestReloadConfiguration()
{
    string reloaded_symbol_list;
    double reloaded_strong_threshold;
    double reloaded_weak_threshold;
    double reloaded_position_size;
    int reloaded_update_frequency;
    
    bool result = controller.ReloadConfiguration(reloaded_symbol_list, reloaded_strong_threshold,
                                                reloaded_weak_threshold, reloaded_position_size,
                                                reloaded_update_frequency);
    
    if(result)
    {
        Print("Configuration reloaded successfully:");
        Print("  SymbolList: " + reloaded_symbol_list);
        Print("  StrongThreshold: " + DoubleToString(reloaded_strong_threshold, 2));
        Print("  WeakThreshold: " + DoubleToString(reloaded_weak_threshold, 2));
        Print("  PositionSize: " + DoubleToString(reloaded_position_size, 2));
        Print("  UpdateFrequency: " + IntegerToString(reloaded_update_frequency));
        
        return true;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Test with different values                                       |
//+------------------------------------------------------------------+
bool TestDifferentValues()
{
    string test_symbol_list = "XAUUSD,XAGUSD,BTCUSD";
    double test_strong_threshold = 0.8;
    double test_weak_threshold = 0.2;
    double test_position_size = 0.05;
    int test_update_frequency = 120;
    
    // Save different values
    if(!controller.SaveConfiguration(test_symbol_list, test_strong_threshold,
                                   test_weak_threshold, test_position_size,
                                   test_update_frequency))
    {
        Print("ERROR: Failed to save different values");
        return false;
    }
    
    // Load and verify
    string loaded_symbol_list;
    double loaded_strong_threshold;
    double loaded_weak_threshold;
    double loaded_position_size;
    int loaded_update_frequency;
    
    if(!controller.LoadConfiguration(loaded_symbol_list, loaded_strong_threshold,
                                   loaded_weak_threshold, loaded_position_size,
                                   loaded_update_frequency))
    {
        Print("ERROR: Failed to load different values");
        return false;
    }
    
    // Verify values match
    if(loaded_symbol_list == test_symbol_list &&
       loaded_strong_threshold == test_strong_threshold &&
       loaded_weak_threshold == test_weak_threshold &&
       loaded_position_size == test_position_size &&
       loaded_update_frequency == test_update_frequency)
    {
        Print("Different values test passed - all values match");
        return true;
    }
    else
    {
        Print("ERROR: Different values don't match");
        Print("Expected: " + test_symbol_list + ", " + 
              DoubleToString(test_strong_threshold, 2) + ", " +
              DoubleToString(test_weak_threshold, 2) + ", " +
              DoubleToString(test_position_size, 2) + ", " +
              IntegerToString(test_update_frequency));
        Print("Got: " + loaded_symbol_list + ", " + 
              DoubleToString(loaded_strong_threshold, 2) + ", " +
              DoubleToString(loaded_weak_threshold, 2) + ", " +
              DoubleToString(loaded_position_size, 2) + ", " +
              IntegerToString(loaded_update_frequency));
        return false;
    }
}
//+------------------------------------------------------------------+
