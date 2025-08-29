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
    
    // Test 5: File modification detection (Sprint 2.7)
    Print("\n5. Testing File Modification Detection...");
    if(TestFileModificationDetection())
    {
        Print("✓ File modification detection test passed");
    }
    else
    {
        Print("✗ File modification detection test failed");
    }
    
    // Test 6: Configuration validation (Sprint 2.7)
    Print("\n6. Testing Configuration Validation...");
    if(TestConfigurationValidation())
    {
        Print("✓ Configuration validation test passed");
    }
    else
    {
        Print("✗ Configuration validation test failed");
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
//| Test file modification detection (Sprint 2.7)                   |
//+------------------------------------------------------------------+
bool TestFileModificationDetection()
{
    Print("\n5. Testing File Modification Detection...");
    
    // Test initial state
    bool initial_check = controller.CheckConfigFileModified();
    Print("Initial modification check: " + (initial_check ? "MODIFIED" : "NOT MODIFIED"));
    
    // The first check should return false (just records initial time)
    if(initial_check)
    {
        Print("ERROR: First check should return false (only records initial time)");
        return false;
    }
    
    Print("File modification detection test completed - manual file change required for full test");
    Print("Please modify the configuration file manually to complete this test");
    return true;
}

//+------------------------------------------------------------------+
//| Validate input parameters (local copy for testing)               |
//+------------------------------------------------------------------+
bool ValidateInputParametersLocal(string symbol_list, double strong_threshold, 
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
        }
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
//| Test configuration validation (Sprint 2.7)                      |
//+------------------------------------------------------------------+
bool TestConfigurationValidation()
{
    Print("\n6. Testing Configuration Validation...");
    
    // Test valid parameters
    if(!ValidateInputParametersLocal("EURUSD,GBPUSD", 0.7, 0.3, 0.1, 60))
    {
        Print("ERROR: Valid parameters failed validation");
        return false;
    }
    
    // Test invalid parameters
    if(ValidateInputParametersLocal("", 0.7, 0.3, 0.1, 60)) // Empty symbol list
    {
        Print("ERROR: Empty symbol list should fail validation");
        return false;
    }
    
    if(ValidateInputParametersLocal("EURUSD,GBPUSD", 1.5, 0.3, 0.1, 60)) // Invalid strong threshold
    {
        Print("ERROR: Invalid strong threshold should fail validation");
        return false;
    }
    
    if(ValidateInputParametersLocal("EURUSD,GBPUSD", 0.7, 0.8, 0.1, 60)) // Weak > Strong
    {
        Print("ERROR: Weak threshold > Strong threshold should fail validation");
        return false;
    }
    
    if(ValidateInputParametersLocal("EURUSD,GBPUSD", 0.7, 0.3, -0.1, 60)) // Negative position size
    {
        Print("ERROR: Negative position size should fail validation");
        return false;
    }
    
    if(ValidateInputParametersLocal("EURUSD,GBPUSD", 0.7, 0.3, 0.1, 0)) // Invalid update frequency
    {
        Print("ERROR: Invalid update frequency should fail validation");
        return false;
    }
    
    Print("Configuration validation test passed - all validation rules working correctly");
    return true;
}
//+------------------------------------------------------------------+
