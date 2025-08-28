## Epic 3: Equity Curve Signal EA (Demo/Strategy Tester)

### Overview

Develop an Expert Advisor that generates trading signals based on the SuperSlopeDashboard strength values and produces an Equity Curve output file for consumption by the Live Trading EA.

---

### User Story 3.1: Core EA Framework Setup
[[Sprint Planning - User Story 3.1 - Core EA Framework Setup]]

**As a** trader  
**I want** an EA framework that can run on demo accounts or in Strategy Tester  
**So that** I can generate equity curve signals without risking real capital

#### Acceptance Criteria:

- [x] EA initializes correctly on demo accounts and Strategy Tester
- [ ] EA validates that it's not running on a live account (safety check)
- [ ] EA creates necessary file directories for output
- [x] EA logs all initialization parameters for audit trail
- [x] EA implements proper cleanup on deinitialization

#### Technical Tasks:

- Create `EquityCurveSignalEA.mq5` main file
- Implement `CEquityCurveController` class for orchestration
- Add account type validation
- Set up logging framework

---

### User Story 3.2: Dashboard Integration

**As a** trader  
**I want** the EA to consume SuperSlopeDashboard strength values  
**So that** trading decisions are based on the proven strength calculations

**Design Decision:** we need to investigate Dashboard Integration vs reuse of dashboard code within the EA.  The EA will need to either display the SuperSlopeDashboard either using the indicator or as part of the EA.  
#### Acceptance Criteria:

- [ ] EA successfully integrates with existing CDataManager class
- [ ] EA can process strength values for configured symbols
- [ ] EA respects user-defined threshold levels (Strong Bull/Bear, Weak Bull/Bear, Neutral)
- [ ] EA handles missing or invalid symbol data gracefully
- [ ] Strength values update at configurable intervals

#### Technical Tasks:
Review and confirm based on design decision:
- Integrate `CDataManager.mqh` into EA
- Create `CSignalGenerator` class for signal processing
- Implement symbol validation and error handling
- Add configurable update frequency parameter

---

### User Story 3.3: Trading Signal Generation

**As a** trader  
**I want** clear trading rules based on strength categories  
**So that** the EA enters and exits trades consistently

#### Acceptance Criteria:

- [ ] EA opens long positions when symbol enters "Strong Bull" category
- [ ] EA opens short positions when symbol enters "Strong Bear" category
- [ ] EA closes positions when symbol returns to "Neutral" category
- [ ] EA implements one position per symbol rule
- [ ] EA can manage multiple symbols simultaneously
- [ ] Optional: EA supports "Weak Bull/Bear" entries with different parameters

#### Technical Tasks:

- Implement `CTradeManager` class for position management
- Create position tracking system
- Add signal filtering logic
- Implement trade execution methods

---

### User Story 3.4: Trade Management System

**As a** trader  
**I want** simple but effective trade management  
**So that** the equity curve accurately reflects the strategy performance

#### Acceptance Criteria:

- [ ] EA uses fixed lot size or percentage-based position sizing
	- [ ] Optional: EA applies weighting to position size based on the ATR or Market Value (TBD) of the pair 
- [ ] EA tracks entry time, price, and strength value for each trade
- [ ] EA implements optional basic stop loss (disaster protection only)
- [ ] EA records exit time, price, and profit/loss for each trade
- [ ] EA maintains accurate position state for all symbols


#### Technical Tasks:

- Create `CPositionTracker` class
- Implement position sizing calculations
- Add trade logging functionality
- Create position state management system

---

### User Story 3.5: Equity Curve Output Generation

**As a** trader  
**I want** a standardized equity curve output file  
**So that** the Live Trading EA can consume the signals reliably

#### Acceptance Criteria:

- [ ] EA generates CSV file with timestamp, balance, equity, and signal strength
- [ ] EA updates file in real-time (configurable interval)
- [ ] EA implements file locking to prevent read/write conflicts
- [ ] EA creates rolling backup files (daily/weekly)
- [ ] EA includes metadata header with configuration parameters
- [ ] Output format supports multiple timeframes
- [ ] Optional: The EA plots the output on a chart  

