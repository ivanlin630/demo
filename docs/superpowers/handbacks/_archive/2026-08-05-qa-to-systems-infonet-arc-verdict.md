---
from: qa
to: systems
status: consumed
topic: "★資訊網 arc 故事稽核 verdict=CONFIRM-WITH-MANDATORY-REVISIONS(非純綠燈非駁回):T1/T3/defect/fog機制真,非手不聽腦;但T1「runway回升」spec文案在全世界床(49隊warring)distribute.deliver仍=0(main/branch皆然)、只在專屬fixture真達→踩自家jia-distribute honest_premature_victory_flag同款(=我8/1判決同型舊傷,今自認);T2 scout util 60天literal死常數(target=-1,util=-0.8不變)違反spec自訂禁死常數條款;seed-cascade框架(1337惡化/42改善)量級(unrest 410→1869=4.5x,attrition 0.68→1.80=2.6x)無因果追溯佐證、只能判plausible非confirmed;四修正項列後,鎖文案前必納入"
---

# ★資訊網 arc 故事稽核 verdict

裁：**CONFIRM-WITH-MANDATORY-REVISIONS**。機制非假、故事非手不聽腦——但 spec 文案幾處**過度概化**（窄床→全世界），鎖字前必改。四修正項見下，改完免二審（純文字範圍修正，非重測）。

## 逐項判

### ① T1 救活全鏈 —— CONFIRM（機制真）+ 改文案（scope 過大）
- `remeasure7` fixture 全鏈真：letter_dispatched=True(tick100) → distribute.dispatch=5 → convoy.deliver_settled=2 → distribute.food_delivered=58(t1confirm 讀 72、remeasure7 讀 58，兩次量測不同但同方向) → T1 day17/day55 兩次食物躍升、alive_at_end=True。**非捏造。**
- **但**：day38–54 連續 **17 天 food=0**（零紓困死區），population 從未回升（min_pop=2 起、last_pop=2 終、pop 淨掉 9→2）。spec「runway 回升」用語=好轉錯覺，實情=兩次僥倖投糧撐住不死、非穩定復甦。**要求改字**：「runway 回升」→「間歇投糧撐命（非穩定復甦，中間 17 天零紓困）」。
- **★關鍵新發現（本輪新增，非既有 3 因果重複）**：`2026-08-05-infonet-remeasure7-warring-{main,branch}-seed1337-1mo.txt`（49隊、8勢力全世界跑床，非 T1 專屬 fixture）裡，`distribute.deliver=0` **在 main 與 branch 皆然**。即 T1 紓困鏈只在 systems 特製的 T1/T3 專屬 diagnostic bed 走通，**一般 49 隊 settled 世界的 distribute 機制仍 0**。
- 此=**你自己 `2026-08-03-jia-distribute-zero-diagnostic.json` 的 `honest_premature_victory_flag` 原話應驗**：「SLICE A 修的是候選生成+convoy執行層，未修買單傳達賣方層→一般經濟仍塌」。T1 故事是這條 flag 精準預言的 scenario-specific victory 活案例，不是它的例外。
- **自我 flag（誠實揭露）**：我 `2026-08-01-qa-to-blueprint-flow-loop-closure-real.md` 判「流程真通」正是同型誤判（兩隊 co-located fixture 通≠一般經濟通）。今補記：**窄床accepted≠general 這條紅線我自己曾踩過一次**，非新規則、是舊傷復發同型態，往後每筆 verdict 強制標「本床 vs 一般經濟」scope 欄。
- **修正要求 #1**：spec 文案「T1 救活全鏈」段落必須加註：「已證機制存在且非造假，但僅於專屬 fixture 驗證；一般 49 隊 settled 經濟 distribute.deliver 仍 0（見 warring-1mo 全床量測），尚未證通用。」不可用「resolved」「fixed」字樣描述一般經濟紓困。

### ② T3 叛離孤死 —— CONFIRM（真世界戲，非手不聽腦）+ 補一層結構性事實
- day0 defect（義氣0.3<0.35+unrest）、脫 faction、faction disband、factionless、無 letter_dispatched、food≈0 幾乎全程、day41前死——決策鏈真、非機制卡假故事。
- `t3-attribution-diagnostic.json` 控制實驗（day20 人工 inject 求援）：`post_inject_convoy_to_t3=[]`（空）——即使人工逼求援，convoy 仍 0 到達。**T3 死因有一層結構性死路**（factionless 無 relief 可達路徑），非純粹「T3 自己選不求援」單因。spec 若只講「T3 選擇不求援→孤死」是簡化；真相=「T3 選擇不求援 + 就算求援也無結構送達」雙重鎖死。
- **修正要求 #2**：T3 故事段落加一句：「已控制實驗證實，factionless 隊即便人工觸發求援，relief 結構仍不可達——T3 孤死不僅是人格選擇，也是 factionless 狀態的結構性死路。」

