//+------------------------------------------------------------------+
//|                                                Test_LiveReload.mq5 |
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
    Print("=== Testing Live Configuration Reload Scenarios (Sprint 2.7) ===");
    
    // Initialize controller
    if(!controller.Initialize())
    {
        Print("Failed to initialize controller");
        return;
    }
    
    // Test 1: Manual trigger simulation
    Print("\n1. Testing Manual Trigger Simulation...");
    if(TestManualTrigger())
    {
        Print("✓ Manual trigger test passed");
    }
    else
    {
        Print("✗ Manual trigger test failed");
    }
    
    // Test 2: Error handling for invalid configurations
    Print("\n2. Testing Error Handling for Invalid Configurations...");
    if(TestErrorHandling())
    {
        Print("✓ Error handling test passed");
    }
    else
    {
        Print("✗ Error handling test failed");
    }
    
    // Test 3: Concurrent reload prevention
    Print("\n3. Testing Concurrent Reload Prevention...");
    if(TestConcurrentReloadPrevention())
    {
        Print("✓ Concurrent reload prevention test passed");
    }
    else
    {
        Print("✗ Concurrent reload prevention test failed");
    }
    
    // Test 4: Configuration validation during reload
    Print("\n4. Testing Configuration Validation During Reload...");
    if(TestValidationDuringReload())
    {
        Print("✓ Configuration validation during reload test passed");
    }
    else
    {
        Print("✗ Configuration validation during reload test failed");
    }
    
    Print("\n=== Live Reload Tests Completed ===");
    Print("Note: For automatic file change detection testing,");
    Print("please manually modify the configuration file and run the EA");
}

//+------------------------------------------------------------------+
//| Test manual trigger simulation                                   |
//+------------------------------------------------------------------+
bool TestManualTrigger()
{
    Print("Simulating manual reload trigger via ForceReloadConfiguration...");
    
    string config_symbol_list;
    double config_strong_threshold;
    double config_weak_threshold;
    double config_position_size;
    int config_update_frequency;
    
    // Simulate manual reload
    bool result = controller.ReloadConfiguration(config_symbol_list, config_strong_threshold,
                                                config_weak_threshold, config_position_size,
                                                config_update_frequency);
    
    if(result)
    {
        Print("Manual reload simulation successful:");
        Print("  SymbolList: " + config_symbol_list);
        Print("  StrongThreshold: " + DoubleToString(config_strong_threshold, 2));
        Print("  WeakThreshold: " + DoubleToString(config_weak_threshold, 2));
        Print("  PositionSize: " + DoubleToString(config_position_size, 2));
        Print("  UpdateFrequency: " + IntegerToString(config_update_frequency));
        return true;
    }
    else
    {
        Print("ERROR: Manual reload simulation failed");
        return false;
    }
}

//+------------------------------------------------------------------+
//| Test error handling for invalid configurations                   |
//+------------------------------------------------------------------+
bool TestErrorHandling()
{
    Print("Testing error handling with invalid configuration values...");
    
    // Save invalid configuration
    string invalid_symbol_list = "INVALID_SYMBOL"; // This symbol doesn't exist
    double invalid_strong_threshold = 1.5; // Out of range
    double invalid_weak_threshold = 0.8; // Greater than strong threshold
    double invalid_position_size = -0.1; // Negative
    int invalid_update_frequency = 0; // Invalid
    
    bool save_result = controller.SaveConfiguration(invalid_symbol_list, invalid_strong_threshold,
                                                   invalid_weak_threshold, invalid_position_size,
                                                   invalid_update_frequency);
    
    if(!save_result)
    {
        Print("ERROR: Failed to save invalid configuration for testing");
        return false;
    }
    
    // Try to reload the invalid configuration
    string loaded_symbol_list;
    double loaded_strong_threshold;
    double loaded_weak_threshold;
    double loaded_position_size;
    int loaded_update_frequency;
    
    bool reload_result = controller.ReloadConfiguration(loaded_symbol_list, loaded_strong_threshold,
                                                       loaded_weak_threshold, loaded_position_size,
                                                       loaded_update_frequency);
    
    // The reload should succeed (file operations work), but validation should catch issues
    if(reload_result)
    {
        Print("Configuration reload completed (file operations successful)");
        Print("Loaded values (should be validated in EA):");
        Print("  SymbolList: " + loaded_symbol_list);
        Print("  StrongThreshold: " + DoubleToString(loaded_strong_threshold, 2));
        Print("  WeakThreshold: " + DoubleToString(loaded_weak_threshold, 2));
        Print("  PositionSize: " + DoubleToString(loaded_position_size, 2));
        Print("  UpdateFrequency: " + IntegerToString(loaded_update_frequency));
        
        // Now test validation function directly
        if(ValidateInputParameters(loaded_symbol_list, loaded_strong_threshold,
                                  loaded_weak_threshold, loaded_position_size,
                                  loaded_update_frequency))
        {
            Print("ERROR: Invalid configuration passed validation - this should not happen");
            return false;
        }
        else
        {
            Print("✓ Invalid configuration correctly failed validation");
            return true;
        }
    }
    else
    {
        Print("ERROR: Reload operation failed completely");
        return false;
    }
}

