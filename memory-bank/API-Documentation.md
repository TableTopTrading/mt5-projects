# API Documentation - Equity Curve Trading Components

## Overview
This document provides API documentation for the core components that will be used by the Equity Curve Signal EA (Epic 3) and Live Trading EA (Epic 4).

## CDataManager Class

### Purpose
Handles data calculations and strength value processing using manual price data calculations.

### Key Methods

#### Initialize()
```mql5
bool Initialize(int ma_period, int atr_period, int max_bars = 0)
```
- **Parameters:**
  - `ma_period`: LWMA period for slope calculations
  - `atr_period`: ATR period for normalization
  - `max_bars`: Maximum bars to process (0 = all available)
- **Returns:** `true` if successful initialization

#### CalculateStrengthValue()
```mql5
double CalculateStrengthValue(string symbol, ENUM_TIMEFRAMES timeframe)
```
- **Parameters:**
  - `symbol`: Symbol name (e.g., "EURUSD")
  - `timeframe`: Timeframe for calculation
- **Returns:** Normalized strength value (double)

#### CalculateLWMA()
```mql5
double CalculateLWMA(const double &close_prices[], int period, int shift)
```
- **Parameters:**
  - `close_prices`: Array of close prices
  - `period`: LWMA period
  - `shift`: Bar index for calculation
- **Returns:** LWMA value at specified shift

#### CalculateATR()
```mql5
double CalculateATR(string symbol, ENUM_TIMEFRAMES timeframe, int period, int shift)
```
- **Parameters:**
  - `symbol`: Symbol name
  - `timeframe`: Timeframe for ATR calculation
  - `period`: ATR period
  - `shift`: Bar index for calculation
- **Returns:** ATR value at specified shift

### Usage Example
```mql5
#include <MyProjects/SuperSlopeDashboard/CDataManager.mqh>

CDataManager data_manager;
if(data_manager.Initialize(7, 50, 500)) {
    double strength = data_manager.CalculateStrengthValue("EURUSD", PERIOD_H1);
    // strength now contains normalized value for trading decisions
}
```

## CDashboardController Class

### Purpose
Orchestrates the MVC architecture between data calculations and visualization.

### Key Methods

#### Initialize()
```mql5
bool Initialize(int ma_period, int atr_period, 
                double strong_threshold, double weak_threshold,
                int max_bars = 500)
```
- **Parameters:** Calculation and threshold parameters
- **Returns:** `true` if successful

#### SetSymbols()
```mql5
void SetSymbols(const string &symbols[])
```
- **Parameters:** Array of symbols to monitor

#### Update()
```mql5
void Update()
```
- Main orchestration method that triggers calculations and rendering

#### GetSymbolStrength()
```mql5
double GetSymbolStrength(string symbol)
```
- **Parameters:** Symbol name
- **Returns:** Current strength value for the symbol

### Usage Example
```mql5
#include <MyProjects/SuperSlopeDashboard/CDashboardController_v2.mqh>

CDashboardController controller;
string symbols[] = {"EURUSD", "GBPUSD", "USDJPY"};

if(controller.Initialize(7, 50, 1.0, 0.5)) {
    controller.SetSymbols(symbols);
    controller.Update();
    
    double eur_strength = controller.GetSymbolStrength("EURUSD");
}
```

## CRenderer Class

### Purpose
Handles dashboard visualization (primarily for indicator use, but methods may be useful for EA debugging).

### Key Methods

#### Initialize()
```mql5
void Initialize(int start_x, int start_y)
```
- **Parameters:** Dashboard position coordinates

#### DrawDashboardHeaders()
```mql5
void DrawDashboardHeaders()
```
- Creates column headers for strength categories

## Integration Patterns for EA Development

### Pattern 1: Direct CDataManager Integration (Recommended)
```mql5
// In EquityCurveSignalEA.mq5
#include <MyProjects/SuperSlopeDashboard/CDataManager.mqh>

CDataManager data_manager;

int OnInit() {
    if(!data_manager.Initialize(SlopeMAPeriod, SlopeATRPeriod, MaxBars)) {
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}

void OnTick() {
    // Calculate strength for each symbol
    for(int i = 0; i < ArraySize(SymbolList); i++) {
        double strength = data_manager.CalculateStrengthValue(SymbolList[i], Timeframe);
        // Generate trading signals based on strength
    }
}
```

### Pattern 2: Full Controller Integration
```mql5
// Alternative approach using full controller
#include <MyProjects/SuperSlopeDashboard/CDashboardController_v2.mqh>

CDashboardController controller;

int OnInit() {
    string symbols[];
    StringSplit(SymbolList, ',', symbols);
    
    if(!controller.Initialize(SlopeMAPeriod, SlopeATRPeriod, 
                            StrongThreshold, WeakThreshold, MaxBars)) {
        return INIT_FAILED;
    }
    controller.SetSymbols(symbols);
    return INIT_SUCCEEDED;
}

void OnTick() {
    controller.Update();
    
    for(int i = 0; i < ArraySize(symbols); i++) {
        double strength = controller.GetSymbolStrength(symbols[i]);
        // Process trading signals
    }
}
```

## Data Types and Constants

### Strength Threshold Constants
```mql5
// Recommended threshold ranges based on testing
#define STRONG_BULL_THRESHOLD_MIN 0.8
#define STRONG_BULL_THRESHOLD_MAX 3.0
#define WEAK_BULL_THRESHOLD_MIN 0.3
#define WEAK_BULL_THRESHOLD_MAX 1.5

// Default values that match SuperSlope indicator
#define DEFAULT_STRONG_THRESHOLD 1.0
#define DEFAULT_WEAK_THRESHOLD 0.5
```

### Error Handling
```mql5
// Common error codes and handling
#define ERROR_DATA_MANAGER_NOT_INITIALIZED -1001
#define ERROR_INVALID_SYMBOL -1002
#define ERROR_INSUFFICIENT_DATA -1003

// Recommended error handling pattern
double GetStrengthWithValidation(string symbol) {
    if(!data_manager_initialized) {
        Print("Error: Data manager not initialized");
        return 0.0;
    }
    
    if(!SymbolInfoInteger(symbol, SYMBOL_SELECT)) {
        Print("Error: Symbol not available: ", symbol);
        return 0.0;
    }
    
    return data_manager.CalculateStrengthValue(symbol, Timeframe);
}
```

## Performance Considerations

### Calculation Optimization
- Use appropriate `MaxBars` value (500-1000 recommended for real-time)
- Consider caching strength values with timestamp validation
- Implement configurable update frequency to reduce CPU load

### Memory Management
- Ensure proper cleanup in `OnDeinit()`
- Use array resizing best practices
- Monitor object creation in chart space

## Version Compatibility
- All APIs compatible with MT5 build 3000+
- Maintain backward compatibility with existing indicator settings
- Use same parameter defaults as SuperSlopeDashboard for consistency

## Testing Recommendations
- Unit test strength calculations against known values
- Validate threshold logic with boundary testing
- Test error conditions (invalid symbols, insufficient data)
- Performance test with maximum symbol count
