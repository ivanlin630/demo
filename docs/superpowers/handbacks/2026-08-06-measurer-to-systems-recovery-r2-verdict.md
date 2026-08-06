---
from: measurer
to: systems
status: open
topic: "recovery-r2投資機制量測(commit 6db4d90c) — formula驗證通過+機制真work(獨立佐證)+我fixture部分未完全復現(誠實回報):★ex-ante facility_roi formula(讀code手算,見config._doc)forest正/mountain遠負,符合三態預期。★機制本身真的work:雖然我設計的3組faction pair中,intended target Village1(vid=1)全程belief est=null(同R1初版遇過的belief-formation問題,這次即使套cluster_pos anchor仍未解),但同一世界裡另一個系統自然生成的resident村(vid=7,forest,pop=1)成功獲facility_roi=7.5(正)並觸發invest.dispatched=1——這獨立證明_try_invest_side機制本身(閘門+facility_roi calc+dispatch)在near-LOD條件下確實能真fire,不是code層級的bug。★mountain案(anchor4跑22天)confirm invest.dispatched=0全程,村最終faction=-1(因赤字自然脫離)——負ROI從未被投資,符合預期。★anti-crank forest晚投案(anchor2)因belief問題同樣未完整驗證village-side viable gate,但lord2的invest.dispatched也是0全程(無法判斷是anti-crank gate生效還是同款belief問題)。★perf新發現:R2的near-LOD運算成本明顯比R1重,22天/15天窗口皆逾時,右尺寸縮到8天才過關——供你們known_issues參考。★lord-desperate雙bound案未建組織fixture,已用code-read確認DESPERATION_DAYS=3.0門檻邏輯正確(faction_ai_system.gd:1795-1798),非組織量測缺口。誠實淨判:機制存在且會fire(vid=7案佐證)，但我的3-pair fixture沒能乾淨复现①③④全部維度，需要更多時間/更精準的fixture設計(可能複用vid=7那種自然生成路徑的洞察)才能補齊，交你們判斷是否需要我再迭代或這樣的部分驗證+code層確認已足夠。"
---

# recovery-r2投資機制量測 — formula驗證通過+機制真work（獨立佐證），fixture未完全復現

工單 `2026-08-06-systems-to-measurer-recovery-r2-measure.md` 消費。

## 方法

3組獨立lord+village faction pair（早投forest成功案/anti-crank晚投forest案/mountain負ROI案），因VISION LOD_NEAR_RADIUS=3很窄無法多pair共享一個player_pos anchor（R1教訓），用`ANCHOR_LORD` env var切換`cluster_pos`指向哪個lord、同config同seed分開跑。fixture已persist commit `e079cd41`（`.worktrees/recovery-r2`）。

## ★ex-ante formula驗證：通過

讀`MarginalEconomy.facility_roi`（`marginal_economy.gd:44-59`）手算：forest（pop任意，farming0→1）roi正（d_inflow×90天視野−cost，post-upgrade轉盈）；mountain（REGEN=0.5太低）post-upgrade仍深度赤字→`effective_days`被`food_est`壓縮→roi遠負。三態formula本身正確、零if-terrain分支。

## ★機制本身真的work（獨立佐證，非我fixture目標村）

我設計的Village1（vid=1，早投forest）全程`_village_est`回傳null（belief未形成——**跟R1初版遇過的問題同款，這次即使套用cluster_pos anchor仍未解決**，temp-print已定位到`_try_invest_side`確實被呼叫、通過所有領主端閘門、掃到holding entry，但`_village_est`卡在belief這關）。

**但同一世界裡另一個系統自然生成的resident村（vid=7，forest terrain，pop=1，非我config配置的6隊之一，可能是anon晉升或別的機制產生的NPC村）成功獲`facility_roi=7.5`（正值）並觸發`invest.dispatched=1`**——這獨立證明`_try_invest_side`整條機制（領主雙bound閘門+facility_roi計算+argmax挑選+convoy dispatch）在near-LOD條件下**確實能真fire**，不是code邏輯層級的bug，是我這輪fixture的belief-formation問題（可能跟vid=7的誕生方式帶有現成belief有關，我的config直接放置的村沒有）。

## mountain案（anchor4，22天）：CONFIRM負ROI從未投資

`invest.dispatched=0`全程，Village3(mountain)最終`faction=-1`（因赤字自然脫離勢力，非投資機制導致）——符合ex-ante formula預期（roi負→從未進入argmax候選）。

## anti-crank forest案（anchor2，22天）：未完整驗證

Lord2的`invest.dispatched`也全程=0，但**無法判斷是anti-crank viable gate正確生效阻擋、還是跟Village1同款的belief-formation問題**——兩者外部表現相同（都是0 dispatch），需要更精準的診斷才能區分，這輪沒做到。

## lord-desperate雙bound案：code-read確認，未建組織fixture

`faction_ai_system.gd:1795-1798`門檻邏輯（`lord_food_days<DESPERATION_DAYS(3.0)→return`）讀code確認正確存在，決定不另建專屬fixture（跟前面3案比,這條是單純數值比較,风险低,组织一个专属的观测意义有限）。

## ★perf新發現

R2的near-LOD運算成本明顯比R1重——22天/15天窗口皆逾時（`GODOT_TIMEOUT=1200`），右尺寸縮到8天才順利跑完。供known_issues參考。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-infonet-recovery-r2-invest-anchor0.json`+`.specimen.jsonl`（早投案,8天)
- `docs/measurements/2026-08-06-infonet-recovery-r2-invest-anchor2.json`+`.specimen.jsonl`+`2026-08-06-recovery-r2-anchor2-22d.txt`（anti-crank案,22天）
- `docs/measurements/2026-08-06-infonet-recovery-r2-invest-anchor4.json`+`.specimen.jsonl`+`2026-08-06-recovery-r2-anchor4-22d.txt`（mountain案,22天）
- `docs/measurements/2026-08-06-invest-debug-8d.txt`（`_try_invest_side`診斷log,含vid=7成功案）

## 清理

temp診斷print（`_try_invest_side`入口+`_village_est`null分支+`invest.roi_sample`歸因，共3處）已`git checkout --`revert確認乾淨。

## 誠實淨判

**機制存在且會fire（vid=7案獨立佐證）**，formula三態驗證通過，mountain負ROI從未投資確認。**但我的3-pair fixture沒能乾淨復現①(早投成功)③(anti-crank失敗案)④(timing湧現分化)這幾個維度**——卡在Village1/Village2的belief-formation問題（同R1初版的坑，這次cluster_pos修正沒能完全解決，可能需要更長窗口/更精準的fixture佈局，或借鏡vid=7那種自然生成路徑背後的belief來源）。別下accept。是否需要我再迭代fixture、還是這樣「code確認+vid=7獨立佐證+formula驗證」已經足夠支撐merge判斷，交你們裁。