#### Technical Tasks:

- Create `CEquityCurveWriter` class
- Implement CSV formatting with headers
- Add file rotation and backup logic
- Implement thread-safe file operations
- Create metadata generation system

#### Output File Format:

```csv
# Metadata
# Version: 1.0
# EA: EquityCurveSignalEA
# Symbols: EURUSD,GBPUSD,USDJPY...
# Timeframe: H1
# Strong Threshold: 1.0
# Weak Threshold: 0.5
# Start Date: 2025-01-01 00:00:00
#
Timestamp,Balance,Equity,DrawdownPercent,SignalStrength,OpenPositions,Symbol,Action
2025-01-01 00:00:00,10000.00,10000.00,0.0,0.0,0,,
2025-01-01 01:00:00,10000.00,10015.50,0.0,2.15,1,EURUSD,BUY
```

---

### User Story 3.6: Configuration Management

**As a** trader  
**I want** comprehensive configuration options  
**So that** I can optimize the signal generation strategy

#### Acceptance Criteria:

- [ ] EA provides input parameters for all dashboard settings (MA period, ATR period)
- [ ] EA allows symbol list configuration
- [ ] EA supports timeframe selection
- [ ] EA provides threshold customization (Strong/Weak levels)
- [ ] EA includes output file configuration (path, update frequency)
- [ ] EA supports multiple configuration profiles

#### Input Parameters:

- Slope MA Period (default: 7)
- Slope ATR Period (default: 50)
- Symbol List (comma-separated)
- Timeframe (M1 to MN1)
- Strong Bull Threshold (default: 1.0)
- Strong Bear Threshold (default: -1.0)
- Weak Bull Threshold (default: 0.5)
- Weak Bear Threshold (default: -0.5)
- Output File Path
- Update Frequency (seconds)
- Position Size Mode (Fixed/Percentage)
- Position Size Value

---

## Epic 4: Live Trading EA (Equity Curve Consumer)

### Overview

Develop an Expert Advisor that reads the Equity Curve output file and executes live trades based on equity curve signals, implementing sophisticated basket trading and risk management.

---

### User Story 4.1: Equity Curve File Reader

**As a** trader  
**I want** the EA to reliably read equity curve signals from file  
**So that** live trading decisions are based on proven signal performance

#### Acceptance Criteria:

- [ ] EA reads CSV file from configurable location
- [ ] EA handles file access errors gracefully
- [ ] EA validates file format and data integrity
- [ ] EA implements configurable read frequency
- [ ] EA detects and handles stale data
- [ ] Optional: EA can read from network locations (for multi-instance setups)

#### Technical Tasks:

- Create `CEquityCurveReader` class
- Implement CSV parsing with validation
- Add file monitoring system
- Create data freshness checks
- Implement error recovery mechanisms

---

### User Story 4.2: Equity Curve Signal Analysis

**As a** trader  
**I want** the EA to analyze equity curve patterns  
**So that** it enters trades during favorable equity conditions

#### Acceptance Criteria:

- [ ] EA calculates moving average of equity curve
- [ ] EA detects equity curve breakouts/breakdowns
- [ ] EA identifies drawdown periods
- [ ] EA calculates signal strength trends
- [ ] EA implements configurable signal filters
- [ ] EA provides multiple signal generation methods

#### Signal Methods:

1. **Simple MA Cross**: Trade when equity > MA(equity)
2. **Momentum**: Trade when equity curve slope > threshold
3. **Drawdown Recovery**: Trade after recovering from drawdown
4. **Strength Confirmation**: Combine equity signal with strength values
5. **Pattern Recognition**: Identify specific equity curve patterns

#### Technical Tasks:

- Create `CEquityCurveAnalyzer` class
- Implement multiple signal generation algorithms
- Add signal strength calculations
- Create pattern detection system
- Implement signal combination logic

---

### User Story 4.3: Basket Trading Management

**As a** trader  
**I want** the EA to trade multiple pairs as a basket  
**So that** I can diversify risk and maximize opportunities

#### Acceptance Criteria:

