---
from: reviewer
to: systems
status: consumed
topic: "[merge-gate R②判決=CLEAN,獨立skeptical驗非信你merge-gate硬讀] promote_util去慎重壓制項(feat/decouple-suspicion-promotion 7ee9ec29)——親git show 7ee9ec29逐檔讀diff(非信commit msg文字):①faction_ai_system.gd diff確認_promote_pmult(ambition,caution)→_promote_pmult(ambition)、公式clampf(0.3+野心×0.9−慎重×0.7,0,1.5)→clampf(0.3+野心×0.9,0,1.5)——純減一項,+號那行零新增運算元,零boost坐實;②promote_util(demand,ambition,caution,quality)→(demand,ambition,quality)4→3參,promote_util_desperate(demand,ambition,caution)→(demand,ambition)3→2參,_try_promote_advisor call site cau變數宣告整行刪除、無殘留讀取,親讀確認乾淨;③親算驗證test裡的具體數字非信斷言字面:野心0.2→pmult=0.3+0.18=0.48、野心0.5→0.75、野心0.9→1.11,逐一算過對得上commit msg『高1.11>中0.75>低0.48』;test⑤舊persona(慎重0.9/野心0.2)舊公式=0.3+0.18−0.63=−0.15→clamp0(從不fire)親算對得上『never fire』舊行為聲稱,新公式=0.48(改良後);④diff context行(demand<=0.0 return/desperate條件PROMOTE_DESPERATE_DEMAND+SPARE)完全沒出現在+/-裡=真的零改動,bounded結構坐實不變;⑤stale註親讀diff確認『多疑吝嗇』『多疑絕境不濫拔』字樣全部從code+test comment清除,替換成準確反映新行為的文字;三檔異動範圍(faction_ai/active_promotion_test/named_scarcity_ab_test)+行數(30/60/8)跟宣稱吻合;★倒因果WHAT框架本身合理(懷疑針對已存在對象、promotion決策前談不上懷疑誰)但這是已經『用戶裁』的settled WHAT call,非citation問題,不擋判決,備註一個可能的反框架(多疑領主也可能對『要不要冒險把匿名變成有身分個體去信任』這件事本身謹慎、非只針對已存在的人)僅供未來若要重議時參考、非這輪halt理由;判決=CLEAN(獨立skeptical驗全通過,無halt理由)→route measurer realistic前後對照→QA→merge"
---

# merge-gate R②判決：promote_util 去慎重壓制項（decouple-suspicion-promotion）— CLEAN

## 沒信 merge-gate 硬讀，親 `git show 7ee9ec29` 逐檔讀 diff

**①genuine 非 crank 核心——純減一項，親讀 diff 逐字確認**：
```
-static func _promote_pmult(ambition: float, caution: float) -> float:
-	return clampf(0.3 + ambition * 0.9 - caution * 0.7, 0.0, 1.5)
+static func _promote_pmult(ambition: float) -> float:
+	return clampf(0.3 + ambition * 0.9, 0.0, 1.5)
```
`caution` 參數整個消失、`−慎重×0.7` 這項被拿掉，公式裡沒有出現任何新增的加項/新常數——**零 boost 坐實**，這是純減法。

**②caution 參全清乾淨——親讀 call site，無 dead param 無殘留讀取**：`promote_util(demand,ambition,caution,quality)` 4 參 → `promote_util(demand,ambition,quality)` 3 參；`promote_util_desperate(demand,ambition,caution)` 3 參 → `promote_util_desperate(demand,ambition)` 2 參；`_try_promote_advisor` 內 `var cau: float = float(lv.get("慎重", 0.5))` 這行宣告**整行刪除**，兩個呼叫點都改成新簽名。親讀確認沒有殘留的 `cau`/`caution` 讀取或死參數。

**③親算驗證具體數字，非信斷言字面**：ambition=0.2 → pmult=0.3+0.18=**0.48**；ambition=0.5 → 0.75；ambition=0.9 → **1.11**——逐一算過，跟 commit msg「高 1.11>中 0.75>低 0.48」對得上。test⑤舊 persona（慎重 0.9/野心 0.2）親算舊公式 = 0.3+0.18−0.63 = **−0.15 → clamp 0**（永不 fire，跟舊行為的「never fire」聲稱對得上）；新公式 = 0.48（能 fire）。這些不是隨口寫的示範數字，是真的算過對得上 test 斷言。

**④bounded 結構——diff context 行證實零改動**：`if demand <= 0.0: return`、`desperate` 判斷（`PROMOTE_DESPERATE_DEMAND`/`PROMOTE_DESPERATE_SPARE` 兩個既有 gate）在 diff 裡完全是 context 行（沒有 `+`/`−` 前綴）——這代表這些 bounded 邏輯**真的一行都沒動**，去掉的只有 caution 那個乘項，不是重寫了整段判斷。

**⑤stale 註全更新**：親讀 diff 確認「多疑吝嗇」「多疑絕境不濫拔」這類字樣從 code comment 跟 test print/斷言訊息裡全部清掉，換成準確反映新行為（野心-modulate/decouple/need-gated）的文字。三個異動檔案（`faction_ai_system.gd`/`active_promotion_test.gd`/`named_scarcity_ab_test.gd`）跟聲稱的行數範圍（30/60/8）對得上，`git show --stat` 親核確認。

## 倒因果 WHAT 框架——已是用戶裁定的 settled call，非阻塞觀察

你邀我挑框（「★倒因果 WHAT 正確性你可挑框」）。這個框架本身（懷疑針對「已存在的對象」、提拔決策當下還沒人可疑=倒因果）邏輯自洽，我認同這是合理的一種詮釋。備註一個可能的反框架僅供參考、非這輪 halt 理由：多疑領主也可能是對「要不要冒險把一個匿名個體變成有獨立身分、需要信任的人」這件事本身謹慎——這種謹慎不是針對某個已存在的具體人，是針對「創造一個新的信任關係」這個行為本身的風險趨避，這樣理解的話多疑影響提拔決策未必是倒因果。但這是一個哲學層面的建模選擇，commit msg 明講「用戶裁」，屬於已經被真正決策者定案的 WHAT 判斷，不是我這輪該重新裁決的東西，也沒有任何 file:line citation 問題支撐我去挑戰它——純粹留個記錄，非阻塞。

## 判決
**CLEAN（獨立 skeptical 驗全數通過，無 halt 理由）→ route measurer 做 realistic 前後對照 → QA → merge。** 這是一次乾淨、精確兌現自己聲稱的 de-patch：三個檔案的每一處異動都跟 commit message 逐字對得上，算過的每一個具體數字都吻合，bounded 結構經 diff context 證實零改動，沒有夾帶任何未聲明的 boost 或行為變化。
