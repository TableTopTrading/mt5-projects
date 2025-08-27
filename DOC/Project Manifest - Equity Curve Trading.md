
**Last Updated:** 2025-08-27
**Version:** 0.2.0 (LWMA implementation completed for consistency with SuperSlope indicator)
**Project Overview:** This document tracks all source files, documentation, and key information for the MT5 Equity Curve Project.

---

## 1. Project Overview

A brief, high-level description of the project, its goal, and its architecture (MVC pattern).

- Epic 1 involves creating a MetaTrader 5 indicator that plots the strength of FX pairs (and other markets) based on a custom (LWMA & ATR) calculation. This is now complete.
- Epic 2 involves creating a MetaTrader 5 indicator that displays a real-time dashboard categorizing multiple forex symbols into strength buckets based on a custom (LWMA & ATR) calculation. This is now completed.
- Epic 3 is to develop an EA to trade a 'dummy' account which produces an Equity Curve.
- Epic 4 project is to develop an EA that consumes the Equity Curve EA's output, and trades a live account.
Following on from this we may want to include enhancements to:
- Include a variety of Moving Average options
- Include a variety of timeframe options
- Include a variety of options for trade management.
## 2. File Manifest

This section is the core of the document. It lists every file in the project with its purpose and status.

### 2.1 Core Source Files

| File Name                   | Type      | Purpose                                          | Status   | Version | Dependencies                                                 |
| :-------------------------- | :-------- | :----------------------------------------------- | :------- | :------ | :----------------------------------------------------------- |
| SuperSlope.mq5              | Indicator | Main indicator file for SuperSlope               | Complete | 1.0     | CSuperSlope.mqh                                              |
| CSuperSlope.mqh             | Include   | Implementation class for SuperSlope calculations | Complete | 1.0     | None                                                         |
| SuperSlopeDashboard.mq5     | Indicator | Dashboard indicator for market strength          | Complete | 1.0     | CDashboardController_v2.mqh, CDataManager.mqh, CRenderer.mqh |
| CDataManager.mqh            | Include   | Data management class for dashboard              | Complete | 1.0     | None (uses manual price data calculations)                   |
| CRenderer.mqh               | Include   | Dashboard visualization class                    | Complete | 1.0     | None                                                         |
| CDashboardController.mqh    | Include   | Controller orchestrating Model-View              | Complete | 1.0     | CDataManager.mqh, CRenderer.mqh                              |
| CDashboardController_v2.mqh | Include   | Fixed version with compilation corrections       | Complete | 1.0     | CDataManager.mqh, CRenderer.mqh                              |

### 2.2 Test Files

| File Name              | Type   | Purpose                                  | Status    |
| :--------------------- | :----- | :--------------------------------------- | :-------- |
| Test_DataManager.mq5   | Script | Unit test for CDataManager class         | Passed ✅  |
| Test_Renderer.mq5      | Script | Unit test for CRenderer class            | Passed ✅  |
| Test_Controller_v2.mq5 | Script | Unit test for CDashboardController class | Created ✅ |
| Test_Controller_v3.mq5 | Script | Updated test with fixed include paths    | Passed ✅  |
| Test_Compile_Final.mq5 | Script | Compilation verification test            | Passed ✅  |

### 2.3 Documentation

| File Name                                      | Purpose                                                       |
| :--------------------------------------------- | :------------------------------------------------------------ |
| `PROJECT_MANIFEST.md`                          | (This file) The central registry for the project.             |
| `Project Context - SlopeStrength Dashboard.md` | Provides high-level context for developers (LLMs).            |
| `SuperSlope_User_Guide.md`                     | Complete user documentation for SuperSlope indicator          |
| `Project Manifest - Equity Curve Trading.md`   | Project tracking and documentation for the full project suite |

---

## 3. Key Data Structures

### Completed Components

#### CSuperSlope
*   **Purpose**: Implements the core SuperSlope calculation logic
*   **Attributes**: 
    - `m_ma_period`: Period for the Linear Weighted Moving Average
    - `m_atr_period`: Period for the Average True Range
*   **Methods**: 
    - `Calculate()`: Performs the normalized slope calculation
    - `Initialize()`: Sets up indicator buffers and parameters

#### CDataManager
*   **Purpose**: Manages data calculations for the strength dashboard using manual price data calculations
*   **Attributes**: 
    - `m_ma_period`: Moving Average period (LWMA)
    - `m_atr_period`: ATR period
    - `m_max_bars`: Maximum bars to calculate
*   **Methods**: 
    - `Initialize()`: Sets up calculation parameters
    - `CalculateStrengthValue()`: Calculates strength value for a symbol using manual LWMA and ATR calculations from price data
    - `Deinitialize()`: Cleans up resources
    - `CalculateLWMA()`: Manually calculates Linear Weighted Moving Average
    - `CalculateATR()`: Manually calculates Average True Range

