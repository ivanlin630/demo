# Spec：人格化資源預算架構（Slice A：層1-3+層5+候選1+候選2 框架）

status: draft（待 heterogeneous R② CLEAN → dispatch implementer）
owner: systems
supersedes/extends: `2026-07-13-survival-layer-unify-3fix.md`（層1-3 本體在該 spec，此為架構傘）
frame: ★大框三對齊（動架構 + 剛拍板願景「求生=個性加權競爭項非硬中斷」）→ **R② 升異質框外審**（別 Opus 代 + refute prompt，用戶指定，01_architect 規則）

## 願景前提（用戶拍板 2026-07-14，留議 close）
**求生 = 個性加權的競爭項，非硬中斷。** 不要「餓破線→無條件停一切求生」；要「求生跟軍備/發展在人格化預算裡競爭權重」。本架構建立在此。

## 核心設計：人格化資源類別目標 + gap-to-target 驅力
統一機制取代散落死常數門檻（候選2 框架）：
- **資源分三類別**：`食物安全 / 軍備 / 發展(生產·囤貨·升階·建設)`。
- **每類別有人格化目標水位** `category_target(leader_values)`＝f(慎重/野心)（+處境調節）：
  - 謹慎↑ → 食物安全目標高、軍備/發展目標相對低（保守囤糧才安心）。
  - 野心/賭徒↑ → 食物安全目標低、軍備/擴張目標高（薄糧搏發展）。
  - 處境調節：真逼近餓死(food_days→0) → 食物類別權重暫時 →1 壓過一切（短暫救急，非常態全砸；沿用既有 survival coeff/local_value 饑荒攀升）。
- **每個花費 option 的 drive = 該類別 gap-to-target**（current stock vs 人格目標）：
  - `買糧` drive ∝ max(0, food_security_target − food_days)：food 低於目標→高，補到目標→趨零→**自動收手在人格化安全存量**（非收手在 DESPERATION 3）。
  - `軍備採購/囤貨/生產發展` drive ∝ 各自類別 gap。
- **∴ 三個湧現效果**（無新 option、無新玩家行為，純 drive 曲線吃人格目標）：
  1. **層4 鋸齒被吸收**：買糧收手線 = 人格化目標(非=觸發線)，gap→0 自然停 → 「觸發≠收手」湧現，不需獨立層4機制。★需量測確認（見驗收）。
  2. **層5 預算分配湧現**：某類別補到目標→其 drive 落→argmax 轉到下個最缺類別→**任一項不吃光預算**，分配浮現個性（謹慎先填糧、賭徒先填軍備）。
  3. **候選1 賣糧對稱**：賣糧 reserve = 同一 `food_security_target`（非死常數 pop×2.5天）→ 不賣到自己餓、不賣破 buy-panic 線。

## Slice A 落地清單（一次做完一次驗）

