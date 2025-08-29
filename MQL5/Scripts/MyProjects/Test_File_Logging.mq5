//+------------------------------------------------------------------+
//|                                           Test_File_Logging.mq5 |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://www.tabletoptrading.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://www.tabletoptrading.com"
#property version   "1.00"
#property script_show_inputs

// Include the controller
#include <MyProjects\EquityCurve\CEquityCurveController.mqh> //updated to crrect path

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    // Create controller instance
    CEquityCurveController controller;
    
    // Initialize the controller
    if(!controller.Initialize())
    {
        Print("Failed to initialize controller");
        return;
    }
    
    // Test various log messages
    controller.LogInfo("This is an informational test message");
    controller.LogWarning("This is a warning test message");
    controller.LogError("This is an error test message");
    
    // Test log initialization parameters
    controller.LogInitializationParameters();
    
    // Test multiple messages to verify rotation would work
    for(int i = 1; i <= 10; i++)
    {
        controller.LogInfo("Test message #" + IntegerToString(i));
    }
    
    // Cleanup
    controller.Cleanup();
    
    Print("File logging test completed successfully. Check the EquityCurveSignals\\Logs\\ directory for log files.");
}
//+------------------------------------------------------------------+
