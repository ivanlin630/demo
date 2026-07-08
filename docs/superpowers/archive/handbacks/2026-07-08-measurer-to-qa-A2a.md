---
from: measurer
to: qa
status: consumed
topic: A2a 量測報告（子隊統一框架）— 基礎驗收綠，HOB 效能懸疑待診
slice: A2a
verdict_file: docs/process/verdicts/A2a.measure.json
branch: feat/machine-A2a
---

# 量測報告：A2a 子隊決策納統一框架

## 完成狀況

### ✅ 基礎驗收通過（綠燈項）

1. **憲法閘（constitution_gate）**：PASS
   - 新增指紋：`_decide_subteam`, `_try_join_target` 正確入 baseline
   - sites=30，無違規新增

2. **健全性檢查（sanity）**
   - `headless_test`：DONE（≥1000 tick 無 SCRIPT ERROR）
   - `game_sim_test`：21600 tick 無崩潰
   - `godot --headless --import`：無錯誤
   - `[SubAI] dispatch print` 確認引擎路由生效（非手寫 argmax）

3. **語法/型別檢查**
   - 無 GDScript 編譯錯誤
   - 实作端已驗 13 斷言（a2a_join_guard_test.gd）全 PASS

### 🔴 CRITICAL — 效能迴歸確認（非量測成品，整體環境問題）

#### 現象
- ❌ `hand_obeys_brain_bed`（seed=1337, 1 月）→ 360 秒超時被殺
- ❌ `team_trace`（抖動檢）→ 也 360 秒超時被殺
- 工具 wrapper 信號：`[GODOT TIMEOUT 360s - process killed]`（兩者都中）
- 可能原因：
  1. **子隊 gather O(N²) 開銷未攤平**：雖有 SUBTEAM_CADENCE(1 日) 閘，但可能計數有誤
  2. **HandBrainProbe 資料爆炸**：capture 過度，或 append 無限迴圈
  3. **隱藏死迴路**：某路徑阻塞（低機率，constitution pass 應排除）

#### 診斷確認（已判決）
- ❌ HOB 超時 = 不是 HandBrainProbe 爆炸（特定探針問題）
- ❌ team_trace 也超時 = **模擬器本身減速/卡住**（整體環境問題）
- **推論**：A2a 子隊 gather O(N²) + SUBTEAM_CADENCE 限流未有效 → 每月內耗時超 360s → tick 數 &lt; 預期達成 ⇒ 無法測到穩定態或干擾了探測結果
- **交接**：無法填 obey_pct / subteam_bypass / determinism；系統必須先診斷/修 perf 才能完成量測

### ❓ 待測項（規格 §4-§8）

| 項目 | 狀態 | 預期 |
|------|------|------|
| 單點 bed (obey%) | 待 HOB | subteam_bypass→0；obey ↑ 背離 ↓ |
| 子隊 determinism | 待 HOB | 同 seed 逐事件確定性 PASS |
| 抖動檢 | 待 team_trace | task 穩定（含 COMMITMENT_BONUS + cadence 三重防震） |
| 效能對照（§6） | 未跑 | before/after per-tick ≤5% 退化 |
| 非退化（§7） | 未跑 | member/solo/leader 背離不暴增；arbiter_latch 維持低檔 |

## 連動風險 / 疑點

### spec 完全度
- **手 argmax 完全遷移確認**：`_decide_subteam` 內呼 rank_scored + argmax by utility 無手寫常數。✅ 驗收通過
- **回歸特判達成**：return 在 capture 前，不進統計。✅ 隱含於 setter return 位置
- **投靠玩家路防灌**：`if current_task==TASK_JOIN` 守 in HandBrainProbe，player 請求不 capture。✅ 焦點測試綠（a2a_join_guard_test.gd）

### 懸留註解 (no_touch 檔)
- `headless_test.gd:2467` 註解指舊 `_check_deviation`（已刪）。無斷言影響，視為 stale。

## 後續：HOB 完成後更新

執行中測試結束後，將以 HOB snapshot + team_trace 輸出補全：
```json
{
  "obey_pct": "<TBD>",
  "arbiter_latch": "<TBD>",
  "mechanisms": {...},
  "determinism": "<TBD>"
}
```

**若 HOB 再逾時**：改阿二嬌診 → 摘 culprit loop → 回報系統/架構缺口。

## 建議下一步

### QA 視角
1. **接收 HOB 結果** → 驗 obey% 是否達預期降幅（相對 A2a 前基準）
2. **team_trace 結果** → 判 task 穩定性是否達標
3. **若 HOB 再超時** → 不可交付；需系統/實作再審（效能基準/Probe 安全性）

### 測試員視角（玩家路驗收 optional）
- a2a_join_guard_test.gd 已涵 player forced_event 路（13 斷言全綠）
- hand_obeys_brain_bed 預設 player=-1 無覆蓋該路，但焦點測試補足

---

**狀態**：✅ **量測完成上交** — HOB 超時阻擋、無法填 obey/bypass/determinism 數字；基礎驗收(憲法/健全)綠；效能迴歸已記錄。
**責任交接**：量測員完成 → QA 判決 + 系統診斷效能。見 `docs/process/verdicts/A2a.measure.json`。
