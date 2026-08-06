# F1 人格化 — threshold 靶（WHAT / vision）v2

status: LOCKED（2026-08-07：R①全靶citation+R² CLEAN、2必查項折入§2.5 → systems build）
owner: blueprint（WHAT）→ systems 做 HOW
parent: `2026-08-07-framework-completion-two-hard-green-design.md`（硬綠① Track、slice F1）
date: 2026-08-07
溯源：F1 audit v1→**premise_contradiction halt**（2/3 靶 citation 錯指、改死 fallback / 機制不存在）→ F1 audit v2 全靶 citation re-verify live → **genuine scope 收斂 2 靶**（靶② uprising CUT=早已 genuine）。★行為變 slice（fp 預期分化=intended、與 ②結構 slice 分不混）。

## §1 守則（沿用 program §2.1 + 乙教訓）
- **genuine 真值 modulate、非 crank 逼 outcome**：讀真實人格傾向、非調數字逼 fire 率。
- **憲法 A 家族判準**（[[project_unification_matrix]] line39）：硬 yes/no 卡人格類別 = 違憲 → soft weight、零差異化損失。
- **fp 預期分化驗 intended**：F0 fingerprint 變=行為改預期;驗分化方向對、非漏。determinism 守。
- **★live-code 鐵律（v1 halt 教訓）**：只改**統一引擎真走**的 live code、禁改 `uses_unified` early-return 的死 fallback（改死 code=零效果 false-confidence）。

## §2 二靶 WHAT

### 靶A `DESPERATION` entry-gate 人格化（新 death-constant）
- **真 live 位置（audit v2 訂正）**：options.gd survival-option applicable——`:100` 返家 / `:152` 投靠 / `:183` 覓食 / `:193` 乞食 / `:263` 買糧，皆 `food_days < DESPERATION_DAYS` = **survival-ENTRY 門檻（WHEN 開始考慮求生選項）**。**非** `_evaluate_survival:3974`（不含 DESPERATION + uses_unified early-return = 死 fallback、不改）。
- **WHAT**：絕境「進入判定」= 主觀風險容忍、該人格分化——**膽大/好戰者撐到更低 food_days 才進求生模式**（"還能撐"）、**謹慎/易懼者更早進**（早備）。entry 門檻讀 膽/懼/慎重（求生欲 + `lv["慎重"]` / `lv["好戰"]`反、與主引擎同組）。systems 建議：`ctx.desperation_entry_threshold` 加權替 raw、applicable 讀之。
- **★★物理錨分離（守）**：`DESPERATION_DAYS` 另作物理 need-anchor（買糧/relief **量**計算）= physical 留死常數不動。本靶**只人格化 decision-ENTRY 門檻**。
- **anti-crank**：modulate 進入點（謹慎 food_days<~5 進、膽大<~2 進）= genuine 風險容忍;禁調逼 survival fire 率。

### 靶B `_evaluate_new_outpost_location` MINING_GREED 硬 persona-gate → soft weight（憲法 A）
- **live 位置（坐實）**：`is_greedy_leader = (貪婪+野心)>=MINING_GREED_THRESHOLD(1.1)`（:3467-3494）= 硬 persona-gate。
- **WHAT**：de-patch → **貪婪/野心 連續 WEIGH 礦址傾向**（選址 greed 傾向連續、非硬類別）。零差異化損失。

### 靶② uprising = ★CUT（documented、非漏）
`_evaluate_uprising` 早已 genuine 連續秤（avg_loy/unrest/stress precondition + stand/flee/secede/stay_u 人格加權 + cohesion `faction_stay_benefit`、cohesion arc 審過）。v1 誤引 `is_military` 實為 `establish_crude_camp` 紮營軍/民型態分類（legit branch、不同性質）。**無真硬 gate 可 de-patch → 移出 F1 scope。**

## §2.5 ★HOW-binding 條件（R² CLEAN 必查、寫死非留 implementer 選）
1. **★靶A 走單一統一計算點**：5 處 applicable(:100/152/183/193/263) **必共讀單一 `ctx.desperation_entry_threshold`**（一處算、五處讀）、**禁 5 處各改**。= 本 arc 反覆驗證的統一紀律（`_contact_elapsed_days` 跨 3 決策點 / `_faction_stay_benefit` 跨 defect+uprising+g3 三系統）;5 各改 = 5 旋鈕散落 precision 病重演。
2. **★entry 門檻 vs PRIO_SURVIVAL 獨立**：entry 門檻 = **candidate 生成層**（WHEN 考慮求生）、PRIO_SURVIVAL = **task 仲裁優先權層**——**兩不同層、HOW 須明講獨立處理、非隱含假設同一值**。

## §3 量測（湧現分化、fp intended）
- **靶A**：survival-entry 分化——膽大隊撐更久才進絕境、謹慎隊早進（同世界不同隊不同進入點）;物理錨（買糧量）不變（分離證）。
- **靶B**：礦址 greed 傾向連續——1.05 者不再被硬排除、高 greed+野心 最傾向;無 1.1 懸崖。
- **共同**：F0 fp 預期變（intended）驗方向對非漏;determinism 同 seed 同結果;無 regression（headless 1000+ 無崩、既有 arc 綠）;constitution_gate 綠（2 靶硬 gate/death-const 移除、無新閘）。
