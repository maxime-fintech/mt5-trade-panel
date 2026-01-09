# Architecture Overview — MT5 Trade Panel

This is a short, practical overview of how the panel is structured and how the pieces interact.

---

## 1. Goals

- **Safe**: avoid inconsistent inputs while a trade is active
- **Deterministic**: calculations are centralized and repeatable
- **Modular**: UI, orchestration, and trading are kept separate
- **Extendable**: new features can be added without a rewrite

---

## 2. High‑level design

The project follows a lightweight MVC‑style split:

- **View**: builds the UI and renders state
- **Controller**: connects UI with calculations and trading actions
- **Calculations**: pure math (ATR, risk, SL/TP conversions)
- **Orders**: broker calls (market/limit/stop, BE, close)

---

## 3. Modules and responsibilities

### `src/panel_mt5.mq5`
Entry point. Wires MT5 lifecycle handlers to the controller and view.

### `src/modules/Panel_MT5_Controller.mqh`
Orchestrates the app:
- creates modules and connects them
- routes chart events and ticks
- coordinates View ↔ Calculations ↔ Orders
- loads saved values before UI creation

### `src/modules/Panel_mt5_View.mqh`
UI container class:
- holds UI elements
- exposes UI methods to other modules
- includes UI and logic submodules

### `src/modules/Panel_mt5_View_UI.mqh`
UI construction:
- creates buttons, labels, inputs, checkboxes
- defines layout and initial values
- draws chart objects (price/SL/TP lines)

### `src/modules/Panel_mt5_View_Logic.mqh`
UI event logic:
- handles clicks and text edits
- keeps linked fields in sync (risk %, risk $, SL/TP ticks/price/ATR)
- locks/unlocks controls during active trades

### `src/modules/Panel_MT5_Order.mqh`
Trading operations:
- sends Market / Limit / Stop orders
- manages pending order / position lifecycle
- applies BE and CLOSE actions
- updates button states and PnL label

### `src/modules/Panel_MT5_Calcul.mqh`
Math helpers:
- ATR calculation (via indicator handle)
- SL/TP conversions (ticks, price, ATR)
- risk ↔ lot calculations

### `src/modules/Panel_MT5_Types.mqh`
Shared enums:
- trade direction (Buy/Sell)
- order type (Market/Limit/Stop)

---

## 4. Data flow

### Tick flow
1. `OnTick()` → controller
2. controller updates orders module
3. controller updates view (prices, button states)

### UI action flow
1. `OnChartEvent()` → view logic
2. view logic updates local values and synchronizes fields
3. controller receives actions (Trade / BE / CLOSE)
4. orders module executes the operation

---

## 5. State model (practical)

The UI is locked only when a trade is placed through the panel.
When the trade is closed via CLOSE, the UI unlocks. External orders
can update button state and PnL but do not auto‑lock the UI.

For the full state description, see `docs/state-model.md`.

---

## 6. Persistence

The panel stores UI values in **Global Variables** and restores them on init:
- order mode and direction
- risk %, risk $, lot, entry price
- SL/TP values (ticks, price, ATR)
- SL/TP enable flags
- panel position (x1, y1, x2, y2)

---

## 7. Error handling and robustness

- Price values are normalized to symbol digits before sending orders.
- Lots are normalized to broker min/max/step.
- Limit/Stop buttons are enabled only when price conditions are valid.
- Trade errors are logged via MT5 result codes.

---

## 8. Extension points

Good candidates for v2+:
- MagicNumber filtering
- trailing stop / partial close
- multi‑symbol grid
- drag‑and‑drop chart lines
- trade history analytics

---

## 9. Summary

The architecture keeps UI, logic, calculations, and trade operations separate.
That makes the panel easier to reason about and safe to extend.
