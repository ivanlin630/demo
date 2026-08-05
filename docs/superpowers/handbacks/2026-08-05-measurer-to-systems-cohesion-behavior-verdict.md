---
from: measurer
to: systems
status: consumed
topic: "faction-cohesion behavior量verdict:★★③下游解鎖(arc最重要目標)未達成——rep床(config/infonet_faction_rich_rep.json,同seed2024 45天)cohesion後仍collapse成factions:1/established:0,跟cohesion前(我先前faction-rich-rep verdict)數字一模一樣,relief長窗/L3 cross-faction domain沒解鎖。①②分化+该散照散本輪被confound污染未答:自建GoodLord(honor0.8)vs BadLord(honor0.15)matched-honor(0.34)member對照床,兩邊member都在day3/5經由完全無關的既有[Diplomacy]背叛(g3.betrayal)機制脫離faction,早於cohesion defect/uprising有機會操作(離隊時unrest恆0,defect precondition unrest>=20從未達成)——兩邊member之後走幾乎一模一樣的獨立生存曲線(食物耗損曲線幾乎重合,day45同步unrest=67/defect_util=0.53),完全沒能測到P4 stay_benefit的差異化效果,誠實回報非隱瞞,懷疑fixture人格值組合意外觸發了不相干的G3信任系統,建議redesign(提高信義/或調整野心等G3判準相關特質避開背叛路徑)才能真正測①②。specimen本輪未產出。純觀測temp taps已revert。落地3檔已ls/wc驗證。已回systems handback:2026-08-05-measurer-to-systems-cohesion-behavior-verdict.md，別下accept，③下游解鎖未達成是核心壞消息優先看,①②需redesign補測，交systems判"
---

# faction-cohesion behavior 量分化：★③下游解鎖未達成（核心壞消息）+ ①②被無關 confound 污染

## ★★③下游解鎖（arc 存在理由，最重要）：未達成

```
rep床(config/infonet_faction_rich_rep.json, seed2024, 45天, cohesion後)：
attrition=19.67% final={teams:8, factions:1, established:0}
g2.faction_found=0  indep.found_ally=3  cohesion.defect_fire=1
```

**跟我先前（cohesion 前）跑這個 rep 床同 seed/同時長的結果幾乎一致**（`factions:1/established:0`，我先前verdict `2026-08-05-measurer-to-systems-faction-rich-rep-bed-verdict.md` 也是 `factions:1/established:0`）。**cohesion fix 沒有讓這個 rep 床「不再秒崩」**——relief 長窗觀測 / L3 cross-faction domain 這兩個下游目標，本輪證據上**沒有解鎖**。這是本次驗收最重要的壞消息，優先呈報。

（`cohesion.defect_fire=1`——這輪只有 1 次真 defect 事件，跟 rep 床本身結構脆弱的既有問題[T2/T3 因 event_faction_defect/uprising 早早脫隊]比，量級太小，不足以解釋 factions 停在 1 的根因是不是被 cohesion 改善了——如實回報數字，不強行解讀。）

## ①②分化 + 该散照散：★本輪被無關 confound 污染，未能回答

自建 matched-honor 對照床（`config/infonet_cohesion_p4.json`，temp，未 persist）：GoodLord（honor0.8,真心relief傾向）+ Member（honor0.34,starving food150）vs BadLord（honor0.15,不relief傾向）+ Member（honor0.34,同 starving），seed5055，45天。

**結果：兩邊 member 都在 day3/day5 就離開了原本的 faction**——但**離隊時 unrest_turns 恆為 0**（defect 的前置門檻 `unrest_turns>=20` 根本從未達成），追 log 找到真正原因：
```
[Diplomacy] Team1 背叛 Team0   （day~3）
[Diplomacy] Team3 背叛 Team2   （day~2-3）
```
**這是一個完全跟 cohesion 無關的既有機制**（G3 diplomacy/信任系統，`g3.betrayal` tap），跟 defect/uprising 是不同的離隊管道。我這組 fixture 選的人格值組合（可能是低信義/或其他跟 G3 信任判準相關的特質）意外觸發了這條路，**在 cohesion 的 P4 stay_benefit 機制有機會操作之前**，member 就已經因為別的理由脫隊了。

兩邊之後都以「獨立」身分繼續生存，**食物耗損曲線幾乎完全重合**（day1~33 都是緩慢消耗、day34起 unrest 才開始爬升），**day45 兩邊的 `diag.defect_util` 快照數字一模一樣**（`unrest:67, distress_pressure:1.0, loyalty_deficit:0.66, stay_benefit:0.13, defect_util:0.53`）——**GoodLord vs BadLord 完全沒有分化**，但這不是因為 cohesion 機制失效，而是因為**兩邊都早就不在各自的 faction 底下了，領主品質從一開始就沒機會影響它們**。

**誠實聲明**：本輪①（分化命門）②（该散照散）兩題**測不到**——不是「測到沒分化」，是「confound 讓測試根本沒開始」。建議 redesign fixture（提高 member 的信義/或調整 G3 判準相關的其他特質，避開這條 betrayal 路徑）才能真正隔離 P4 stay_benefit 的效果。

## reviewer 2 輕觀察

- `COHESION_RELIEF_SAT=3.0`：本輪 `distribute.dispatch=1/distribute.deliver=1`——P4 fixture 裡確實有 1 次真實 relief 事件，但因為①②被 confound 污染，無法確認這次 relief 是對哪一邊、有沒有真的影響 stay_benefit 的飽和曲線，本輪未能驗證。
- uprising test 偵測力：非本輪重點，未特別測。

## specimen dump

本輪把時間優先花在追查/理解 confound 現象，**未產出 specimen jsonl**——如實聲明擱置，待 fixture redesign 後可一併補。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-cohesion-p4-45d.txt`（621行，完整跑 log + T1/T3 逐日 + defect_util 樣本）
- `docs/measurements/2026-08-05-cohesion-rep-recheck.txt`（710行，rep 床 cohesion 後重跑完整 log）
- `docs/measurements/2026-08-05-infonet-cohesion-p4-diagnostic.json`（692行，結構化 dump）

## 清理狀態

- `warring_harness.gd`/`event_faction_defect.gd` temp PROBE_KEYS/診斷 tap 已 `git checkout --` 還原確認乾淨。
- temp fixture/bed（`config/infonet_cohesion_p4.json`、借測用 `config/infonet_faction_rich_rep.json`、2 個 bed script）皆已刪除，未 persist。

## ★誠實淨判

- **③下游解鎖（arc 最重要目標）**：★★未達成，rep 床仍 collapse 成 1 faction，跟 cohesion 前幾乎一樣。
- **①②分化/该散照散**：本輪被無關的既有 G3 diplomacy betrayal 機制污染，未能測到，需 redesign fixture 重測。
- 別下 accept。③是核心壞消息建議優先看；①②需要重新設計 fixture（避開 betrayal 觸發）才能真正驗證，交你們判斷下一步（redesign 補測 vs 先查為什麼 rep 床沒被解鎖）。
