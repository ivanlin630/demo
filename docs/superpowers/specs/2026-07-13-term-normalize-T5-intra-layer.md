# T5：層內 base 校 + 訓練 eval-gate 對齊（systems HOW）

> 藍圖裁 T5 範圍(`T5-scope-decision`)：normalize 補齊 spec「in-band≠competitive」漏判。diag 坐實 6-zero 真根=層內 base 競爭（coeff 跨層分辨、層內不分辨）。

## 原則（守優先序保全）
抬 ① term 使 **favorable 人格達競爭 band [~0.8,1]、unfavorable 人格仍低**（保人格梯度）——**禁 flat-floor**（會讓全 option over-lift/over-select）。coeff（需求）仍跨層 gate（抬 base 只在該 option 層 urgent + 人格 favors 時才翻，非無條件）。base∈[0,1] 不變。

## T5.1 base 校（備戰/駐守/買糧，gap 3-5x）
`terms.gd` eval 改（TEST VALUE，measurer 校幅）：
- **`prepare_drive`(備戰)**：`慎·0.6+好·0.3` → **`clampf(慎·0.9 + 好·0.2, 0, 1)`**。謹慎隊(慎0.9)→0.81+（競爭 FLEE 0.6/迎戰）；好戰隊(慎低)仍低→迎戰贏。人格梯度保。
- **`settle_fit`(駐守 分支)**：駐守 return `0.6` → **`0.9`**（單-term 補足對雙-term 生產/建設；生產/建設分支 0.4 不動）。知足隊(低野心→ambition_drive≈0)→駐守 0.9×weight 勝生產(0.4);野心隊→生產/建設(+ambition_drive)仍贏。
- **`buyfood_drive`(買糧)**：`dist_disc` → **`clampf(0.5 + 0.5×dist_disc, 0, 1)`**。近市集→1.0(=覓食);遠→0.5(仍可競)。餓+有市集+錢時競覓食（applicable 已 gate 市集+specie）。

## T5.2 訓練 eval-gate 對齊（真 bug）
`applicable`(FORCE+anon) ⊋ `eval-nonzero`(FORCE+rung∈[ACC,EXP]) → FORCE 隊在 SURVIVE/STATE/HEGEMON rung + anon = applicable 但 eval=0。對齊：
- `decision_context.gd` gather：`ambient_train_drive` 給值條件由 `archetype==FORCE AND rung∈[ACCUMULATE,EXPAND]` → **`archetype==FORCE`**（drop rung 限制；applicable 的 has_trainable(anon) 已供 context gate）。值 `0.5`(TEST VALUE) 不變。
- 效果：FORCE 隊有 anon 可練時 eval 非 0（own_util>0），rung 高低由 coeff（esteem urgency）調，非 eval 硬 0。

## T5.3 吸納 modest（邊界,gap 7-11x）
`absorb_drive`：`ABSORB_DRIVE_BASE(1.0) × slack × (0.3+0.7×yield) × (0.5+0.5×gap)` → yield floor 抬 **`(0.5+0.5×yield)`**（modest,measurer 觀察是否需更多）。

## T5.4 乞食 → known_issues（記錄不修）
`docs/known_issues.md` 記：乞食 chosen≈0 = BEG_FLOOR_FACTOR(0.5) 故意最後手段 + applicable 稀有(appl_n 8-180 遠低於 base-校 option 的萬級)→合理現象非缺陷。

## determinism
純算術改（clampf/常數），零 randf。

## TDD（headless_test.gd）
`_test_t5_intra_layer`：
- 備戰：謹慎隊(慎0.9好0.2) eval>0.7；好戰隊(慎0.1好0.9) eval<0.4（梯度保）。
- 駐守：settle_fit("駐守")==0.9、settle_fit("生產"/"建設")==0.4（未動）。
- 買糧：dist_disc=1→eval=1.0；dist_disc=0→eval=0.5。
- 訓練：FORCE 隊 rung=STATE + has_trainable → ambient_train_drive==0.5（非 0）；非 FORCE→0。

## 驗收（measurer 終驗）
- **9-zero 收斂**：備戰/駐守/買糧/訓練/吸納 per-option chosen>0 跨 seed（乞食 除外,記錄）。剩幾個非零報告。
- **既有不回歸**：迎戰/FLEE(好戰隊仍迎戰)、生產/建設(野心隊)、覓食(餓隊)、survival-dominance、determinism、融合閘。
- **優先序保全**：抬 base 未致 over-select（如 備戰 在無威脅隊 spurious、駐守 蓋過野心隊生產）——organic 對照。

## 風險（R② 審）
- 抬 base 破優先序保全？——coeff 仍跨層 gate（備戰只在 safety urgent 時競,駐守只在 low-ambition 時勝）。R② 查抬幅是否致非-favorable 情境 over-select。
- 訓練 drop rung gate → over-train？——has_trainable(anon)+FORCE 已 gate,coeff(esteem)調;measurer 驗。
- 全 TEST VALUE,measurer 校幅（同前例）。
