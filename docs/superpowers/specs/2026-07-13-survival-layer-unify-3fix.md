# Spec：求生層統一 3-fix（Team10 override thrash + crisis edge-trigger + esteem 乘法陷阱）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: 三根皆 file:line 坐實（見下），R① 自 factcheck 通過（無 premise_contradiction）
frame_challenge: ★三對齊（強結論=退役 legacy 子系統+重設計核心公式／redirect 大工／decision-core 難逆）→ **R② 建議升異質框外審**（別 Opus 代 + refute prompt，見 00_roles §框外挑框）

## 為何三項一份 spec
三根同屬「**求生/需求決策層未統一**」家族，且**互相咬合**——分開修會漏掉交互：
- Fix1 退役非-unified 求生 override → 求生改走引擎（rank_scored）。但引擎 re-pick 受 `_should_reeval` cadence 閘。
- Fix2 crisis edge-trigger → 餓隊在 override 退役後，crisis 重評**正是**它的求生安全網（edge 觸發+/4 節流＝commit 夠久執行，非每 tick thrash）。
- Fix3 esteem 漸進 → 餓隊靠 Fix1+2 穩定買糧脫困後，能真的爬升到生產（否則脫困也卡回買糧）。
∴ 三者是**同一條 survival→esteem 決策路徑**的一次性統一，非三個獨立補丁。

---

## Fix 1：退役非-unified `_evaluate_survival` override（Team10 真殺隊 thrash）

**根（坐實）**：tick loop `faction_ai_system.gd:680 _evaluate_solo` + `:737 _evaluate_survival` 同 tick 對非-unified 隊跑**兩個決策生產者**：solo rank(idle→建設 ambient) vs legacy override(缺糧→買糧/貿易)，互蓋 livelock → Team10 day89 餓滅。unified 隊 `:3046 uses_unified→return` 跳過故無病 → override 是 unification arc 未退役 legacy。

**設計（reviewer R② 修正後 = option A：退役範圍排除子隊）**：
非-unified **且非子隊**的隊求生走引擎；**子隊維持 legacy override**（reviewer 抓：子隊建造中無非-IDLE 引擎路徑，全退會餓死 zombie，見下）。
1. `_evaluate_survival` 的 legacy 求生 body（:3065 起）gate 改為：
   ```
   if uses_unified(team) or team.parent_team_id == -1:
       return   # 有引擎求生路徑（unified 任隊 / 非子隊 solo·成員走 _evaluate_solo/_decide_unified）→ 求生走引擎
   # 剩：非-unified 「子隊」(parent_team_id != -1) → 保留下方 legacy override body（子隊無非-IDLE 引擎路徑）
   ```
   求生選擇對非子隊統一由 `_evaluate_solo→rank_scored`（survival option 覓食/買糧/掠奪/乞食/返家/紮營/併入 已在引擎 repertoire + coeff 求生層 urgency 高→自然勝出）承載。
   - **★Team10 確認 fix 得到**：probe（`docs/measurements/2026-07-13-team10-type-probe-<hash>-dirty.log`）→ Team10 `parent_team_id=-1 faction_id=-1 tags=["獨立軍隊"]`＝**非子隊獨立隊，走 SoloAI**（`[SoloAI] Team10→…`）→ option A 退其 override→ rank_scored 承接求生，收斂。thrash 根（SoloAI 建設 vs override 掠奪/覓食 每 tick 互蓋）消除。
2. **為何排除子隊（reviewer 抓的 regression）**：`_evaluate_subteam`（:1620-1660）對 TASK_BUILD(:1625)/CONSTRUCT/UPGRADE/EXPAND(:1629) **提前 return 不進引擎**，只 IDLE→`_decide_subteam`。子隊全退 override → 建造中子隊**完全無求生評估**（連 :3095 一般餓死觸發都沒了）→ 可預期 zombie 餓死 regression。∴ 子隊**維持現狀 legacy body**（含一般觸發+礦山豁免），blast radius 最小。子隊求生本走不同路徑，切開不影響 Fix2/Fix3。
3. **必須保留（非決策、跨全隊）**：`:3035-3045` TASK_CAMP 到達立營在 gate **之前**，對全隊成立，不動。
4. **invariant 守**：
   - 進得去出得來：非子隊靠引擎 latch（:1825 stuck-release + :1798 reeval gate）；子隊靠原 legacy latch。皆無永凍。
   - 餓隊必反應：非子隊靠 Fix2 crisis 確保餓時 `_should_reeval` 觸發——**Fix1 依賴 Fix2**，故同 spec；子隊靠原 override 每 tick。