### 層1 Fix2 漸進安全網 — 已在 branch（不動）
### 層2 Fix3 門檻人格化 — 已在 branch；**收編**：`esteem food_ready` 的 `food_security_threshold` = 本架構 `food_security_target` 同一函式（單一 owner，別雙常數）。
### 層3 Fix3c 償付能力認武器 — reviewer CLEAN，本輪納入（見 3fix spec §Fix3c）。★implementer 順手 coinless+武器 specimen trace 驗 barter 真 fire（reviewer #1）。
### 層5 預算戰略分配（架構本體）
- 定 `food_security_target(leader)` / `military_target(leader)` / 發展為 default 類別。TEST VALUE 映射（慎重/野心）。
- 花費 option（買糧/囤貨/軍備採購/生產/建設…）的 drive term 改吃「類別 gap-to-target」——**在既有 `terms.gd` drive + `need_hierarchy` coeff 架構內表達**（gap 是連續信號，非新 band/判斷器；沿用 coeff 乘法調變精神）。**無 spending ledger、無 per-period reset**（stateless：讀當下 resource vs 人格目標，deterministic）。
- 處境 override：food_days 逼近絕境 → 食物類別 drive 壓過（沿用 survival coeff 饑荒攀升，不新增硬閘）。
### 候選1 賣糧 reserve 人格化
- `trade_valuation.gd:58-63` food reserve `pop×0.1×FOOD_RESERVE_TICKS`（死常數，過期 0.1/tick vs 真實 `FOOD_PER_PERSON_PER_DAY=0.8`）→ 改 `food_security_target(leader) × pop × FOOD_PER_PERSON_PER_DAY`。★對齊 aid-reserve 已人格化先例（`interaction_system.gd:1000-1002 lerpf(2,60,hoard)`）——賣糧端補齊同型一致。
### 候選2 人格化門檻框架（統一 home）
- 提供單一 helper（home 建議 `DecisionTerms` 或新 `PersonalityBudget` util）算 `category_target(leader, category)`；層2/層5/候選1 全呼此**單一源**（judge 盤點精神：不並存散落常數）。
- **★scope 界（systems HOW 裁，控 blast radius）**：本 slice **只實例化「食物安全 + 軍備 + 發展」三類別 + 相關 option**。非食物 gate（佔村 OCCUPY_MIN_POP/血仇 FEUD_ATTACK_MIN/匱乏搶 SCARCITY_RAID_MIN/capability VIABLE_ARMED_RATIO）**同框架、延後 follow-up 逐 gate 遷入**（非本輪，非 attrition 相關，一次全遷=過大 blast radius）。框架設計成可擴，本輪只接食物簇。列 known_issues 追蹤 follow-up。

## 排之後（known_issues，用戶定）
- 候選3：faction 不救成員求生 + 徵收從餓的窮成員抽血（無反向補糧 directive）。
- 候選4：breed「養不起還一直生」正反饋（只看瞬時 needs.food>0.7，無人均存糧剎車）＝Team7 pop 暴崩候選。
- 非食物 applicable gate 人格化 follow-up（候選2 框架擴用）。
- 層4 鋸齒獨立機制（僅當本 slice 量測後殘餘鋸齒、且非真赤貧才補）。

## 驗收法（measurer 標準床，一次跑 seed1337/42/7，全 slice A）
1. **attrition 回落 ≈ main baseline**（headline；branch vs main 同世界，從惡化 1.9-3.7× 回落）。
2. **Team10 thrash 仍治好**、**established 不退**、determinism、憲法閘綠。
3. **Team14 型「滿手武器買不起糧餓死」消除**（層3；weapon-rich has_specie true + barter 換糧成交 `trade.barter_deal`）。
4. **★層4 吸收確認**：窮隊**不再貼 3 天鋸齒餓死**（買到人格化安全存量才收手）——**若殘餘鋸齒餓死（真赤貧無錢/無武器/無貨 除外）→ 回報，補層4**。
5. **★資源分配浮現個性非二元擺盪**：抽驗謹慎隊(食物比例高、有 buffer)vs 野心隊(軍備/擴張比例高、薄糧)——**非「全砸買糧 or 全砸軍備」二元**；謹慎隊仍能升階（非變純糧倉廢發展）；野心隊不因薄糧即崩。
6. **候選1 賣糧不自餓**：囤貨/賣糧隊不再賣到 <buy-panic 線後自己掉恐慌。
7. **reviewer 沿用條件**：attrition+reeval 頻率雙報；經濟無扭曲（糧價/coin 流無暴走）。

## 觸及檔（架構增量，Slice A）
`decision_context.gd`（類別 gap/target 入 ctx）、`terms.gd`/`need_hierarchy.gd`（drive 吃 gap-to-target + 統一 `category_target` helper）、`trade_valuation.gd`（候選1 賣糧 reserve）、`team_data.gd`（若需類別 target 快取欄）。單一 owner 收斂人格門檻函式。

## 內部 build 序（implementer 參考，仍一次量測）
① `category_target` helper（單一源，收編層2 esteem threshold）→ ② 買糧/賣糧 drive+reserve 吃 food_security_target（層2 對齊+候選1+層4 吸收）→ ③ 軍備/發展類別 gap drive（層5 分配）→ ④ 處境 override 接既有 survival coeff。層3 Fix3c 獨立可先做。
