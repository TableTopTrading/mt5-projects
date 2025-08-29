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
input int ReloadConfigKey = 115; // F4 key for manual configuration reload (Sprint 2.7)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    string config_symbol_list;
    double config_strong_threshold;
    double config_weak_threshold;
    double config_position_size;
    int config_update_frequency;
    
    // Initialize controller (handles account validation, directories, logging)
    if(!controller.Initialize())
    {
        Print("Failed to initialize EquityCurveController");
        return INIT_FAILED;
    }
    
    // Load configuration from file (Sprint 2.6)
    if(!controller.LoadConfiguration(config_symbol_list, config_strong_threshold, 
                                   config_weak_threshold, config_position_size, 
                                   config_update_frequency))
    {
        Print("Failed to load configuration from file, using input parameters as fallback");
        // Use input parameters as fallback
        config_symbol_list = SymbolList;
        config_strong_threshold = StrongThreshold;
        config_weak_threshold = WeakThreshold;
        config_position_size = PositionSize;
        config_update_frequency = UpdateFrequency;
    }
    
    // Validate loaded/input parameters
    if(!ValidateInputParameters(config_symbol_list, config_strong_threshold, 
                              config_weak_threshold, config_position_size, 
                              config_update_frequency))
    {
        Print("Input parameter validation failed");
        return INIT_FAILED;
    }
    
    // Initialize data manager with default parameters
    if(!data_manager.Initialize(7, 50, 500))
    {
        Print("Failed to initialize Data Manager");
        return INIT_FAILED;
    }
    
    // Log initialization parameters with actual values
    controller.LogInitializationParameters(config_symbol_list, config_strong_threshold, 
                                         config_weak_threshold, config_position_size, 
                                         config_update_frequency);
    
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
        // Check for configuration file modifications (Sprint 2.7)
        if(controller.CheckConfigFileModified())
        {
            Print("Configuration file modified detected - reload required");
            // TODO: Implement automatic reload logic in future sprint
        }
        
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
//| Chart event handler for manual configuration reload              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    // Handle key press events for manual configuration reload
    if(id == CHARTEVENT_KEYDOWN)
    {
        if(lparam == ReloadConfigKey)
        {
            Print("Manual configuration reload triggered by hotkey (F4)");
            ForceReloadConfiguration();
        }
    }
}

//+------------------------------------------------------------------+
//| Force reload configuration from file                             |
//+------------------------------------------------------------------+
void ForceReloadConfiguration()
{
    string config_symbol_list;
    double config_strong_threshold;
    double config_weak_threshold;
    double config_position_size;
    int config_update_frequency;
    
    // Store current values for potential rollback
    string current_symbol_list = SymbolList;
    double current_strong_threshold = StrongThreshold;
    double current_weak_threshold = WeakThreshold;
    double current_position_size = PositionSize;
    int current_update_frequency = UpdateFrequency;
    
    Print("Manual configuration reload initiated...");
    
    // Reload configuration from file
    if(controller.ReloadConfiguration(config_symbol_list, config_strong_threshold,
                                     config_weak_threshold, config_position_size,
                                     config_update_frequency))
    {
        // Validate the reloaded parameters
        if(ValidateConfigurationChanges(current_symbol_list, current_strong_threshold, current_weak_threshold,
                                      current_position_size, current_update_frequency,
                                      config_symbol_list, config_strong_threshold, config_weak_threshold,
                                      config_position_size, config_update_frequency))
        {
            Print("Configuration reloaded and validated successfully:");
            Print("SymbolList: " + config_symbol_list);
            Print("StrongThreshold: " + DoubleToString(config_strong_threshold, 2));
            Print("WeakThreshold: " + DoubleToString(config_weak_threshold, 2));
            Print("PositionSize: " + DoubleToString(config_position_size, 2));
            Print("UpdateFrequency: " + IntegerToString(config_update_frequency));
            
            // TODO: Apply the new configuration to the running EA
            // This will be implemented in future sprints when signal processing is active
        }
        else
        {
            Print("ERROR: Reloaded configuration failed validation - configuration not applied");
            // Note: Input parameters cannot be modified at runtime in MQL5.
            // The reloaded configuration will not be applied to the running EA.
            // Users must restart the EA to apply configuration changes from file.
        }
    }
    else
    {
        Print("ERROR: Failed to reload configuration from file");
    }
}

