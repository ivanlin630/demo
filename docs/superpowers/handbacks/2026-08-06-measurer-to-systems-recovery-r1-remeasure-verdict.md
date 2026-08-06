---
from: measurer
to: systems
status: open
topic: "recovery-r1移民重量(執行層修後,commit 14203b57) — 決策層再確認CONFIRM,但migrant.arrived仍=0(執行修在我床上未生效):同床同seed重跑對14203b57,plains(marginal+0.1668)3次全獲dispatch/mountain(−2.2396)0次,數字跟修前完全一致(dispatch側不受此fix影響本就預期)——但★migrant.arrived依然全程=0,跟implementer自己r1_test 8/8(含驗執行端pop2→5併入+arrived=1)的PASS結果矛盾。temp-print追進`_tick_migrant`本身:確認它真的被呼叫(3次,每個subteam各1次)+move_target正確設定為目標村真實座標(23,20)——fix邏輯本身在我床上有執行到、target算對了。但每個subteam只在`_tick_migrant`裡出現過1次(對應dispatch瞬間),之後從未再被觀察到——懷疑真正的逐tick位置推進(由獨立的movement/`_step2_move_teams`系統負責,非`_tick_migrant`本身)可能沒有把這些migrant subteam納入處理,可能是我這輪已經解開的near/far LOD team-partitioning問題的第二個變種(這次是subteam層級,非team層級)。已追到能力邊界,effort budget高,建議systems若要繼續查優先看movement系統對new-spawned subteam的LOD/near-far分類邏輯,或直接請implementer在我的具體fixture(distance=3,cluster_pos anchor)上重現。核心①③④決策層分化仍然CONFIRMED不受影響。"
---

# recovery-r1移民重量（執行層修後） — 決策層再CONFIRM，migrant.arrived仍0（新細節）

工單 `2026-08-06-systems-to-measurer-recovery-r1-remeasure.md` 消費。

## 做法

沿用`deb10640`bed（`cluster_pos` anchor）+同seed=9090+同config，對`feat/recovery-r1`新commit`14203b57`（`_tick_migrant`執行層修）重跑。

## 決策層：再次CONFIRM（數字與修前完全一致，符合預期）

```
plains(T1): marginal=+0.1668（唯一正值）→ 3次全dispatch，target_village=1
mountain(T3): marginal=−2.2396（負值）→ 0次dispatch
```

跟修前(`deb10640`那輪)數字**逐位元相同**——這完全合理，因為`14203b57`只改`_tick_migrant`（dispatch**之後**的移動邏輯），不影響dispatch本身的決策計算，determinism理應不變。

## ★★migrant.arrived仍=0——跟implementer自己的r1_test矛盾

22天窗口，3次dispatch，**依然0次arrived**（`docs/measurements/2026-08-06-recovery-r1-remeasure-22d.txt`）。這跟commit message寫的「r1_test 8/8含驗執行端migrant抵村→target pop2→5併入+arrived=1」矛盾——implementer自己的controlled unit test PASS，但在我的organic fixture上不生效。

## temp-print深入`_tick_migrant`本身（已revert，落地`docs/measurements/2026-08-06-migrant-tick-debug.txt`）

```
[MTDBG] sub=5 pos=(20, 20) move_target=(23, 20) tick=260
[MTDBG] sub=6 pos=(20, 20) move_target=(23, 20) tick=500
[MTDBG] sub=8 pos=(20, 20) move_target=(23, 20) tick=740
```

**好消息**：`_tick_migrant`真的被呼叫（3次，精準對應3個dispatch），`move_target`正確設成目標村的真實座標`(23,20)`（=plains村位置）——**fix邏輯本身在我的fixture上有執行到、目標算對了，不是target設錯的問題**。

**懸案**：**每個subteam只在這個log裡出現過恰好一次**（對應dispatch瞬間那一tick），之後22天內從未再被`_tick_migrant`觀察到過。`_tick_migrant`本身只負責「設定move_target/判斷是否已抵達」，**真正逐tick把`tile_pos`往`move_target`推進的是另一個獨立的movement系統**（`sim_runner.gd`phase table的`"move"`/`_step2_move_teams`）——如果這個系統沒有把這些新生migrant subteam納入處理範圍，`tile_pos`就會卡在原地永遠不變，`_tick_migrant`後續每次檢查`sub.tile_pos==target.tile_pos`都不成立，也就永遠不會再被有意義地呼叫（因為`_evaluate_subteam`本身可能是低頻決策層,不代表subteam「活著」與否，movement才是真正決定它會不會動的系統）。

**我的假設（未坐實）**：這可能是我這輪已經解開的near/far LOD team-partitioning問題的**第二個變種**——這次可能不是team層級（lord本身），是**subteam層級**（新生的migrant/scout/convoy等subteam是否自動繼承parent的LOD分類，還是需要獨立計算，如果獨立計算且用subteam自己的位置去比對anchor距離，考量subteam一開始跟parent同位置應該仍在near範圍——但如果LOD partition list是每tick開頭重算、只包含「這tick開始時已存在」的teams，新生subteam要等下一輪partition才會被納入，這頂多延遲1 tick非永久卡死，所以這個簡單假設解釋不了「22天都不動」）。

## 誠實淨判

- **決策層（①③④三態分化）：CONFIRMED，不受這次fix影響，維持有效**。
- **執行層（migrant真的走到並merge）：仍未在我的fixture上驗證通過**——fix邏輯本身有執行、target算對，但實際的逐tick位置推進似乎沒有發生，根因指向movement系統對new-spawned subteam的處理，超出這輪temp-print能力邊界（已經是第二層LOD-like問題，effort budget已經很高，不再繼續深挖）。

## 建議

若要繼續查，建議方向二選一：①systems/implementer直接在我這個具體fixture（`config/infonet_recovery_r1_migrant.json`+`cluster_pos`anchor，已persist commit`deb10640`）上重現，比我隔空猜測movement系統的LOD邏輯更有效率；②或先確認r1_test的controlled unit test是否也用了跟我一樣的`cluster_pos`/near-far anchor設置——如果r1_test根本沒有near/far概念（純函數呼叫或全員near），那可能就是同一個LOD-in-headless-bed的坑，只是這次咬在subteam的movement而非team的vision。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant-remeasure.json`（62行）
- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant-remeasure.specimen.jsonl`（4829行）
- `docs/measurements/2026-08-06-recovery-r1-remeasure-22d.txt`（11536行）
- `docs/measurements/2026-08-06-migrant-tick-debug.txt`（409行，`_tick_migrant`診斷）

## 清理

temp print（`_tick_migrant`診斷+per-village歸因bump_sample，共2處）已`git checkout --`revert確認乾淨。bed script DAYS常數確認已恢復22（跟`deb10640`一致，本輪無新commit需要）。

別下accept。決策層可視為驗收通過；執行層是否要繼續查/優先序交你們判。
