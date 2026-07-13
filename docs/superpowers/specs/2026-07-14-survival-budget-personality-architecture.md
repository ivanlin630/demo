# Spec：人格化資源預算架構（Slice A：層1-3+層5+候選1+候選2 框架）

status: draft（待 heterogeneous R② CLEAN → dispatch implementer）
owner: systems
supersedes/extends: `2026-07-13-survival-layer-unify-3fix.md`（層1-3 本體在該 spec，此為架構傘）
frame: ★大框三對齊（動架構 + 剛拍板願景「求生=個性加權競爭項非硬中斷」）→ **R② 升異質框外審**（別 Opus 代 + refute prompt，用戶指定，01_architect 規則）

## 願景前提（用戶拍板 2026-07-14，留議 close）
**求生 = 個性加權的競爭項，非硬中斷。** 不要「餓破線→無條件停一切求生」；要「求生跟軍備/發展在人格化預算裡競爭權重」。

**★願景 A 精修（2026-07-14 真根定位後，兩層防線分工）**：
1. **日常主力＝安全網**（層1 漸進 + 層2 人格化安全存量 + 層5 預算分配）：隊伍提早備糧、維持緩衝，**根本不走到「糧剩 1 天」危機區**。天天運作的主剎車。
2. **最後保險＝超量級 boost（層0）**：極低糧時 survival option 產生**加法式超過 1.0 的量級**（隨 food→0 放大，復原舊 ~12 域碾壓力），突破 util 天花板奪回 argmax。**安全氣囊非日常剎車**——正常隊幾乎不觸發。仍 util 競爭（量級碾壓非繞過引擎），非硬中斷。
3. **★驗收鐵律：boost 觸發頻率要低。常觸發 = 安全網失職**（老掉危機才靠 boost 硬救＝上游備糧沒做好）。boost 觸發頻率＝健康指標。
4. **★不許結構性餓死**：性格調「多冒進/多囤糧」風格（層2/5），但**任何性格都不許在結構上必然餓死**（翻正 v2 `need_hierarchy:70-71` 舊立場「野心餓死=特色」）。boost 保證極端時人人有活路。

## ★真根（2026-07-14 blueprint 讀 v2 branch code 坐實，顛覆前 esteem-focus 診斷）
前 v1/v2 一路調門檻（3→5→人格化 2-8）都在治**次要症狀**。真根 = **求生 util 量級被 term-normalize 閹割封頂**：
- `terms.gd:52-54` survival_pressure eval **硬 `return 1.0`**（T1 正規化剝 urgency 移 coeff）。urgency 進 coeff（`need_hierarchy:39` raw[L_SURVIVAL]=clampf((5-food)/5)）**但 coeff 是有界軟乘子 [0.15,1]，只壓別選項、推不動求生自己過 1.0**。
- v2 實測（food_days=1、野心統一 Team10）：覓食 util=**0.91**(封頂) vs 建設=**1.14**(base 1.135+承諾 0.3) → **建設贏到餓死**。就算 esteem urgency 歸零建設仍 util≈1.05+0.3 > 覓食 → **esteem 門檻(Fix3)只是次要加劇，主根是求生量級封頂**（systems 已 `terms.gd:52-54` 覆核坐實）。
- 真根2：統一隊兩安全網空轉——Fix2 漸進只管「多久重算」不管「重算誰贏」（重算仍選建設，decision_count 暴增 965）；PRIO_SURVIVAL 硬 floor（`faction_ai:3063-3064`）v2 已對統一隊/solo 非子隊退役 → 統一隊求生全靠 util argmax，而 util 求生封頂贏不了 = 安全網有名無實。

