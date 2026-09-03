---
from: reviewer
to: systems
status: open
slice: commitment-outlives-applicability
topic: R②判決:issues——①負斷言查完:11個survival-set option逐一核對,沒有找到「抵達後才applicable」的真實風險案例;唯一位置門檻的「駐守」(has_own_outpost)沒有travel leg不會被打斷;「紮營」的reclaim分支/「覓食」都是每輪從當下位置重算且位置在抵達前不變,不是remembered-target-invalid-once-moved的形狀;②不加遲滯同意,但要看③;③兩個擁有者不是「誰先誰後結果不同」而是「side effect不同」——STALLED分支會設cooldown,新規則若沒設,會跟②的抖動疑慮耦合成真的thrashing,建議新規則排在_detect_survival_stall之後執行或也設同款cooldown
---

# 判決：`issues`，`premise_contradiction: false`

## ★★★①負斷言——**查完了，沒找到真的「抵達後才 applicable」的案例，逐一列給你**

先列出全部屬於 `survival` 集合（`survival_committed_option` 才會追蹤的那組）的 option（`grep '"sets":.*survival.*true' options.gd`，共 11 個），逐一核對其 `applicable`：

```
覓食(:52)      has_forage_tile           → _find_forage_tile 只查【本格+鄰格】(:557-559)
自救建田(:62)  can_rescue_build          → 不涉及移動(原地評估)
返家補給(:109) has_home_outpost          → _find_own_outpost 走 OwnerOutpostIndex，位置無關
求援(:284)     has_aid_target            → _find_aid_target 走 belief+reachability，非「已抵達」
求貢/攻擊(:144/303等) has_weak_prey/has_occupy_target → belief-based reachability，接近時只會更容易成立不會消失
投靠(:171)     has_strong_neighbor/consolidate_target_id → belief-based，同上
紮營(:208)     has_farmable_tile(fallback 分支只查本格+鄰格) / (reclaim 分支查 team_market_known 找最近，每輪重算)
紮根(:238)     can_settle_here or settle_resume_site!=-1 or own_camp_pos!=-1 → 你今天已經修好的那條
買糧(:353)     has_food_market           → team_market_known belief store，位置無關
覓食×買糧混合(:390) 同上兩者組合
```

★**關鍵事實**：`team.tile_pos` 在【抵達目的地之前不會改變】（這個引擎的移動模型是整格跳轉，非漸進座標）——所以任何「查本格+鄰格」的 applicable（覓食、紮營 fallback），只要目標在啟動移動的那一刻已經是本格或鄰格，**在抵達之前每一輪重算都還是同一個本格+鄰格，結果不變**，不存在「移動中途因為換了位置而查不到」的視窗。**唯一真正依賴【當下位置】的是 `has_own_outpost`**（`own_granary_tile` 讀 `team.tile_pos`）——但用到它的是「駐守」（`:100-106`），而「駐守」的 `to_task` 是 `{TASK_GOVERN, target: team.tile_pos}`（原地不動），**它從來不會有跨 tick 的移動途中狀態可以被打斷**——applicable 位置門檻對它沒有風險，因為它沒有旅程。

⇒ **結論：11 個 survival-set option 裡，沒有一個具備「抵達後才 applicable、且有多 tick 移動途中狀態」的組合**。你的規則（不 applicable 就解承諾）不會複刻 own-camp 那個病，**不需要加豁免**。

## ②抖動——**同意不加遲滯，但要跟③一起看**

見下。

## ★★③兩個擁有者——**不是「誰先誰後結果不同」，是「side effect不同」，而這會跟②耦合成真的抖動**

讀了 `_detect_survival_stall`（`faction_ai_system.gd:6146-6172`，你信裡的行號）：`STALL_STALLED` 分支除了清空 `survival_committed_option`，**還設了 `survival_stall_cooldown[option] = current_tick + STALL_EXCLUDE_WINDOW`**（硬排除窗，防止立刻重選同一個 option）。`_detect_survival_stall` 自己在函式頭有 guard：`if team.survival_committed_option == "": return`——**代表若本刀的新規則先清空了欄位，`_detect_survival_stall` 那次評估會直接跳過，STALLED 分支的 cooldown 就不會被設**。

★**這代表兩者清的雖然是同一個欄位、最終值相同（都是 `""`），但【副作用不同】**：走 stall 路徑會拿到排除窗保護，走新規則不會（除非你也給它加一個）。若某個 option 的 applicable 剛好在某個邊界附近輕微擺動（即使你不加遲滯、即使我在①沒找到系統性案例，個別床仍可能因為浮點/belief staleness edge 偶然擺一下），沒有 cooldown 保護的新規則會讓它【解承諾→下一輪立刻重新 applicable→重新 committed→再次不 applicable→再解】——這就是②你在擔心的抖動，只是觸發點不在「要不要加遲滯」，在「新規則的釋放有沒有跟 stall 路徑一樣的排除窗保護」。

⇒ **建議（兩選一，我沒有偏好）**：
```
①把新規則排在 _detect_survival_stall 之後執行（同一輪內）——讓 stall 路徑先有機會判定+設 cooldown，
   新規則只處理「stall 路徑判斷完之後仍然不 applicable」的殘留情況
②新規則自己也設一個（可以更短的）cooldown，跟 STALL_EXCLUDE_WINDOW 同款寫法，禁止立刻重選同一個剛被解掉的 option
```
**不需要遲滯視窗（②你的判斷仍然對）——需要的是「解承諾之後,別讓同一個選項下一輪立刻無防護地重新贏」這個較窄的保護，兩個既有機制（順序/cooldown）都能做到，不用發明新常數。**

## ⇒ 要你補的
1. ①不用補，負斷言查完確認不成立，可以放心用通用規則不加豁免。
2. ②不用補，判斷正確。
3. ③：新規則要嘛排在 `_detect_survival_stall` 之後、要嘛自己也設 cooldown，二選一，spec 明寫哪一種，不要讓兩個擁有者的副作用差異變成沒人注意的隱性風險。

**premise_contradiction: false，③處理過即可整票 CLEAN。**
