# State Model — MT5 Trade Panel (Showcase)

This document describes the panel state machine, the allowed transitions, and how UI locking is applied to keep behavior deterministic and safe.

---

## 1. Purpose

The panel maintains an internal state to ensure:

- The UI cannot be edited while an order/position is active (prevents inconsistent parameters).
- Only valid actions are available at any moment (button enable/disable).
- Restoring state after reinit/timeframe change remains reliable.

---

## 2. Core states (v1)

The panel uses a simple three-state model for a single chart symbol:

### **S0 — IDLE**
No pending orders and no open positions for the current symbol.

- UI fields are **editable**
- Trade button can be enabled if inputs are valid
- SL/TP blocks can be toggled on/off
- Risk and SL/TP inputs are synchronized in all modes

Allowed actions:
- Set direction (Buy/Sell)
- Set order mode (Market/Limit/Stop)
- Edit Price/Lot/Risk/SL/TP
- Submit Trade

---

### **S1 — PENDING ORDER**
A pending order exists for the current symbol (Limit or Stop).

- UI is **locked** (or mostly locked, depending on implementation)
- The panel focuses on order safety and allows only safe operations

Allowed actions:
- **CLOSE** (delete the pending order)
- (Optional in v1) Update SL/TP if supported
- (Optional in v2) Modify entry/SL/TP directly

Notes:
- If the pending order is executed and becomes a position, the state moves to **S2** automatically.

---

### **S2 — ACTIVE POSITION**
An open position exists for the current symbol.

- UI fields are **locked**
- Only position management actions are allowed

Allowed actions:
- **BE** (breakeven) — only if position is in profit and SL is eligible for move
- **CLOSE** — close the position

Notes:
- When the position is closed, the state returns to **S0**.

---

## 3. State detection (source of truth)

The panel polls the terminal trade context for the current symbol to update
button states and PnL on each tick. UI locking is applied when an order is
placed via the panel and released on CLOSE; external orders may update buttons
but do not automatically lock the UI on reinit.

---

## 4. Transition diagram (ASCII)

```text
           +-------------------+
           |      S0 IDLE      |
           | (editable fields) |
           +---------+---------+
                     |
                     | Trade submitted
                     | (Market)
                     v
           +-------------------+
           | S2 ACTIVE POSITION|
           |   (UI locked)     |
           +----+---------+----+
                |         |
                | CLOSE   | BE (if eligible)
                |         |
                v         v
           +-------------------+
           |      S0 IDLE      |
           +-------------------+


From S0:
  Trade submitted (Limit/Stop)
           |
           v
   +-------------------+
   |  S1 PENDING ORDER |
   |   (UI locked)     |
   +----+---------+----+
        |         |
        | CLOSE   | Executed by market
        |         |
        v         v
   +---------+   +-------------------+
   |  S0 IDLE|   | S2 ACTIVE POSITION|
   +---------+   +-------------------+
```

## 5. UI locking rules

### 5.1 Editable fields in **S0 (IDLE)**

Editable:
- Direction switch (Buy / Sell)
- Order mode (Market / Limit / Stop)
- Entry price
- Lot / Risk (% and $)
- SL / TP enable checkboxes
- SL / TP values (Ticks / Price / ATR)

---

### 5.2 Locked behavior in **S1 (PENDING ORDER)**

Locked:
- Direction
- Order type
- Risk / Lot
- SL / TP setup inputs

Enabled:
- **CLOSE** (delete pending order)

Optional:
- Update SL / TP for the pending order via a dedicated action (not implemented)

---

### 5.3 Locked behavior in **S2 (ACTIVE POSITION)**

Locked:
- All trade setup inputs (direction, type, price, risk, lot, SL / TP setup blocks)

Enabled:
- **BE** (only if profit condition is met)
- **CLOSE** (close position)

---

## 6. Button enable / disable rules

### 6.1 Trade button

Enabled only in **S0 (IDLE)** when all inputs are valid.

Validation examples:
- Lot > 0 and normalized to broker step
- Market mode: entry price is auto (Bid / Ask)
- Limit / Stop mode (current implementation uses Bid for Buy checks and Ask for Sell checks):
  - Buy Limit: entry < Bid
  - Buy Stop: entry > Bid
  - Sell Limit: entry > Ask
  - Sell Stop: entry < Ask
- SL / TP validity is not enforced beyond basic price calculations.

---

### 6.2 BE button

Enabled only in **S2 (ACTIVE POSITION)** if:
- a position exists
- position is in profit (or above a minimal threshold)
- No broker stop‑level checks are applied before the move.

---

### 6.3 CLOSE button

Enabled in **S1 (PENDING ORDER)** and **S2 (ACTIVE POSITION)** if:
- a pending order or position exists for the current symbol

---

## 7. Persistence and restore

The panel stores selected UI parameters using **Global Variables**:
- last selected order mode and trade direction
- risk %, risk $, lot, entry price
- SL / TP values (ticks, price, ATR)
- SL / TP enable flags
- panel position (x1, y1, x2, y2)

State restoration rules:
- UI values are restored regardless of current orders or positions.
- Order/position existence is reflected in button states on ticks.

---

## 8. Out of scope (v2+)

The following extensions are intentionally excluded from v1:
- Partial close workflows
- Trailing stop logic
- Multi-symbol position grids
- MagicNumber-based position filtering

---

## 9. Summary

The state model is intentionally simple and deterministic:
- **S0 (IDLE)** — setup and submit trades
- **S1 (PENDING ORDER)** — manage or cancel pending orders
- **S2 (ACTIVE POSITION)** — manage open positions

This structure ensures predictable behavior, UI safety, and clean extension paths.
