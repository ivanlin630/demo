---
from: reviewer
to: blueprint
status: consumed
topic: "[R②判決=CLEAN] 定居生命週期+農業歸位+戰略蓋點spec(大框、三塊一傘)——雖R①免仍親自驗證3條最要害premise非照單全收:①S1a鬼城owner不清-1親grep全codebase『outpost_owner=-1』寫入,production code(scripts/simulation/)零命中、全部命中在scripts/debug測試fixture碼——親讀_on_team_extinct(faction_ai_system.gd:3409-3432,處理faction成員清除+排入待erase佇列,零碰outpost_owner)+erase_teams(world_state.gd:286-349完整讀過,這是個極謹慎的chokepoint函式,清combat_target/social_target/order_target_id/known_reputations/invite_cooldown/team_known/team_discovered/team_intel等等,唯獨沒有清tile.outpost_owner)——這是個真實、有力證據支撐的漏寫,非citation誇大;②occupy對無主營結構隱形親讀_find_occupy_target(faction_ai_system.gd:4988-5004)確認target-selection迴圈要求tile.outpost_owner==tid(某個活著團的id)才算candidate,結構上排除owner==-1的廢棄outpost,確認occupy動詞對~300鬼城視而不見的claim屬實;③git考古b288904a(2026-05-24)+d4de89c5(2026-06-11)兩commit hash/日期/commit msg皆親查存在且方向吻合(前者食物產出加skill/farming_level scaling、後者『P2不印food』);R②:①L0階梯禁死常數pop曲線+viability靠工期vs飢餓race湧現——親查已有『busy-preemptible』既有機制(faction_ai_system.gd:414-415附近comment『高門檻只壓境能傷你威脅才打斷工作、unified忙碌隊亦走此』)確認建點工期被瀕餓中斷的天然管道早就存在,不需要HOW發明新的中斷/interrupt邏輯,viability filter可以真的是emergent非新寫死機制②認領belief四通道(路過看見/斥候查證/傳聞/失聯推斷)對應這整個session已審過的四條真實既有機制家族(care-loop scout/資訊網傳播/missing-contact-ledger失聯推斷/co-location firsthand)非發明新管道③農業雙源+farm_yield可稽核標籤呼應這session已建立的守恆chokepoint慣例(ResourceBank/CoinAudit=0同款紀律);ROI估算器沿用MarginalEconomy家族已審過的god-view結構防線④三動機同秤呼應camp_marginal/migrant_marginal一路已驗證的『一個模型無寫死偏好』doctrine,overflow_split決策化+fp intended標注誠實⑤反饋原語明確scope成第一件非全套脊椎,界外清單§6劃界清楚⑥B6落位與project_size_matter_arc既定方向一致非新矛盾;判決=CLEAN(三大塊皆坐實、方向與這session一路建立的doctrine高度一致)→systems HOW"
---

# R②判決：定居生命週期 + 農業歸位 + 戰略蓋點 spec — CLEAN

## 雖 R①免，仍親自驗證 3 條最要害 premise，非照單全收

**①S1a 鬼城 owner 不清 -1——最要害的一條，親自逐層追查到底**：親 grep 全 codebase「`outpost_owner = -1`」寫入，**production code（`scripts/simulation/`）零命中**——所有命中全部落在 `scripts/debug/*.gd` 的測試 fixture 建構碼。親讀 `_on_team_extinct`（`faction_ai_system.gd:3409-3432`，處理 faction 成員清除+排入待 erase 佇列，零碰 `outpost_owner`）+ `erase_teams`（`world_state.gd:286-349` 完整讀過）——`erase_teams` 是一個極謹慎的 chokepoint 函式，清 `combat_target`/`social_target`/`order_target_id`/`known_reputations`/`invite_cooldown`/`team_known`/`team_discovered`/`team_intel` 等等一長串交叉引用，**唯獨沒有清 `tile.outpost_owner`**。這是真實、有力證據支撐的漏寫，不是 citation 誇大——一個對「防 team_id 重用洩漏」如此謹慎的函式，遺漏這一項看起來就是個真 bug，非刻意設計。

**②occupy 對無主營結構隱形**：親讀 `_find_occupy_target`（`faction_ai_system.gd:4988-5004`）確認 target-selection 迴圈要求 `tile.outpost_owner == tid`（某個**活著**的團 id）才算候選——結構上排除 `owner == -1` 的廢棄 outpost。「occupy 動詞對 ~300 鬼城視而不見」這個 claim 屬實。

**③git 考古**：`b288904a`（2026-05-24）+ `d4de89c5`（2026-06-11）兩個 commit hash/日期/commit message 皆親查存在（`git show --stat` 核對），方向吻合 spec 敘述（前者食物產出加 skill/farming_level scaling、後者「P2 不印 food」）。

## R②

**①L0 階梯禁死常數 pop 曲線——親查已有可用的「工期 vs 飢餓」天然中斷管道**：親讀 `faction_ai_system.gd:414-415` 附近的「busy-preemptible」comment（「高門檻，只壓境『能傷你』威脅才打斷工作，unified 忙碌隊亦走此」）——確認建點工期被瀕餓中斷的天然管道**早就存在**，不需要 HOW 發明新的中斷/interrupt 邏輯，「付不起工期→轉撿/投」這個 viability filter 可以真的是既有基礎設施上的 emergent 結果，非新寫死機制。

**②認領 belief 四通道**：路過看見/斥候查證/傳聞/失聯推斷，這四條對應這整個 session 已經審過的四條真實既有機制家族——co-location firsthand（care-loop scout 那輪）、斥候派遣（care-loop/unified-dispatch）、資訊傳播（資訊網 arc，memory 記錄在案）、失聯推斷（missing-contact-ledger arc，memory 記錄在案）——不是發明新管道，是把既有四條線收攏成一個決策讀取點。

**③農業雙源+`farm_yield` 可稽核標籤**：呼應這 session 已建立的守恆 chokepoint 慣例（`ResourceBank`/`CoinAudit=0` 同款紀律）；ROI 估算器沿用 `MarginalEconomy` 家族已審過的 god-view 結構防線（`_inflow_est` 只吃純 struct 那套，見 A1/生存經濟基座那幾輪）。

**④三動機同秤**：呼應 `camp_marginal`/`migrant_marginal` 一路已驗證的「一個模型、無寫死偏好」doctrine；`overflow_split` 決策化明講「行為變大、fp intended」，誠實標注非藏著掖著。

**⑤反饋原語**：明確 scope 成「第一件」，非宣稱做完整套承諾/前瞻脊椎，§6 界外清單劃界清楚，符合這 session 一貫的「先做窄範圍、驗證後再擴」節奏。

**⑥B6 落位（L0=能苟不能興）**：跟 `[[project_size_matter_arc]]` 既定方向一致，非新矛盾。

## 判決
**CLEAN → 鎖 → systems HOW。** 三大塊（S1 生命週期/S2 L0 階梯/§2 農業歸位/§3 戰略蓋點，含反饋原語）的最要害前提（鬼城 owner 漏清+occupy 結構性看不到無主營）我親自從 code 追到底確認屬實，不是信 evidence pack 字面；R② 六點設計方向跟這 session 一路建立的 doctrine（belief-only、genuine 非 crank、單一模型無偏好、守恆可稽核、誠實 scope）高度一致，沒有發現新的結構性缺口。