## ★層0（最底層地基，優先做）：求生 util 量級復原
**沒有層0，門檻/預算調再好，極端飢餓求生仍贏不了**——層0 是所有上層人格化/預算成立的地基。
**設計（vision A：util 競爭框內、量級碾壓非硬中斷）**：
- `DecisionEngine.rank_scored`（`decision_engine.gd`）算完各 option `u` 後，對 **survival-class option**（`DecisionOptions.SURVIVAL_OPTION_SET`）在**極低糧**時加**加法式 boost**：
  ```
  # 層0 安全氣囊:極低糧→survival option 加法超量級,突破 coeff 天花板奪回 argmax。
  # floor 低→正常隊靠層1/2/5 安全網不觸發;boost 頻率=健康指標(常觸發=安全網失職)。
  if ctx.food_days < SURVIVAL_BOOST_FLOOR and opt in DecisionOptions.SURVIVAL_OPTION_SET:
      u += SURVIVAL_BOOST_MAX * (SURVIVAL_BOOST_FLOOR - ctx.food_days) / SURVIVAL_BOOST_FLOOR
  ```
  - `SURVIVAL_BOOST_FLOOR` **低**（TEST VALUE ~2 天，遠低於人格安全存量目標）→ 安全氣囊非日常剎車。
  - `SURVIVAL_BOOST_MAX` 夠大（TEST VALUE ~2.5）→ food→0 時 survival util →~1+2.5 碾壓任何 dev（建設 1.14）→ 奪回 argmax。隨 food→0 線性放大（復原舊 12 域碾壓語意）。
  - **加法**（非乘法/非 coeff）→ 突破 [0,1] 封頂。
  - **★★插入點寫死（reviewer 二次異質框外審唯一條件 2026-07-14）**：boost **必須加在 `u *= _coeff`（`decision_engine.gd:29` 對應行）之後**，**絕不可在 coeff 乘法之前**——否則 boost 2.5 被 `COEFF_FLOOR=0.15` 打折剩 0.375，起不到碾壓 1.14 的保底。`+= COMMITMENT_BONUS`(:37) 之前或之後皆可（加法不敏感）。邊界 food_days=FLOOR 時 `(FLOOR-food_days)/FLOOR=0` 線性平滑銜接，無 flip-flop。
  - **範圍＝全 SURVIVAL_OPTION_SET，勿縮到只覓食/買糧**（reviewer #1：等量加不改 survival-class 內部相對序，只集體破頂；縮範圍會讓「只能投靠/掠奪才活」的隊卡在頂下選不出正確求生）。
  - **restores 統一隊求生**（經 util，非重加硬 floor）→ Team10/TAG_PRODUCE 統一隊極低糧時 survival 奪回 argmax，不再發展死。
- **真根3 立場翻正**：改 `need_hierarchy:70-71` 註解（刪「野心餓死=特色」定義）→ 明載「性格調日常風格，層0 boost 保證極端不結構性餓死」。
- **determinism**：純算術（food_days/const），零 randf。

## 層0 與上層關係
層0（保險）+ 層1 漸進偵測（多久重算）+ 層2 人格安全存量（日常目標）+ 層5 預算分配（日常剎車）+ 層3 認武器（買得起）+ 候選1 賣糧對稱（不自餓）= **兩層防線**：日常安全網讓隊不掉危機區（boost 少觸發），層0 兜極端。**boost 觸發頻率低 = 整套健康**。

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
- **∴ 三個效果**（無新 option、無新玩家行為，純 drive 曲線吃人格目標）：
  1. **層4 鋸齒改善（★假說待驗，非架構保證——reviewer 異質框外審降級 2026-07-14）**：買糧 drive∝gap→補到人格目標趨零→**傾向**收手在人格化安全存量而非 DESPERATION(3天)。**但 `rank_scored` 是 flat argmax、無 lexicographic「先填滿食物再看下個類別」保證**：食物補到一半時若軍備/發展 gap 反超，argmax 會跳走，食物**可能停在人格目標以下**＝鋸齒**地板抬高/齒變淺，非保證消除**。∴ 這是「**預期改善的假說**」，量測驗證，**非已證湧現**。殘餘鋸齒（真赤貧除外）→ 補獨立層4（驗收④）。
  2. **層5 預算分配（傾向，非硬保證）**：某類別補到目標→其 drive 落→argmax 傾向轉到下個最缺類別→**傾向**任一項不吃光；但同 flat-argmax 性質，target 高的類別 gap 可能長期最大→該類別偏重（=人格光譜設計意圖，非 bug；風險=target 太高致收斂超遊戲時長，驗收⑤ 抽驗謹慎隊仍升階把關）。
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
- 提供單一 helper（**home = `DecisionTerms`**，reviewer 定案 2026-07-14：三讀取者 need_hierarchy/terms/trade_valuation 都 import DecisionTerms 較乾淨，need_hierarchy 已有向 decision 層 import 先例如 DESPERATION_DAYS）算 `category_target(leader, category)`；層2/層5/候選1 全呼此**單一源**（judge 盤點精神：不並存散落常數）。
- **★scope 界（systems HOW 裁，控 blast radius）**：本 slice **只實例化「食物安全 + 軍備 + 發展」三類別 + 相關 option**。非食物 gate（佔村 OCCUPY_MIN_POP/血仇 FEUD_ATTACK_MIN/匱乏搶 SCARCITY_RAID_MIN/capability VIABLE_ARMED_RATIO）**同框架、延後 follow-up 逐 gate 遷入**（非本輪，非 attrition 相關，一次全遷=過大 blast radius）。框架設計成可擴，本輪只接食物簇。列 known_issues 追蹤 follow-up。

