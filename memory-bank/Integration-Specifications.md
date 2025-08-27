# Integration Specifications - Equity Curve Trading System

## Overview
This document specifies how the Equity Curve Signal EA (Epic 3) and Live Trading EA (Epic 4) will integrate with the existing SuperSlopeDashboard components and external systems.

## Integration Architecture

### System Components Integration
```
[SuperSlopeDashboard Components] ←→ [EquityCurveSignalEA.mq5] → [CSV Output File] ←→ [LiveTradingEA.mq5]
      ↑                               ↑                           ↑                     ↑
CDataManager.mqh               CDataManager.mqh           CEquityCurveWriter      CEquityCurveReader
CDashboardController_v2.mqh    CSignalGenerator.mqh                               CEquityCurveAnalyzer
                               CTradeManager.mqh                                  CBasketManager.mqh
                               CPositionTracker.mqh                               CRiskManager.mqh
```

## Epic 3: Equity Curve Signal EA Integration

### Component Integration Pattern

#### Preferred Approach: Direct CDataManager Integration
```mql5
// EquityCurveSignalEA.mq5 structure
#include <MyProjects/SuperSlopeDashboard/CDataManager.mqh>
#include "CSignalGenerator.mqh"
#include "CTradeManager.mqh"
#include "CPositionTracker.mqh"
#include "CEquityCurveWriter.mqh"

CDataManager data_manager;
CSignalGenerator signal_generator;
CTradeManager trade_manager;
CPositionTracker position_tracker;
CEquityCurveWriter equity_writer;
```

### Data Flow Specification

#### Strength Calculation Integration
1. **Input**: Symbol list, timeframe, MA/ATR parameters from EA inputs
2. **Processing**: CDataManager.CalculateStrengthValue() for each symbol
3. **Output**: Normalized strength values for signal generation

```mql5
// Example data flow implementation
void CalculateAllStrengths() {
    string symbols[];
    StringSplit(SymbolList, ',', symbols);
    
    for(int i = 0; i < ArraySize(symbols); i++) {
        double strength = data_manager.CalculateStrengthValue(symbols[i], Timeframe);
        signal_generator.ProcessStrength(symbols[i], strength);
    }
}
```

### Signal Generation Rules Integration

#### Strength Category Mapping
```mql5
// Must match SuperSlopeDashboard categorization
ENUM_STRENGTH_CATEGORY CategorizeStrength(double strength) {
    if(strength >= StrongThreshold) return STRONG_BULL;
    if(strength >= WeakThreshold) return WEAK_BULL;
    if(strength <= -StrongThreshold) return STRONG_BEAR;
    if(strength <= -WeakThreshold) return WEAK_BEAR;
    return NEUTRAL;
}
```

#### Trading Logic Integration
```mql5
// Trading rules based on user stories
void GenerateTradingSignals() {
    for each symbol in monitored symbols:
        category = CategorizeStrength(current_strength)
        
        if category == STRONG_BULL and no existing long position:
            OpenBuyPosition(symbol)
        else if category == STRONG_BEAR and no existing short position:
            OpenSellPosition(symbol)
        else if category == NEUTRAL and has position:
            ClosePosition(symbol)
}
```

### File Output Integration

#### CSV File Format Specification
```mql5
// File: EquityCurve_[AccountNumber]_[Timestamp].csv
// Header format must be consistent for Live EA consumption
#Version: 1.0
#EA: EquityCurveSignalEA
#Symbols: EURUSD,GBPUSD,USDJPY
#Timeframe: H1
#StrongThreshold: 1.0
#WeakThreshold: 0.5
#StartDate: 2025-01-01 00:00:00
#
Timestamp,Balance,Equity,DrawdownPercent,SignalStrength,OpenPositions,Symbol,Action,EntryPrice,CurrentPrice
```

#### File Writing Protocol
- **Update Frequency**: Configurable (default: 60 seconds)
- **File Locking**: Use FileOpen() with FILE_SHARE_READ | FILE_SHARE_WRITE
- **Backup Strategy**: Daily file rotation with timestamp
- **Error Handling**: Retry logic with exponential backoff

## Epic 4: Live Trading EA Integration

### File Reading Integration

#### CSV File Parsing Specification
```mql5
class CEquityCurveReader {
private:
    string m_filename;
    datetime m_last_read_time;
    
public:
    bool Initialize(string filename);
    bool ReadLatestData(EquityData &data);
    bool ValidateFileFormat();
    datetime GetDataFreshness();
};

struct EquityData {
    datetime timestamp;
    double balance;
    double equity;
    double drawdown_percent;
    double signal_strength;
    int open_positions;
    string symbol;
    string action;
    double entry_price;
    double current_price;
};
```

### Signal Analysis Integration