- [ ] EA opens positions on multiple symbols based on signals
- [ ] EA implements correlation-based position sizing
- [ ] EA tracks basket performance metrics
- [ ] EA supports different basket compositions (all pairs, strong only, etc.)
- [ ] EA implements basket rebalancing logic
- [ ] EA provides basket-level risk management

#### Technical Tasks:

- Create `CBasketManager` class
- Implement correlation calculations
- Add position sizing algorithms
- Create basket performance tracking
- Implement rebalancing logic

---

### User Story 4.4: Advanced Entry Criteria

**As a** trader  
**I want** additional entry filters beyond equity curve signals  
**So that** trade quality is maximized

#### Acceptance Criteria:

- [ ] EA supports time-of-day filters
- [ ] EA implements volatility filters (ATR-based)
- [ ] EA checks spread conditions before entry
- [ ] EA supports news event filtering (optional)
- [ ] EA implements maximum position limits
- [ ] EA supports additional technical indicator confirmation

#### Optional Confirmations:

- RSI overbought/oversold
- Support/Resistance levels
- Trend line breaks
- Volume confirmation
- Market sentiment indicators

#### Technical Tasks:

- Create `CEntryFilter` class hierarchy
- Implement time and volatility filters
- Add spread monitoring
- Create indicator integration framework
- Implement filter combination logic

---

### User Story 4.5: Risk Management System

**As a** trader  
**I want** comprehensive risk management at both individual and basket levels  
**So that** capital is protected while allowing for profit maximization

#### Acceptance Criteria:

- [ ] EA implements individual position stop loss and take profit
- [ ] EA implements basket-level stop loss and take profit
- [ ] EA supports trailing stop functionality (individual and basket)
- [ ] EA implements maximum drawdown protection
- [ ] EA supports partial position closing
- [ ] EA implements break-even management
- [ ] EA closes all positions on equity curve signal reversal

#### Risk Parameters:

- Individual SL (points/percentage/ATR)
- Individual TP (points/percentage/ATR)
- Basket SL (currency/percentage)
- Basket TP (currency/percentage)
- Trailing Stop (individual and basket)
- Maximum Daily Drawdown
- Maximum Open Positions
- Risk per Trade (percentage)

#### Technical Tasks:

- Create `CRiskManager` class
- Implement multiple stop loss types
- Add basket-level calculations
- Create trailing stop system
- Implement emergency close functionality

---

### User Story 4.6: Performance Monitoring & Reporting

**As a** trader  
**I want** comprehensive performance monitoring and reporting  
**So that** I can track system effectiveness and make improvements

#### Acceptance Criteria:

- [ ] EA tracks all trade statistics (win rate, profit factor, etc.)
- [ ] EA generates performance reports (daily/weekly/monthly)
- [ ] EA creates visual dashboard on chart
- [ ] EA exports detailed trade logs
- [ ] EA implements alert system for important events
- [ ] EA provides real-time performance metrics

#### Metrics to Track:

- Total Trades
- Win Rate
- Profit Factor
- Maximum Drawdown
- Sharpe Ratio
- Average Win/Loss
- Basket Performance
- Correlation Analysis
- Equity Curve Smoothness

#### Technical Tasks:

- Create `CPerformanceMonitor` class
- Implement statistics calculations
- Add report generation system
- Create chart dashboard display
- Implement alert notifications

---

### User Story 4.7: Multi-Instance Coordination

**As a** trader  
**I want** the EA to coordinate with other instances  
**So that** I can run multiple strategies without conflicts

#### Acceptance Criteria:

- [ ] EA implements unique magic number system
- [ ] EA can read multiple equity curve files
- [ ] EA supports master/slave configurations
- [ ] EA implements position conflict resolution
- [ ] EA provides inter-instance communication (optional)

#### Technical Tasks:

- Create instance identification system
- Implement file-based communication
- Add conflict resolution logic
- Create master/slave coordination

---

### User Story 4.8: Configuration & Optimization

**As a** trader  
**I want** comprehensive configuration and optimization capabilities  
**So that** the system can be adapted to different market conditions

#### Acceptance Criteria:

