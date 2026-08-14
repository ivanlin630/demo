---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1必查項(四通道class name不精確)] settlement HOW spec——★發現§0『belief四通道既有機制家族』引用的class name有兩個不準:親grep確認VisionSystem(vision_system.gd:1)/BeliefSystem(belief_system.gd:1)真實存在,但『ScoutSystem』全codebase零class_name命中(斥候邏輯實際掛在FactionAISystem._try_scout_side/SubteamSystem.dispatch_anon_messenger,非獨立ScoutSystem類,我這session已多輪親讀過這些函式)、『MessageSystem』真實class name是SimMessageSystem(message_system.gd:1)非MessageSystem——這不是機制不存在(四條belief通道底層機制我這session已審過多次確認真實),是HOW spec寫的class name本身兩個不準,implementer去找不存在的ScoutSystem類或打錯MessageSystem會卡關或走錯路,要求訂正成implementer真能grep到的準確名稱(斥候通道指向FactionAISystem的scout dispatch函式群/傳聞通道指向SimMessageSystem);①S1a erase_teams修法方向對,建議實作用單一pass over state.world.tiles配合erase_teams已經在用的dead:Dictionary membership check(既有:315附近同款pattern for otid in teams: if dead.has(...))而非對每個dead team各掃一次全圖,避免O(dead×tiles)——這條是效率建議非阻塞;②S1b occupy擴無主營候選+belief-gated設計跟這session已驗證的belief-only doctrine一致;③L0/L1兩階拆分(outpost_level引入L0語意或tile flag camp_level)是合理的HOW層技術選擇,兩個選項都不違反WHAT命門,留給systems依實作方便定案;④busy-preemptible重用(faction_ai:414-415)已在R②WHAT判決親驗過存在,這輪HOW直接引用同一個既有機制非重新發明,正確;判決=CLEAN+1必查項(四通道class name訂正,非阻塞但要求implementer開工前修正避免卡關)→S1 plan→dispatch implementer"
---

# R②判決：settlement lifecycle+農業+戰略蓋點 HOW spec — CLEAN + 1必查項

## ★必查項：§0「belief 四通道既有機制家族」的 class name 有兩個不準

親 grep 確認 `VisionSystem`（`vision_system.gd:1`）/`BeliefSystem`（`belief_system.gd:1`）真實存在。但**「`ScoutSystem`」全 codebase 零 `class_name` 命中**——斥候邏輯實際掛在 `FactionAISystem._try_scout_side`/`SubteamSystem.dispatch_anon_messenger`（非獨立 `ScoutSystem` 類，我這 session 已多輪親讀過這些函式：care-loop scout de-patch、unified-dispatch 那兩輪）。「**`MessageSystem`**」真實 class name 是 **`SimMessageSystem`**（`message_system.gd:1`）非 `MessageSystem`。

這不是機制不存在——四條 belief 通道底層機制我這 session 已經審過多次、確認真實運作。是 HOW spec 寫的 **class name 本身兩個不準**：implementer 照著這份 HOW 去找一個不存在的 `ScoutSystem` 類、或打錯 `MessageSystem` 這個名字，會卡關或走錯路徑。**要求**訂正成 implementer 真能 grep 到的準確名稱（斥候通道應指向 `FactionAISystem` 的 scout dispatch 函式群、傳聞通道應指向 `SimMessageSystem`）。

## 其餘技術決策

**①S1a erase_teams 修法**：方向正確。**建議**（效率考量、非阻塞）：實作用單一 pass over `state.world.tiles` 配合 `erase_teams` 已經在用的 `dead: Dictionary` membership check（既有 `:315` 附近同款 pattern：`for otid in teams: if dead.has(o.combat_target): ...`），而非對每個 dead team 各掃一次全圖——避免 `O(dead × tiles)`，跟既有 batch-erase 的單趟設計哲學一致。

**②S1b occupy 擴無主營候選+belief-gated**：設計跟這 session 已經驗證過的 belief-only doctrine 一致。

**③L0/L1 兩階拆分**（`outpost_level` 引入 L0 語意 or 新 tile flag `camp_level`）：兩個技術選項都不違反 WHAT 命門，這是合理的 HOW 層技術選擇，留給 systems 依實作方便定案，不需要我這輪替它挑一個。

**④busy-preemptible 重用**（`faction_ai:414-415`）：這個機制我在 WHAT 那輪 R② 判決時已經親驗過真實存在（見 `2026-08-14-reviewer-to-blueprint-R2-settlement-CLEAN.md`），這輪 HOW 直接引用同一個既有機制、非重新發明，正確。

## 判決
**CLEAN + 1必查項（四通道 class name 訂正，非阻塞但要求 implementer 開工前修正避免卡關）→ S1 plan → dispatch implementer。**
