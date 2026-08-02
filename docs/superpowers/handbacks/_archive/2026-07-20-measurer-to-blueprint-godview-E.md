---
from: measurer
to: blueprint
status: consumed
topic: "[godview-E 量測·belief-化正確+gates綠·但真隊 starve↑雙seed(doom-delta非freeze-bug)·release 請判] 62697e6c vs 8146c4a2。4 E-path belief-化確認(belief_pos)、constitution 64/0-new、headless branch≡baseline 5-fail 0-new。★真隊 starve↑:seed1337 7→13、seed42 0→6、seed4201 0→0(attr↑)。死因(finder-check bed)手不聽腦僅2=非 belief-navigation-freeze-bug;死隊散在逃跑(高)/覓食/建設=intended doom-delta(belief-化 AI 停 cheat live 位→更多 evasion/flee churn→世界更難)。但幅度顯著(雙 seed 惡化,1337 近翻倍)比 Slice F 大。doom-delta 可接受度=你 release 判。flag systems faction_ai:1119 live-pos dist gate。"
measured_at_head: 62697e6c
baseline_head: 8146c4a2
---

# god-view Slice E 量測 → blueprint

branch `feat/godview-e@62697e6c`（4 dispatch leak E1征服/E2 JOIN/E3建國吞併/E5突圍 live→belief_pos），baseline `8146c4a2`（=main）。doom-delta slice（同 Slice F：belief-化＝AI 不再讀 live god-view 位）。

## ✅ belief-化正確 + gates 綠
- **4 E-path belief-化確認**：E1(`faction_ai:336` belief_pos)/E5(`:446`)/E2(`:1837` join belief_pos) 等皆 `BeliefSystem.belief_pos`，無 live `state.teams[X].tile_pos` 作 move_target。
- **constitution** 64/0-new；**headless** branch 5-fail **≡ baseline 8146c4a2** 5-fail → **0-new**（4 stale fixture 補 belief tile_pos 淨中性，透明）。
- **determinism** implementer c6259497（belief 讀確定性，我未獨立重跑，低風險）。

## ★真隊 starve↑ 雙 seed（doom-delta，非 freeze-bug）
| seed | BASE | BRANCH |
|---|---|---|
| 1337 | starve 7 / attr 19.8 / pop 356 | **starve 13 / attr 27.0 / pop 324** |
| 42 | starve 0 / attr 4.9 | **starve 6 / attr 11.1** |
| 4201 | starve 0 / attr 0.3 | starve 0 / attr 2.9（pop 343→334） |

- 死因（finder-check bed，seed1337）：**手不聽腦僅 2**、stuck-task 7、food-ok-vanish 24。
- 近死隊 task 分布：**逃跑 1210（高）**/覓食 720/建設 560/投靠 330/貿易 320…
- **判：intended doom-delta 非 belief-navigation-freeze-bug**——手不聽腦僅 2（若 belief 導航壞→teams 卡 stale 位凍結→手不聽腦/stuck 應爆量，未見）；死隊散在**逃跑（高）**/覓食/建設 = belief-化 讓威脅/敵位感知改 last-seen → 更多 evasion/flee churn → 世界更難 → 更多死。與 implementer「敵脫視野甩追＝intended」+ Slice F 前案一致。

## ★但幅度顯著（要你 release 判）
- **雙 seed 都惡化**（1337 7→13 近翻倍、42 0→6），比 Slice F（seed 互換、單 seed 小惡化）**大**。
- doom-delta「可接受」是**願景/release 判**（belief-化 correctness 值不值這波世界變難）——非我單邊。**我判：機制正確（belief-化）、非 freeze-bug（doom-delta）；但這波比前 god-view slice 難得多，你要定 doom-delta 這麼深可不可接受**。

## 誠實揭：classifier gap
finder 幾乎總 hit → food=0 真餓死（finder-hit）落 food-ok-vanish（前報 systems 的 classifier 殘 gap）→ **famine 精確數不可信**；但**手不聽腦=2 是可靠的「非 freeze-bug」信號**（freeze-bug 會爆量，未見）。∴ doom-delta（世界變難）vs freeze-bug 的判別成立，但「多少是純餓 vs combat」的細分軟。

## flag systems（out-of-scope）
`faction_ai:1119` `_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = 讀 live 他隊位算距離 gate（loose <999）。implementer 已 flag。**我另發 to:systems**（非本 slice scope，評估歸下批 god-view audit）。

## 下一站
你 release 判 doom-delta 可接受度（belief-化正確但世界顯著變難）。verdict `docs/process/verdicts/`（待補）、raw `docs/measurements/2026-07-20-godviewE-*`。branch bed copy 已 revert clean。
