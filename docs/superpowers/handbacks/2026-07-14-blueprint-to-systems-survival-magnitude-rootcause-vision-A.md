---
from: blueprint
to: systems
status: consumed
topic: [★真根定位+願景A拍板·顛覆前spec] 求生util被normalize閹割封頂1.0=attrition主根(非esteem門檻);願景=超量級boost當最後保險+安全網日常主力提早備糧,boost頻率=健康指標
---

# 真根定位(v2 branch 實測坐實) + 願景A拍板

## 為何顛覆:之前所有門檻修法都在治次要症狀
v1/v2 attrition 一路惡化,我們一直在調門檻(3天→5天→人格化2-8天=Fix3系列)。讀 v2 branch(`feat/survival-layer-unify` @2ee09f9b,measurer 實驗版)真實 code 重算,揪出**真根不是門檻,是求生 util 的量級被閹割**：

### 真根1(主根)：survival_pressure 被 term-normalize flatten 成封頂 1.0
- `terms.gd:52-54`(v2 與 main 逐字同)：survival_pressure eval 硬封頂 ≤1.0。註解殘留舊「食0→12」域證據——那輪 term 正規化把 urgency 移進 coeff 後，**求生失去「food→0 時碾壓量級」**。
- urgency 進了 coeff(`need_hierarchy:39` raw[L_SURVIVAL]=clampf((5-food)/5)，food=0→1.0 確實飆高)，**但 coeff 是有界軟乘子[0.15,1]，只能把別選項往下壓、永遠推不動求生自己過 1.0**。
- **v2 實測數字(food_days=1、野心 Team10、統一隊)**：覓食 util=**0.91**(封頂)vs 建設 util=**1.14**(base 1.135 + 承諾 0.3)。**建設贏，一路蓋到餓死。**
- ★驗算：就算 esteem urgency 歸零，建設 coeff 仍≈0.71、util≈1.05+0.3 > 覓食。**∴ esteem 門檻(Fix3)只是次要加劇，主根是求生量級封頂。**

### 真根2：統一隊兩安全網皆失效
- **漸進安全網(Fix2-v2, GRADUAL_DECLINE_FLOW=-0.5, `faction_ai:96,1775`)**：確在 v2，但只餵 `_should_reeval`/cadence÷4＝**只管「多久重算」，不管「重算誰贏」**。重算→再跑 rank_scored→求生封頂→**還是選建設**。fire 了但空轉，這正是 decision_count 暴增 965 的來源(更頻繁重做同一錯決定)。
- **PRIO_SURVIVAL 硬 floor(`faction_ai:3063-3064`)**：`if uses_unified or parent_team_id==-1: return`。v2 排除更廣(Fix1 退役連 solo 非子隊都退出 legacy 求生)。Team10=TAG_PRODUCE 統一隊→跳過→**拿不到 priority-80 求生保護**。
- ∴ 統一隊求生全靠純 util argmax，而 util 求生封頂贏不了＝**有安全網之名、無實**。

### 真根3(立場問題，需翻正)：v2 把野心餓死當「特色」不當 bug
`need_hierarchy:70-71` 註解**明確定義野心 leader 餓死為「角色缺陷致死、非系統 bug」**。Fix3-v2 設計上就接受這結果、不救。**這跟用戶願景直接衝突**(見下)——性格影響「多冒進」可以，但「結構上讓野心隊必然餓死」不是特色是缺陷。

## ★願景 A 拍板(用戶親裁，翻正 v2 立場)
用戶選 **A：求生超量級 boost(仍競爭派，非硬中斷)**，但加關鍵約束「**安全網要先發揮功效，不能每次都硬撞求生**」。定調兩層防線分工：

1. **日常主力＝安全網**(層1漸進偵測 + 層2人格化安全存量 + 層5預算分配)：讓隊伍**提早備糧、維持緩衝，根本不走到「糧食剩1天」的危機區**。這是天天運作的主剎車。
2. **最後保險＝超量級 boost**：極低糧時讓 L_SURVIVAL 產生**超過 1.0 的加法式量級**(隨 food→0 放大，復原舊 ~12 域的碾壓力)，突破 util 天花板、奪回 argmax。**但這是安全氣囊，不是日常剎車**——正常隊幾乎不該觸發它。
3. **★驗收鐵律：boost 觸發頻率要低。常觸發 = 安全網失職**(隊伍老是掉到危機才靠 boost 硬救 = 上游備糧沒做好)。boost 觸發頻率本身是健康指標，不是越多越好。

**願景明確**：性格決定「多冒進/多囤糧」的風格差異(層2/層5)，但**不允許任何性格在結構上必然餓死**(翻正 v2 的「角色缺陷致死=特色」立場)。求生 boost 保證極端時人人有活路，性格只調日常風格。

## 併入 slice A(修正你已過審的 spec)
你 slice A 架構 spec(`282591fe` + 異質框外審 `64f0fb70` CLEAN)是在「門檻人格化」框架下設計的。此真根**新增一塊該 spec 沒涵蓋的核心**：**求生 util 量級復原(去封頂/加法式 boost)**。請把它併入 slice A：
- 原 slice A：層1漸進 + 層2門檻人格化 + 層3認武器 + 層5預算 + 候選1賣糧對稱 + 候選2全option門檻人格化。
- **新增層0(最底層、優先做)：求生 util 量級復原** ——這是所有上層人格化/預算分配能成立的地基。沒有它，門檻/預算調得再好，極端飢餓時求生還是贏不了。

## 請做
1. 判斷「層0 求生量級復原」的落法(去 flatten 封頂 or 加法式 boost 隨 food→0 放大 or 統一隊補回 survival floor——你 owner HOW，但恪守願景 A：仍在 util 競爭框架、不是無條件硬中斷；boost 是量級碾壓不是繞過引擎)。
2. 併入 slice A 重開/補 spec。
3. ★動決策核心量級 + 翻正願景立場 = 大框 → **升框外異質 skeptic 審 R②**(你上輪已做過一次，這次改動更底層，再過)。CLEAN 才 dispatch。
4. implementer → 修完**整包一次量測驗收**(用戶原則：全好才量，不半套 bisect，半套=假訊號)。驗收點：attrition 回落 main 水準 + Team10/14 統一隊不再「發展死」 + ★boost 觸發頻率低(常觸發=安全網失職) + established 不退 + 建設不再 94% 鎖死。

## 邊界
HOW 你 owner。用戶原則鐵律：①全好才量(不半套 bisect)②不新增玩家可見 option/行為③性格調風格但不許結構性餓死。願景 A 已 close(超量級 boost 競爭派 + 安全網日常主力)，不再留議。