- [ ] EA provides all parameters as inputs
- [ ] EA supports configuration profiles
- [ ] EA implements parameter validation
- [ ] EA provides optimization-friendly parameters
- [ ] EA supports dynamic parameter adjustment

#### Key Input Parameters:

```mql5
// Equity Curve Settings
input string EquityCurveFile = "EquityCurve.csv";
input int ReadFrequencySeconds = 5;
input ENUM_SIGNAL_METHOD SignalMethod = SIGNAL_MA_CROSS;
input int EquityMAPeriod = 20;

// Trading Settings
input string TradingSymbols = "EURUSD,GBPUSD,USDJPY";
input double RiskPercentage = 1.0;
input ENUM_POSITION_SIZE_MODE SizeMode = SIZE_FIXED;
input double PositionSize = 0.01;

// Risk Management
input bool UseIndividualSL = true;
input double IndividualSL = 50;
input bool UseBasketSL = true;
input double BasketSL = 2.0; // percentage
input bool UseTrailingStop = false;
input double TrailingStopDistance = 30;

// Filters
input bool UseTimeFilter = false;
input string TradingStartTime = "08:00";
input string TradingEndTime = "20:00";
input bool UseSpreadFilter = true;
input double MaxSpreadPoints = 3.0;
```

---

## Testing & Validation Stories (Both EAs)

### User Story 5.1: Strategy Testing

**As a** developer  
**I want** comprehensive testing capabilities  
**So that** both EAs can be validated before live deployment

#### Acceptance Criteria:

- [ ] Signal EA runs correctly in Strategy Tester
- [ ] Live EA can consume historical equity curve files
- [ ] Both EAs provide detailed logging for debugging
- [ ] Performance metrics match expected results
- [ ] File operations work correctly across different environments

---

### User Story 5.2: Integration Testing

**As a** developer  
**I want** end-to-end integration testing  
**So that** the complete system works reliably

#### Acceptance Criteria:

- [ ] Signal EA output is correctly read by Live EA
- [ ] Signals translate to appropriate trades
- [ ] Risk management works across the full system
- [ ] Performance is acceptable under load
- [ ] System recovers from errors gracefully

---

## Implementation Priority

### Phase 1: Equity Curve Producer MVP (Minimum Viable Product)

1. Epic 3: Stories 3.1, 3.2, 3.3, 3.5 (Basic signal generation and output)

### Phase 2: Equity Curve Producer Core Features

1. Epic 3: Stories 3.4, 3.6 (Enhanced trade management)

At this point I can back test scenarios for SuperSlope Equity Curve Trading and commence strategy development.

### Phase 3: Equity Curve Consumer MVP (Minimum Viable Product)

1.  Epic 4: Stories 4.3 (Basic trading)

Basic Trade Monitoring EA
### Phase 4: Equity Curve Consumer Core Features

1. Epic 4: Stories 4.1, 4.5 (Basic file reading and risk management)

### Phase 5: Equity Curve Consumer Core Features

1. Epic 4: Stories 4.2, 4.4, 4.6, 4.7, 4.8 (Signal analysis, Filters, monitoring, multi-instance)



---

## Success Metrics

### Signal EA (Epic 3)

- Generates consistent signals aligned with dashboard
- Produces readable equity curve files
- Maintains stable operation over extended periods
- Accurate position tracking and reporting

### Live Trading EA (Epic 4)

- Successfully reads and interprets equity curve signals
- Executes trades with minimal latency
- Risk management prevents excessive drawdowns
- Performance metrics meet or exceed backtested results

---

## Technical Debt & Future Enhancements

### Potential Enhancements:

1. Machine learning for signal optimization
2. Multi-timeframe analysis
3. Sentiment analysis integration
4. Advanced correlation-based hedging
5. Cloud-based signal distribution
6. Mobile app notifications
7. Web-based monitoring dashboard
8. Automated parameter optimization
9. Integration with other trading platforms
10. Advanced money management algorithms (Kelly Criterion, etc.)

---
## Notes and Items to review
### End of Sprint 1
- I could not find an actual directory setup on the test environment but think that this is because we will need to add in some includes or library code to do this at a later point in the project 
- At some point I will need to check that I get an error when trying to run on a live account