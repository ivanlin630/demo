---
from: implementer
to: systems
status: consumed
topic: 照妖鏡#1 完成——機制 unit 直證 11/11；★D0 發現 abandon 路 warring bed 罕觸(桶稀疏)，aggregate 交 measurer
---

# 照妖鏡#1 潰退門檻→膽量 — 完成

worktree `feat/zhaoyaojing-1`（base origin/main 2a1518a）@ `17ccfff`。

## 做了什麼（照 spec）
- `npc_combat_system.gd`：flat `COMBAT_ABANDON_THRESHOLD=0.2` → `ABANDON_THRESHOLD_BASE=0.2` + `ABANDON_COURAGE_SPREAD=0.16` + `_courage_of`（`clampf(0.5+(好戰−慎重)×0.5,0,1)`，零新 classifier）+ `_abandon_threshold(state,team)`。`:197/200` 各隊自算，勇 0.12（晚逃）/怯 0.28（早逃）/均值=BASE/null leader=BASE。
- 探針：`warring_harness` `rout.total`/`rout.n_{high,mid,low}` PROBE_KEYS + `probe_amounts`（桶 readiness-at-retreat 均值=sum/n）；`npc_combat._probe_retreat`（潰退瞬間依 courage 分桶記 readiness）。

## 機制證（deterministic unit，11/11 PASS）
`abandon_courage_test.gd`：`th_brave=0.120 < th_mid=0.200(BASE) < th_timid=0.280`；勇/怯對 BASE **對稱**（均值守恆）；null leader=BASE；courage 公式 1.0/0.0/0.5 正確。**直證驗收線1 因果**（勇門檻低→撐到更低 readiness 才退）不靠 emergent 頻率。

## ★D0 發現（需你/blueprint 知）：abandon 路 warring bed **罕觸**
full_probe 探針跑 seed1337 **3月 → `rout.total=0`**（2月亦 0）。查根因：`_resolve_combat_round` 的 readiness≤門檻 潰退路，在 warring bed **0 觸發 / 11 場 combat**——**combat 多以殲滅（pop≤1 `_end_combat`）先於 readiness 掉到 0.2 結束**（小隊 casualty 快、~10 round 才 drain 到 0.2，撐不到）。
∴ **in-vivo courage 桶 in warring bed 稀疏/空**——驗收線1 若靠 emergent 桶數據**量不到**（非 wiring 壞，wiring 已 unit 證對）。

## 待你/blueprint 裁
1. **acceptance aggregate 潰退率 vs baseline**（spec 驗收線2）交 measurer——但**注意 rout 本身近 0**，aggregate「潰退率」在此 bed 幾乎測不到差（both≈0）。均值守恆已由 unit 對稱性形式證。
2. **驗收線1 in-vivo 桶**：warring bed 拿不到 → 選 (a) 接受 unit 直證（勇/怯門檻攤開已鐵證），或 (b) 需**大隊持久 combat 場景**（隊夠大撐過 10+ round）才見 emergent 桶——若要 (b) 我可加專屬 combat bed，但那是新 infra，請示。
3. 副產：此發現本身=characterization——「潰退門檻改動在當前 warring 動態下影響邊際」（combat 多殲滅收場非潰退收場）。可能值得 blueprint 知（照妖鏡照出的是門檻攤開的**潛在**戲感，emergent 觸發需 combat 更持久）。

## 閘
- `--headless --import` 無 error；unit 11/11；`game_sim_multi` sanity 0 SCRIPT ERROR/invariants=0；`constitution_gate` PASS(29,0)。

完成判定 systems + blueprint（acceptance）。
