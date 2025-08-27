**Objective:** To develop a fully functional MT5 dashboard indicator through an iterative process of LLM-driven development and human-led testing.  We are now in Phase 2 of the project - Development of the View (CRenderer Class).

**Development Methodology:** 
Agile/Iterative, with a focus on discrete, testable components.

**Roles:**
*   **LLM (Developer):** Writes code for specified components based on detailed instructions and context.
*   **Human (Tester/Manager):** Provides context, defines tasks, runs tests, provides feedback, and conducts final acceptance testing.

**Development Rules**:
- Use the Project Manifesto - Equity Curve Trading.md file when wider context is needed.
- We will work on one file at a time.  If changes are needed to other files, stop and request confirmation first.
- Always create a plan of actions for confirmation.
- Always review your plan to ensure that you are considering any MQL5 constraints.
- Request clarification if something is not clear.
- Symbolic links are used to share files between dev and test.
- Handling Include files
    - For custom includes #include <MyProjects/Trade/RiskManager.mqh> #include "..\Includes\MyProjects\Indicators\RSI.mqh"
    - For MT5 standard includes (not in the repo) #include <Trade/Trade.mqh>

- The SuperSlopeDashboard indicator file can be found C:\Users\calmo\OneDrive\Documents\Development\mt5-projects\MQL5\Indicators\MyProjects\SuperSlopeDashboard

### Current Task

There is an inconstancy in the slope strength results.  For example, with user settings the same on both the SuperSlope and the SuperSlopeDashboard indicators, I would expect the same result.  Instead the Superslope result for the current chart pair e.g. USDJPY pair is a close (but not accurate) match to the SuperSlopeDashboard result, while other pairs are displaying very strange results e.g. large positive or negative values.  