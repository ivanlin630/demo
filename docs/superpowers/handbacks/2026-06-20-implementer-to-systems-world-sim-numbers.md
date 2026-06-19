---
from: implementer
to: systems
status: open
topic: 純 NPC 長期世界量測台 — 2 年全跑數字 + 90 天對照（emergent 魂仍未觸發）
---

# Hand Back: world_sim 長期世界量測台（2 年全跑）

plan `2026-06-20-world-sim-measurement.md` 全部 Task 完成。branch `feat/world-sim`。

## 實作摘要

- `config/world_sim.json`（新）：複製 game_sim_test 8 隊 archetype，**去 `player` + `command_schedule`**，`max_ticks=172800`（2 年）、`seed=77`、Team0 改名「統領城」。零欄位增刪。
- `scripts/debug/world_sim.gd`（新）：`extends SceneTree` 純 NPC 長跑量測迴圈。`player_pos=(-1,-1)`、encounter 逾時(>800)強制 draw、月取樣 TeamTrace/SpineTrace、每 240 tick `InvariantAudit.check`、世界全滅連 3 取樣提早收尾。`Probe.enabled` 開頭開、結尾還原 false。
- **零遊戲 code 改**。

### 與 plan 差異（1 處）
- plan harness 草稿寫 `InvariantAudit.run(...)`；實際 class 介面是 `InvariantAudit.check(state) -> Array[String]`（plan 已標「對齊既有」）→ 照實際用 `check`。

## 驗收結果

| 驗收項 | 結果 |
|---|---|
| 跑滿 max_ticks | ✅ 172800 全跑完，**無提早全滅**（8→3 隊存活） |
| SCRIPT ERROR | ✅ 0 |
| player_id=-1（無玩家 game_over 凍結） | ✅ 確認（無 `[WARN] player_id`）；世界全程推進不凍 |
| `[ProbeSummary]` 印 | ✅ |
| **長期 emergent 至少數項 >0** | ❌ **未達標**（見下，核心發現） |
| 不變量維持 | ⚠ 2138 violations，**單一型**：known_reputations 懸空死隊（見連動風險） |

架構命題成立：**config 無 player → `_setup_player` 早退（game_setup.gd:504）→ player_id=-1 → `event_system.gd:26` 玩家繼承閘 false → 不觸發絕後 game_over → 世界跑滿 2 年。**

## [ProbeSummary] 全表（2 年 = 172800 tick）

```
g1.order_placed      = 3873
g1.shortage_buy      = 2986
g2.ambition_demote   = 7
g2.ambition_promote  = 22
g3.detect_信假        = 31
g3.detect_生疑        = 2
g3.trust_down        = 5578
g3.trust_up          = 3228
g3.claim_peak    peak= 4.0
訂單履約率 = 0.0%
套利命中率 = n/a
scout 收斂率 = n/a
```

存活曲線（月）：8,6,5,5,6,6,6,6,6,7,6,6,5,5,5,5,4,4,4,4,4,4,4,**3**。緩降，無雪崩。
末態存活：T1(定居/商隊) food=39412、T2(武力/敵軍) food=55298、T3(定居/生產) food=44470；coin 540/325/600。
**食物巨量囤積**（無消耗/腐壞壓力 → 經濟半空轉，呼應首輪 G1 訂單不閉環）。

## 90 天對照（apples-to-apples，同 harness 無玩家，21600 tick）

> 註：首輪量測表（`...spine-measurement.md`）是 **game_sim_test 有玩家**場景。下表是我**用同一 world_sim harness 跑 90 天**（無玩家），與 2 年同條件比，分離「沒跑夠久」vs「真沒條件」。

| 訊號 | 90 天(無玩家) | 2 年(無玩家) | 判讀 |
|---|---|---|---|
| g1.order_placed | 572 | 3873 | 線性隨時間 ✓ |
| g1.shortage_buy | 440 | 2986 | 同上 |
| g1 履約率 | 0.0% | 0.0% | **仍不閉環**（首輪待裁#1，跑久不會自閉） |
| g2.ambition promote/demote | 8/3 | 22/7 | 階梯持續動 ✓ |
| g3.detect 信假/生疑/裁決 | 12/2/0 | 31/2/0 | **裁決恆 0**（首輪待裁#2，識破不發生） |
| g3.trust down/up | 309/142 | 5578/3228 | 持續 churn |
| g3.claim_peak | 3 | 4 | 撞 cap |
| **g2.faction_found** | **0** | **0** | ❌ 立國未觸發 |
| **g2.vendetta_trigger** | **0** | **0** | ❌ 復仇未觸發 |
| **g2.feud_formed** | **0** | **0** | ❌ 血仇未觸發 |
| **g3.scout_dispatch / converge** | **0** | **0** | ❌ scout 查證未觸發 |
| **g3.ambush** | **0** | **0** | ❌ 誘殺未觸發 |
| **g1.mint** | **0** | **0** | ❌ 鑄幣未觸發 |

（emergent 鍵全 0 → ProbeSummary 不列；已逐鍵確認 bump site 真存在於 faction_ai_system / npc_ai_system / outpost_system，非探針沒接。）

## 核心結論：emergent 魂 = 「真沒條件」非「沒跑夠久」

plan 驗收要 emergent 數項 >0 — **未達標**。但這是**有價值的負結果**：

- 2 年 = 90 天的 **8×** 時長，6 個 emergent 鍵（立國/復仇/血仇/scout/誘殺/鑄幣）**全程 0**。
- SpineTrace 全程佐證：所有 G2 edges 恆 `feud0/grat0/prot0/trust0`、`vendetta=-1`，2 年無一條社會連結成形。
- → 確定首輪待裁 **#3** 答案：**這些機制需專門觸發場景，預設 8 隊 config 永遠造不出條件**（不確定攻擊+偽裝+血仇對+立國路徑+鑄幣 outpost）。跑再久都不會自己長出來。
- 量測台本身達成 plan 真正目的：**證明「跑不夠久」不是主因**，把問題收斂到「缺場景」。

## 連動風險

- **`known_reputations` 懸空死隊（2138 violations，唯一型）**：隊伍 2 年內死亡（8→3），存活隊的 `known_reputations` 保留指向已移除死隊的 entry，從不清理 → `InvariantAudit._check_no_dangling_team_id` 連環報。
  - 90 天只 47 例、首輪 game_sim_test **完全沒抓到**（其 `_check_invariants_periodic` 不跑 InvariantAudit.check，較弱）→ 此 bug **長跑+強審計才現形**。
  - 行為上良性（對死隊的信用值不再被查），但記憶體單調增長 + 審計噪音。**建議列 known_issues**：隊伍移除時清掃他隊 `known_reputations[死隊]`。屬遊戲 state hygiene，非量測台限制。

## 待主 session（systems）確認

1. **emergent 觸發場景**：首輪待裁#3 現由 2 年量測**證實**為「缺場景」非「缺時長」。要不要排專門場景 config（偽裝弱目標誘莽者 / 預置血仇對 / 立國路徑 / 鑄幣 outpost）來驗這 6 條魂？量哪些 feel 仍待藍圖定。
2. **known_reputations 懸空清掃**：是否開小修（隊死時清他隊 reputation entry）。屬系統域 hygiene。
3. 食物巨量囤積（末態 food 4–5 萬）：無消耗/腐壞壓力 → 經濟半空轉，與 G1 履約 0% 同源。是否納入 G1 閉環 task 一併處理。

## 跑法備忘
```
$env:GODOT_TIMEOUT="3000"  # 2 年約需放寬 timeout
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
（2 年純 NPC 實測分鐘級完成。log 不入 git。）
