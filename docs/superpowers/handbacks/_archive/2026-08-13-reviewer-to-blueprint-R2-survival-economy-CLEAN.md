---
from: reviewer
to: blueprint
status: consumed
topic: "[R②判決=CLEAN,R①免抽驗坐實(非照單全收)] 生存經濟基座接入+產出arc——雖標R①免(前提已本session實測坐實)仍抽驗可code-verify的部分而非照單全收:①camp_drive flat親讀terms.gd:190-193逐字確認`\"camp_drive\": if opt!=\"紮營\" or not ctx.has_farmable_tile: return 0.0 ... return 1.0`——comment自己寫『T1:剝hunger urgency(移coeff)』,證實這是被前人動過手腳拿掉人格/緊迫度modulation後留下的死1.0,坐實A1『分數修法』要接的正是這個具體位置②★B5food need不隨famine升的根因親自往下挖到底非只信文字宣稱:_workstation_need(labor_system.gd:93-107)呼NeedOracle.need_keep→_self_use(need_oracle.gd:105-114)確認food分支=`FOOD_PER_PERSON_PER_DAY×population×food_security_target(leader_values)`——只讀population跟人格靜態值,零一處讀team.famine_days或任何飢餓狀態,_supply_chain對food直接return 0(食物終端無供應鏈)——B5premise逐字坐實,且這正是同一個NeedOracle.need_keep既是labor_system.gd rebalance()的need權重輸入源、也是這session其他多輪審過的coin_need等機制共用的單一真源函式,B5的修改天然落在這個既有單點、非另開一條平行food-need計算,直接回答R②④『勿與統一矩陣need-oracle arc撞架構』——不但不撞,B5根本就是繼續往這個既有single-source-of-truth函式裡加東西,是這個arc本身的自然延伸;③附帶發現labor_system.gd:42 comment『★動員後只算未動員勞力(guns-vs-butter)』證實junmin-militia Slice B已經merge落地,跟我前幾輪審過的內容一致;R②①A1邊際經濟公式(地期望食物流−現有收入)×緊迫度結構上跟移民R1/投資R2既有模型(expected-value-minus-baseline×urgency形狀)一致,非另創新公式②bounded四象限第4象限(瀕餓+只有山地→不紮)是這session已經驗證過決定性的genuine-vs-crank判準型態(呼應乙boost誤修那次教訓:真值就低是正確非starvation),判準夠硬③A2進駐/紮營同秤竸爭無顯式偏好branch,設計上无隱藏偏好④已在上方親驗坐實非架構衝突⑤scope乾淨(效能arc/B6明確排除,spec文字已排除);判決=CLEAN→鎖→systems HOW"
---

# R②判決：生存經濟基座 — 接入+產出 arc — CLEAN

## R①免——抽驗可 code-verify 的部分，非照單全收

spec 標 R①免（前提已本 session 實測坐實、帳關+直讀 tap）。我沒有因為「免」就整段跳過，抽驗了兩個可純讀 code 驗證的關鍵前提：

**①camp_drive flat**：親讀 `terms.gd:190-193` 逐字確認：
```
"camp_drive":
	if opt != "紮營" or not ctx.has_farmable_tile: return 0.0
	# T1：剝 hunger urgency(移 coeff)。可耕地已 gate→品質 1.0。
	return 1.0
```
comment 自己寫「剝 hunger urgency（移 coeff）」——證實這是**曾經有 urgency 修正、被前一輪動過手腳拿掉之後留下的死 `1.0`**。A1「分數修法」要接的正是這個具體位置，坐實。

**★②B5 food need 不隨飢餓升的根因——親自往下挖到底，非只信文字宣稱**：`_workstation_need`（`labor_system.gd:93-107`）呼 `NeedOracle.need_keep` → `_self_use`（`need_oracle.gd:105-114`）確認 food 分支：
```
if res == "food":
	return ResourceSystem.FOOD_PER_PERSON_PER_DAY * float(team.population) \
		* DecisionTerms.food_security_target(leader_values)
```
只讀 `population` 跟人格靜態值，**零一處讀 `team.famine_days` 或任何飢餓狀態**；`_supply_chain` 對 food 直接 `return 0.0`（「food 終端無供應鏈」）。**B5 的 premise 逐字坐實**。

更重要的是：`NeedOracle.need_keep` 這個函式**同時是** `labor_system.gd` `rebalance()` 的 need 權重輸入源、**也是**這 session 其他多輪審過的 `coin_need`（F2 treasury 那輪）等機制共用的單一真源函式。B5 的修改天然落在這個既有單點，不是另開一條平行的 food-need 計算——這直接回答了 R②④「勿與統一矩陣 need-oracle arc 撞架構」：**不但不撞，B5 根本就是繼續往這個既有 single-source-of-truth 函式裡加東西，是那個 arc 本身的自然延伸**，非另立山頭。

**附帶發現**：`labor_system.gd:42` comment「★動員後只算未動員勞力（guns-vs-butter）」證實上一輪 junmin-militia Slice B 已經 merge 落地，跟我前幾輪審過的內容一致，沒有漂移。

## R②

**①A1 邊際經濟公式一致性**：「（地期望食物流−現有收入）×緊迫度」這個「expected-value-minus-baseline×urgency」結構形狀，跟已核可的移民 R1/投資 R2 模型一致，非另創新公式——符合 §1「接既有邊際經濟計算層」的命門。

**②bounded 四象限——判準夠硬**：第 4 象限（瀕餓+只有山地→紮了沒救→不紮）是這 session 已經驗證過決定性的 genuine-vs-crank 判準型態，直接呼應 memory 裡「乙 boost 誤修」那次教訓（真值就低是正確、非 starvation，crank 才會 paper over 規模經濟沒模型化的洞）——這個象限測的正是「會不會被逼出一個表面看起來合理、實際上是硬灌分數讓瀕餓隊無論如何都紮營」的 crank，判準設計得夠尖銳。

**③A2 進駐/紮營同秤湧現**：兩者透過同一套邊際經濟計算競爭 argmax，spec 沒有描述任何顯式的「先看有沒有村再看有沒有地」這類硬 branch，設計上沒有隱藏偏好。

**④**：見上方親驗坐實，非架構衝突，是既有 need-oracle 單源函式的自然延伸。

**⑤scope 乾淨**：效能 arc（§5 明確排入後續、非本 arc）、B6（§3 明確標 PENDING、未裁不動）皆已排除在外，spec 文字自己劃清了邊界。

## 判決
**CLEAN → 鎖 → systems HOW。** R①雖免但抽驗坐實（非照單全收）；R②五點皆合理，尤其 B5 的 need-oracle 落點親自追到底確認是既有單源函式的自然延伸、非撞架構的平行機制。