**風險**：非子隊求生反應從「每 tick override」變「reeval cadence（crisis /4）」。可接受＝commit 夠久執行滿週期正是治 thrash；驗收法①守餓隊不因 cadence 太疏反應不及。

---

## Fix 2：crisis level-trigger → edge-trigger（重評 381/13087 根）

**根（坐實）**：`_should_reeval`（:1781）`if _decision_crisis: return true` 是 level-trigger——慢性糧負隊每 tick trip crisis（reeval.crisis=13087=93%，seed1337 log:6455）→ 繞過 cadence，`:1802` 本想給 crisis 的 `/4` 短 throttle 變死碼。

**設計**：crisis 改邊緣觸發 + 持續期走 /4 cadence。
1. TeamData 加 `crisis_latched: bool = false`（data 欄）。
2. `_should_reeval` crisis 分支改：
   ```
   var in_crisis: bool = _decision_crisis(state, team)
   if in_crisis:
       if not team.crisis_latched:
           team.crisis_latched = true
           return true          # edge：進入 crisis 當下 fire 一次
       # 持續 crisis → 不每 tick，落下方 cadence 閘（:1802 排程已 /4）
   else:
       team.crisis_latched = false   # 離開 crisis → 解 latch，供下次 edge
   ...
   return state.world.current_tick >= team.decision_eval_next_tick
   ```
3. 效果：crisis 13087 → edge 次數（每次進 crisis 1）+ /4 cadence 命中（60 ticks 一次）。預估 Team7 381→低百，全世界大降。
4. **determinism**：新欄初值 false，純確定性狀態機，無 randf。
5. **invariant 守**：新 crisis 仍即時響應（edge fire）；持續 crisis 靠 /4 cadence 不失反應（6 小時一次，餓隊足夠）。★與 Fix1 咬合：Fix1 退 override 後，此 crisis 重評＝非-unified 餓隊唯一求生觸發點，故 edge+/4 節流須確保「進 crisis 立即 + 持續期定期」雙保。

---

## Fix 3：esteem 乘法門檻雞生蛋陷阱（低 pop 隊卡生存底層無法升階）

**根（坐實）**：`need_hierarchy.gd:57 raw[L_ESTEEM] = food_ready × safe_ready × ambition_gap`，`food_ready = clampf(food_days/SURVIVAL_SATED_DAYS(5),0,1)`（:53）。買糧 applicable 於 `food_days<DESPERATION_DAYS(3)`（`options.gd:136`/`terms.gd:6`）→ 救回量大概率只到 3-5 天邊緣，`food_ready` 碰不到接近 1 的舒適線 → esteem urgency 卡低 → 生產(affinity esteem 0.5,`need_hierarchy.gd:95`) 的 `consistency_coeff`(:128) alignment 低→壓 FLOOR 0.15 → 生產 util 永輸買糧(survival 0.9→coeff~1) → 自我強化 survival-lock。已確認生產全程在 candidates（非 applicable 濾掉），是每輪算分穩定輸。

**設計**（兩桿，implementer 量測選定，reviewer 審）：
- **桿 A（主，漸進非乘法門檻）**：esteem `food_ready` 的參考線從 SATED(5) 降到「脫離絕境即開始給分」，讓「剛脫困(food_days≥3)」的隊 esteem 就 ramp，而非摸到 5 才啟動。
  - **★實作採用（implementer 修正 2026-07-13）**：`food_ready = clampf(food_days / ESTEEM_FOOD_REF_DAYS(3), 0, 1)`（參考線 5→3，脫困即近滿）。
  - ⚠️ 原草稿曾寫 `(food_days-DESPERATION)/(SATED-DESPERATION)` = **方向寫反**（food_days=3→0，比舊 f/5=0.6 更低，與 intent 相反）→ 作廢。implementer 抓到並改對，systems ACCEPT。★TEST VALUE，measurer 驗收③量校（f/3 若太急致復餓再 tune 曲線）。
