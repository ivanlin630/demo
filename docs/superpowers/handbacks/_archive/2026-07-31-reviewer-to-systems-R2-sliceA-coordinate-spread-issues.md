---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN-with-required-correction] SLICE A convoy協調散單——★spec把live-scan跟state-registry當同等選項，但親查`_on_team_extinct`(faction_ai:2524-2547)確認porter死於戰鬥/餓死走這條泛用死亡路徑零convoy特判，state-registry會漏清變幽靈認領永久佔單；live-scan結構性免疫(死隊自動從state.teams消失不用額外清)，要求鎖定live-scan非留implementer自選"
---

# R②判決：SLICE A flow-fix — convoy 協調散未填單 — CLEAN + 1 必要訂正

## ★①in-flight registry lifecycle——spec把兩個選項當同等，但它們不是同等安全
spec §1/接點把「live-scan active convoy子隊`task_extra_data.order_id`」跟「state級registry(dispatch+/DELIVER·RETURN·dissolve−)」並列成「或」——**這兩個選項的漏清風險完全不對等**。

親查`_on_team_extinct`(`faction_ai_system.gd:2524-2547`)——這是**任何**team死亡(含convoy porter)的泛用處理路徑：戰鬥死/餓死都會走這裡，路由遺財+排入`teams_pending_erase`，**完全沒有convoy專屬清理的hook**。porter是普通subteam，會受一般combat/famine風險——這代表：**如果選state-registry，porter半路被打死或餓死，走的是這條泛用死亡路，不會經過spec講的「DELIVER成交/RETURN/dissolve」任何一個清理點**，registry裡那筆認領永遠不會被扣掉——變成幽靈認領永久佔住那張buy單的`effective_rem`，未來的convoy會一直跳過這張其實早就沒人在送的單。這正好是這輪修正想解決的「未填單沒人去」問題的**同型復發**，只是原因從「naive全打同一單」變成「幽靈認領誤判單已被填」。

**live-scan(直接掃`state.teams`裡`current_task==TASK_CONVOY`且`task_extra_data.order_id`匹配的活隊)結構性免疫這個問題**——porter死了就從`state.teams`消失，下一次live-scan自動不會再算到它的認領，不需要任何額外的清理程式碼、不可能漏清，因為它根本沒有「登錄」這個動作可以漏做。

**要求**：鎖定用live-scan，不要留給implementer自選——state-registry這個選項要嘛整個刪掉，要嘛明確要求它的清理必須額外接進`_on_team_extinct`(或`cleanup_extinct_teams`)，覆蓋combat/famine等所有死亡路徑，非只有DELIVER/RETURN/dissolve三點；但既然live-scan本來就結構性安全又不用多寫清理code，沒有理由選risk更高的那條。

## ②effective_rem計算——結構對，取決於①選哪個
`effective_rem=order.qty_remaining−Σ在途認領`——扣減邏輯本身沒問題，前提是「Σ在途認領」這個數字本身要可信（見①）。live-scan版本這個sum永遠反映真實還活著的porter，不會多算也不會少算。

## ③散選util非scripted round-robin——設計對
`gain×reachable×effective_rem>0`是util-weighted排除已認領滿的單，非硬性輪流分配——賣方仍照經濟理性選「划算+搆得到+還缺貨」的單，只是排除了已經被別人在路上填滿的選項，不是強迫每個賣方輪流去不同單。這是正確的「排除選項」而非「重新分配選項」，維持util秤決策的精神不變。

## ④★fulfilled真升MEASURE-VERIFY——spec這輪的紀律已經到位
spec §3明確要求re-run量真值(45→顯著升toward192+散到多買家+sell_no_surplus降)，這是本session被靜態斷言駁6-7次後真正吸收的教訓，這條不用我再加碼要求。

## 判決
**CLEAN + 1必要訂正（鎖定live-scan、刪除或強化state-registry選項）→ `to:systems`。** 其餘設計(effective_rem/散選util/measure-verify紀律)方向對，不需要重新設計，只需要把①這個「兩個選項不等價」的地方講清楚、選定安全的那個，訂正後可以直接進implementer，不需要再回合一次完整R②。
