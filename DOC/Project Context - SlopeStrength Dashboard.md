**Objective:** To develop a fully functional MT5 dashboard indicator through an iterative process of LLM-driven development and human-led testing.

**Development Methodology:** 
Agile/Iterative, with a focus on discrete, testable components.

**Roles:**
*   **LLM (Developer):** Writes code for specified components based on detailed instructions and context.
*   **Human (Tester/Manager):** Provides context, defines tasks, runs tests, provides feedback, and conducts final acceptance testing.

**Development Rules**:
- We will work on one file at a time.  If changes are needed to other files, stop and request confirmation first.
- Request clarification if something is not clear.
- Handling Include files
    - For custom includes #include <MyProjects/Trade/RiskManager.mqh> #include "..\Includes\MyProjects\Indicators\RSI.mqh"
    - For MT5 standard includes (not in the repo) #include <Trade/Trade.mqh>

- The SuperSlopeDashboard indicator file can be found C:\Users\calmo\OneDrive\Documents\Development\mt5-projects\MQL5\Indicators\MyProjects\SuperSlopeDashboard
### Current Task
**Objective:** Task 1.3.1 (LLM):** Write a standalone test script (`Test_DataManager.mq5`) that:
    *   Includes `DataManager.mqh`.
    *   Creates an instance of `CDataManager` with hardcoded parameters (e.g., MA=20, ATR=14).
    *   Calls `CalculateStrengthValue` for a major symbol like "EURUSD".
    *   Prints the result to the log (`Print("Strength for EURUSD: ", result)`).
*   **Deliverable:** `Test_DataManager.mq5`