- **桿 B（可疊，脫困緩衝期）**：隊 food_days 上穿 DESPERATION 後給一段 grace（如 N 天）內 esteem urgency 加成/floor 抬高，讓升階念頭有機會冒出、生產有機會贏一次啟動正循環。需 TeamData 記「脫困 tick」或用既有 previous 欄。
- **保留**：乘法 safe_ready × ambition_gap 的語意（不安全/無爬升空間→不該追地位）合理，**只鬆綁 food_ready 這一桿**，不動另兩桿（避免過度改寫，最小手術）。

**風險**：放寬 esteem 可能讓「剛脫困但仍脆弱」的隊過早追生產而復餓。→ 驗收法③守「脫困隊不因升階復崩」。傾向桿 A（漸進）優先，桿 B 視量測補。

**invariant 守**：需求層獨立（§2，esteem 不讀他層 urgency，只讀世界訊號）——桿 A/B 只改 food_ready 對 food_days 的映射，仍只讀世界訊號，守。

---

## Fix 4：覓食 util 可達性預檢查（追加，blueprint 2026-07-13；look-before-leap 輕量版）

**根**：覓食 applicable（`options.gd:81-84`）只檢查 `pop <= FORAGE_VIABLE_POP`，**不檢查 `_find_forage_tile` 搆不搆得到獵物** → util 恆高(單 survival_pressure term)，選了才在 dispatch 撞 target=(-1,-1) 靠 fallthrough 補救。model 看起來「笨」（選才知搆不到）。blueprint 要：**選之前就知道搆不到**。

**設計（鏡射既有 gather-flag pattern，最小手術）**：
1. `decision_context.gd` 加 `var has_forage_tile: bool = false`（+ 選配 `var forage_pos: Vector2i = Vector2i(-1,-1)`）。
2. `gather()`（鏡射 `has_food_market` 那段 :205-208）：`var _forage: Vector2i = _fa._find_forage_tile(state, team); c.has_forage_tile = _forage != Vector2i(-1,-1); c.forage_pos = _forage`。★finder 只跑一次(radius-1，7 格，cheap)。
3. `options.gd:81-84` 覓食 applicable 加 `and ctx.has_forage_tile`：
   ```
   "覓食":
       if ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile:
           out.append(opt)
   ```
   → 搆不到獵物時覓食**根本不入 candidates**（非入了 util 高再撞牆）→ rank 直接在可達 option 裡選 → 正常情況 fallthrough 不常態觸發（fallthrough 仍留當保險）。
4. 選配：`to_task` 覓食 target 可讀 `c.forage_pos` 免二次 scan（implementer 判；to_task 不取 ctx，留原 `_find_forage_tile` 亦可，cheap）。

**scope 裁定（blueprint 問）**：**只做覓食**。稽核其餘 target-resolving option——買糧(`has_food_market`+`has_specie`✓)/返家補給(`has_home_outpost`✓)/掠奪·攻擊(`has_weak_prey`/`feud_target`✓)/佔村(`has_occupy_target`✓)/併入(`consolidate_target`✓)/吸納(`absorb_target`✓)**都已有 applicable 可達性 gate**，覓食是唯一漏的。∴ 範圍不擴大，不需 blueprint 再裁。

**invariant 守**：不改 fallthrough 機制（保險留）；純把可達性從「dispatch 事後」提前到「applicant 事前」。determinism：finder 純確定性讀 tile。

---

# ★修訂 v2（2026-07-14）：attrition 惡化根治——Fix2 漸進安全網 + Fix3 門檻人格化

**背景**：4-fix 全維度驗收（`2026-07-14-measurer-to-blueprint-survival4fix-acceptance.md`）發現 **population attrition 惡化 1.9-3.7×（3 seed 一致，硬 FAIL）**，established 無回歸、determinism MATCH。blueprint 讀死亡故事線(Team14 seed1337)+ systems 讀 diff 坐實根因，用戶裁定修向（`2026-07-14-blueprint-to-systems-attrition-rootcause-personalize-threshold.md`）。