#### CRenderer
*   **Purpose**: Handles dashboard visualization
*   **Attributes**: 
    - `m_start_x`, `m_start_y`: Dashboard position coordinates
    - `m_column_width`, `m_row_height`: Layout dimensions
    - `m_column_colors[5]`: Color array for strength columns
    - `m_font_name`, `m_font_size`: Text styling
*   **Methods**: 
    - `Initialize()`: Sets up renderer with position
    - `DrawDashboardHeaders()`: Creates column headers with colored backgrounds
    - `Draw()`: Main rendering method
    - `DeleteAllObjects()`: Cleans up all SSD_ prefixed objects
    - `DrawSymbolRow()`: Displays individual symbol entries
    - `SetColors()`, `SetPosition()`, `SetDimensions()`: Configuration methods

#### CDashboardController
*   **Purpose**: Orchestrates Model-View communication for the strength dashboard
*   **Attributes**: 
    - `m_data_manager`: CDataManager instance for strength calculations
    - `m_renderer`: CRenderer instance for dashboard display
    - `m_symbols[]`: Array of symbols to monitor
    - `m_strength_values[]`: Calculated strength values per symbol
    - `m_categories[]`: Category assignments per symbol
    - `m_threshold_*`: Configurable categorization thresholds
*   **Methods**: 
    - `Initialize()`: Sets up both Model and View components
    - `Update()`: Core orchestration method connecting calculations to display
    - `SetSymbols()`: Configures symbols for monitoring
    - `SetThresholds()`: Configures strength categorization thresholds
    - `SortSymbolsByStrength()`: Orders symbols within categories
    - `GetSymbolStrength()`: Queries individual symbol strength values


---

## 4. Version History

A changelog to track progress and changes.

| Version   | Date       | Author | Description                                                                                                  |
| :-------- | :--------- | :----- | :----------------------------------------------------------------------------------------------------------- |
| **0.1.0** | 2025-08-25 | CM     | SlopeStrength Indicator completed                                                                            |
| 0.1.1     | 2025-08-26 | CM     | Project Initiation of Dashboard Project                                                                      |
| 0.1.2     | 2025-08-26 | Claude | Implemented basic Dashboard structure                                                                        |
| 0.1.3     | 2025-08-26 | Claude | Completed CDataManager implementation                                                                        |
| 0.1.4     | 2025-08-26 | Claude | Created Test_DataManager script                                                                              |
| 0.1.5     | 2025-08-26 | Claude | CDataManager unit test passed (EURUSD: 1.0126)                                                               |
| 0.1.6     | 2025-08-26 | Claude | Created CRenderer class structure                                                                            |
| 0.1.7     | 2025-08-26 | Claude | Completed CDashboardController v1.0 implementation                                                           |
| **0.1.8** | 2025-08-26 | Claude | Fixed compilation errors, created test suite                                                                 |
| **0.1.9** | 2025-08-26 | DS     | MVC integration complete, SuperSlopeDashboard.mq5 v1.0 delivered for full integration and acceptance testing |
| **0.2.0** | 2025-08-27 | DS     | Fixed ERR_INDICATOR_NO_DATA issue by replacing indicator handles with manual price data calculations         |

---

## 6. Technical Notes & Fixes

### Phase 3.2 Compilation Fixes (Version 0.1.8)

During the implementation of CDashboardController v1.0, several compilation errors were encountered and resolved:

#### Issues Resolved:
1. **`'abs' - undeclared identifier`**
   - **Problem:** Used `abs()` function which doesn't exist in MQL5
   - **Solution:** Replaced with simplified mathematical logic using `(m_threshold_weak_bear * 2.0)`

2. **CRenderer.Draw() Parameter Mismatch**
   - **Problem:** Method expects 15 parameters (5 symbol arrays + 5 counts + 5 value arrays)
   - **Solution:** Enhanced data structure to maintain both symbol names and strength values in parallel arrays

3. **Array Management Enhancement**
   - **Improvement:** Added proper value array handling for each strength category
   - **Result:** Complete integration with CRenderer's visualization requirements

#### Files Created:
- `CDashboardController_v2.mqh` - Fixed version with all compilation errors resolved
- `Test_Controller_v3.mq5` - Updated test script with corrected include paths
- `Test_Compile_Final.mq5` - Simple compilation verification test

#### Testing Status:
- ✅ **Compilation:** All errors resolved, clean compilation achieved
- ✅ **Structure:** Complete MVC architecture implemented
- 🔄 **Integration Testing:** Ready for Phase 3.3

---

## 7. Backlog


### **Project Plan: 
