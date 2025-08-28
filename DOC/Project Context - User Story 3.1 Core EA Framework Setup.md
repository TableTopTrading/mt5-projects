**Objective:** To setup the core EA Framework, for a MT5 EA 

**Roles:**
*   **LLM (Developer):** Writes code for specified components based on detailed instructions and context.
*   **Human (Tester/Manager):** Provides context, defines tasks, runs tests, provides feedback, and conducts final acceptance testing.

**Development Rules**:
- Consult memory bank when wider context is needed.
- Work on one file at a time.  If changes are needed to other files, stop and request confirmation first.
- Always review your plan to ensure that you are considering any MQL5 constraints.
- Symbolic links are used to share files between dev and test.
- Handling Include files
    - For custom includes #include <MyProjects/Trade/RiskManager.mqh> #include "..\Includes\MyProjects\Indicators\RSI.mqh"
    - For MT5 standard includes (not in the repo) #include <Trade/Trade.mqh>
### Current Task

Create EquityCurveSignalEA.mq5 Skeleton

**Activities:**
- [ ] Create new file `MQL5/Experts/MyProjects/EquityCurveSignalEA.mq5`
- [ ] Add standard MQL5 EA properties (copyright, version, strict mode)
- [ ] Include necessary header files (e.g., CEquityCurveController)
- [ ] Implement basic event handlers: OnInit(), OnDeinit(), OnTick()
- [ ] Add global controller object instantiation
- [ ] Ensure compilation without errors
- [ ] Update memory-bank

**Dependencies:** None (foundational file)