**根因（坐實）**：
- **Fix3 主兇**：`food_ready = food_days / ESTEEM_FOOD_REF_DAYS(3)` → food_days=2.5(已跌破絕境) 時 food_ready 仍 =0.83 → esteem urgency 高 → 生產/採購 coeff 壓過買糧（生產 alignment 0.57 > 買糧 0.45 @food_days=2.5）→ **team 餓著發展不買糧** → famine 死。/3 過低=矯枉過正（舊 /5 太難=trap，/3 太易=餓死）。
- **Fix2 補刀**：crisis edge-trigger 只抓「暴跌」；**慢性漸進糧損(food_flow_avg 輕負，非 <DEEP -2.0)不 trip crisis** → 不 latch 不提前重評 → team 停採購過 cadence → 餓死。舊 level-trigger 93% 重評雖吵，但每 tick 重看食物＝誤打誤撞安全網，被 de-patch 犧牲。

**診斷通則命中**：安全門檻是**全域死常數 pre-empt 人格**＝變相補丁（照妖鏡「死常數人格化」同款病，`潰退門檻#1` 已治過，此安全門檻同型漏）。

## Fix2-v2：crisis 加漸進滑坡觸發（安全網不能省，主藥）
`_decision_crisis`（:1766，純讀 team 欄零 gather）加漸進項：
```
# 既有：pop 驟降 / food_flow_avg < RUNG_CRASH_FOOD_DEEP(-2.0)=暴跌
# 新增 v2：慢性糧滑坡(輕負 flow)=漸進安全網→糧一開始流失就週期性拉回確認補糧
if team.food_flow_avg < GRADUAL_DECLINE_FLOW:   # TEST VALUE ~-0.5（DEEP -2.0 與 0 之間）
    return true
```
- **不 revert edge-trigger 機制**：`crisis_latched` 節流仍在→漸進 crisis edge fire 一次 + 持續落 /4 cadence(60 ticks=6h 重看糧)，非每 tick。∴ 保安全網又不回 13997 spam（預估 reeval.crisis 34→數百，遠低基線）。
- 純讀 `food_flow_avg`（已存欄），零 gather、零 randf，守原設計。
- ★measurer 驗 reeval 頻率不失控（仍遠低 13997）+ 餓隊被漸進拉回補糧。

## Fix3-v2：ESTEEM_FOOD_REF_DAYS 人格化（死常數→f(領袖人格)）
`need_hierarchy.gd` esteem food_ready 參考線改人格化：
```
static func esteem_food_ref(leader_values: Dictionary) -> float:
    var caution: float = float(leader_values.get("慎重", 0.5))
    var ambition: float = float(leader_values.get("野心", 0.5))
    # 謹慎↑→ref↑(存久才敢鬆懈發展)；野心↑→ref↓(薄庫存搏發展)
    return clampf(ESTEEM_REF_BASE + (caution-0.5)*ESTEEM_REF_CAUTION - (ambition-0.5)*ESTEEM_REF_AMBITION,
                  ESTEEM_REF_MIN, ESTEEM_REF_MAX)
# food_ready = clampf(food_days / esteem_food_ref(leader_values), 0, 1)
```
- TEST VALUE 建議：`BASE=4, CAUTION=4, AMBITION=4, MIN=2, MAX=8`（謹慎狂 caution=1/ambition=0→ref≈7 存久；賭徒 caution=0/ambition=1→ref≈1→clamp 2 薄庫存搏）。
- **效果**：Team14 餓死 → 從「全體共用死常數的系統 bug」變「領袖是好高騖遠賭徒，剩薄糧就敢買武器賭發展，賭輸餓死」＝**角色缺陷致死、有故事性**。謹慎領袖存糧多→存活但發展慢；trap 從「全體卡死」溶成「謹慎者保守/野心者搏」的人格光譜。
- **實作**：`compute_raw`（gather :323 呼，有 team→leader）取 `leader.values` 算 ref。need_hierarchy 讀人格 trait 非他層 urgency，守 §2。determinism：純算術零 randf。

## v2 觸及檔（增量）
`faction_ai_system.gd`(Fix2-v2 `_decision_crisis` 漸進 + `GRADUAL_DECLINE_FLOW` const)、`need_hierarchy.gd`(Fix3-v2 `esteem_food_ref` + 4 const，`compute_raw` 取 leader values；改簽名或內部 fetch leader)。

## Fix3b（併入 v2，blueprint 2026-07-14 第三條）：食物戰略備糧對稱化 + 安全存量水位＝Fix3 門檻同一參數

