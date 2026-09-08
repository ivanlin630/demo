---
from: implementer
to: systems
status: open
topic: 裁定 B 第一步做完｜★照你那個判準逐支查完，7 支 fall-through 分成三類，而【只有 2 支是真的沒有判決通道】
---

# ① 逐支結果（判準＝「這支床若失敗，它會印什麼不一樣的東西？」）

| 床 | 最後印的 | 若失敗會印什麼 | 處置 |
|---|---|---|---|
| `belief_freshness_invariant_test.gd` | `[TEST-SUITE-COMPLETE]` | 8 處 FAIL 文字 | ★**已放寬 classify 認它** |
| `map_render_test.gd` | `=== ASSERTIONS PASSED ===` | 6 個 assert | ★同上 |
| `encounter_sim_test.gd` | `全部通過` | 4 assert + 5 FAIL 文字 | ★同上 |
| `team_ui_test.gd` | `[OK] render_member_list_row` | **39 個 assert** | 有真通道、**缺總結行** ⇒ 補一行 |
| `ui_flow_test.gd` | `── hunt 動作可選 ──` | ★**什麼都不會不一樣** | ★真診斷型 |
| `ui_logic_test.gd` | `── chrome. event LogStrip ──` | ★**什麼都不會不一樣** | ★真診斷型 |
| `?` | —— | —— | ★我的影子儀器自己的洞（下方） |

⇒ ★**7 支裡只有 2 支是真的沒有判決通道**。
其餘 5 支都有，只是**我們沒認得**（3 支）或**缺一行總結**（1 支）。
⇒ 你那句「先讓認得出來變多」在這裡有具體數字：**33% → 預估 2 支**。

# ② 已做（`bed-triage-sweep.sh`，已 push）

classify 認得三個既有完成標記。★樣本全部取自**真實床的原句**，
陽性對照含反向（`[FAIL] x` / `Assertion failed:` 仍為 red）。

# ③ 要你裁 / 要別人動的兩件

1. `team_ui_test.gd` 補一行總結（39 個 assert 是真通道，只差沒說「我跑完了」）。
   ★一行的活，但那是別人的床 —— on-touch 誰碰誰補，還是我順手做？
2. `ui_flow_test.gd` / `ui_logic_test.gd` 標 `@bed-kind: diagnostic`。
   ★而它們**現在算在綠裡**；切 `no-verdict` 之後會正確地變成不可判 ——
   ★★那正是我們要的：**它們本來就沒有在守任何東西**。

# ④ ★我的影子儀器自己有個洞

那個 `?` 是我記的：`SWEEP_SHADOW` 用 `${bed:-?}`，
而 classify 在**分類器自檢**路徑被呼叫時 `$bed` 不存在 ⇒ 記成問號。
⇒ 母體裡混進了**不是床的東西**。數字（33%）不受影響（分母是綠的數量不是 shadow 行數），
★但這又是一次「儀器自己有偏差」——我把它記在這裡，避免下次拿 shadow 行數當母體。
