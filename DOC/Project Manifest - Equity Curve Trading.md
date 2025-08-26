
**Last Updated:** 2025-08-16
**Version:** 0.1.1 (Slope Strength Indicator complete. Project Initiation of Dashboard)
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
|           |      |         |        |         |              |
|           |      |         |        |         |              |
|           |      |         |        |         |              |
|           |      |         |        |         |              |
|           |      |         |        |         |              |

### 2.2 Test Files

| File Name | Type | Purpose | Status |
| :-------- | :--- | :------ | :----- |
|           |      |         |        |
|           |      |         |        |

### 2.3 Documentation

| File Name                                      | Purpose                                            |
| :--------------------------------------------- | :------------------------------------------------- |
| `PROJECT_MANIFEST.md`                          | (This file) The central registry for the project.  |
| `Project Context - SlopeStrength Dashboard.md` | Provides high-level context for developers (LLMs). |
|                                                |                                                    |
|                                                |                                                    |

---

## 3. Key Data Structures

A quick reference for the core data objects used in the code.
e.g.
*   **`Name`**
    *   `Attributes`: 
    *   `Methods`: 


---

## 4. Version History

A changelog to track progress and changes.

| Version   | Date       | Author | Description                             |
| :-------- | :--------- | :----- | :-------------------------------------- |
| **0.1.0** | 2025-08-25 | CM     | SlopeStrength Indicator completed       |
| 0.1.1     | 2025-08-26 | CM     | Project Initiation of Dashboard Project |
|           |            |        |                                         |
|           |            |        |                                         |

---

## 5. Backlog


### **Project Plan: Multi-Market Strength Dashboard (Integrated Calculation)**

**Objective:** To develop a fully functional MT5 dashboard indicator through an iterative process of LLM-driven development and human-led testing.
**Development Methodology:** Agile/Iterative, with a focus on discrete, testable components.
**Roles:**
*   **LLM (Developer):** Writes code for specified components based on detailed instructions and context.
*   **Human (Tester/Manager):** Provides context, defines tasks, runs tests, provides feedback, and conducts final acceptance testing.

---

### **Phase 0: Project Setup & Foundation**
**Objective:** Establish the shared context and development environment.
- [ ] **Task 0.1 (Human):** Create the `project_context.md` file (as described previously) and make it accessible to the LLM.
- [ ] **Task 0.2 (Human):** Create a new blank MetaTrader 5 Indicator file (`MultiMarketStrengthDashboard.mq5`) and a dedicated include folder for the project.
- [ ] **Task 0.3 (LLM):** Generate the basic structure for the main indicator file, including the `#property` directives, `OnInit()`, `OnDeinit()`, `OnCalculate()` skeleton, and input parameters for thresholds, MA/ATR periods, and symbol list. *(This provides a scaffold to build upon)*.
	- [ ] **Deliverable:** `MultiMarketStrengthDashboard.mq5` (v0.1)

---

### **Phase 1: Development of the Model (`CDataManager` Class)**
**Objective:** Create and unit-test the core calculation engine.

- [ ] **Iteration 1.1: Core Class Structure**
	- [ ] **Task 1.1.1 (LLM):** Write the `CDataManager` class skeleton in an include file. It should have private attributes for `MA_Period` and `ATR_Period`, a constructor to set them, and the stub for the `CalculateStrengthValue` method.
*   **Deliverable:** `DataManager.mqh` (v0.1)

**Iteration 1.2: Implementation of Calculation Logic**
*   **Task 1.2.1 (LLM):** Implement the `CalculateStrengthValue(string symbol)` method. The logic must:
    1.  Use `CopyClose()`, `CopyHigh()`, `CopyLow()` to get sufficient historical data for the requested `symbol`.
    2.  Calculate the SMA of the closes.
    3.  Calculate the ATR.
    4.  Return the value `(close[0] - SMA[0]) / ATR[0]`.
*   **Deliverable:** `DataManager.mqh` (v1.0 - feature complete)

**Iteration 1.3: Unit Test Creation**
*   **Task 1.3.1 (LLM):** Write a standalone test script (`Test_DataManager.mq5`) that:
    *   Includes `DataManager.mqh`.
    *   Creates an instance of `CDataManager` with hardcoded parameters (e.g., MA=20, ATR=14).
    *   Calls `CalculateStrengthValue` for a major symbol like "EURUSD".
    *   Prints the result to the log (`Print("Strength for EURUSD: ", result)`).
*   **Deliverable:** `Test_DataManager.mq5`

**Iteration 1.4: Unit Testing & Feedback Loop**
*   **Task 1.4.1 (Human):** Compile and run `Test_DataManager.mq5` on a chart.
*   **Task 1.4.2 (Human):** **Unit Test:** Verify the calculation is correct by manually checking the latest candle's close, SMA(20), and ATR(14) on the EURUSD chart. The script's output should match `(Close - SMA) / ATR`.
*   **Task 1.4.3 (Human):** Provide feedback to the LLM (e.g., "Calculation is correct" or "There's a bug, the value is off by X").
*   **Gate:** Proceed to Phase 2 only after the Model passes unit testing.

---

### **Phase 2: Development of the View (`CRenderer` Class)**
**Objective:** Create and unit-test the dashboard rendering engine.

**Iteration 2.1: Core Class Structure & Constants**
*   **Task 2.1.1 (LLM):** Write the `CRenderer` class in an include file. It should have private attributes for X/Y start positions, an array for column colors, and methods `DrawDashboardHeaders()`, `Draw()`, `DeleteAllObjects()`, and `DrawSymbolRow()`.
*   **Deliverable:** `Renderer.mqh` (v0.1)

**Iteration 2.2: Implementation of Rendering Methods**
*   **Task 2.2.1 (LLM):** Implement the rendering methods. Use `ObjectCreate` and `ObjectSetString` to draw text labels. Use a consistent naming convention for objects (e.g., `"MSS_"+object_type+"_"+symbol_name`).
*   **Deliverable:** `Renderer.mqh` (v1.0 - feature complete)

**Iteration 2.3: Unit Test Creation**
*   **Task 2.3.1 (LLM):** Write a standalone test script (`Test_Renderer.mq5`) that:
    *   Includes `Renderer.mqh`.
    *   Creates a static, hardcoded data structure (e.g., an array of 5 lists, each containing 2-3 dummy `CSymbolData` objects).
    *   Creates an instance of `CRenderer` and calls its `Draw` method with this fake data.
*   **Deliverable:** `Test_Renderer.mq5`

**Iteration 2.4: Unit Testing & Feedback Loop**
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
