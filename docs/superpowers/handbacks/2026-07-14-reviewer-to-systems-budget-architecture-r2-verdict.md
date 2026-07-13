---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·異質框外審已做] 人格化資源預算架構 Slice A：CLEAN 附條件——#1「湧現層4」宣稱過強，改判「經驗性、非架構保證」+ 既有 acceptance fallback 已夠接"
---

# R② 判決（升異質框外審，refute-first）：CLEAN 附條件

verdict: clean（附條件，見下）
premise_contradiction: false

## factcheck
- 候選1 死常數：`trade_valuation.gd:58-63` `pop×0.1×FOOD_RESERVE_TICKS` 坐實（陳舊 0.1 vs 真實 `FOOD_PER_PERSON_PER_DAY`，你標的「過期」屬實）。
- aid-reserve 人格化先例：`interaction_system.gd:999-1002` `hoard=greed-honor → lerpf(2,60,...)` 坐實，是可複製的既有 pattern（同型一致論證成立）。
- 層3 barter：`interaction_system.gd:720-722` 三呼無條件，前輪已驗，此輪重申一致。

## 逐點 refute（主動找破綻）

1. **「層4 吸收」宣稱過強，需降級**：你自己框「drive 排序≠一定補到位」的疑慮**成立**。機制上 `rank_scored` 是**flat argmax**（`decision_engine.gd`／各 option drive 同層競秤），無 lexicographic 優先序保證「先把某類別填滿再看下一個」。若軍備 gap 在食物補到一半時反超，argmax 確會跳走，食物停在**人格化目標以下**——這不是「觸發≠收手」的完全湧現，是**把鋸齒的地板從 DESPERATION(3天) 抬高到某個浮動點**（仍可能鋸齒，只是齒變淺/變高）。**判定**：不算 premise_contradiction（機制描述本身無錯，只是「保證收手在 target」這句宣稱太滿）——**你 spec 自己已留後路**（驗收④：「若殘餘鋸齒餓死→回報，補層4」），∴ 不擋 CLEAN，但**要求措辭改**：層4 標「預期改善，非結構保證」，别讓 implementer/measurer 以為這是已證明的湧現，只是**假說待驗**（差一句話，但關乎 measurer 判讀「沒完全消除鋸齒＝失敗」還是「符合預期，只是沒到 100%」）。
2. **stateless 恆最大 gap→單類別霸佔**：同意這是**真實可能**（謹慎隊食物 target 高時，食物 gap 长期最大→長期壓過軍備/發展），但**判定=可接受**：（a）target 有界（沿用 Fix3-v2 `MIN=2,MAX=8` 式 clamp，非無限高）→ gap 終將收斂非永久；（b）持續偏重某類別**正是人格光譜設計意圖**（謹慎者本該重食物輕發展）——這不是 bug，是 spec 願景要的「分配浮現個性」。**唯一風險**：target 設太高導致「終將收斂」的時間尺度超過遊戲有意義時長（如 3mo 內都收斂不了、謹慎隊整局都在買糧）——**這正是你驗收⑤已經在測的東西**（「謹慎隊仍能升階非變純糧倉」），已有 empirical gate，不需新增機制，不阻塞。
3. **願景前提張力（角色缺陷死 vs attrition 回落，是否矛盾）**：你自己點出的兩難是真的，**我判斷：不必然矛盾，但需要驗收數字才能定論**——賭徒隊「偶爾因己選而死」跟「整體 attrition 回落 baseline」可並存，前提是賭徒隊佔母體比例夠低（非全民賭徒）+ 死亡是「小尾巴」非「常態」。若驗收①(attrition headline)過但⑤(賭徒仍死)也出現，那就是**設計預期內**，非矛盾；只有當①過不了才是真衝突，屆時才需回 blueprint 校，你 spec 已經這樣寫（premise_contradiction→halt 回報），**同意此處理方式，不需 spec 階段先解**。
4. **crisis coeff 接得住薄糧賭徒**：既有 `raw[L_SURVIVAL]` 線性攀升（`need_hierarchy.gd:39`）+ Fix2-v2 crisis edge-trigger（食物流負→即時重評）雙層已存在，非新機制、非本 spec 引入的風險——薄糧賭徒本就受這兩層保護，同一套機制服務所有人格，非賭徒特例弱化。判**不擋**。
5. **食物簇先行、其餘 gate 延後的不一致**：判**可接受**——這是标准增量切法（先驗證框架在一個簇內有效，再擴），非架構缺陷；已入 `known_issues` 追蹤，非本輪 silent 遺漏。跟 R②-3fix 輪的「三項綁一份 vs 獨立」判準一致：食物簇內部咬合(層2/5/候選1 共用 target)必須綁，跨簇(食物 vs 佔村/血仇)不咬合，可切開——判斷正確。
6. **owner**：同前輪 Fix3b 判斷，建議 `DecisionTerms`（或新 util 若三處讀取者都要 import 它，放 DecisionTerms 底下更乾淨，need_hierarchy 已有向 decision 層 import 先例）。非阻塞，implementer 定案時採。

## 條件（CLEAN 附帶，非阻塞 dispatch）
- **層4 措辭降級**：spec/驗收文件把「湧現吸收」改標「假說待驗」，measurer 報告需明確區分「鋸齒消失」vs「鋸齒變淺但仍在」兩種結果，別二元 pass/fail 掩蓋部分改善的訊號。
- 沿用前二輪條件（attrition+reeval 雙報、謹慎隊長期升階抽驗、經濟扭曲守）**適用範圍自動涵蓋 Slice A**（同一 target 函式）。
- 驗收①③⑤三者若任一嚴重不過 → 你已承諾 halt 回 blueprint，此輪不需要我再加碼要求。

## 回報
CLEAN → hold 到 measurer v2(層1-2) 回，dispatch 全 Slice A。
（寄件永遠 open，你讀後改 consumed。）
