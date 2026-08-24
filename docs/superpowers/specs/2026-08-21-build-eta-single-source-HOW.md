---
slice: build-eta-single-source
tier: full
qa: required   # ★2026-08-25 systems 自糾：原標 probe 是判錯維度（見 01_architect「tier 判準」）
from: systems
topic: 工期單一真相源 —— 六份公式三種答案差 240 倍,改接線非改數值
---

# 工期單一真相源

**來源**：`docs/estimator-ledger.md §E`（**六份獨立公式、三種答案、極端相差 240 倍**）。
★**本刀是〈估算器禁手抄物理〉的第一個正式應用**，也是 `estimator-lineage-scan.sh` **規則2 轉綠**的條件。

## §1 真值（唯一權威）
`outpost_system.gd:311` `ticks_left -= max(pop,1)`，掛 **`LOD_NEAR`**（`sim_runner.gd:153`）、
`NEAR_CADENCE = TICKS_PER_HOUR = 10`
⇒ **每日執行 `TICKS_PER_DAY / NEAR_CADENCE` ＝ 24 次**
⇒ **`days = ticks / (pop × 24)`**

## §2 要做的事
新增**單一 accessor**（掛在施工推進的擁有者 `OutpostSystem` 上）：
```
build_eta_days(ticks_left: int, pop: int) -> float
```
★**分母不得手抄 `24`** —— 必須由 **cadence 同源推導**（`TICKS_PER_DAY / NEAR_CADENCE`）。
**驗收標準**：若日後 `outpost_tick` 改掛 `LOD_FAR`，**六處估值自動跟著改**。

## §3 六個呼叫點全部改接線（窮盡，見 §E 表）
| # | 站點 | 現況 |
|---|---|---|
| 1 | `goal_resolver.gd:526,539` `BUILD_DAYS_EST` | flat 3.0 天 |
| 2 | `decision_context.gd:335` `settle_eta_days` | `CORVEE_DAYS + dist` |
| 3 | `persist_strength.gd:95` | `ticks_left ÷ pop`（漏 ÷24）＝ 高估 24× |
| 4 | `faction_ai_system.gd:3799` `_eta_build` | 同上，高估 24× |
| 5 | `faction_ai_system.gd:4548` | `÷ pop ÷ 240` ＝ 低估 10× |
| 6 | `decision_context.gd:364` | `÷ 240`、**連 pop 都沒除** |

★**#5 的閘（求生蓋田「蓋得完才蓋」）修好後語意會變嚴**——**那是修對了，不是回歸**。
★**harm 未坐實**（C6-#3：閘確認誤放，但 30/3785 樣本沒抓到受害者）——
**修法理由是正確性，不是已證明傷害**；帳上不得升格。

## §4 驗收
- `estimator-lineage-scan.sh` **規則2 轉綠**（目前紅，三處域外手抄）
- 各站行為變化**照實列**：#3/#4 由高估 24× 轉正 ⇒ **持守與糧橋會變寬鬆**，
  #5/#6 由低估 10× 轉正 ⇒ **求生蓋田閘會變嚴**。**這些都是 intended-change，要在 handback 標明。**
- `det×3` fp **預期會變**（估值變 ⇒ 決策變）⇒ **intended-change，非 regression**

## §5 閘
`headless` ／ `det×3`（intended-change）／`constitution_gate` ／ `seam-gate`（HARD）／
★`estimator-lineage-scan.sh` **規則2 必須綠**（本刀的存在理由）
