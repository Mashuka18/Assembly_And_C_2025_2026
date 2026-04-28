# Secure Parameter Passing & Summation (m68k to x86_64 Port)

**Author:** Mariia Vanaga  
**Student ID:** C00313153  
**Platform:** Linux x86_64  
**Assembler:** NASM  

---

## 1. Project Overview
This project demonstrates the architectural migration of a legacy assembly application from the **Motorola 68000** (m68k) to modern **x86_64**. The program implements a 3-iteration running sum with "Expert-Level" security features, including strict input validation and overflow recovery.

### Core Functionality:
* **Three-Loop Running Sum:** Accumulates totals over three pairs of user-inputted numbers.
* **Secure Input Parsing:** Custom `read_int_secure` function filters every byte of input.
* **Overflow Protection:** Proactive use of CPU condition flags (`JO`) to prevent integer wrap-around.
* **C-Assembly Hybrid Testing:** Integrated unit testing using a C driver and automated Makefile logic.

---

## 2. Architectural Considerations & Mapping

### Register Mapping Table
The migration required a strategic re-mapping of registers to comply with the 64-bit environment and the System V ABI calling convention:

| Feature / Register | m68k (Legacy) | x86_64 (Modern Port) | Purpose in this Project |
| :--- | :--- | :--- | :--- |
| **Accumulator** | D0 | **RAX** | Used for math results and return values. |
| **Argument 1** | Stack / D1 | **RDI** | First parameter for `register_adder`. |
| **Argument 2** | Stack / D2 | **RSI** | Second parameter for `register_adder`. |
| **Running Total** | D7 | **R12** | Preserved register for the 3-loop sum. |
| **Loop Counter** | D3 | **R13** | Tracks remaining iterations. |
| **Stack Pointer** | A7 | **RSP** | Current top of the stack. |

### Technical Challenges:
* **Calling Convention:** Unlike m68k, x86_64 passes the first six arguments via registers (`RDI`, `RSI`, etc.), which improves performance but requires careful register management.
* **Symbol Collision Handling:** To allow the C test suite to link with the assembly object, the `Makefile` uses `objcopy -L _start`. This localizes the assembly entry point, preventing conflicts with the C library's `main` while keeping `register_adder` globally visible.

---

## 3. Security & Validation Features
1. **Alphabet Rejection:** Proactively traps non-numeric ASCII characters to prevent parsing errors.
2. **Special Character Filtering:** Explicitly rejects negative signs (`-`) and decimal points (`.`) to enforce unsigned-only logic as per requirements.
3. **Memory Safety:** Implementation of the `.note.GNU-stack` section ensures the stack is non-executable (NX), defending against common buffer overflow exploits.

---

## 4. Test Plan & Cases

| Test ID | Input Scenario | Expected Result | Logic Verified |
| :--- | :--- | :--- | :--- |
| **TC-01** | Standard Digits (e.g., 50 + 100) | Output: 150 | Basic Arithmetic |
| **TC-02** | Alphabetic Input (e.g., "abc") | Error: Invalid input! | Input Sanitization |
| **TC-03** | Decimals/Negatives (e.g., 10.5, -5) | Error: Special chars not allowed! | Integer Integrity |
| **TC-04** | Large Number Overflow | Error: Arithmetic Overflow! | Bound Checking |
| **TC-05** | Empty Input (Enter key only) | Error: Invalid input! | Null Buffer Handling |

---

## 5. Installation & Execution

### Prerequisites
* `nasm` (Netwide Assembler)
* `gcc` (GNU Compiler Collection)
* `make` (Build Automation Tool)

### Commands
* **Build Everything:** `make`
* **Run Interactive Program:** `make run`
* **Run Automated C-Suite Tests:** `make test`
* **Clean Build Files:** `make clean`
