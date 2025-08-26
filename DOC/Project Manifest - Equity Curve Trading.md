
**Last Updated:** 2025-08-26
**Version:** 0.1.6 (CRenderer class structure created)
**Project Overview:** This document tracks all source files, documentation, and key information for the MT5 Equity Curve Project.

---

## 1. Project Overview

A brief, high-level description of the project, its goal, and its architecture (MVC pattern).

- This first project involves creating a MetaTrader 5 indicator that plots the strength of FX pairs (and other markets) based on a custom (SMA & ATR) calculation. This is now complete.
- This project involves creating a MetaTrader 5 indicator that displays a real-time dashboard categorizing multiple forex symbols into strength buckets based on a custom (SMA & ATR) calculation. This is starting now.
- The next project is to develop an EA to trade a 'dummy' account which produces an Equity Curve.
- The next project is to develop an EA that consumes the Equity Curve EA's output, and trades a live account.

## 2. File Manifest

This section is the core of the document. It lists every file in the project with its purpose and status.

### 2.1 Core Source Files

| File Name | Type | Purpose | Status | Version | Dependencies |
| :-------- | :--- | :------ | :----- | :------ | :----------- |
| SuperSlope.mq5 | Indicator | Main indicator file for SuperSlope | Complete | 1.0 | CSuperSlope.mqh |
| CSuperSlope.mqh | Include | Implementation class for SuperSlope calculations | Complete | 1.0 | None |
| SuperSlopeDashboard.mq5 | Indicator | Dashboard indicator for market strength | In Progress | 0.1 | CSuperSlope.mqh, Arrays\ArrayString.mqh |
| CDataManager.mqh | Include | Data management class for dashboard | Complete | 1.0 | Trade\Trade.mqh, MovingAverages.mqh |
| CRenderer.mqh | Include | Dashboard visualization class | Complete | 0.1 | None |

### 2.2 Test Files

| File Name | Type | Purpose | Status |
| :-------- | :--- | :------ | :----- |
| Test_DataManager.mq5 | Script | Unit test for CDataManager class | Passed ✅ |

### 2.3 Documentation

| File Name                                      | Purpose                                            |
| :--------------------------------------------- | :------------------------------------------------- |
| `PROJECT_MANIFEST.md`                          | (This file) The central registry for the project.  |
| `Project Context - SlopeStrength Dashboard.md` | Provides high-level context for developers (LLMs). |
| `SuperSlope_User_Guide.md`                    | Complete user documentation for SuperSlope indicator |
| `Project Manifest - Equity Curve Trading.md`  | Project tracking and documentation for the full project suite |

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
*   **Purpose**: Manages data calculations for the strength dashboard
*   **Attributes**: 
    - `m_ma_period`: Moving Average period
    - `m_atr_period`: ATR period
    - `m_max_bars`: Maximum bars to calculate
    - `m_ma_buffer[]`: Buffer for MA values
    - `m_atr_buffer[]`: Buffer for ATR values
*   **Methods**: 
    - `Initialize()`: Sets up calculation parameters
    - `CalculateStrengthValue()`: Calculates strength value for a symbol using (close[0] - SMA[0]) / ATR[0]

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

### Planned Components

#### CDashboardController (Planned)
*   **Purpose**: Orchestrates the Model and View components
*   **Methods**: 
    - `Update()`: Main control loop for dashboard updates


---

## 4. Version History

A changelog to track progress and changes.

| Version   | Date       | Author | Description                             |
| :-------- | :--------- | :----- | :-------------------------------------- |
| **0.1.0** | 2025-08-25 | CM     | SlopeStrength Indicator completed       |
| 0.1.1     | 2025-08-26 | CM     | Project Initiation of Dashboard Project |
| 0.1.2     | 2025-08-26 | Claude | Implemented basic Dashboard structure   |
| 0.1.3     | 2025-08-26 | Claude | Completed CDataManager implementation   |
| 0.1.4     | 2025-08-26 | Claude | Created Test_DataManager script        |
| 0.1.5     | 2025-08-26 | Claude | CDataManager unit test passed (EURUSD: 1.0126) |
| 0.1.6     | 2025-08-26 | Claude | Created CRenderer class structure       |

---

## 5. Backlog


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
- [x] **Task 0.2 (Human):** Create a new blank MetaTrader 5 Indicator file (`MultiMarketStrengthDashboard.mq5`) and a dedicated include folder for the project.
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