//+------------------------------------------------------------------+
//| Test concurrent reload prevention                                |
//+------------------------------------------------------------------+
bool TestConcurrentReloadPrevention()
{
    Print("Testing concurrent reload prevention mechanism...");
    
    // This test simulates what would happen in the EA with the global flag
    // Since we're in a script, we'll simulate the logic
    
    bool is_reloading = false;
    
    // First attempt - should proceed
    if(!is_reloading)
    {
        is_reloading = true;
        Print("First reload attempt: Starting reload operation");
        // Simulate reload delay
        Sleep(1000);
        is_reloading = false;
        Print("First reload attempt: Completed successfully");
    }
    else
    {
        Print("ERROR: First reload should not be blocked");
        return false;
    }
    
    // Second attempt while first is "in progress" - should be blocked
    bool second_attempt_blocked = false;
    if(is_reloading)
    {
        Print("Second reload attempt: Blocked (reload already in progress)");
        second_attempt_blocked = true;
    }
    else
    {
        Print("ERROR: Second reload should be blocked when first is in progress");
        return false;
    }
    
    if(second_attempt_blocked)
    {
        Print("✓ Concurrent reload prevention working correctly");
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Test configuration validation during reload                      |
//+------------------------------------------------------------------+
bool TestValidationDuringReload()
{
    Print("Testing configuration validation during reload process...");
    
    // Test various validation scenarios
    string test_cases[][5] = {
        {"EURUSD,GBPUSD", "0.7", "0.3", "0.1", "60"},  // Valid
        {"", "0.7", "0.3", "0.1", "60"},               // Empty symbol list
        {"EURUSD,GBPUSD", "1.5", "0.3", "0.1", "60"},  // Invalid strong threshold
        {"EURUSD,GBPUSD", "0.7", "0.8", "0.1", "60"},  // Weak > Strong
        {"EURUSD,GBPUSD", "0.7", "0.3", "-0.1", "60"}, // Negative position size
        {"EURUSD,GBPUSD", "0.7", "0.3", "0.1", "0"}    // Invalid update frequency
    };
    
    int passed = 0;
    int total = ArraySize(test_cases);
    
    for(int i = 0; i < total; i++)
    {
        string symbol_list = test_cases[i][0];
        double strong_threshold = (double)StringToDouble(test_cases[i][1]);
        double weak_threshold = (double)StringToDouble(test_cases[i][2]);
        double position_size = (double)StringToDouble(test_cases[i][3]);
        int update_frequency = (int)StringToInteger(test_cases[i][4]);
        
        bool isValid = ValidateInputParameters(symbol_list, strong_threshold,
                                              weak_threshold, position_size,
                                              update_frequency);
        
        // First case should be valid, others should be invalid
        if((i == 0 && isValid) || (i > 0 && !isValid))
        {
            passed++;
            Print("Test case " + IntegerToString(i+1) + ": ✓");
        }
        else
        {
            Print("Test case " + IntegerToString(i+1) + ": ✗");
        }
    }
    
    if(passed == total)
    {
        Print("✓ All validation test cases passed (" + IntegerToString(passed) + "/" + IntegerToString(total) + ")");
        return true;
    }
    else
    {
        Print("ERROR: Validation test cases failed (" + IntegerToString(passed) + "/" + IntegerToString(total) + ")");
        return false;
    }
}

//+------------------------------------------------------------------+
//| Validate input parameters (copied from EA for testing)           |
//+------------------------------------------------------------------+
bool ValidateInputParameters(string symbol_list, double strong_threshold, 
                            double weak_threshold, double position_size, 
                            int update_frequency)
{
    // Validate SymbolList format and existence
    if(StringLen(symbol_list) == 0)
    {
        return false;
    }
    
    string symbols[];
    int symbol_count = StringSplit(symbol_list, ',', symbols);
    
    if(symbol_count == 0)
    {
        return false;
    }
    
    for(int i = 0; i < symbol_count; i++)
    {
        string symbol = symbols[i];
        StringTrimLeft(symbol);
        StringTrimRight(symbol);
        
        if(StringLen(symbol) == 0)
        {
            return false;
        }
        
        // Note: In real EA, we check SymbolInfoInteger(symbol, SYMBOL_SELECT)
        // For testing purposes, we'll skip the actual symbol check
    }
    
    // Validate StrongThreshold range (0.0-1.0)
    if(strong_threshold < 0.0 || strong_threshold > 1.0)
    {
        return false;
    }
    
    // Validate WeakThreshold range (0.0-1.0)
    if(weak_threshold < 0.0 || weak_threshold > 1.0)
    {
        return false;
    }
    
    // Validate threshold logic (StrongThreshold should be greater than WeakThreshold)
    if(strong_threshold <= weak_threshold)
    {
        return false;
    }
    
    // Validate PositionSize (must be positive)
    if(position_size <= 0.0)
    {
        return false;
    }
    
    // Validate UpdateFrequency (minimum reasonable value)
    if(update_frequency < 1)
    {
        return false;
    }
    
    return true;
}
//+------------------------------------------------------------------+
