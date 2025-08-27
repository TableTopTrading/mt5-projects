
**Last Updated:** 2025-08-27
**Version:** 0.2.0 (LWMA implementation completed for consistency with SuperSlope indicator)
**Project Overview:** This document tracks all source files, documentation, and key information for the MT5 Equity Curve Project.

---

## 1. Project Overview

A brief, high-level description of the project, its goal, and its architecture (MVC pattern).

- Epic 1 involves creating a MetaTrader 5 indicator that plots the strength of FX pairs (and other markets) based on a custom (LWMA & ATR) calculation. This is now complete.
- Epic 2 involves creating a MetaTrader 5 indicator that displays a real-time dashboard categorizing multiple forex symbols into strength buckets based on a custom (LWMA & ATR) calculation. This is starting now.
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
| **0.1.9** | 2025-08-26 | Claude | MVC integration complete, SuperSlopeDashboard.mq5 v1.0 delivered for full integration and acceptance testing |
| **0.2.0** | 2025-08-27 | Claude | Fixed ERR_INDICATOR_NO_DATA issue by replacing indicator handles with manual price data calculations |

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


### **Project Plan: Multi-Market Strength Dashboard (Integrated Calculation)**

**Objective:** To develop a fully functional MT5 dashboard indicator through an iterative process of LLM-driven development and human-led testing.
**Development Methodology:** Agile/Iterative, with a focus on discrete, testable components.
**Roles:**
*   **LLM (Developer):** Writes code for specified components based on detailed instructions and context.
*   **Human (Tester/Manager):** Provides context, defines tasks, runs tests, provides feedback, and conducts final acceptance testing.

---

DONE - ### **Phase 0: Project Setup & Foundation**
**Objective:** Establish the shared context and development environment.
- [x] **Task 0.1 (Human):** Create the `project_context.md` file (as described previously) and make it accessible to the LLM.
- [x] **Task 0.2 (Human):** Create a new blank MetaTrader 5 Indicator file (`SuperSlopeDashboard.mq5`) and a dedicated include folder for the project.
- [x] **Task 0.3 (LLM):** Generate the basic structure for the main indicator file, including the `#property` directives, `OnInit()`, `OnDeinit()`, `OnCalculate()` skeleton, and input parameters for thresholds, MA/ATR periods, and symbol list. *(This provides a scaffold to build upon)*.
	- [x] **Deliverable:** `SuperSlopeDashboard.mq5` (v0.1)

---

DONE - ### **Phase 1: Development of the Model (`CDataManager` Class)**
**Objective:** Create and unit-test the core calculation engine.

- [x] **Iteration 1.1: Core Class Structure**
	- [x] **Task 1.1.1 (LLM):** Write the `CDataManager` class skeleton in an include file. It should have private attributes for `MA_Period` and `ATR_Period`, a constructor to set them, and the stub for the `CalculateStrengthValue` method.
*   **Deliverable:** `CDataManager.mqh` (v0.1) - Created with basic structure, needs include path fixes

- [x] **Iteration 1.2: Implementation of Calculation Logic**
*   **Task 1.2.1 (LLM):** Implement the `CalculateStrengthValue(string symbol)` method. The logic must:
    1.  Use `CopyClose()`, `CopyHigh()`, `CopyLow()` to get sufficient historical data for the requested `symbol`.
    2.  Calculate the SMA of the closes.
    3.  Calculate the ATR.
    4.  Return the value `(close[0] - SMA[0]) / ATR[0]`.
*   **Deliverable:** `DataManager.mqh` (v1.0 - feature complete)

- [x] **Iteration 1.3: Unit Test Creation** - DONE
*  [x]  **Task 1.3.1 (LLM):** Write a standalone test script (`Test_DataManager.mq5`) that:
    *   Includes `DataManager.mqh`.
    *   Creates an instance of `CDataManager` with hardcoded parameters (e.g., MA=20, ATR=14).
    *   Calls `CalculateStrengthValue` for a major symbol like "EURUSD".
    *   Prints the result to the log (`Print("Strength for EURUSD: ", result)`).
*  [x]  **Deliverable:** `Test_DataManager.mq5`

- [x] **Iteration 1.4: Unit Testing & Feedback Loop**
- [x] *   **Task 1.4.1 (Human):** Compile and run `Test_DataManager.mq5` on a chart.
- [x] *   **Task 1.4.2 (Human):** **Unit Test:** Verify the calculation is correct by manually checking the latest candle's close, SMA(20), and ATR(14) on the EURUSD chart. The script's output should match `(Close - SMA) / ATR`.
- [x] *   **Task 1.4.3 (Human):** Provide feedback to the LLM (e.g., "Calculation is correct" or "There's a bug, the value is off by X").
- [x] *   **Gate:** Proceed to Phase 2 only after the Model passes unit testing.

---

COMPLETED ✅ ### **Phase 2: Development of the View (`CRenderer` Class)**
**Objective:** Create and unit-test the dashboard rendering engine.

DONE - **Iteration 2.1: Core Class Structure & Constants**
*   **Task 2.1.1 (LLM):** Write the `CRenderer` class in an include file. It should have private attributes for X/Y start positions, an array for column colors, and methods `DrawDashboardHeaders()`, `Draw()`, `DeleteAllObjects()`, and `DrawSymbolRow()`.
*   **Deliverable:** `CRenderer.mqh` (v0.1)

DONE - **Iteration 2.2: Implementation of Rendering Methods**
*   **Task 2.2.1 (LLM):** Implement the rendering methods. Use `ObjectCreate` and `ObjectSetString` to draw text labels. Use a consistent naming convention for objects (e.g., `"SSD_"+object_type+"_"+symbol_name`).
*   **Deliverable:** `CRenderer.mqh` (v1.0 - feature complete)

