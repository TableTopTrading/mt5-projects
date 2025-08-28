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

Decompose the user story below into a set of deliverables.
Produce a design of each technical component.
Identify the end user tests for each component.
Prioritise each to be delivered as a Sprint.
### User Story 3.1: Core EA Framework Setup

**As a** trader  
**I want** an EA framework that can run on demo accounts or in Strategy Tester  
**So that** I can generate equity curve signals without risking real capital

#### Acceptance Criteria:

- [ ] EA initializes correctly on demo accounts and Strategy Tester
- [ ] EA validates that it's not running on a live account (safety check)
- [ ] EA creates necessary file directories for output
- [ ] EA logs all initialization parameters for audit trail
- [ ] EA implements proper cleanup on deinitialization

#### Technical Tasks:

- Create `EquityCurveSignalEA.mq5` main file
- Implement `CEquityCurveController` class for orchestration
- Add account type validation
- Set up logging framework