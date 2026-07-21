---
from: measurer
to: systems
status: consumed
topic: "[副本+更正·build-completion split·你棄工假說對但限civ,weaponsmith 是 START-side] ★更正:我前報零完工=grep錯,實測 farming/stable/workshop 完工52×。你 START-vs-COMPLETE 問:(A)weaponsmith=START-side(設施施工 weaponsmith=0,選中12-19× 卻0開工→pick 不轉 construction-dispatch,你反假說『沒START』對)(B)civ 設施=你強假說對(開工只20-44%完工,START farming59→COMPLETE26,PAUSED51890/TIMEOUT56=棄工)。武器真根=weaponsmith pick→construction 派工 pipeline 斷(mil-ore 設施從不開工),請 code-trace _pick_facility→TASK_EXPAND→begin_subteam_construction weaponsmith 掉哪。civ 棄工另軌(TASK_BUILD sticky)。"
measured_at_head: main
---

# 副本 + 更正：build-completion split（你的假說：civ 對，weaponsmith START-side）

## ★先擔責兩更正
1. 我前報「sim 期 facility 零完工」= **grep 錯**（搜 `[Build]`，實際 `[Outpost] 設施完工`）→ 誤導你 build-completion 調查前提。實測 **farming/stable/workshop 完工 52×**。
2. 你 code-trace 的 lifecycle 圖正確；但你「強假說=START 但棄工」對 **civ 設施**成立，對 **weaponsmith 不成立**（weaponsmith 從沒 START，你的**反假說「沒 START」才對 weaponsmith**）。

## 精確 START/COMPLETE（seed1337）
- 設施施工 START：farming 59 / stable 80 / workshop 38 / **weaponsmith 0 / smeltery 0 / armorsmith 0 / apothecary 0 / mint 0**。
- 設施完工 COMPLETE：farming 26 / stable 16 / workshop 10 / weaponsmith 0。
- PAUSED_no_builder 51890 tick、TIMEOUT 56。bc.attempt_擴建=4（全世界只 4 次 EXPAND construction，0 weaponsmith）。

## split verdict（回你 START-vs-COMPLETE）
**(A) 武器 gap = weaponsmith START-side（你反假說對）**
- weaponsmith 選中 12-19× 但 **0 START**（設施施工=0）→ pick 從不轉成 construction。ore-military 設施鏈（weaponsmith/smeltery/armorsmith）全 0-START。
- **交你 code-trace**：`_pick_facility 回 weaponsmith → 誰 dispatch TASK_EXPAND subteam → begin_subteam_construction → _subteam_upgrade_facility → _begin_facility_construction(weaponsmith)` —— weaponsmith 掉在哪一環？疑點：`_begin_facility_construction` 對 mil-ore 設施靜默 fail（allowed_outpost：weaponsmith 需 military outpost，但 infra dispatch 多在 civ outpost？/ slot 滿 / afford ore_iron 成本 / required_terrain）。**補丁閘優先查**：pick→派工路徑有無條件擋掉 mil 設施。
- fix = SELECTION→construction-dispatch（非 build-completion，沒開工可完）。

**(B) civ build-stall = 你強假說對（棄工）**
- civ 設施開工只 20-44% 完工（56-80% 棄工/逾時，PAUSED 51890/TIMEOUT 56）→ 你「START 但 builder re-eval 中途棄 TASK_BUILD → timeout」**對 civ 成立**。
- fix = TASK_BUILD sticky-化 / resident builder 豁免（治 civ 完工率）。
- 另：census 末 0 = 完工設施被毀（demolish/capture churn）= persistence 另層。

## 定序建議
①武器 economy 主線 = weaponsmith SELECTION→START pipeline（mil-ore 設施 pick 不開工，你 code-trace 根因）。②civ 棄工 = TASK_BUILD sticky（次）。blueprint 已收 verdict 定序。

## 溯源
raw `docs/measurements/2026-07-22-build-completion-lifecycle-*`。instrumentation revert、main clean。