//+------------------------------------------------------------------+
//| Validate configuration changes and compare with current values   |
//+------------------------------------------------------------------+
bool ValidateConfigurationChanges(string current_symbol_list, double current_strong_threshold,
                                 double current_weak_threshold, double current_position_size,
                                 int current_update_frequency,
                                 string new_symbol_list, double new_strong_threshold,
                                 double new_weak_threshold, double new_position_size,
                                 int new_update_frequency)
{
    // First validate the new parameters using the existing validation
    if(!ValidateInputParameters(new_symbol_list, new_strong_threshold, new_weak_threshold,
                              new_position_size, new_update_frequency))
    {
        Print("ERROR: New configuration parameters failed basic validation");
        return false;
    }
    
    // Compare with current values and log changes
    bool changes_detected = false;
    
    if(new_symbol_list != current_symbol_list)
    {
        Print("SymbolList changed: " + current_symbol_list + " -> " + new_symbol_list);
        changes_detected = true;
    }
    
    if(new_strong_threshold != current_strong_threshold)
    {
        Print("StrongThreshold changed: " + DoubleToString(current_strong_threshold, 2) + 
              " -> " + DoubleToString(new_strong_threshold, 2));
        changes_detected = true;
    }
    
    if(new_weak_threshold != current_weak_threshold)
    {
        Print("WeakThreshold changed: " + DoubleToString(current_weak_threshold, 2) + 
              " -> " + DoubleToString(new_weak_threshold, 2));
        changes_detected = true;
    }
    
    if(new_position_size != current_position_size)
    {
        Print("PositionSize changed: " + DoubleToString(current_position_size, 2) + 
              " -> " + DoubleToString(new_position_size, 2));
        changes_detected = true;
    }
    
    if(new_update_frequency != current_update_frequency)
    {
        Print("UpdateFrequency changed: " + IntegerToString(current_update_frequency) + 
              " -> " + IntegerToString(new_update_frequency));
        changes_detected = true;
    }
    
    if(!changes_detected)
    {
        Print("Configuration reloaded but no changes detected - values identical to current configuration");
    }
    
    return true;
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
bool ValidateInputParameters(string symbol_list, double strong_threshold, 
                            double weak_threshold, double position_size, 
                            int update_frequency)
{
    // Validate SymbolList format and existence
    if(StringLen(symbol_list) == 0)
    {
        Print("ERROR: SymbolList cannot be empty");
        return false;
    }
    
    string symbols[];
    int symbol_count = StringSplit(symbol_list, ',', symbols);
    
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
    if(strong_threshold < 0.0 || strong_threshold > 1.0)
    {
        Print("ERROR: StrongThreshold must be between 0.0 and 1.0, got: " + DoubleToString(strong_threshold, 2));
        return false;
    }
    
    // Validate WeakThreshold range (0.0-1.0)
    if(weak_threshold < 0.0 || weak_threshold > 1.0)
    {
        Print("ERROR: WeakThreshold must be between 0.0 and 1.0, got: " + DoubleToString(weak_threshold, 2));
        return false;
    }
    
    // Validate threshold logic (StrongThreshold should be greater than WeakThreshold)
    if(strong_threshold <= weak_threshold)
    {
        Print("ERROR: StrongThreshold (" + DoubleToString(strong_threshold, 2) + 
              ") must be greater than WeakThreshold (" + DoubleToString(weak_threshold, 2) + ")");
        return false;
    }
    
    // Validate PositionSize (must be positive)
    if(position_size <= 0.0)
    {
        Print("ERROR: PositionSize must be positive, got: " + DoubleToString(position_size, 2));
        return false;
    }
    
    // Validate UpdateFrequency (minimum reasonable value)
    if(update_frequency < 1)
    {
        Print("ERROR: UpdateFrequency must be at least 1 second, got: " + IntegerToString(update_frequency));
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
