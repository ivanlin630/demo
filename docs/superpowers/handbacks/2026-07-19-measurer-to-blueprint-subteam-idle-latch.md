---
from: measurer
to: blueprint
status: consumed
topic: "[subteam-idle-latch 量測·NOT clean-pass·send-back-leaning] 036fc42c 停了 thrash-死(食物流進,HOW-correct)但 ★terminal-sticky 坐實且顯著(非 benign WHAT-flag):foragers 永久 detach 卡 forage、囤 200-2000 food-days、從不歸建/交母團 → 破食物供給環 → ★seed42 0→10 famine regression(強因果嫌疑非純 cascade)。seed1337 marginal(7→6)、seed4201 identical。gates 綠。建議 send-back systems:1727 fix 需配套 forager『食足→交糧/歸建/re-rank』release 路,否則 trade thrash-死 為 hoard-卡+餓死母團。terminal-sticky=blocker 非 flag。"
measured_at_head: 036fc42c
baseline_head: c5ab36d9
---

# subteam-idle-latch 量測 → blueprint（NOT clean-pass）

branch `feat/subteam-idle@036fc42c`（1-line：1727 加 `not in SURVIVAL_TASKS`，我上封定位的 root），baseline `c5ab36d9`。

## ✅ thrash-死 修好（HOW-correct）
- foragers 不再被秒召回：食物流進。seed1337 team62 food 9-11（vs baseline thrash-卡 2.5-4.58）。ARRIVE↔RELEASE 1:1 振盪消失。fix 確實執行引擎覓食決策（1727 不再 pre-empt）。

## ❌ 但 terminal-sticky 坐實且顯著（implementer/reviewer 標 non-blocker，我不同意＝blocker）
SITRACE（survival-subteam task-duration + food 逐時）：
- **seed1337**：tid=49 卡 forage **48140 ticks**（~6.7mo）囤 **1970 food-days**；tid=70/58/81/62 卡 1000-1220t、food 9-60。
- **seed42**：tid=57 卡 **32480 ticks** 囤 **209 food-days**；tid=54/79 卡 1000+t。
- **機制**：FORAGE **無 release 路** → forager 抵達覓食格後（fix 不召回）留下覓食，`current_task=覓食`（非 IDLE）→ `_decide_subteam` 只在 IDLE 跑 → **永不 re-rank/歸建** → 覓食+囤糧但**從不把糧交回母團**。fed 卻 detached 卡死。

## ★seed42 0→10 famine REGRESSION（強因果嫌疑）
| seed | baseline | branch |
|---|---|---|
| 1337 | starve 7 / attr 19.82 | starve 6 / attr 19.14（marginal 改善）|
| **42** | **starve 0 / attr 4.86** | **starve 10 / attr 20.83**（REGRESSION）|
| 4201 | 0 / 0.29 | 0 / 0.29（identical）|

- seed42 branch 死因 = **10 famine（0 stuck/手不聽腦）**。baseline seed42 = 0 starve（健康 control）。
- **因果鏈**：fix 唯一行為變 = foragers 留 forage 不歸建 → 覓食糧囤在 detached 子隊（tid=57 囤 209 days）**不回母團** → 母團失去子隊覓食貢獻 → 母團 famine。
- **這不是 benign cascade**：terminal-sticky 是**系統性**行為變（全 seed 皆有），seed42 是它最壞的顯化（母團依賴子隊交糧者餓死）。seed4201 不依賴故 identical、seed1337 已在苦 basin 故 marginal。
- **誠實限制**：未逐-parent 坐實「seed42 famine-dead 隊 = 卡住 forager 的母團」（bed 沒 log parent_team_id）→ 機制**強嫌疑、circumstantially 紮實，非 parent-by-parent 鐵證**。要硬證我可補 parent_team_id trace。

## 判定：NOT clean-pass，建議 send-back
- fix HOW-correct（停 thrash，執行引擎決策）——但 **terminal-sticky 副作用破食物供給環**，把「seed1337 thrash-餓死」換成「terminal-卡+囤糧+seed42 母團餓死」。net 不明顯更好，且引入新失敗模式（食物 sink 進卡住子隊）。
- **terminal-sticky = blocker**（非 implementer 說的 non-blocker WHAT-flag）：它直接因果 seed42 regression。
- **建議 (B) send-back systems**：1727 fix 需**配套**——forager（FORAGE/CAMP）加「食足→交糧/歸建/re-rank」release 路（食滿或 parent 缺糧時歸建交糧），否則卡死囤糧。這是 reviewer R² 升級的 terminal-sticky 正是此洞，**確認為真且有後果**。

## gates（綠，供參）
constitution 64/0-new、headless branch≡baseline 5-fail 0-new、determinism implementer-reported ebf82786（無 RNG 1-line，我未獨立重跑，低風險）。

## 下一站
你判：accept-with-known-limitation（食物 sink 可接受？）vs send-back systems 配套 forager-release。我傾向 send-back（seed42 死是真後果）。verdict `docs/process/verdicts/subteam-idle-latch.measure.json`、raw `docs/measurements/2026-07-19-subteamidle-*`。SITRACE instrumentation 已 revert、branch clean。
