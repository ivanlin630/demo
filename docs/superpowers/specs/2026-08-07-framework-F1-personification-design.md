# F1 人格化 — 3 threshold 靶（WHAT / vision）

status: DRAFT（pending R①[① physical-anchor 分離確認] + R² → build）
owner: blueprint（WHAT）→ systems 做 HOW
parent: `2026-08-07-framework-completion-two-hard-green-design.md`（硬綠① Track、slice F1）
date: 2026-08-07
溯源：F1 audit `2026-08-07-framework-F1-threshold-audit.md`（9 sites careful-verify、6 已人格化/physical 留、3 genuine 靶）。★這是**行為變 slice**（fp 預期分化＝intended、與 ②結構 slice 分不混）。

## §1 守則（沿用 program §2.1 + 乙教訓）
- **genuine 真值 modulate、非 crank 逼 outcome**：人格化 = 讓決策讀真實人格傾向、非調數字逼想要的 fire 率。
- **憲法 A 家族判準（[[project_unification_matrix]] line39、早定）**：硬 yes/no 卡人格類別 = 違憲 → de-patch soft weight、**零差異化損失**（soft weight 保留意圖、去掉任意 cliff）。
- **fp 預期分化驗 intended**：F0 fingerprint 會變（行為改）= 預期；驗**分化方向對**（膽勇/謹慎產不同傾向）、非漏改。determinism 守（同 seed 同結果）。

## §2 三靶 WHAT

### 靶① `_evaluate_survival` DESPERATION-entry 人格化（新 death-constant）
- **現況**：`food_days < DESPERATION_DAYS(3.0 raw const)`（:3215）= 絕境進入門檻用死常數、無人格 modulate。
- **WHAT**：絕境「進入判定」= **主觀風險容忍**、該人格分化——**膽大/好戰者撐到更低 food_days 才慌**（"還能撐"）、**謹慎/易懼者更早進絕境**（早備糧覓食）。entry 門檻讀 膽/懼/慎重（求生欲 + `lv["慎重"]` / `lv["好戰"]`反、與主引擎同組人格值）。
- **★★物理錨分離（R①-confirm 靶、systems audit 標）**：`DESPERATION_DAYS` **另作物理 need-anchor**（買糧目標量/relief 量計算）——**該用途 physical、留死常數 3.0 不動**。本靶**只人格化 decision-ENTRY 門檻**，物理錨計算不碰。（HOW 必須把兩用途拆開處理。）
- **anti-crank**：modulate 進入點（謹慎者 food_days<~5 進、膽大者<~2 進）= genuine 風險容忍;**禁**調成逼 survival fire 更多/更少。

### 靶② `_evaluate_uprising` `is_military` 硬 persona-gate → soft weight（憲法 A）
- **現況**：`is_military = martial>0.6 or ambition>0.7`（:4544）= 硬 persona-gate（0.59-martial 者被任意排除整段起義能力）。
- **WHAT**：de-patch → **martial/ambition 連續 WEIGH 起義傾向**（高好戰/高野心 = 更強起義驅力、但連續非二元 cliff）+ uprising 門檻讀 膽/unrest（勇者+高怨易反）。**零差異化損失**（保留「好戰野心者領導起義」意圖、去掉 0.6/0.7 任意懸崖）。

### 靶③ `_evaluate_new_outpost_location` `(貪婪+野心)>=MINING_GREED_THRESHOLD(1.1)` 硬 persona-gate → soft weight（憲法 A）
- **現況**：`is_greedy_leader = (貪婪+野心)>=1.1`（:15）= 硬 persona-gate 選礦址。
- **WHAT**：de-patch → **貪婪/野心 連續 WEIGH 礦址傾向**（選址的 greed 傾向連續、非硬類別）。零差異化損失。

## §3 量測（湧現分化、fp intended）
- **①**：survival-entry 分化——膽大隊撐更久才進絕境、謹慎隊早進（同世界不同隊不同進入點）;物理錨（買糧量）不變（分離證）。
- **②**：起義傾向連續——0.55-martial 者不再被硬排除（低傾向仍可能）、高 martial+高 unrest 者最易反;無 0.6 懸崖。
- **③**：礦址 greed 傾向連續。
- **共同**：F0 fp 預期變（intended 分化）、驗方向對非漏;determinism 同 seed 同結果;無 regression（headless 1000+ 無崩、既有 arc 綠）;constitution_gate 綠（3 硬 persona-gate/death-const 移除、無新閘）。
