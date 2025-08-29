//+------------------------------------------------------------------+
//|                                             Test_Error_Handling.mq5 |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://www.tabletoptrading.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://www.tabletoptrading.com"
#property version   "1.00"
#property script_show_inputs

// Include the controller
#include <MyProjects/EquityCurve/CEquityCurveController.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== Testing Error Handling Implementation ===");
    
    // Test 1: Create controller and initialize
    CEquityCurveController controller;
    Print("Test 1: Controller created");
    
    // Test 2: Test parameter validation
    Print("Test 2: Testing parameter validation...");
    controller.LogInfo(""); // Should show warning about empty message
    controller.LogWarning(""); // Should show warning about empty message
    controller.LogError(""); // Should show warning about empty message
    
    // Test 3: Test initialization
    Print("Test 3: Testing initialization...");
    if(controller.Initialize())
    {
        Print("✓ Controller initialized successfully");
        
        // Test 4: Test logging with various error scenarios
        Print("Test 4: Testing logging functionality...");
        controller.LogInfo("This is an informational message");
        controller.LogWarning("This is a warning message");
        controller.LogError("This is an error message");
        
        // Test 5: Test directory creation with invalid path
        Print("Test 5: Testing invalid directory creation...");
        if(!controller.CreateDirectoryWithCheck("")) // Empty path should fail
        {
            Print("✓ Empty path validation working correctly");
        }
        
        // Test 6: Test error description function
        Print("Test 6: Testing error description function...");
        Print("Error 0: " + GetErrorDescription(0));
        Print("Error 4103: " + GetErrorDescription(4103)); // Cannot open file
        Print("Error 9999: " + GetErrorDescription(9999)); // Unknown error
        
        Print("=== Error Handling Tests Completed Successfully ===");
    }
    else
    {
        Print("✗ Controller initialization failed");
    }
    
    // Cleanup
    controller.Cleanup();
    Print("=== Test Script Finished ===");
}
//+------------------------------------------------------------------+
