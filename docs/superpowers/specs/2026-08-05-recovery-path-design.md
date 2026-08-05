# 復甦路徑/村經濟可持續 — 給被救的村一條靠自己站起來的路（WHAT / vision）

status: LOCKED（2026-08-06：R① CLEAN + 底查 grounding 納入 §2.5[動詞通用、邊際經濟湧現、禁地型查表] → systems HOW）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-05
溯源：cohesion ①natural 四執行 blocker 同族收斂（race/target/need-gate/anon-exhaustion）→ 深根 = 村經濟不可持續；charity≠prosperity 判（relief=survive、thrive 要 flow-surplus）；用戶拍 A + 遷村令設計 2026-08-05。

## §1 防 crank 條款（同 cohesion 先例）
復甦 = 湧現結果非目標值：**無復甦配額**；動詞 util 全真值（禁 boost）；**村站不起來照樣站不起來**（爛地+爛領主+人太少=真死路存在）；量測驗**分化**（好領主投資的村真回升 vs 疏忽的照樣完蛋）。

## §2 三動詞 + 遷村令（全人格秤、真成本、零死常數）
1. **遷村（村自願）**：貧瘠村秤「沉沒成本（蓋好的據點、persist 統一既有秤）vs 前景（好地產出、經 belief 知道的地）」→ 決定搬。真代價（棄據點/路程風險）。
2. **★遷村令（領主端、用戶定兩層對抗）**：
   - 領主可下「遷村令」= **信使指令走資訊網**（信要真送到）；下不下 = 領主人格（規劃型整併/仁君勸+送搬遷糧/放任不管）。
   - **村收令 ≠ 服從**：從 vs 抗人格秤（忠/懼→從但**帶怨 unrest 累積**；傲/戀土→抗命）。
   - 抗命後果 = 領主人格（算了/斷賑濟/武力）——**武力押遷 = 軍事 arc（本 arc 只留鉤子）**。暴君強遷→怨→起義/叛離（既有出口）= 湧現劇情源。
3. **領主派移民**：送人非只送糧（勞力池既有:人到=產能到）。領主人格秤投資哪村。
4. **領主投資設施**：領主出料在村蓋設施（idle-labor→build 既有）→ 村產出爬過消耗線 → flow surplus → breed → 人力回補 = 真復甦。

## §2.5 ★底查 grounding 定案（2026-08-06）：動詞通用、選擇靠邊際經濟湧現（禁地型查表）
底查三態：山地滿升投資仍差 ×5.06 = **不可救**（遷村唯一路）；森林 **pop sweet-spot 極窄**（pop≥3 赤字）→ **移民對森林 = 負政策**（加人推村進赤字）、投資才划算（30mat 把打平線 pop2.8→5+）；平原 pop2 明顯盈餘 → 真 distress 必別因（劫掠/relief 延遲/事件、逐村查）。
**WHAT 裁**：**不寫「山→遷、森→投」查表**（那是策略腳本）——三動詞保持通用，**util 必讀真邊際經濟**：
- 移民 util = **目的村邊際產出**（多一人真加多少產 − 吃 0.8;森林邊際負 → 引擎自己算出不移）。
- 投資 util = **投資後預期 surplus 增量 vs 料成本**（ROI 真算）。
- 遷村 util = 他地前景 vs 沉沒（既有）。
→ 三態行為**從邊際數字湧現**、零地型 lookup。「人到=產能到」直覺被底查**修正**（僅在邊際為正的地成立）——記血證。
平原 distress = 先查因再開藥（care-loop scout 正好是查因工具）。CASE B 數字確證（規模經濟仍 absent）記 size-matter 長程。

## §3 開場經濟底查（measure-first、spec 鎖前）
各地型 × 村規模的**產耗打平點**：pop2 入不敷出（1.4<1.6）是「地不好」還是「人太少哪都活不了」？→ 定主力動詞（人太少→③移民主力；地不好→①②遷村主力）。含：最小可活村規模 / 各 tile 型產出曲線 / relief+投資成本 vs 回收。

## §4 前提（pending R①）
- P1 沉沒成本秤既有（persist 統一 merged）可 reuse 於遷村決策。
- P2 勞力池共址即產能（merged）→ 移民到村即效。
- **P3（R① 訂正=真缺口）**：`idle_employ_value` **util 公式可 reuse 當計算基礎**，但「建設」option 的 target **寫死自隊自 tile**（options.gd:40-46）——「領主出料指定**別的村**蓋」**結構上不支援** → 需**新建 lord-side 機制**（類 distribute/herald 的 lord-side dispatch：材料指定+convoy 交付 → **目標村自己的建設決策**收到料才真蓋）、**非簡單延伸既有 option**。HOW 範圍照此評估。
- P4 信使指令（資訊網 merged）可載「遷村令」類 directive。
- P5 unrest/起義/叛離出口（cohesion merged）可承接「被迫遷怨」。

## §5 量測（湧現、無配額）
- **被救的村真站起來**：relief→（移民/投資/遷）→ flow surplus>BREED_MIN → breed fire → pop 回升（cohesion ①natural 全閉環的真考）。
- **分化**：好領主投資的村回升;疏忽領主的村照樣完蛋;爛地村遷走或死。
- 遷村令劇情鏈可觀測（令送達/從帶怨/抗命/暴君逼反案例）。
- determinism / 感知鐵律 / QA 故事稽核照新常態。