DONE - **Iteration 2.3: Unit Test Creation**
*   **Task 2.3.1 (LLM):** Write a standalone test script (`Test_Renderer.mq5`) that:
    *   Includes `CRenderer.mqh`.
    *   Creates a static, hardcoded data structure (e.g., an array of 5 lists, each containing 2-3 dummy symbol data).
    *   Creates an instance of `CRenderer` and calls its `Draw` method with this fake data.
*   **Deliverable:** `Test_Renderer.mq5`

DONE - **Iteration 2.4: Unit Testing & Feedback Loop**
*   **Task 2.4.1 (Human):** Compile and run `Test_Renderer.mq5` on a chart. ✅ PASSED
*   **Task 2.4.2 (Human):** **Unit Test:** Visually verify that a dashboard with five columns and sample data (e.g., "TEST_SYM 1.23") is drawn correctly on the chart. Ensure no errors are thrown and the panel is deleted cleanly when the script is removed. ✅ PASSED
*   **Gate:** Proceed to Phase 3 after the View passes unit testing. ✅ GATE CLEARED

---

DONE ### **Phase 3: Development of the Controller (`CDashboardController` Class)**
**Objective:** Create the logic that orchestrates the Model and View.

DONE - **Iteration 3.1: Core Class Structure & Data Handling**
*   **Task 3.1.1 (LLM):** Write the `CDashboardController` class in an include file. It must hold instances of `CDataManager` and `CRenderer`, manage the list of symbols, and have an `Update()` method (to be called from `OnCalculate`).
*   **Deliverable:** `CDashboardController.mqh` (v0.1) ✅ COMPLETED

✅ COMPLETED - **Iteration 3.2: Implementation of Business Logic**
*   **Task 3.2.1 (LLM):** Implement the core `Update()` method. It must:
    1.  Loop through all symbols in the configured list.
    2.  For each symbol, call `dataManager.CalculateStrengthValue()`.
    3.  Categorize the result into one of five strength groups based on `Threshold_1` and `Threshold_2`.
    4.  Store the symbol, its value, and its trend direction.
    5.  Sort each group.
    6.  Call `renderer.Draw()` with the final sorted data.
*   **Deliverable:** `CDashboardController.mqh` (v1.0 - feature complete) ✅ COMPLETED

DONE - **Iteration 3.3: Integration Test Creation**
*   **Task 3.3.1 (LLM):** Update the main `SuperSlopeDashboard.mq5` file to `#include` all three class files. In `OnInit()`, create instances of the three classes and initialize them. In `OnCalculate()`, call the controller's `Update()` method. ✅
*   **Deliverable:** `SuperSlopeDashboard.mq5` (v1.0 - integrated) ✅

---

### DOING
### **Phase 4: Integration Testing & Bug Fixing**
**Objective:** Combine all components and test them as a whole system.
DONE *   **Task 4.1 (Human):** Compile and load the integrated `SuperSlopeDashboard.mq5` indicator onto a chart.
*   **Task 4.2 (Human):** **Integration Test:**
  Done  *   **Test 1 (Functionality):** Does the dashboard appear? Does it show multiple symbols? Are they in the correct columns based on their strength value?
  **  *   **Test 2 (Configuration):** Change the `MA_Period` input. Does the dashboard update and recalculate values?
* [ ] Yes it does but it is not using the LWMA (i.e. it dos not match the slopestrength indicator)
    *   **Test 3 (Robustness):** Add a non-existent symbol (e.g., "FOOBAR") to the symbol list. Does the indicator handle the error gracefully without crashing? (It should skip it and perhaps print a warning).
*   **Task 4.3 (Human):** Log any bugs or unexpected behavior and provide feedback to the LLM.
*   **Task 4.4 (LLM):** Fix identified bugs iteratively.
*   **Gate:** Proceed to Phase 5 after the indicator passes basic integration testing.
**
---

### ToDo
### **Phase 5: Acceptance Testing (Against User Stories)**
**Objective:** Verify the complete system meets the original requirements.
*   **Task 5.1 (Human):** Execute **Acceptance Tests** based on the "Acceptance Criteria" from the User Stories (Sprint 1: MVP).
    *   **US 1:** Are the five columns with correct headings visible?
    *   **US 2:** Does it display real symbols and their calculated `n` values, sorted correctly within columns?
    *   **US 3:** Does it update on every new tick?
*   **Task 5.2 (Human):** Provide final sign-off.

---

### **Phase 6: Future Enhancement Cycles**
*   **Cycle A (User Configuration):** Implement the input parameters for thresholds and symbol selection (Sprint 2 stories).
*   **Cycle B (Polish & UX):** Implement color customization, trend arrows, and advanced error handling (Sprint 3 stories).
*   Each cycle would follow the same pattern: **Task Definition (Human) -> Implementation (LLM) -> Unit/Integration Test (Human) -> Feedback.**
---

### Known Issues
* It would be useful to show the threshold in the heading for each column e.g. Strong Bull (>0.2) - based on the user input.
* It would be useful to have an arrow next to the pair value showing the change since the previous bar - up to down - user option.
* It would be useful to be multi-timeframe enabled - i.e. 
* Too many logs in the log file - this can be reduced.

### Recent Updates
- **2025-08-27**: Fixed SMA/LWMA inconsistency - CDataManager now uses Linear Weighted Moving Average (LWMA) via built-in iMA() function with MODE_LWMA parameter, ensuring consistency with the main SuperSlope indicator
- **2025-08-27**: Updated CDataManager to use indicator handle management for better performance and consistency
