# 勢力凝聚力 — 拆死常數出口、真好處接進留走秤（WHAT / vision）

status: LOCKED（2026-08-05：R① CLEAN + exit-attribution 定案 emphasis[P4 真好處=PRIMARY、門檻 refinement=SECONDARY] → systems 寫 §2 HOW → R²）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-05
溯源：faction-fragility 三擋驗收（relief 窗被起義斷 / rep 床崩單勢力 / L3 無 cross-faction domain）→ 用戶拍 A 提前；統一路線圖 #7 政治入口。

## §1 ★防 crank 條款（用戶命門、寫死在第一節）
1. **凝聚力是湧現結果、不是目標值。** 本 arc 驗收**無穩定配額**（禁「X% 勢力存活」型指標——配額是 crank 溫床）。
2. **「留下來」的 util 必須＝真期望價值**（救援會救你[已量證]/保護/經濟共享/未來復甦路）。**禁忠誠加成常數、禁 boost 逼留**（乙 crank 教訓）。「走」的一側同樣真值（野心/受虐/更好去處）——**兩邊真值、引擎自己秤**。
3. **該散的散**：暴君/疏忽領主**就該**失人心（T2 型流失＝正確）。驗的是**分化**（好領主勢力比爛領主持久）。
4. **拆完硬閘世界仍散 → 誠實回報、不灌分**：代表真好處太弱 → 修好處的**真實性**（復甦路/保護有效性），非調分數。
5. 防線全套：R① → R²（防 crank＝明列審點）→ QA 故事稽核（留/走故事合不合人格）→ 用戶驗收。

## §2 設計（WHAT）——★emphasis 依 exit-attribution 定案（2026-08-05）
> **量測定案：exits 是 genuine distress-driven**（matched-honor 對照：餵飽 honor0.34 六十天不走、餓的 honor0.34 day0 走——真 gatekeeper=unrest 餓值非 honor 門檻）→ **拆 genuine 行為=反向 crank**。∴ 主刀change：
> **PRIMARY = P4 真好處接留走秤**（給真餓 member 留下的理由：領主 relief 救援史/保護/經濟共享 → 好領主留住人、爛領主流失 = 正確分化）。
> **★belief guardrail**：stay-util 讀「**自身經歷**（被救過=自我記憶）+ 聽聞的領主聲譽（belief）」——**禁讀全知統計**（god-view）。
> **SECONDARY = 死門檻 refinement**（0.35 cliff → distressed 之中連續 honor/人格 weigh = 照妖鏡 polish、非刪行為）。
- **拆死常數出口（de-patch，SECONDARY refinement）**：
  - 叛離：`義氣<0.35 → 自動走` 死門檻 → **「留 vs 走」人格加權 utility**（義氣/忠誠/野心/恐懼 modulate 真值）。
  - 起義：起義後**無條件清空**勢力關係 → 起義**後果也秤**（推翻領主 ≠ 必然脫離勢力；可能換領主留勢力——按人格與情勢）。
  - **★R① 加碼（刀口擴）**：`_evaluate_uprising`（:4535-4553）自藏**三道額外死常數前置門**（`avg_loy>=0.2`／`unrest_turns<60`／`stress_sources<2`）——de-patch 刀口**必含這三道**（非只義氣/信義那組）；後段 stand/flee 只讀 4 項人格、零 benefit 信號（P4 同源）。
- **真好處接進留走秤**：留下的期望價值讀**真機制**（relief 救援史/保護紀錄/經濟共享流量/秩序），不造新常數。
- **立國卡點**（envoy accept/establish 從不成功）：**查根**；修否視根而定（若小=順修、若大=歸立國/正統 arc）。
- **不在本 arc**：正統/名分/繼承（王朝 arc）、復甦路徑動詞（記檔的 cohesion 兩段論第二段、視量測需要拉入）。

## §3 現況前提（pending R① + 開場量測）
- **P1** 叛離死門檻：`event_faction_defect`（義氣<0.35 OR 信義<0.35、`DEFECT_HONOR_THRESHOLD=0.35`）。
- **P2** 起義無條件清：`faction_ai:4571/4577` faction 關係 clear（無秤）。
- **P3（R① 驗實+追深一層）** 立國 never-establish：`_declare_established`（:4498-4510）只在 `:1820「立國」in f.goals` 才被呼——**真卡點 = 「立國」goal 何時被賦予**（比 establish 更早一步）；HOW 階段查根。
- **P4** 留下的真好處已存在但未接進留走決策：relief（generalizes 已證）/labor pool 共址/distribute——「留 vs 走」現況**不讀**這些。
- **★開場量測（spec 鎖前）**：exit-attribution——床裡逐件叛離/起義 trace，分「人格 genuine（該走）vs 死常數驅動（假走）」＋各出口佔比 → grounding §2 的刀口。

## §4 量測（湧現式、無配額）
- **分化**：仁厚/責任領主的勢力顯著比暴君/疏忽的持久（同機制、人格產不同壽命）。
- 該散的照散（暴君失人心案例仍在）。
- 下游解鎖驗證：rep 床不再秒崩 → relief 長窗觀測可行、L3 cross-faction domain 可行使。
- determinism / 感知鐵律 / need-gated 全守。QA 故事稽核（留/走案例逐個講得通）。
