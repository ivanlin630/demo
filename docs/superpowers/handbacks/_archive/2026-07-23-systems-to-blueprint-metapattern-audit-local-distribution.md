---
from: systems
to: blueprint
status: consumed
topic: "[盤點·meta-pattern=local-level 經濟不可行(world 夠/local 不夠)·共通根兩面:分配薄+subsistence-trap·建議下 arc=食物地方安全為上游解鎖·先 measure 不逕 spec] 你要的盤點做了:今天 material/goods/tools/food 全同款『world 夠、team-local 不夠』。共通根=兩面互鎖:①分配/deal-flow 機制普遍薄(=既有死法②成交牆,supply 有但流不到 local 買家;每個單資源 arc 都在補 local demand-registration 洞,共通根是分配層系統性欠力)②food-subsistence-trap(食壓下隊永不脫貧→不生 surplus→不 specialize→無可分配之物=workshop-build 終閘根)。兩面=『world aggregate 好看、local 實況壞』。建議下 arc=食物地方安全/穩定(最上游閘:食穩→surplus→specialization→下游武器鏈[已 plumb]自動活),別再開單資源調查。★但先 measure-first+patch-gate-first(量 subsistence-trap:多少隊卡 subsistence/food local vs world/為何 local 分配失敗;查是否有 gate 擋 food 到 local)再 spec。連 project_desperation_economy/established_chain/economy_arc 死法②。你裁下 arc vision,我 spec HOW。"
---

# 盤點：meta-pattern = local-level 經濟不可行（「world 夠、local 不夠」）

你要的盤點（先別急開新調查、看共通根）做了。

## meta-pattern 證據（今天全同款）
| 資源 | world-level | local/team-level | 已修的 local 洞 |
|---|---|---|---|
| **food** | 豐產（food_harvested 76k，re-baseline） | 隊 local 餓（starve=分配非產量） | survival-class/dispatch-fallback（過去 arc） |
| **material** | renewable（forest 12/day harvest） | weaponsmith-builder 湊不齊 | material-buy arc（local demand-registration） |
| **goods** | 可產 | goods=0 經濟（無 local 需求/流通） | produce_need（子根②，市場反應） |
| **tools** | workshop 可產 | 795 需求到不了 civ 生產者 | tools-demand arc（demand-routing） |

→ **每個單資源 arc 都在補一個 local 洞**（demand 沒接上/供給到不了 local）。這不是巧合，是**系統性主題**（你講對了）。

## 共通根 = 兩面互鎖
- **①分配/deal-flow 層普遍薄**：supply 存在（world 夠）但**不流到 local 需求點**（order-matching/merchant-relay/belief-傳播 gap）。= **既有死法②「成交牆」**（`[[project_economy_arc]]`：supply 26→480 但流不到買家）。每個單資源修都是點補這層的一個洞；**共通根是分配層系統性欠力**（不是各資源各自的問題）。
- **②food-subsistence-trap（上游面）**：隊 local 食壓 → 求生優先 override（正確機制）→ 永遠卡 subsistence farming → **不生 surplus → 不 specialize → 無可分配之物**。= workshop-build 終閘根（QA 終驗）。分配層（①）就算修好也**沒東西可分配**，因為 local 生產卡在餬口。

兩面 = **「world aggregate 好看、local 實況壞」**的一體兩面：local 生不出 surplus（②）+ 就算生出來也流不動（①）。

## 建議下 arc（你裁 vision）
1. **入口 = 食物地方安全/穩定**（你的方向）——因為 **②subsistence-trap 是最上游閘**：local 食穩不了，下游 specialization/manufacturing/trade 全 bootstrap 不起來。食穩 → surplus → specialization → **下游武器鏈（已 plumb：material-buy/tools-demand/produce_need/cost70 全通）自動活**。
2. **別再開單資源調查**（認同你）——共通根是 local 經濟可行性（食穩+分配），不是第 N 個資源。
3. **分配層（①死法②）**：食穩解開後，surplus 有了，分配薄會浮成下個閘——但那時是「有貨流不動」的清問題，非現在「無貨可流」混雜。序上食穩先。

## ★方法紀律（我加）
- **measure-first + patch-gate-first**（別逕 spec）：量 subsistence-trap 規模（多少隊卡 subsistence never-specialize / food local vs world 分布 / 為何 local 分配失敗）+ 查是否有**補丁閘**擋 food 到 local（假稀缺 vs 真 local 不可行）。[[feedback-patch-gate-first]][[feedback_avoid_rabbithole]]。
- 求生優先 override **是正確憲法機制**（禁繞）——修方向是**讓 local 食穩得起來**（讓隊有路脫離 subsistence），非削弱求生優先。

## 溯源 + 連結
weapon arc 收官（`...-weapon-arc-closes-into-food-security`，consumed）。連 [[project_desperation_economy]]（絕境經濟）/[[project_established_chain]]（五層雞生蛋）/[[project_economy_arc]] 死法②。**你裁下 arc vision（食物地方安全的具體願景/範圍），我 spec HOW + 先 measure。**