Doing ### **Phase 2: Development of the View (`CRenderer` Class)**
**Objective:** Create and unit-test the dashboard rendering engine.

DONE - **Iteration 2.1: Core Class Structure & Constants**
*   **Task 2.1.1 (LLM):** Write the `CRenderer` class in an include file. It should have private attributes for X/Y start positions, an array for column colors, and methods `DrawDashboardHeaders()`, `Draw()`, `DeleteAllObjects()`, and `DrawSymbolRow()`.
*   **Deliverable:** `Renderer.mqh` (v0.1)

DONE - **Iteration 2.2: Implementation of Rendering Methods**
*   **Task 2.2.1 (LLM):** Implement the rendering methods. Use `ObjectCreate` and `ObjectSetString` to draw text labels. Use a consistent naming convention for objects (e.g., `"SSD_"+object_type+"_"+symbol_name`).
*   **Deliverable:** `CRenderer.mqh` (v1.0 - feature complete)

DONE - **Iteration 2.3: Unit Test Creation**
*   **Task 2.3.1 (LLM):** Write a standalone test script (`Test_Renderer.mq5`) that:
    *   Includes `CRenderer.mqh`.
    *   Creates a static, hardcoded data structure (e.g., an array of 5 lists, each containing 2-3 dummy symbol data).
    *   Creates an instance of `CRenderer` and calls its `Draw` method with this fake data.
*   **Deliverable:** `Test_Renderer.mq5`

DOING - **Iteration 2.4: Unit Testing & Feedback Loop**
*   **Task 2.4.1 (Human):** Compile and run `Test_Renderer.mq5` on a chart.
*   **Task 2.4.2 (Human):** **Unit Test:** Visually verify that a dashboard with five columns and sample data (e.g., "TEST_SYM 1.23") is drawn correctly on the chart. Ensure no errors are thrown and the panel is deleted cleanly when the script is removed.
*   **Gate:** Proceed to Phase 3 after the View passes unit testing.

---

### **Phase 3: Development of the Controller (`CDashboardController` Class)**
**Objective:** Create the logic that orchestrates the Model and View.

**Iteration 3.1: Core Class Structure & Data Handling**
*   **Task 3.1.1 (LLM):** Write the `CDashboardController` class in an include file. It must hold instances of `CDataManager` and `CRenderer`, manage the list of symbols, and have an `Update()` method (to be called from `OnCalculate`).
*   **Deliverable:** `DashboardController.mqh` (v0.1)

**Iteration 3.2: Implementation of Business Logic**
*   **Task 3.2.1 (LLM):** Implement the core `Update()` method. It must:
    1.  Loop through all symbols in the configured list.
    2.  For each symbol, call `dataManager.CalculateStrengthValue()`.
    3.  Categorize the result into one of five strength groups based on `Threshold_1` and `Threshold_2`.
    4.  Store the symbol, its value, and its trend direction.
    5.  Sort each group.
    6.  Call `renderer.Draw()` with the final sorted data.
*   **Deliverable:** `DashboardController.mqh` (v1.0 - feature complete)

**Iteration 3.3: Integration Test Creation**
*   **Task 3.3.1 (LLM):** Update the main `MultiMarketStrengthDashboard.mq5` file to `#include` all three class files. In `OnInit()`, create instances of the three classes and initialize them. In `OnCalculate()`, call the controller's `Update()` method.
*   **Deliverable:** `MultiMarketStrengthDashboard.mq5` (v1.0 - integrated)

---

### **Phase 4: Integration Testing & Bug Fixing**
**Objective:** Combine all components and test them as a whole system.
*   **Task 4.1 (Human):** Compile and load the integrated `MultiMarketStrengthDashboard.mq5` indicator onto a chart.
*   **Task 4.2 (Human):** **Integration Test:**
    *   **Test 1 (Functionality):** Does the dashboard appear? Does it show multiple symbols? Are they in the correct columns based on their strength value?
    *   **Test 2 (Configuration):** Change the `MA_Period` input. Does the dashboard update and recalculate values?
    *   **Test 3 (Robustness):** Add a non-existent symbol (e.g., "FOOBAR") to the symbol list. Does the indicator handle the error gracefully without crashing? (It should skip it and perhaps print a warning).
*   **Task 4.3 (Human):** Log any bugs or unexpected behavior and provide feedback to the LLM.
*   **Task 4.4 (LLM):** Fix identified bugs iteratively.
*   **Gate:** Proceed to Phase 5 after the indicator passes basic integration testing.

---

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
