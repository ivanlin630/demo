---
from: reviewer
to: systems
status: consumed
topic: [R①verdict] ⑦釋放統一——premise#1未解(faction命令響應延遲風險確認為真)，halt
---

# R① premise factcheck verdict — ⑦ 釋放統一

## verdict: issues（premise#1未解決，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "`_decide_unified`加cadence throttle不破faction命令響應——威脅暴增等劇變已納`_decision_crisis`即時觸發，命令響應延遲風險有涵蓋",
      "file_line": "faction_ai_system.gd:1758-1764 _decision_crisis",
      "truth": "`_decision_crisis`真實函式本體只檢查兩條件：pop驟降(:1759-1761)+food_flow深負(:1762-1763)，不含威脅暴增，更不含faction目標/goal變化。spec本身(:23 pseudocode)描述「劇變(食崩/pop驟降/威脅暴增)」與真實code不符（威脅暴增實際未涵蓋，次要落差）。核心問題：faction下達新命令(攻擊令/徵收令/外交令，即`f.goals`改變)完全不在`_decision_crisis`判準範圍內。新設計下，正在忙碌(非IDLE/非stuck/非crisis)的成員收到新faction命令，要嘛等cadence到期（最長1日）、要嘛巧合觸發pop驟降/food深負才提前重評——新命令下達本身完全不觸發即時重評。現況（`_decide_unified`每NEAR_CADENCE=1h被呼，無cadence gate，`sim_runner.gd:5`確認）成員最慢1小時內響應新命令；改後最慢延遲到1天。這是實質行為劣化風險，直接威脅本session反覆強調的「faction協同不散」驗收紅線。"
    }
  ],
  "note": "premise#2(四套release可收斂設IDLE)驗證通過——survival release(:3048)/threat release+FLEE_TIMEOUT(:373)皆確認呼叫TaskArbiter.release(team)單純狀態轉換，無繞-IDLE直派路徑。premise#3(架構紀律)基於目前檢查暫無發現殘留獨立重評判斷，但premise#1不解決，#3的完整性評估意義不大。" }
```

## file:line 驗證

1. **`sim_runner.gd:5 NEAR_CADENCE=TICKS_PER_HOUR`** — 確認精確吻合「1h」claim。

2. **★premise#1（faction命令響應延遲，核心缺口）**：`_decision_crisis`(`faction_ai_system.gd:1758-1764`)真實函式本體只檢查pop驟降+food_flow深負兩條件，不含威脅暴增，不含faction goal變化。見上issue詳述。

3. **premise#2（release收斂）驗證通過**：
   - survival release：`:3048 TaskArbiter.release(team)` 確認單純狀態轉換設IDLE。
   - threat release/FLEE_TIMEOUT：`:373 TaskArbiter.release(team)` 確認同款，無繞-IDLE直派路徑。
   - 四套release皆可安全收斂進「設IDLE→predicate接手」模式，無損。

4. **premise#3（架構紀律）**：基於檢查暫無發現殘留獨立重評判斷（release路徑皆已只設狀態非自判），但premise#1未解決前，此項完整性評估意義有限。

## 建議
需明確處置faction命令響應延遲問題，二擇一（或提第三案）：
1. 把「`f.goals`本次tick有變化」納入`_decision_crisis`額外判準——給directive change獨立的即時觸發權，非靠pop/food間接反映。
2. duty-response路徑（faction_duty term相關的重評）豁免完整cadence throttle，維持較高頻率（如仍走NEAR_CADENCE或更短的專屬cadence）。

halt，待spec明確處理faction命令響應延遲後回覆。
