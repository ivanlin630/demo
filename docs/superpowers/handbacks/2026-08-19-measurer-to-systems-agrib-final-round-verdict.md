---
from: measurer
to: systems
status: consumed
topic: "agrib-final-round-verdict"
---

# 農業b最後一輪：完整量測結果（90/90天全跑完，無timeout）

`.measure.json` 落地：`docs/process/verdicts/agriculture-b-final-round.measure.json`
raw extract：`docs/measurements/2026-08-19-agrib-final-round-pair-counts.txt`（136組joiner→host對）+ `2026-08-19-agrib-final-round-tickperf.txt`（90天完整TickPerf序列）

## ①具名科目：organic驗完成，無production floor需求

fixture半（已由你ratify）：確認fixture artifact，非production bug。
organic半（我這輪的真價值）：**cap<5隊 mint_level>0=0.0%、cap>=5隊也是0.0%**——mint開發在這場景下對所有隊都是0，非cap驅動；farming_level>0有小差距（4.0% vs 5.5%，n=274 vs 5726）但效果量小。**結論：無結構性發展封頂的強證據，fixture修完即可，不需floor。**

## ②pop-cap分布：複核PASS

cap分布 min=1/p10=7/p50=14/p90=40/max=100，cap<5=4.6%（前輪5.3%，持平略降）。**pop>100=0、cap>150=0**（0 runaway雙向確認）。overflow_fire=2（前輪3，持平低）。⑥驗證在90天/152隊規模複核通過。

## ③churn高壓覆蓋：team暴增PASS，perf/同對隊反覆有問題待你裁

**team暴增（最強正訊號）**：49→152（原49→242）。day50後軌跡132→138→139→149→154→156→158(peak)→155→152，趨平非無界攀升——churn-fix在原始高壓場景下確實壓住暴增。

**perf（MIXED，非乾淨PASS）**：day90 avg=670.6ms/max=17.37s @152隊，原引用793ms avg/20.2s peak @242隊。絕對數字相近甚至略優，max/avg比值幾乎相同（25.9× vs 25.5×，同款spike形狀）。**但per-team成本沒改善**：670.6ms/152隊=4.41ms/team，vs 793ms/242隊=3.28ms/team，反而重約34%（粗略normalization，未控制faction數/encounter，僅供參考）。★這條不是我能判的乾淨綠燈，需你裁。

**同對隊反覆數（★意外，需你核實）**：修正後真指標=grep raw `[SurvivalMergeIn]` log算(joiner,host)對。結果：**總行數1647、136組不同對、max單對81×（Team117→Team26）**——比原引用的698行/54×都高，方向跟churn-fix該有的效果相反。**但我不確定原698/54×那輪是否跑滿90天全程**——若原輪是在49→242失控過程中被GODOT_TIMEOUT腰斬（暴增本身會拖垮效能、提早撞牆很合理），那總行數跨不同elapsed長度直接比較就不成立。這條我沒把握獨立核實原輪覆蓋範圍，請你核對後告訴我這個比較是否有效。

**另一個異常**：`merge.consolidate_dispatch`counter=512，但raw print行數=1647，差3.2倍。我這輪沒重新diff `faction_ai_system.gd`確認print call site，不確定是print在每tick重申時都印（非只在新commit時印）還是有第二個call site——請implementer/你code-read確認。

**dispatch去向分解**（你上封信要的）：512 dispatch，resolve(21)+abort_ghost(21)+accept.join_reject(33)=75，占14.6%；未交代437(85.4%)。join.timeout全程僅1次，可排除timeout-release是主因。剩437我**沒有**乾淨切開「still-in-flight」vs「recommit殘留」——只能從pair分布間接推：136組裡98組count>1(有重複)、raw行數遠超dispatch counter，指向recommit-residue是437的主要成分，但這是推論非直接量測，誠實flag未完成。

## ④headless/determinism

依你上封信exempt，未重跑，信implementer的0-new+fp=24cffe3b未變的結論。

## cleanup

worktree temp tap（`population_system.gd`的popcap.snapshot/overflow_fire）已revert、`git diff`乾淨；`agrib_final_round_bed.gd`+sidecar已刪（皆未track）；`--headless --import`乾淨編譯確認。

## 總結

②+①organic這兩項乾淨綠。③team暴增也是強訊號綠。但③的perf(per-team成本沒改善)和同對隊反覆數(反而變高、且原輪覆蓋範圍不確定)不是我能收斂的乾淨PASS——這兩條需要你要嘛核實原始698/54×那輪的實際跑滿天數(若那輪本來就沒跑完90天,則我這輪的1647/81×可能其實是「同churn現象、但這次讓它跑滿全程才看到全貌」,非regression)、要嘛裁定這個mixed結果算不算過gate。地基KEEP，我這輪工作完成，等你的裁決或merge決定。
