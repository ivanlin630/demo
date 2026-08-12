# named-scarcity 出口 — 急徵（A、弱）+ 訓練（B、正常）（WHAT / vision）

status: DRAFT（pending R①[硬數據、機制可承載] + R² → build）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-12
溯源：主動升匿名建好但 dormant（硬數據：平民 quality 0.14<門檻 0.3 + 訓練 util 0.33 flat 從不勝 argmax）→ 用戶定案：**訓練=平常但緩不濟急 → 做 A+B;A 急徵人手，人才庫只有平民則選出來很廢**。共用既有 promotion 機制（`generate_for_team`、已 build banked `31d42ee5` 系）。

## §1 命門（用戶定、寫死）
- **所有 action util 非死常數**（用戶 2026-08-12 定）→ need-driven。
- genuine 非 crank（乙教訓）：兩路各有**真代價/真限制**，非硬調贏、非逢缺必補。

## §2 B 正常路 — 訓練 util need-connected（真根修）
- **現況錯**：訓練 util = `ambient_train_drive` flat 0.33、**跟 officer-need 脫鉤** → 缺 officer 的領主照樣不練（硬數據：FORCE 領主 20 天 0.33 永輸 build 1.11）。= 死常數 fake number。
- **WHAT**：訓練價值 = **f(officer-need)**——named-scarcity（缺記名）+ 想派任務沒人可派 + （可含 threat 需戰力）。缺 officer → 訓練值高、贏 argmax → 練兵 → 平民 tier-up（既有 train→exp→try_promote 鏈）→ 過既有 quality gate → promote **好 officer**。
- **★bounded 檢驗（非 crank）**：officer 夠/不缺的領主 → 訓練值**低、不練**（machine/measure demonstrate、非 flat always-train）。慢、但可持續、品質好。

## §3 A 急徵路 — 絕境 field-promote（弱、救急）
- **WHAT**：真絕境（急需 officer + 無夠格候選 + 無時間訓練）→ promotion 門檻 relax → 拔**最佳平民 NOW**。
- **★品質反映來源（用戶「很廢」）**：平民→**弱 officer**（低技能/低領導/高失敗+高叛風險）= genuine 賭注、救急不救好。（`_apply_promotion_skills` 依 src_tier 灌技能=平民 tier 灌少 → 天然弱、非額外機制。）
- **★bounded（非逢缺必補）**：只真絕境（真急需+真無替代+真無時間）才 relax 門檻;非絕境照守 quality gate（平民不夠格）。

## §4 自平衡（湧現非腳本）
A 弱（拔平民=廢 officer）→ 自然只當**最後手段**;B（練好兵）品質好 → 自然是**首選**。領主人格分化（謹慎早練備著/野心擴張多練/絕境被迫急徵拔廢的）。無腳本強迫、從真代價湧現。

## §5 量測（湧現、硬數據、5× over-claim 教訓）
- **B**：缺 officer 領主真訓→tier-up→promote 好 officer（端到端 fire）;★officer 夠→不練（bounded 非 always-train）;人格分化訓練率。
- **A**：絕境真 fire→**弱 officer**（promoted 品質低、可測 skills/leadership）;★非絕境不 fire（bounded、平民照擋）。
- **紓解驗**：named-scarcity 前後對照（T12 型 1-named 領主 → 有 A+B 後能 genuine 補班底、不再全程 0 派遣）genuine 非玩壞（crank/補滿）。
- 禁預設 payoff、RNG-confound 誠實標、UNTESTABLE 照實報。determinism/regression/constitution 綠（util 接 need 非硬閘、無新死常數）。