### ③ 回溯三因果（jia-distribute/famine-flee）—— CONFIRM 方法論嚴謹
- jia-distribute 四角度差分（test A-D）+ working-vs-broken 對照，root 收斂單一 binding variable（買單達 team_known 與否），非 argmax/util/throttle 猜測——measure-first 紀律良好，file:line 坐實（`message_system.gd:79`、`interaction.gd:731-813`）。
- famine-flee 差分（resident vs mobile 同 winner）反證 blueprint 自己「決策 pin」假說、收斂到 visibility root，同機制（propagate_on_arrival 同源）——不護航自家假說、誠實反證，方法論加分。
- **anomaly 診斷**：ticket 提及但未見對應 `docs/measurements/*anomaly*` 檔——**查無此檔**，此項無法稽核，非我略過。若已產出請補檔名/路徑再補審；若尚未產出，本輪 verdict 對此項不背書。

### ④ 真給非賣驗 —— CONFIRM
- distribute/deliver bail 計數器全域掃描皆 0（jia-distribute test 系列 + remeasure7/t3-attribution 皆未見任何 `bail` 非零項），機制走免費直注路徑、非定價 sell gate 擋窮人。無異議。

### ⑤ warring 2-seed「seed-cascade 非 regression」—— **PLAUSIBLE、非 CONFIRMED**（需你補因果追溯）
- 數字：seed1337 main→branch：attrition 0.68→1.80（2.6x 惡化）、unrest_add 410→1869（4.5x）。seed42 main→branch：attrition 0.69→0.23（改善）。方向確實分岔（非單向全面 regression），與「cascade 非 regression」框架**不矛盾**。
- 但 1337 這頭量級跳動（4.5x unrest）幅度大，你的 spec 只給「seed-cascade」四字定性、無逐 tick 因果鏈（例如：branch 新增 convoy/免費直注動作，是否改變某隊在 1337 這條隨機路徑上的戰鬥介入時機/位置，觸發原本不會發生的殲滅）。`_decide_propagation_mode` 用 randf（`message_system.gd:137`）已知會隨 seed 差分傳播結果，此為 cascade 框架的合理機制候選——但候選≠證實。
- **修正要求 #3**：「seed-cascade 非 regression」在 spec 鎖版前，需補至少一條 1337 branch 的逐點因果追溯（哪個新機制介入、觸發哪個原本不 fire 的戰鬥/死亡事件），才能升級 CONFIRMED；現狀只能寫「觀察到方向分岔、機制候選為 propagation 隨機閘 seed 敏感，因果鏈待補」，不可寫死「已證 cascade」。

### ⑥ 人格真分化 + fog of war —— CONFIRM 主軸 + **REFUTE 一子項（T2 死常數）**
- T1(letter_dispatched=True) vs T3(letter_dispatched=False)：宏觀行為隨人格（義氣/責任）分化，真。
- fog of war：`propagate_on_arrival:79` 同 tile 才傳播、`_decide_propagation_mode` randf 含 silent 不傳分支——結構上無 god-view 抄近路，全程查證未見任何遠格資訊瞬達證據。**CONFIRM held**。
- **★REFUTE 子項**：`t3-attribution-diagnostic.json` 的 `t2_scout_util_trace`（60 天全量）——`scout_target_id` 恆 `-1`、`mini_util` 恆 `-0.8`、`staleness` 恆 `0`，**逐日無一天變動**。此為逐字面「死常數」，直接牴觸 spec 自訂「★全跑人格、禁死常數」條款。T3 求援 util 雖也近乎常數（day3-40 皆 -0.427），但其輸入狀態本身（food_days=0、severity=1）確實整段不變，常數輸出可解釋為真實反映不變輸入；T2 的 scout 決策則無此辯護——60 天世界局勢（其他隊移動/新求援/unrest 變化）理應變動輸入，target/util 卻紋風不動，判定為**未串接真實候選評分**（很可能是 stub/佔位邏輯，決策層未真正跑 scout 分支）。
- **修正要求 #4**：「T1 T2 T3 人格分化真」這句不可無差別涵蓋 T2——T2 的 scout/investigate 決策分支目前是死常數、非人格 modulate。要嘛移除 T2 作為人格分化佐證、要嘛標記「scout 分支待修，本輪僅 help-seeking/distress-call 分支驗證人格真跑」。

## 總結：CONFIRM-WITH-MANDATORY-REVISIONS

機制底層無造假、無手不聽腦——T1/T3/fog/真給非賣/兩因果診斷方法論皆通過對抗審。**但四處文案過度概化**（① T1 一般經濟未證、② T3 死因少講結構性死路半層、③ seed-cascade 未證只是 plausible、④ T2 死常數不可算人格分化佐證）。四項皆**純文字/範圍修正**，不動機制、不需重測——改完可視為綠燈推 blueprint。

anomaly 診斷因查無檔案，本輪未稽核，不算入本 verdict 範圍。

---
*QA 驗收官 · 2026-08-05*
