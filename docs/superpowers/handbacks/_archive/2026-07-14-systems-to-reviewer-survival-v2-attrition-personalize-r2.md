---
from: systems
to: reviewer
status: consumed
topic: [R②·建議異質框外審] 求生層v2:Fix2漸進安全網+Fix3門檻人格化(死常數→f領袖謹慎/野心);attrition惡化根治,decision-core+人格化
---

# R② 審 spec v2（attrition 惡化根治）

spec `2026-07-13-survival-layer-unify-3fix.md` **§修訂 v2**（新增段，讀）。4-fix 驗收 attrition 惡化 1.9-3.7×（3seed 硬 FAIL），blueprint+用戶裁定修向：Fix2 漸進安全網 + Fix3 門檻人格化。branch `feat/survival-layer-unify` 未 merge，v2 修 Fix2/Fix3 後連同重驗。

## ★建議升異質框外審（三對齊 + blueprint 明示建議過對抗閘）
1. 強結論+redirect：de-patch 死常數→人格化（改核心 esteem 公式 + crisis 判定）。
2. 相關跳因果：attrition 根因是「讀死亡故事線+diff」定位，非統計 bisect——**可能歸錯 fix**（measurer 自承無法 bisect）。
3. decision-core 難逆 + 用戶正判 fidelity。

## 根因坐實（供 factcheck 抽驗）
- Fix3：`food_ready=food_days/3` → food_days=2.5(跌破絕境)時 food_ready 仍 0.83 → 生產 alignment 0.57 > 買糧 0.45 → 餓著發展。diff `need_hierarchy.gd` ESTEEM_FOOD_REF_DAYS=3。
- Fix2：edge-trigger 只抓暴跌(`food_flow_avg<DEEP -2.0`)，慢性輕負 flow 不 trip → 不重評 → 停採購餓死。diff `_should_reeval` crisis_latched。

## 請 refute（別 confirm）
1. **根因歸屬**：attrition 惡化真是 Fix3 主+Fix2 補，還是 Fix1(退 override)/Fix4(覓食濾除) 也有份？我沒 bisect，靠 death-story+code 邏輯。**若你判歸因不穩→建議先 revert-bisect(measurer 單獨 revert Fix3 重測)再定，別在錯歸因上 spec**（premise gap）。
2. **Fix2-v2 漸進 threshold `GRADUAL_DECLINE_FLOW≈-0.5`**：會不會 over-trigger 回 13997 spam？我論證 crisis_latched /4 節流頂住(edge+60tick)，但沒量。攻擊點：mild-negative flow 是不是常態(很多隊輕微負 flow)→ 即使 /4 節流，reeval.crisis 會不會爆到數千？
3. **Fix3-v2 人格化再造 trap**：謹慎領袖 ref=7→需 food_days≥7 才 esteem 滿→會不會謹慎隊全部 survival-lock 回到原 trap(只是換一批隊)？我論證「謹慎者保守是角色特徵非 bug」，但攻擊：謹慎+低產隊會不會永遠升不了階=另一種系統卡死？
4. **compute_raw 讀 leader values**：esteem readiness 原設計註「讀世界訊號、禁讀他層 urgency」。人格 trait 非「他層 urgency」但也非「世界訊號」——這算不算破壞層獨立 §2？語意邊界你判。
5. **食物盤糧為何靠 reeval 頻率**：更根本——survival 是否該是「可競爭 util 選項」還是「硬中斷」(blueprint 留議的大問題)。若你認為 v2 仍是治標(靠 reeval 撞上補糧)、真根是 survival 不該跟發展同秤→標記，我回報 blueprint 拍那個更大的板。

## 回報
CLEAN → dispatch implementer 改 branch。問題/premise gap → 標點(或要 bisect 先)，我改 spec/halt。
（寄件永遠 open，你讀後改 consumed。）
