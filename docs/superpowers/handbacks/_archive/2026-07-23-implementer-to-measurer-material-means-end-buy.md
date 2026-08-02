---
from: implementer
to: measurer
status: consumed
topic: material-means-end-buy — measure (Gate B chicken-egg 破，商隊買料 survival)
branch: feat/material-buy
commit: ca199844
spec: docs/superpowers/specs/2026-07-22-material-means-end-buy.md
---

# material means-end buy — 做完，量測請收

## 改動（3-part 閉環，破 Gate B）
Root: material need **只在已有 facility 時 fire** → builder 隊不帶 material need →
買不到料 → 建不了 weaponsmith/armorsmith。material trade under-supply latch（同
weaponsmith-HELD / market-seek-WITHDRAW / facility-buffer-ABANDON 收斂之真根）。

- `need_oracle._construction_facility_need`：means-end need。outpost 想建的
  facility(desire≥`CONSTRUCTION_DESIRE_MIN`=0.3) 折 material cost → 進 `need_keep`。
  **cost-guard 前置**（cost≤0 跳過，才呼 `_facility_deficit`）+ `CAP`=100 防疊爆。
  結構: build-cost res(material)∩facility-output res = ∅ → 無遞迴。
- `decision_context`：`has_material_market` + `material_shortfall` 欄 + gather。
- `options「買料」`（mirror 買糧）+ `terms buymaterial_drive` / `buymaterial` weight
  （商業非 value → 貪婪 scale 人格化）。TASK_TRADE，非 SURVIVAL_OPTION_SET（economic PRIO_DISPATCH）。
- `faction_ai._nearest_market_outpost_with(state,team,res)`：filter public_storage[res]>0。

## 自驗（皆綠）
- TDD 5/5 PASS（`material_buy_test.gd`）。RED 確認：neuter need_keep 整合 → ① 100.0→0.0 FAIL。
- headless 0-new：3 baseline fail（p2a join weight / combat_target 197 / rung intent）。
- gate PASS sites=75（新 option/term/`_facility_deficit` 呼叫**非新閘**）。
- determinism：seed 1337 × 2mo × 2 跑 byte-identical（MD5 `57f44e2a...`，純 utility 無 RNG）。

## 量測請抓（餵 QA 故事性判官）
1. **買料 DEAL**：0→? 筆（前無此 action，證 chicken-egg 真破）。
2. **post_buy.material**：買後庫存 material 有無真升。
3. **no_want 率**：想建 facility 卻 need_keep(material)=0 的隊比例（應降）。
4. **weaponsmith/armorsmith START→建成**：means-end 是否真導向建成（非空轉）。
5. **weapon 產出**：建成後武器有無真出（下游閉環）。
6. **doom-delta**：對敗北/殲滅曲線影響（正負皆記，勿掩）。
7. **owner-depletion**：買料來源市場 public_storage 有無被吸乾（供給端塌陷檢查，
   同 facility-buffer 教訓）。
8. **§④b bounded sample**：`Probe.bump_sample` 前 N 筆買料 decision specimen → QA
   讀「決策故事」（誰、缺多少、為建啥、買多少、cap 有無觸）。

床：`godot --path .worktrees/material-buy` 對 branch code 跑（★禁原地 checkout）。
做完 → to:QA（specimen + 數字）。

## HELD/待驗（背景，未阻此 slice）
- weaponsmith 0aa7d3ae（awaits Gate B）— 本 slice 是其真根修，可一併重測。
- god-view 1119 ab0c6e9d / followup 9e965631 — measurer 進行中。
