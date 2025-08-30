Note:  this has been revised to a beta product and streamlined.
### Critical Design Artifacts and Decisions
1. Signal Generation Architecture
	1. __Decision__: Implement CSignalGenerator with threshold-based categorization:
	- Use ENUM_STRENGTH_CATEGORY (STRONG_BULL, WEAK_BULL, NEUTRAL, etc.)
	- Map categories to ENUM_TRADE_SIGNAL (BUY, SELL, CLOSE, HOLD)
	- Implement strength value caching to avoid recalculating on every tick
2. Trade Execution Pattern
	1. __Decision__: Use CTradeManager with position validation:
	- Check for existing positions before executing new signals
	- Implement proper lot size calculation
	- Include basic error handling for trade execution failures
3. Position Tracking Approach
	__Decision__: CPositionTracker should:
	- Maintain array of open positions with ticket numbers
	- Provide methods to check position existence and details
	- Integrate with trade manager for position management
4. Data Output Strategy
	__Decision__: CEquityCurveWriter should:
	- Write minimal essential data for live trading EA integration
	- Use simple CSV format with timestamp, equity, strength, and position data
	- Implement basic file rotation to prevent unlimited growth
5. Performance Considerations
	__Essential optimizations for beta:__
	- Implement strength value caching with timestamp validation
	- Use ArrayResize with reserve for position tracking arrays
	- Add configurable update frequency to reduce CPU load
	- Basic memory usage monitoring in logs

---
## Sprint 3 (User Story 3.1): Integration Ready & Performance

### __Sprint 3.1: Core Trading Implementation__ (Highest Priority)
- Implement CSignalGenerator with threshold logic
- Implement CTradeManager with basic trade execution
- Implement CPositionTracker for position management
- Implement CEquityCurveWriter for data output

# DONE
#### Task 3.1.1: Implement CSignalGenerator Class
- Create CSignalGenerator.mqh file in MQL5/Includes/MyProjects/EquityCurve/
- Define class structure with threshold parameters and categorization logic
- Implement ENUM_STRENGTH_CATEGORY and ENUM_TRADE_SIGNAL mappings
- Add methods: Initialize(), CategorizeStrength(), GenerateSignal()
- Integrate with CDataManager for strength value access
- Implement basic signal logic: STRONG_BULL → BUY, STRONG_BEAR → SELL, NEUTRAL → CLOSE
# DOING
#### Task 3.1.2: Implement CTradeManager Class
- Create CTradeManager.mqh file in MQL5/Includes/MyProjects/EquityCurve/
- Define class structure with position size parameters
- Implement trade execution methods: OpenBuyPosition(), OpenSellPosition(), ClosePosition()
- Add position size calculation based on input parameter
- Include basic error handling for trade execution failures
- Integrate with CPositionTracker for position validation
##### Current Project Analysis
- __CSignalGenerator.mqh__ is already implemented and provides signal generation functionality
- __CEquityCurveController.mqh__ exists and handles initialization, logging, and configuration
- __CPositionTracker__ is required for integration but doesn't exist yet
- The task requires creating CTradeManager.mqh with specific trade execution methods
##### Implementation Plan
1. Create CPositionTracker.mqh (Prerequisite Dependency)
	Since CTradeManager needs to integrate with CPositionTracker for position validation, I'll first create CPositionTracker.mqh with the following structure:
		- Define ENUM_POSITION_TYPE (BUY/SELL)
		- Implement PositionInfo struct with symbol, ticket, volume, entry_price, entry_time, and type
		- Create CPositionTracker class with methods for:
		  - UpdatePositions() - sync with current open positions
		  - AddPosition() - track new positions
		  - RemovePosition() - remove closed positions
		  - GetPosition() - retrieve position info
		  - HasPosition() - check if symbol has open position
		  - GetOpenPositionCount() - count open positions
		  - GetTotalExposure() - calculate total risk exposure