## 排之後（known_issues，用戶定）
- 候選3：faction 不救成員求生 + 徵收從餓的窮成員抽血（無反向補糧 directive）。
- 候選4：breed「養不起還一直生」正反饋（只看瞬時 needs.food>0.7，無人均存糧剎車）＝Team7 pop 暴崩候選。
- 非食物 applicable gate 人格化 follow-up（候選2 框架擴用）。
- 層4 鋸齒獨立機制（僅當本 slice 量測後殘餘鋸齒、且非真赤貧才補）。

## 驗收法（measurer 標準床，一次跑 seed1337/42/7，全 slice A；★用戶鐵律：全好才量、不半套 bisect）
0. **★層0 求生量級（headline·主根）**：極低糧統一隊（Team10/14 型）**survival 奪回 argmax、不再發展死**；`建設` winner **不再 ~94% 鎖死**（餓隊選求生非建設）。
0b. **★boost 觸發頻率低（健康鐵律）**：survival boost 觸發次數/隊·時間**低**（正常隊靠層1/2/5 安全網不掉危機區）；**常觸發＝安全網失職**（回報，非 boost 壞）。boost 頻率本身當健康指標報。
1. **attrition 回落 ≈ main baseline**（headline；branch vs main 同世界，從惡化 1.9-3.7× 回落）。
2. **Team10 thrash 仍治好**、**established 不退**、determinism、憲法閘綠。
3. **Team14 型「滿手武器買不起糧餓死」消除**（層3；weapon-rich has_specie true + barter 換糧成交 `trade.barter_deal`）。
4. **★層4 鋸齒（假說待驗，reviewer 條件：別二元 pass/fail）**：measurer **明確區分三態**——(a)鋸齒消失(買到人格安全存量才收手)＝假說成立；(b)**鋸齒變淺/地板抬高但仍在**＝部分改善(符合預期，非失敗，別當 fail 掩蓋)；(c)鋸齒如舊＝假說不成立。(b)/(c) 且非真赤貧(無錢/武器/貨)餓死 → 回報，補獨立層4。**別用二元 pass/fail 掩掉「部分改善」訊號。**
5. **★資源分配浮現個性非二元擺盪**：抽驗謹慎隊(食物比例高、有 buffer)vs 野心隊(軍備/擴張比例高、薄糧)——**非「全砸買糧 or 全砸軍備」二元**；謹慎隊仍能升階（非變純糧倉廢發展）；野心隊不因薄糧即崩。
6. **候選1 賣糧不自餓**：囤貨/賣糧隊不再賣到 <buy-panic 線後自己掉恐慌。
7. **reviewer 沿用條件**：attrition+reeval 頻率雙報；經濟無扭曲（糧價/coin 流無暴走）。

## 觸及檔（架構增量，Slice A）
`decision_engine.gd`（★層0 survival boost + `SURVIVAL_BOOST_FLOOR/MAX` const）、`decision_context.gd`（類別 gap/target 入 ctx；food_days 已有）、`terms.gd`/`need_hierarchy.gd`（drive 吃 gap-to-target + 統一 `category_target` helper + 真根3 註解翻正）、`trade_valuation.gd`（候選1 賣糧 reserve）、`team_data.gd`（若需類別 target 快取欄）。單一 owner 收斂人格門檻函式。

## 內部 build 序（implementer 參考，仍一次量測）
① `category_target` helper（單一源，收編層2 esteem threshold）→ ② 買糧/賣糧 drive+reserve 吃 food_security_target（層2 對齊+候選1+層4 吸收）→ ③ 軍備/發展類別 gap drive（層5 分配）→ ④ 處境 override 接既有 survival coeff。層3 Fix3c 獨立可先做。