#### Equity Curve Analysis Methods
```mql5
class CEquityCurveAnalyzer {
public:
    // Signal generation methods from user stories
    bool IsMACrossSignal(const EquityData &data, int period = 20);
    bool IsMomentumSignal(const EquityData &data, double slope_threshold = 0.001);
    bool IsDrawdownRecoverySignal(const EquityData &data, double recovery_threshold = 0.5);
    bool IsStrengthConfirmationSignal(const EquityData &data, double min_strength = 0.7);
};
```

### Basket Trading Integration

#### Correlation-Based Position Sizing
```mql5
class CBasketManager {
private:
    string m_symbols[];
    double m_correlations[][];
    
public:
    bool Initialize(const string &symbols[]);
    double CalculateCorrelation(string symbol1, string symbol2, int period = 100);
    double CalculatePositionSize(string symbol, double risk_percentage, 
                                const double &correlation_factors[]);
    void RebalancePortfolio();
};
```

### Risk Management Integration

#### Multi-Level Risk Controls
```mql5
class CRiskManager {
public:
    // Individual position risk
    bool CheckIndividualSL(string symbol, double entry_price, double current_price);
    bool CheckIndividualTP(string symbol, double entry_price, double current_price);
    
    // Basket-level risk
    bool CheckBasketSL(double total_equity, double initial_equity);
    bool CheckBasketTP(double total_equity, double initial_equity);
    bool CheckMaxDrawdown(double current_drawdown);
    
    // Emergency procedures
    void EmergencyCloseAll();
};
```

## Cross-EA Communication

### File-Based Communication Protocol

#### Signal EA → Live EA Communication
```mql5
// EquityCurveSignalEA writes:
void WriteSignalUpdate() {
    string filename = "EquityCurve_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ".csv";
    // Append latest data with timestamp
}

// LiveTradingEA reads:
void ReadSignalUpdate() {
    // Read latest line, validate timestamp freshness
    // Process only if data is recent (configurable threshold)
}
```

### Configuration Synchronization

#### Parameter Consistency Requirements
```mql5
// Critical parameters that must match between systems:
#define REQUIRED_CONSISTENT_PARAMS {
    "SlopeMAPeriod",
    "SlopeATRPeriod", 
    "StrongThreshold",
    "WeakThreshold",
    "SymbolList",
    "Timeframe"
}
```

## Error Handling and Recovery

### Integration Error Scenarios

#### File Access Conflicts
- **Scenario**: Both EAs trying to access same file simultaneously
- **Solution**: Implement file locking with timeout and retry logic

#### Data Freshness Issues
- **Scenario**: Live EA reading stale equity curve data
- **Solution**: Configurable maximum data age threshold

#### Parameter Mismatch
- **Scenario**: Inconsistent calculation parameters between systems
- **Solution**: Configuration validation on EA initialization

### Recovery Procedures

#### File Corruption Recovery
```mql5
void HandleFileCorruption() {
    // 1. Attempt to read backup file
    // 2. If backup fails, initialize with default values
    // 3. Log error and continue operation
    // 4. Attempt to recreate file on next update
}
```

#### Communication Failure Recovery
```mql5
void HandleCommunicationFailure() {
    // 1. Switch to fallback signal generation mode
    // 2. Reduce trading activity
    // 3. Attempt to re-establish communication
    // 4. Resume normal operation when communication restored
}
```

## Performance Optimization

### Calculation Efficiency

#### Caching Strategies
```mql5
// Cache strength values with timestamp validation
struct StrengthCache {
    string symbol;
    double strength;
    datetime timestamp;
    bool is_valid;
};

StrengthCache m_strength_cache[];
```

#### Update Frequency Optimization
```mql5
// Configurable update intervals based on timeframe
int GetOptimalUpdateFrequency(ENUM_TIMEFRAMES tf) {
    switch(tf) {
        case PERIOD_M1: return 30;    // 30 seconds
        case PERIOD_M5: return 60;    // 1 minute
        case PERIOD_M15: return 120;  // 2 minutes
        case PERIOD_H1: return 300;   // 5 minutes
        default: return 600;          // 10 minutes
    }
}
```

## Testing Integration Points

### Integration Test Scenarios

#### File Format Compatibility Tests
- Test CSV header parsing
- Validate data type conversions
- Test missing data handling

#### Signal Consistency Tests
- Verify strength calculations match dashboard
- Test categorization logic consistency
- Validate trading signal generation

#### Error Condition Tests
- File permission errors
- Network location accessibility
- Corrupted data handling
- Configuration mismatch scenarios

### Performance Testing

#### Load Testing Scenarios
- Maximum symbol count (50+ symbols)
- High-frequency updates
- Large historical data processing
- Multiple EA instances running concurrently

#### Resource Usage Monitoring
- Memory consumption patterns
- CPU utilization during peak loads
- File I/O performance metrics
- Network bandwidth usage (if applicable)
