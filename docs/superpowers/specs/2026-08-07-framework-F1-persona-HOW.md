# F1 threshold 死常數人格化 HOW（systems、①硬綠首 slice、行為變）

status: LOCKED（R①全靶 citation + R² CLEAN、blueprint 2 HOW-binding 折入 §2.5）
owner: systems（HOW）← F1 audit v2（2 靶）+ blueprint 人格化裁
date: 2026-08-07
★行為變 slice（①人格化）：F0 fp **預期分化**（intended、非漏）、與②結構 slice **分不混**。genuine 真值 modulate 非 crank 逼 outcome（乙教訓）。

## §1 靶A：DESPERATION entry-gate 人格化
- **真 live 位置**：`options.gd` survival-option applicable 5 處（:100 返家/:152 投靠/:183 覓食/:193 乞食/:263 買糧、皆 `food_days < DESPERATION_DAYS`）= survival-ENTRY 門檻（WHEN 考慮求生）。★非 `_evaluate_survival`（死 fallback、②結構 dead-code 清除）。
- **人格化**：膽/懼/慎重 modulate entry-threshold=**真風險容忍**（膽大隊撐更久 food_days 低才進絕境/謹慎早進）。**genuine 非 crank**（禁調逼 fire 率、乙教訓）。

## §2 靶B：MINING_GREED persona-gate → soft weight
- `_evaluate_new_outpost_location`(:3467-3494) `(貪婪+野心)>=MINING_GREED_THRESHOLD(1.1)` 硬 persona-gate → **貪婪/野心 WEIGH**（連續、選址 greed 傾向、**無 1.1 懸崖**）。憲法 A 家族（硬 persona-gate→soft weight、零差異化損失）。

## §2.5 ★★HOW-binding（blueprint 寫死、必查）
1. **★靶A 統一計算點**：5 處 applicable **共讀單一 `ctx.desperation_entry_threshold`**（DecisionContext.gather 一處算[膽/懼/慎重 modulate DESPERATION_DAYS]、5 處 applicable 讀之）。**禁 5 處各改**（=5 旋鈕散落重演、違統一紀律；_contact_elapsed_days/_faction_stay_benefit 統一計算前例）。
2. **★entry 門檻 vs PRIO_SURVIVAL 獨立**：entry-threshold（candidate 生成層=applicable WHEN 求生可選）vs `PRIO_SURVIVAL`（task 仲裁層=求生 task 優先序）**HOW 明講獨立、非隱含同值**（人格化 entry 不動仲裁優先序）。
3. **★靶A 物理錨分離守**：`DESPERATION_DAYS` 作 **need-anchor**（買糧量/relief target=DESPERATION×pop×0.8）=**physical 留 raw**、**只 entry-gate 化**（entry 讀 desperation_entry_threshold、need-anchor 讀 raw DESPERATION_DAYS）。

## §3 守 / 驗
- genuine（真值 modulate 非 crank 逼 fire 率）/ 統一計算點（§2.5.1）/ entry-仲裁分離（§2.5.2）/ 物理錨留（§2.5.3）。
- ★**F0 fp 預期分化驗 intended**（行為變 slice、fp diff=膽大隊撐更久/謹慎早進 entry 分化=intended、非漏；與②結構 fp-byte-identical 分不混）。
- build 後量：靶A entry 分化（膽大隊撐更久才進絕境/謹慎早進）+ 物理錨不變 + 靶B 礦址 greed 連續無 1.1 懸崖 + determinism + 無 regression（headless/既有 arc）+ constitution 綠。

## §4 序
build → QA → merge = F1 收（硬綠①推進）→ F2 純程序模組切。地基 KEEP。