**根（比 Fix3 更深，坐實）**：食物採購**不對稱**——
- 買糧 applicable（`options.gd:133-135`）：`food_days < DESPERATION(3) and has_food_market and has_specie` = **純絕境救急**。
- 囤貨/貿易：`food_days >= SURPLUS(7)` 得戰略機會權重（`terms.gd:203` 只給貿易/囤貨）= **戰略主動**。
- ∴ **食物只有「絕境買糧」，無對稱「充足時戰略備糧」**。team 一到 food_days≥3 → 買糧 option **直接失 applicable**（模型眼中選項消失）→ 檯面只剩囤貨/買武器 → 跑去發展 → 糧跌回<3 買糧才冒出、常來不及。**不是模型選擇不備糧，是系統沒給「戰略備糧」選項**（像人只准快餓死才能買菜）。物資有戰略採購、食物沒有＝設計缺口，比 Fix3 門檻常數更根本。

**設計（與 Fix3 人格化門檻合併＝同一「安全感門檻」兩面）**：
1. **統一門檻函式**：`Fix3-v2` 的 `esteem_food_ref` 更名/擴為 `food_security_threshold(leader_values)`（同公式 f(慎重/野心)），**同時駕馭兩面**：
   - esteem food_ready（該不該鬆懈去發展）：`food_ready = clampf(food_days / food_security_threshold, 0, 1)`（不變）。
   - 買糧 safety-stock（該備糧到幾天）：見下 applicable。
   - 語意：一個「安全感」數字——謹慎領袖高(備糧多才敢發展)、賭徒低(薄糧就搏)。
2. **買糧 applicable 對稱化**（`options.gd:133-135`）：
   ```
   "買糧":
       if ctx.food_days < maxf(DecisionTerms.DESPERATION_DAYS, ctx.food_security_threshold) \
               and ctx.has_food_market and ctx.has_specie:
           out.append(opt)
   ```
   - `maxf(DESPERATION, threshold)`：**絕境永遠是地板**（賭徒 threshold=2 → max(3,2)=3 絕境救急、無戰略備糧＝符合賭徒；謹慎 threshold=7 → max(3,7)=7 戰略備糧到 7 天）。
   - `ctx.food_security_threshold` 於 gather 算填（取 leader values），mirror 既有 flag。
3. **buyfood_drive 加 security-gap 驅力**（`terms.gd:106-111`）：現只留旅費折扣 base 0.5-1.0；戰略帶(food_days∈[DESPERATION, threshold]) survival coeff 低 → 買糧 rank 恐永輸發展（blueprint 警「applicable 放行但 rank 永輸＝白做」）。加一項「低於安全線」驅力（非 hunger urgency，是「補到安全存量」的戰略驅）：
   ```
   var _gap: float = clampf((ctx.food_security_threshold - ctx.food_days) / maxf(ctx.food_security_threshold, 1.0), 0, 1)
   return clampf(0.5 + 0.5*_dd + SECURITY_STOCK_DRIVE * _gap, 0, 1)   # SECURITY_STOCK_DRIVE TEST VALUE
   ```
   越低於安全線→備糧驅越強→謹慎隊維持 buffer。糧價便宜/arb 可再加成（選配，避免無限買）。

**效果**：謹慎領袖 food_days 6→仍 <threshold 7 → 買糧 applicable + 有驅力 → 主動補到 7 → 有 buffer 抗波動 → 不週期性挨餓。賭徒 threshold 低 → 只絕境買 → 薄糧搏發展 → 可能餓死（角色缺陷）。**Team14 型「脫離絕境就棄糧買武器」消除**（謹慎者根本不會棄糧；賭徒棄糧=角色選擇）。

**觸及檔（Fix3b 增量）**：`decision_context.gd`（`food_security_threshold` 欄+gather 填）、`need_hierarchy.gd`（`esteem_food_ref`→統一 `food_security_threshold`，或 need_hierarchy 呼 DecisionTerms 的統一函式——避雙 owner，實作定單一 home）、`options.gd`（買糧 applicable maxf）、`terms.gd`（buyfood_drive security-gap + `SECURITY_STOCK_DRIVE` const）。

**★三條收斂同一 spec**（blueprint 問）：是——Fix2 漸進(安全網) + Fix3 門檻人格化 + Fix3b 備糧對稱化，三者共用**同一 `food_security_threshold(leader)` 人格門檻**，同屬求生決策層，一份 spec 一次實作一次驗。

