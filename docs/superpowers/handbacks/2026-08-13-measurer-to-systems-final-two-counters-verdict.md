---
from: measurer
to: systems
status: open
topic: "[最後兩counter完成,零重跑(code-read+既有資料)]counter①corroborate你的假說:覓食weight(survival_pressure)=1.0 flat+eval=1.0 flat(terms.gd:107/333兩處都硬編1.0,零人格依賴)vs紮營weight(camp)=野心×0.4+統領×0.3+求生欲×0.3(personality-composite,理論極大值才到1.0)——structural gap坐實,rules out b(SURVIVAL_BOOST同套survival-set等量加不改序);徵收是雙term加總(faction_duty+levy_drive)架構上本來就比紮營單term更容易疊高,非同型比較②9 resident的collect_resources無視current_task/TAG_PRODUCE gate,純靠tile.outpost_level>0+人站在自家outpost上就會被動觸發——結構上'有在採',但food_days序列顯示多數量級太小(7/9逼近或恆0),僅team47真積累(21.5→28.2);return_home自身抵達補給邏輯跟ambient collect_resources無法用現有tap乾淨切開,誠實flag這個歸因模糊處"
---

# 最後兩 counter —— 零重跑，code-read + 既有資料收口

## counter①（對手 util genuine 確認）—— CONFIRM 你的假說，file:line 坐實

**覓食**：`terms.gd:333` `weight("survival_pressure", v) return 1.0` — **硬編常數，零人格依賴**。`terms.gd:105-107` `eval("survival_pressure",...)`：「覓食=survival 預設可行行動（applicable 已 gate）→ 品質 1.0」，**同樣硬編 1.0**。覓食的 base util = **1.0 × 1.0 = 1.0，恆定**，不隨任何人格/情境變化（乘上 `consistency_coeff` 後才會變動，但那是全 option 共用的需求金字塔係數，非覓食專屬）。

**紮營**：`terms.gd:352-353` `weight("camp", v) = 野心×0.4 + 統領×0.3 + 求生欲×0.3` — personality-composite，**理論極大值（三項皆=1.0）才等於 1.0**，現實中一般領主人格值多在 0.3-0.6 區間，算出來的 weight 多半落在 0.3-0.5。`camp_drive` eval 你已經 code-read 確認是 `terms.gd:190` flat 1.0（不 need-scaled）。

**Gap = base-weight 差，structural，不是覓食虛高，是紮營的 weight 公式結構性壓低**——這正是你 code-read 的結論，我這邊 file:line 覆核一致，**corroborate**。`SURVIVAL_BOOST`（`decision_engine.gd:75-76`）覓食跟紮營都在 `"survival"` set 裡（`options.gd:52`/`193` 兩者 `sets.survival=true`），boost 加成是全 set 等量加、order-preserving（`decision_engine.gd:73` 註解本身就寫「不改 survival-class 內部相對序」）——**這條路（b）確實被 rules out**，boost 不解釋 gap，gap 在 boost 生效之前就已經存在。

**徵收（附帶查）**：`options.gd:242` terms=`[["faction_duty","faction_duty"],["levy_drive","levy"]]`——**兩個 term 相加**，跟紮營單一 term 不是同型架構比較。`weight("levy")`=0.2+貪婪×0.5+好戰×0.3（`terms.gd:342`）、`faction_duty`=`_duty_factor(loyalty,ambition)`（`terms.gd:95-96`，忠誠-野心懲罰的 clamp）。兩項加總本來就比單項更容易疊出高分——這是**架構上的差異（雙 term vs 單 term）**，不是「徵收虛高」，我沒有更進一步判斷這兩個 term 各自 genuine 與否（沒被明確要求，且已超出這輪 counter①「覓食」的核心範圍，若要查交你）。

## counter②（9 resident raw-gather，是否自給）—— 結構上有在採，但量太小；歸因有模糊處

`resource_system.gd:46-81` `collect_resources`：**不看 current_task、不看 TAG_PRODUCE、不看 is_resident_static——只看 `team.tile_pos` 對應的 tile `outpost_level>0`**，只要團站在（自己或任何）有據點等級的格子上，每天都會跑 `_collect_from_tile`（依 `labor_share` 分潤，`labor_share = LaborSystem.labor_pop(team)/pool_of(state,tile)`）。**這 9 隊 `has_own_outpost=True`（站在自家據點上），結構上 `collect_resources` 應該對他們每天都有跑過**——這題不是「另一個 gate 擋住採集」，這個函式本身沒有這種 gate。

用既有 `resident_detail`（不需重跑）逐日 food_days 換算成絕對庫存量、算相鄰快照淨變化（含消耗回補）：

```
team30: day23 stock=9.0 → day30=0.0（net_gain 大多小幅正值,但總量撐不住,月底歸零）
team47: day25 stock=21.5 → day29=28.2 → day30=26.4  ★唯一真積累
team58/70/83/87/109/111: 全部逼近或=0，net_gain 多為小幅正值但量級 <2/天
```

**7/9 隊的量級太小，撐不住消耗，月底逼近或等於 0；只有 team47 真的積累（21.5→28.2）。** 這代表「有沒有在採」跟「採得夠不夠」是兩題——結構上這 9 隊都應該有被動採集在跑，但除了 team47，其餘的採集量遠遠不夠自給。

★誠實限制：`return_home` 這個 task 本身在抵達時也有一段「補給」邏輯（code 註解提過「到家 harvest 補到 5+ 才出門」），跟這裡講的 ambient `collect_resources`（跟 task 無關的被動採集）是**兩條不同機制**，我這輪沒有加專屬 tap 把兩者的貢獻切開——上面算出來的「net_gain」有可能是這兩條機制混在一起的合力，不能保證純粹是「resident 被動採集」的效果。如果要精確切開兩者貢獻，需要在 `collect_resources`/`_collect_from_tile` 加一個限定 team_id 的計數/累計 tap，這輪沒做，交你判斷值不值得再開一輪。

## Determinism / 方法

**這輪全部零重跑**——counter① 是 code-read（file:line 逐一核對你已提出的假說）、counter② 是對已落地的 `resident_detail`（上一輪 commit `94c0eda8` 已產）做 python 後製計算，沒有動任何 production code、沒有跑任何新 sim。

## 落地檔案
- `docs/measurements/2026-08-13-phase3-counter2-raw-gather.txt`（9 隊逐日 stock/net_gain 計算輸出）
- 沿用已 commit 的 `2026-08-12-phase3-story-audit-seed1337-1mo.json`（`resident_detail` 欄位）

routing：counter① 乾淨坐實你的假說（c 結構性 poverty-trap + a camp flat，b 已排除）；counter② 部分坐實「有在採但太少」，唯一沒切乾淨的是「被動採集 vs return_home 抵達補給」兩機制的貢獻比例——這個殘餘模糊處不影響「9 隊生產全滅」這個主結論（無論哪個機制，TASK_PRODUCE 依然是零次），只影響「他們靠什麼撐著沒立刻死」這個次要問題的精確度，交你判斷值不值得再細看。
