# 军民混编 / 民兵動員 — 團型驅動的 mobilizable 分數（WHAT / vision）v2

status: Slice A MERGED `998f5344`；Slice B R② CLEAN（charter/mobilization split、正交性結構保證、單點 uses_unified wrapper 4-caller 自動受益）→ systems build
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-12
★Slice A/B 已 merge(998f5344/6fff46e7);唯一活項=團型梯度待驗(completion checklist D5)。
溯源：size-matter 維度②（audit 2026-08-03）+ grounding 表 + ★R② 異質框外審 ISSUES（6 findings、Agent 讀 code + reviewer 親驗 2/2 最要害）→ 訂正。

## §0 ★R② 訂正定案（framing 誠實化 + 拆刀）
- **★不是「5 折 1」（訂正 finding①，我原 framing 自相矛盾）**：實情=**guard_ratio 死常數 de-patch（照妖鏡）** + **新建 mobilizable 分數（動員維度、grep 零=全新）** + **團型二元→梯度**;而 armed_anon_ratio（裝備上限、非動員量）/ captive_guard_ratio（既連續、別域）/ TASK_TRAIN（育成品質、非動員量）= **明講保留、不折**。誠實 scope。
- **★★拆兩 slice（blast radius 差異大）**：
  - **Slice A（低風險、先）**：guard_ratio 照妖鏡（離散死常數→連續人格）+ 動員 trigger 走 **belief-threat**（修 `_has_hostile_within` god-view）。不碰決策路由。
  - **Slice B（高風險、後）**：團型梯度 + pool_of 分數化 + guns-vs-butter 動員機制。**★finding② 承重牆**：`uses_unified(team)=has(TAG_PRODUCE)`（`faction_ai:2394`）決策路由綁團型 binary、~15 處硬 binary gate（is_resident_static 等）→ 團型梯度須先/同時**decouple 路由 vs 團型**（觸 framework 結構債、見 §3）。

## §1 命門（寫死）
統一非補丁（收進一模型禁平行補丁）/ genuine 非死常數（動員由真 threat+團型+人格湧現）/ ★感知鐵律（動員 trigger 讀 belief-threat 非 god-view）。

## §2 Slice A — guard 照妖鏡 + belief-threat（低風險先做）
- guard_ratio（`faction_ai:3069` 硬編碼 0.1/0.15/0.2/0.35/0.4 離散 tag-gated 死常數）→ **連續、人格化**（慎重/責任/威脅感知 modulate、非死值），不損原意（夜哨比 + ★finding⑤ 漏列消費者 `_check_night_raid` 夜襲免疫一併接）。
- 動員/守衛 trigger → **belief-threat**（`ThreatAssessment.score`）取代 `_has_hostile_within` god-view。★finding⑥：belief-threat 現只服務 uses_unified 隊、純軍團零 belief-threat → Slice A 須讓守衛決策的 threat 也走 belief（否則軍團無感知）。

## §3 Slice B — charter/mobilization split（spike 解承重牆、MEDIUM gameplay 續、避 Track②A）
★spike 核心洞見：`TAG_PRODUCE` binary **混淆兩正交概念**——**charter/團型**（村/軍/商、穩定、建點定=「這是什麼隊」）vs **mobilization**（當下勞力↔戰力配置、動態隨威脅=「人力怎麼分配」）。decouple = **拆這兩者**（非主業過半 flip、非全解綁含路由=Track②A）：
- **charter（穩定）驅動**：A 路由（`uses_unified:2394`/:2901/:412/:4535）+ E 薪資 pop-cap（`population:30`/`salary:30`）+ C 居民鎖（`faction_ai:502` is_resident_static/駐守）。★**讀 charter 不改行為**——村 charter 隊動員民兵時 charter 不變 → **路由不 churn → 零 Track②A 糾纏**。
- **★mobilization-fraction（動態、新欄）驅動**：B 勞力池（`labor:27/37 pool_of`/`faction_ai:3683/3728`、pool 分數化）+ F 裝備（`faction_ai:3002/3037`）+ D 脆弱度（`interaction:395/301/303/521`/`diplomatic:263` 劫/撫/稅）。= Slice B 核心工作。
- **團型梯度** = charter 本身可分級（專業軍團/後備半兵半農/居民團）+ mobilized_fraction 動態 → guns-vs-butter（威脅→動員抽勞力→產出掉;和平解甲）。
- ★finding④ `manufacturing:86` labor_share>1 膨脹 bug 同修;finding③ 3 天 cache staleness 觸重算。
- **effort=MEDIUM**（加 mobilized_fraction 欄 + B~4/F~2/D~4 讀 fraction;A 路由/E 薪資/C 居民鎖 UNCHANGED 讀 charter 零行為變）= **gameplay arc、不需 user-scale Track②A**。

## §3-old Slice B — 團型梯度 + 分數化動員（高風險、須先解承重牆）
- 團型二元（`outpost:401` civilian/military 定死）→ **梯度**（專業軍團純軍/後備半兵半農/居民團民兵）。
- pool_of 二元 by-tag（`labor:23`）→ **分數 membership**（表達半兵半農）。★finding④：`manufacturing:86` 分子仍讀原始 population → labor_share>1.0 產出膨脹 bug、須同修。★finding③：guns-vs-butter 勞力池 3 天 cache staleness 須觸發重算。
- **guns-vs-butter**：威脅→動員抽勞力→產出掉;和平→解甲回田。
- **★★承重牆（finding②，Slice B 前置）**：`uses_unified` + ~15 硬 binary gate 綁團型 TAG → 團型變梯度前，**須定義半軍半民隊的路由語意**（decouple 路由 vs 團型分類）= 觸 [[project_framework_seams]] 結構債（可能需 Track②A 一角）。**Slice B 開工前先小 spike 定 decouple 法**。

## §4 前提（R① CLEAN 全坐實）
P1 三 ratio 各 owner / P2 pool_of 二元 / P3 團型二元 / P4 動員機制 grep 零全新 / P5 guard god-view（`_has_hostile_within`）。+ ★finding② uses_unified 綁 TAG binary（`faction_ai:2394`、~15 gate blast）。

## §5 量測（湧現、硬數據）
- **Slice A**：guard_ratio 連續人格分化（慎重高守衛保守/責任高多守）+ 動員 trigger belief-threat（遠/敵 stale、無 god-view、軍團也有感知）。
- **Slice B**：威脅→動員→產出掉（guns-vs-butter）+ 和平解甲 + 團型梯度分化(軍團/半農/民兵) + labor_share≤1（膨脹 bug 修）+ 路由 decouple 後半軍半民隊行為定義正確。
- 統一驗無平行補丁殘留;determinism;constitution。
