//+------------------------------------------------------------------+
//|                                 EquityCurveSignalEA.mq5          |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://ttt.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://ttt.com"
#property version   "1.00"
#property strict

// Standard MT5 includes
#include <Trade/Trade.mqh>
#include <Trade/AccountInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/PositionInfo.mqh>

// Remove placeholder functions that conflict with compilation
// These will be implemented in future sprints with proper components

// Custom project includes
#include <MyProjects\SuperSlopeDashboard\CDataManager.mqh>
#include <MyProjects\EquityCurve\CEquityCurveController.mqh>

// Forward declarations for future components
// Include Conventions: 
// - Use angle brackets `< >` for all project includes
// - Paths should be relative to MQL5/Includes directory
// - Example: `#include <MyProjects\ComponentName\FileName.mqh>`

//#include <MyProjects\EquityCurve\CSignalGenerator.mqh>
//#include <MyProjects\EquityCurve\CTradeManager.mqh>
//#include <MyProjects\EquityCurve\CPositionTracker.mqh>
//#include <MyProjects\EquityCurve\CEquityCurveWriter.mqh>

// Global objects
CDataManager data_manager;
CEquityCurveController controller;
//CTrade trade; // MT5 standard trade object (commented out for now)

// Configuration parameters
input string SymbolList = "EURUSD,GBPUSD,USDJPY";
input double StrongThreshold = 0.7;
input double WeakThreshold = 0.3;
input double PositionSize = 0.1;
input int UpdateFrequency = 60; // seconds

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Validate input parameters first
    if(!ValidateInputParameters())
    {
        Print("Input parameter validation failed");
        return INIT_FAILED;
    }
    
    // Initialize controller (handles account validation, directories, logging)
    if(!controller.Initialize())
    {
        Print("Failed to initialize EquityCurveController");
        return INIT_FAILED;
    }
    
    // Initialize data manager with default parameters
    if(!data_manager.Initialize(7, 50, 500))
    {
        Print("Failed to initialize Data Manager");
        return INIT_FAILED;
    }
    
    // Log initialization parameters with actual values
    controller.LogInitializationParameters(SymbolList, StrongThreshold, WeakThreshold, PositionSize, UpdateFrequency);
    
    Print("EquityCurveSignalEA initialized successfully");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Clean up resources
    controller.Cleanup();
    Print("EquityCurveSignalEA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    static datetime last_update = 0;
    
    // Update on frequency or new bar
    if(TimeCurrent() - last_update >= UpdateFrequency || IsNewBar())
    {
        ProcessSignals();
        last_update = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Process trading signals                                          |
//+------------------------------------------------------------------+
void ProcessSignals()
{
    // Signal processing will be implemented in future sprints
    // This is a placeholder that will be replaced with CSignalGenerator and CTradeManager
}

//+------------------------------------------------------------------+
//| Check if new bar has formed                                      |
//+------------------------------------------------------------------+
bool IsNewBar()
{
    static datetime last_bar_time = 0;
    datetime current_bar_time = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    if(current_bar_time != last_bar_time)
    {
        last_bar_time = current_bar_time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Validate input parameters                                        |
//+------------------------------------------------------------------+
bool ValidateInputParameters()
{
    // Validate SymbolList format and existence
    if(StringLen(SymbolList) == 0)
    {
        Print("ERROR: SymbolList cannot be empty");
        return false;
    }
    
    string symbols[];
    int symbol_count = StringSplit(SymbolList, ',', symbols);
    
    if(symbol_count == 0)
    {
        Print("ERROR: SymbolList must contain at least one valid symbol");
        return false;
    }
    
    for(int i = 0; i < symbol_count; i++)
    {
        string symbol = symbols[i];
        // Remove any whitespace around the symbol
        StringTrimLeft(symbol);
        StringTrimRight(symbol);
        
        if(StringLen(symbol) == 0)
        {
            Print("ERROR: Empty symbol found in SymbolList");
            return false;
        }
        
        // Check if symbol exists and is selectable
        if(!SymbolInfoInteger(symbol, SYMBOL_SELECT))
        {
            Print("ERROR: Symbol '" + symbol + "' is not available or selectable");
            return false;
        }
    }
    
    // Validate StrongThreshold range (0.0-1.0)
    if(StrongThreshold < 0.0 || StrongThreshold > 1.0)
    {
        Print("ERROR: StrongThreshold must be between 0.0 and 1.0, got: " + DoubleToString(StrongThreshold, 2));
        return false;
    }
    
    // Validate WeakThreshold range (0.0-1.0)
    if(WeakThreshold < 0.0 || WeakThreshold > 1.0)
    {
        Print("ERROR: WeakThreshold must be between 0.0 and 1.0, got: " + DoubleToString(WeakThreshold, 2));
        return false;
    }
    
    // Validate threshold logic (StrongThreshold should be greater than WeakThreshold)
    if(StrongThreshold <= WeakThreshold)
    {
        Print("ERROR: StrongThreshold (" + DoubleToString(StrongThreshold, 2) + 
              ") must be greater than WeakThreshold (" + DoubleToString(WeakThreshold, 2) + ")");
        return false;
    }
    
    // Validate PositionSize (must be positive)
    if(PositionSize <= 0.0)
    {
        Print("ERROR: PositionSize must be positive, got: " + DoubleToString(PositionSize, 2));
        return false;
    }
    
    // Validate UpdateFrequency (minimum reasonable value)
    if(UpdateFrequency < 1)
    {
        Print("ERROR: UpdateFrequency must be at least 1 second, got: " + IntegerToString(UpdateFrequency));
        return false;
    }
    
    Print("Input parameter validation passed successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Custom enumerations                                              |
//+------------------------------------------------------------------+
enum ENUM_TRADE_SIGNAL
{
    SIGNAL_BUY,
    SIGNAL_SELL,
    SIGNAL_CLOSE,
    SIGNAL_HOLD
};

//+------------------------------------------------------------------+
