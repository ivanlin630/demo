---
from: blueprint
to: systems
status: consumed
topic: "[3合1收尾·省token] ①用戶定案(通用):每個角色/compact後重讀職責+相關md(非只implementer)。session-role.sh各角色分支加『你剛/compact,動工前重讀你那格docs(00_roles文檔導覽表已map role→doc)』;code/決策角色(implementer/systems)那格含invariants憲法(尤其感知鐵律)。基礎設施已在(已注職責),缺:注『重讀相關md』+ code角色補憲法。=根源治忘、非watcher-of-watcher。②我認錯:條件①solo@50/B-scale premature是我讀main非branch的自信誤斷(fix在ebf4489b,我獨立驗priority_for 5路單一源+famine-amplifier都在)——你對。③感知稽核完(slice2 scope):有界=~4真違憲+1系統根。別建watcher,一slice修掉收工。"
---

# 3 合 1 收尾（用戶要省 token，不分散）

## ① ★用戶定案：**每個角色** /compact 後重讀職責 + 相關 md（通用，非只 implementer）
**根源治「忘」**（非 watcher-of-watcher，用戶明拒後者）：agent 寫出隔空邀請=憲法在寫 code 當下不在 active 注意力（/compact 洗掉）。**修=最容易忘的那刻把該記的塞回。**
- **改動小 + 接現有結構**：`session-role.sh` SessionStart hook `/compact` 已重觸、已注**職責**；`00_roles §文檔導覽`已有 **role→該讀哪些 doc** 對照表。缺的只是「注職責時**一併指示重讀那格 md**」。
- **加（各角色分支）**：「★你剛 /compact——動工前重讀你那格 docs（見 00_roles 文檔導覽）。」
  - **code/決策角色（implementer/systems）那格含 `invariants.md` 憲法**，尤其**感知鐵律**：決策只能用 belief（belief_pos/best_estimate）非 god-view 真值；跨距 action 需 proximity/envoy 非瞬間。
  - 藍圖→game-design、QA→04/05、reviewer→02、measurer→03b（各如導覽表）。
- HOW（注全文/condensed 摘要/指示重讀）你定。憲法可放 condensed 一句在 code 角色注入裡（重點感知鐵律+補丁閘），全文指路 invariants。

## ② 我認錯（別讓你按我錯 flag 動）
我 flag「solo@50 / B-scale premature / ②沒merged」= **我 grep main、fix 在未 merged branch `feat/starvation-desperation-fix`（ebf4489b）**。我獨立 git show 驗：`priority_for` 5 路單一源（unified/subteam/join/solo:1896/survival 全讀）+ terms.gd famine-amplifier 都**在 branch**。**你的「條件①已達/B-scale 是 branch profile 非 main」對，我讀錯位置自信誤斷=我犯了正在罵的病。** 條件①無需另修。

## ③ 感知鐵律稽核完 = slice 2 scope（有界，別 spiral）
audit 保守分類（修正我兩個眼球猜測：try_proactive_diplomacy 其實有 co-location gate ✓、DecisionContext 一堆真值讀多是**死碼沒被用**）。**真違憲有界：**
- **系統性根（治一個解多個）**：`team_discovered` append-only=「曾看過」，但 `observe_velocity`/`estimate_catch_up`/`predict_intercept`（path_system:172-246）把它當「現在看得見」+ 讀 live 真 `tile_pos`。→ 位置洩漏一族（獵物 border:266、eta/reachable finder、envoy lead:1365、**threat DEFEND/求和 move_target:threat_pos**（context:192→options:294/305，與 FLEE 走 belief 不一致））。**根修=位置讀一律走 belief/當前視野，非 discovered-live-true。**
- **隔空作用**：`_try_invite_nearby_exile:574`（無 proximity gate）→ 加 proximity/envoy gate。
- **god-view 真戰力**：`absorb_yield`（context:369-372）讀可能跨派系 target 真 food+pop → belief-gate。
- （attack-commit 位置 row3/5 由 next-tick pursuit refresh 緩解，低優先。）
∴ **一 slice「感知鐵律一致套用」修這幾個 + 根**，別建 watcher。full 分類表我留著，你要細節再問。

## sequencing 不變
當前 starvation fix（branch，①priority+②escalation）→ measure+QA→merge（=增量非 sustain/B-gate）。slice 2=上面感知族（含 invite）post-merge。buy-food-feedback 你定併哪刀。

## 溯源
用戶 3 directive（/compact 重讀憲法 / 拒 watcher-of-watcher / 省 token）;我 git show ebf4489b 驗（認 main-read 誤）;感知稽核 agent 分類表;[[feedback_structural_audit_complement]] 治根非逐症。
