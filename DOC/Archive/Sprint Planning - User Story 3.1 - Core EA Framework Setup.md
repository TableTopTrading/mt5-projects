## Deliverables

### 1. Main EA File (EquityCurveSignalEA.mq5)
**Purpose**: Primary entry point for the EA, handling MQL5 event hooks and orchestration
**Components**: 
- OnInit() for initialization
- OnDeinit() for cleanup
- OnTick() for main processing (stubbed for future implementation)
- Configuration loading and validation

### 2. CEquityCurveController Class
**Purpose**: Central orchestration class coordinating all framework components
**Key Methods**:
- Initialize(): Sets up all components and validates environment
- ValidateAccountType(): Safety check for demo/Strategy Tester only
- SetupDirectories(): Creates necessary output directories
- ConfigureLogging(): Initializes logging framework
- Cleanup(): Handles proper shutdown procedures

### 3. Account Validation System
**Purpose**: Prevents execution on live accounts as safety measure
**Implementation**: 
- Check AccountType() using MQL5 AccountInfoInteger(ACCOUNT_TRADE_MODE)
- Validate server name for demo accounts
- Throw graceful errors with clear messages

### 4. Logging Framework
**Purpose**: Comprehensive audit trail for initialization and operations
**Components**:
- File-based logging with timestamping
- Log levels (INFO, WARN, ERROR)
- Parameter logging for all initialization values
- Rotating log files to prevent excessive size

### 5. Directory Management System
**Purpose**: Creates and manages necessary file output directories
**Paths to Create**:
- /Files/EquityCurveSignals/Output/
- /Files/EquityCurveSignals/Logs/
- /Files/EquityCurveSignals/Configuration/

### 6. Initialization & Cleanup Routines
**Purpose**: Proper resource management and state consistency
**Features**:
- Ordered initialization of components
- Graceful error handling during setup
- Comprehensive cleanup releasing all resources
- State persistence between sessions

## Technical Component Designs

### EquityCurveSignalEA.mq5 Structure
```mql5
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://github.com/TableTopTrading"
#property version   "1.00"
#property strict

#include <MyProjects/EquityCurve/CEquityCurveController.mqh>

CEquityCurveController controller;

int OnInit() {
    return controller.Initialize();
}

void OnDeinit(const int reason) {
    controller.Cleanup(reason);
}

void OnTick() {
    // To be implemented in future user stories
}
```

### CEquityCurveController Class Design
```mql5
class CEquityCurveController {
private:
    bool m_initialized;
    string m_log_path;
    string m_output_path;
    
public:
    CEquityCurveController();
    ~CEquityCurveController();
    
    int Initialize();
    bool ValidateAccountType();
    bool SetupDirectories();
    bool ConfigureLogging();
    void LogInitializationParameters();
    void Cleanup(int deinit_reason);
    bool IsInitialized() const;
};
```

## End User Tests for Each Component

### 1. Initialization Test
**Test Case**: EA loads successfully in Strategy Tester
**Verification**: Check OnInit() returns INIT_SUCCEEDED
**Expected**: No compilation errors, EA appears in MT5 navigator

### 2. Account Validation Test
**Test Case**: EA rejects live account execution
**Verification**: Attempt to run on live account, expect error message
**Expected**: Graceful error with "Cannot run on live account" message

### 3. Directory Creation Test
**Test Case**: Required directories are created automatically
**Verification**: Check existence of /Files/EquityCurveSignals/ directories
**Expected**: All three directories exist after initialization

### 4. Logging Test
**Test Case**: Initialization parameters are logged
**Verification**: Check log file contains configuration values
**Expected**: Timestamped log entries with all init parameters

### 5. Cleanup Test
**Test Case**: Proper resource release on deinitialization
**Verification**: Run EA then remove, check for resource leaks
**Expected**: No open file handles or memory leaks after removal

## Sprint Prioritization

### Sprint 1: Core Framework Foundation (Highest Priority)
[[US 3.1 - Sprint 1- Core Framework Foundation - Tasks and Activities]]
- [x] Create EquityCurveSignalEA.mq5 skeleton
- [x] Implement CEquityCurveController class structure
- [x] Add account type validation logic
- [x] Set up basic logging framework
- [x] Create directory management system

### Sprint 2: Enhanced Reliability & Audit (Medium Priority)
[[US 3.1 - Sprint 2- Enhanced Reliability & Audit]]
- [x] Comprehensive error handling
- [x] Parameter validation and logging
- [x] Resource cleanup guarantees
- [ ] Configuration file support

### Sprint 3: Integration Ready (Lower Priority)
- [ ] Performance optimization
- [ ] Memory management
- [ ] Cross-version compatibility
- [ ] Documentation and comments

## MQL5 Constraints Considered
- Using #property strict for compatibility
- Proper include paths for custom includes
- File I/O operations within MQL5 sandbox limitations
- Account information access restrictions
- Memory management best practices

This decomposition provides a solid foundation for the core EA framework while maintaining flexibility for future enhancements. The prioritization ensures that essential safety and functionality are delivered first, with additional features following in subsequent sprints.