## v2 未納（blueprint 留議，非本輪）
「求生該是可競爭 util 選項還是硬中斷」——更根本問題，blueprint 與用戶討論浮出未拍板，本輪先 Fix2 漸進+Fix3 人格化+Fix3b 備糧對稱化，留議。

## 驗收法（measurer 標準床，一次跑，seed1337 + 補 seed42/7）
1. **Fix1/2 治 thrash**：seed1337 3mo，Team10（及同型非-unified 隊）**無 `建設↔貿易↔idle` 每 tick livelock**；`[Survival]` thrash print 消失；Team10 **不再 day89 餓滅**（或至少 thrash-death 機制消除，餓死若發生須是真無解非 livelock）。
2. **Fix2 頻率**：`_should_reeval` 分支計數 reeval.crisis 從 13087 **大降**（預估 <2000）；Team7 decision_count 381→**低百**。（用現有 `reeval_attribution_bed.gd` + probe。）
3. **Fix3 升階**：低 pop 隊（如 Team7）脫離「67 天卡生存底層」——量 winner 分布**出現生產/建設升階**（非 100% 覓食/買糧）；且**脫困後不復崩**（pop 穩、food_days 站上 DESPERATION 以上）。
4. **Fix4 可達性預檢**：搆不到獵物的隊，candidates **不再出現覓食**（specimen trace：無 `覓食=..✗` 常態出現）；正常情況 dispatch fallthrough 不常態觸發；覓食 winner 分布只在真有獵物時出現。
5. **不回歸**：established 跨 seed 無退化（維持 seed7=1 等）；determinism byte-identical（新欄確定性）；憲法閘綠；無新 famine/death 惡化。
6. **★v2 attrition 回落（headline）**：branch vs main baseline 同世界（`seeded_warring_bed` 3seed×3mo），**attrition 從惡化 1.9-3.7× 回落到 ≈ main baseline 水準**（±可接受餘裕）；Team14 型「餓著發展」死亡消失（謹慎領袖存活，僅野心賭徒仍可能餓死＝角色缺陷非系統 bug）。同時 Team10 thrash 仍治好、established 不退。
   - **★reviewer 條件 #2（防 over-trigger 換皮）**：measurer 報告**必須同時附 attrition + reeval 頻率兩數字**（reeval.crisis/TOTAL 仍遠低基線 13997）——不能只報 attrition 過關；怕 Fix2-v2 漸進 spam 到某程度也壓低 attrition 但代價是效能/thrash 復發。
   - **★reviewer 條件 #3（防人格化 trap 換皮）**：抽驗**謹慎領袖隊（caution 高，ref≈7）長期(3mo)仍能在合理時間升階**（非永久 esteem 卡 0）——若謹慎隊全程升不了階＝trap 換皮沒解，回頭調 CAUTION 係數非 declare 完工。
   - **★reviewer 條件 #1（隱含 bisect）**：attrition 若沒回落到 baseline ±餘裕 → premise 訊號不足，屆時才要求真 bisect（隔離 Fix1/4 貢獻），非現在預防性做。
7. **★Fix3b 備糧對稱化**：謹慎領袖隊**主動買糧維持 buffer**（food_days 常態站在其 `food_security_threshold` 附近，非貼著 DESPERATION 3 天挨餓）；Team14 型「脫離絕境即棄糧買武器」死亡消除；賭徒仍可能薄糧餓死（角色缺陷）。**副作用守**：買糧活動增加不致經濟扭曲（糧價/coin 流無異常暴走）；winner 分布仍多樣（非全 buy food lockstep）。
5. **順帶觀察（非閘）**：Team7 pop 暴崩 60%（tick5580→9000）現象——三修後消失/改善＝連帶驗證；仍在＝另開查。

## dispatch 註（reviewer CLEAN 後）
- 觸及檔：`faction_ai_system.gd`（Fix1 override 退役 + Fix2 `_should_reeval`）、`team_data.gd`（Fix2 `crisis_latched` 欄 + 可能 Fix3 脫困 tick 欄）、`need_hierarchy.gd`（Fix3 food_ready 映射）、`decision_context.gd`（Fix4 `has_forage_tile` 欄+gather 填）、`options.gd`（Fix4 覓食 applicable gate）。注意事項寫本 spec。
- 三項一次實作、一次 measurer 驗收（用戶定：不分批）。
- task 完成判定 = systems + reviewer，非 implementer 自判。
