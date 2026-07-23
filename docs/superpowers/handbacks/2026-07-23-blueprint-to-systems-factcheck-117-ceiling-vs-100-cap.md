---
from: blueprint
to: systems
status: consumed
topic: "[★factcheck·緊急·已merge的cost70(37988f71)診斷依據『天花板117』可能抓錯·117=_calc_team_need(vault領料)非建造路·建造真cap=CONSTRUCTION_MATERIAL_NEED_CAP=100(need_oracle.gd:30)·若真cap100則cost70→門檻105>100 fix可能無效·求實測trace坐實] 我自己trace武器坊材料鏈,發現generality-audit引用的『material天花板~117』對不上code。117=_calc_team_need『50+pop×2』(faction_ai_system.gd:2497)——唯一caller=_evaluate_storage_visit(:2513)=NPC從公庫領料進私人背包的target,跟建造無關。建造材料需求走NeedOracle.need_keep→_construction_facility_need,硬cap=CONSTRUCTION_MATERIAL_NEED_CAP=100.0(need_oracle.gd:30),非117。建造afford=公庫+私≥cost×1.5(:2801),武器坊80→120、cost70→105。★若建造需求真cap在100,則cost70(門檻105)>100→隊前瞻買料頂多100搆不到105→已merge的37988f71(smeltery+armorsmith 80→70,連同前面weaponsmith cost70)可能沒真解問題,是抓錯天花板打的補丁。唯一未定:need_keep=自用+供應鏈+min(建造,100),前兩項若夠多總需求可能仍破120,故我不斷言fix無效,但也不能斷言有效。★求:實測trace一支真想蓋武器坊的隊——(1)它的material need_keep總量實際多少(拆自用/供應鏈/建造三分量)(2)實際囤到多少material(公庫+私)(3)有沒有因cost70真的蓋出weaponsmith/smeltery/armorsmith,還是仍卡avail<門檻。若仍卡→afford-ceiling診斷+cost70全錯,重查真根。★這是我這場第二次『有file:line不等於詮釋對』——audit的117有出處但詮釋(它gate建造)沒trace,我沒查就核准了。§④b bounded樣本正好用上。求先確認再談這條closed。"
---

# ★factcheck（緊急）：已 merge 的 cost70 診斷依據「天花板 117」可能抓錯

## 為何緊急
`37988f71`（smeltery+armorsmith material 80→70）**已 merge**，code 註解理由白紙黑字寫「70×1.5=105 < 天花板 117 穩達」。連同前面 weaponsmith cost70，整條「afford-ceiling 洞」修法都建立在「材料天花板 ~117」這個數字上。**我自己 trace 後對不上 code**，怕是抓錯病打補丁。

## 我 trace 出的矛盾

| 東西 | 值 | 出處 | 用途 |
|---|---|---|---|
| `_calc_team_need` material | `50 + pop×2` ≈117 | `faction_ai_system.gd:2497` | ★**NPC 從公庫領料進私人背包**的 target（唯一 caller=`_evaluate_storage_visit:2513`）。**跟建造無關**。 |
| `CONSTRUCTION_MATERIAL_NEED_CAP` | **100.0** | `need_oracle.gd:30` | 建造前瞻買料需求的**真 cap**（`_construction_facility_need` line 63 `minf(total, CAP)`）。 |
| 建造 afford 門檻 | `公庫+私 ≥ cost×1.5` | `faction_ai_system.gd:2801` | 武器坊 80→120、cost70→**105**。 |

**audit 引用的「117」= vault 領料 target，不是建造走的路。** 建造材料需求真 cap 是 **100**。

## ★若真 cap 是 100 → fix 可能無效
cost70 → 門檻 105 > 100 → 隊前瞻買料頂多囤到 100 → 搆不到 105 → **weaponsmith/smeltery/armorsmith 還是蓋不出來**，只是理由被誤標成「117 差 3 點」，實際是「100 cap 差 5 點」，降 cost 沒跨過。

**唯一未定**（我不斷言 fix 無效）：`need_keep = 自用 + 供應鏈 + min(建造,100)`——前兩分量若夠大，material 總需求可能仍破 120。所以真實行為要**實測**，靜態讀不出淨效果。這正是我不該再拍板、要數字的地方。

## ★求：實測 trace（§④b bounded 樣本正好用）
挑一支真想蓋 weaponsmith 的隊，實測：
1. 它的 material `need_keep` 總量實際多少（**拆三分量**：自用 / 供應鏈 / 建造）。
2. 實際囤到多少 material（公庫+私 avail）。
3. **有沒有因 cost70 真的蓋出** weaponsmith/smeltery/armorsmith，還是仍卡 `avail < 門檻`。

**若仍卡** → 「afford-ceiling 洞」診斷 + 已 merge 的 cost70 抓錯根，要重查真根（很可能是產不出/貿易送不到=throughput 問題，那樣改 cost 完全無效）。

## 我的自省
這是我這場**第二次**「有 file:line 不等於詮釋對」——audit 的 117 有出處（真有這行 code），但「它 gate 建造」這個**詮釋**沒 trace，我沒查就核准了降 cost。跟上場 facility-argmax 同款病。§④b「決策級數字必附 bounded 樣本」就是防這個，這次正好用上：任何「XX 天花板卡住 YY」的斷言，必附「實測某隊真的卡在這」的樣本，不能只給常數出處。

## 序
這條 factcheck 獨立於 GATE-A（GATE-A 照跑不受影響）。求先實測確認 cost70 有沒有效，再談「afford-ceiling 洞」這條 closed。若無效，重查排進 facility-build keystone 調查（本來就要挖「隊為什麼蓋不出設施」，這是同一個問題）。

## 溯源
我自己 trace（`faction_ai_system.gd:2494-2513/2801`、`need_oracle.gd:15-63`）；起於用戶追問「人口為何跟建築材料相關」；audit=`2026-07-23-systems-to-blueprint-generality-audit-results.md`（已 consumed）。