2. Create CTradeManager.mqh
	This will be the main implementation file with:
		- Include guards and necessary headers (Trade/Trade.mqh, CPositionTracker.mqh)
		- Define ENUM_POSITION_SIZE_MODE (SIZE_FIXED, SIZE_PERCENTAGE, SIZE_ATR_BASED)
		- Implement the CTradeManager class with:
		  - Private members: CPositionTracker instance, position size, size mode
		  - Constructor/destructor
		  - Initialize() method to set position size parameters
		  - ExecuteSignal() method to process trade signals
		  - OpenBuyPosition()/OpenSellPosition() methods with error handling
		  - ClosePosition() method with error handling
		  - CalculatePositionSize() method based on size mode
		  - HasOpenPosition() method using CPositionTracker
3. Key Implementation Details
	- __Trade Execution__: Use MQL5's CTrade class for order placement with proper error checking
	- __Error Handling__: Implement comprehensive error handling for trade execution failures with descriptive messages
	- __Position Sizing__: Support multiple sizing modes (fixed, percentage of balance, ATR-based)
	- __Integration__: Ensure proper integration with CPositionTracker for position validation and tracking
	- __Logging__: Use Print statements for now, with potential integration to CEquityCurveController logging later
4. Testing Considerations
	- The implementation will need to be tested in Strategy Tester due to account restrictions
	- Error handling should be robust to handle various trade execution scenarios
	- Position size calculations should be validated for different modes

# Testing
It compiles but how to test?  Observations
- On Demo account - it installs and then immediately closes - removes itself
- In tester - it seems to just run and not remove itself
- I have a sprint allocated to testing later so perhaps there isnt much to see / do at this point? -
The chat - confirms an approach to complete the other classes and integrate then test
# NEXT
#### Task 3.1.3: Implement CPositionTracker Class
- Create CPositionTracker.mqh file in MQL5/Includes/MyProjects/EquityCurve/
- Define PositionInfo structure to store position data
- Implement methods: UpdatePositions(), AddPosition(), RemovePosition(), HasPosition()
- Provide position counting and exposure calculation
- Ensure thread-safe access for multi-symbol trading
#### Task 3.1.4: Implement CEquityCurveWriter Class
- Create CEquityCurveWriter.mqh file in MQL5/Includes/MyProjects/EquityCurve/
- Define class structure with output path configuration
- Implement WriteData() method for CSV output
- Include essential fields: timestamp, balance, equity, strength, symbol, action
- Add basic file rotation to prevent unlimited file growth
- Integrate with controller for path management
#### Task 3.1.5: Integrate Components into Main EA
- Update EquityCurveSignalEA.mq5 to include new component headers
- Modify OnInit() to initialize all new components with configuration parameters
- Replace placeholder ProcessSignals() with actual signal generation and trade execution
- Add proper cleanup of new components in OnDeinit()
- Ensure error handling propagates through all components
#### Task 3.1.6: Basic Functional Testing
- Create simple test script to verify signal generation logic
- Test trade execution in Strategy Tester with visual validation
- Verify CSV output file creation and data format
- Test configuration reload with new components
- Validate position tracking accuracy
#### Task 3.1.7: Documentation and Examples
- Add essential inline comments to all new classes
- Create configuration examples for different trading strategies
- Document signal logic and threshold recommendations
- Provide troubleshooting notes for common issues
#### Dependencies and Sequencing:
1. CSignalGenerator must be implemented first (3.1.1)
2. CPositionTracker should be completed before CTradeManager (3.1.3 before 3.1.2)
3. Component integration (3.1.5) can begin once individual classes are stable
4. Testing (3.1.6) should run in parallel with development

#### Estimated Focus Areas:
- __Signal Generation__: ~40% of effort (core logic)
- __Trade Execution__: ~30% of effort (execution and error handling)
- __Position Tracking__: ~20% of effort (state management)
- __Data Output__: ~10% of effort (simple CSV writing)

### __Sprint 3.2: Essential Optimization__ (Medium Priority)
- Strength value caching to avoid recalculations
- Basic memory management for position arrays
- Configurable update frequency implementation
- Minimal performance profiling

## __Sprint 3.3: Integration Preparedness__ (Low Priority)
- Basic test framework for signal generation
- Mock dashboard integration points
- Configuration examples for trading strategies
