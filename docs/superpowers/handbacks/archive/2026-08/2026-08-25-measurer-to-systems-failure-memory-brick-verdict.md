---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "★★磚自身指標健康(覆蓋率main1個option→branch16個structural id,build_workshop:resource=140逐字符合implementer自報;規律驗證算術證明count1→2→3嚴格遞減至COUNT_CAP後plateau,符合設計非bug;反面驗證code結構+exact-pair既有數據雙重佐證)——但★★★§7世界層明確regression:outpost day90 branch=8<day0=11(main那輪12>11)，中途新增main1/branch0，outpost.l0_to_l1main1/branch0(counter整條缺席)，棄置率83.3%→90.0%惡化;只有collect.no_outpost_no_camp_zero_food改善(1042→886)。磚機制生效與世界層變差同時發生，我沒做因果診斷，呈現對照供你判讀是否為磚的副作用；specimen已直寄QA挑day0-90間的流失/新增缺席案例；順手修godot-detach.ps1白名單漏洞(implementer預警的第二次同型血證)"
---

# 失敗記憶磚驗收：機制健康，但§7世界層明確regression

## ①覆蓋率+suppressed分佈：決定性改善

main(舊表)：`entries_written=0`(舊tap沒有這個)，day90 distinct key=5，**只有1個structural id『買單』**(339次)，`build_workshop:resource=0`(完全沒覆蓋)。

branch(新結構身分key)：`entries_written=569`，day90 distinct key=11，**16個structural id都有真實suppress次數**：`build_workshop:resource=140`(★與你自報逐字相符)、`build_apothecary:resource=134`、`survival=67`、`求和=92`、`紮營=47`等。**coverage從main的1個option擴到16個。**

## ②過渡窗tap：健康

`entries_written=569`，首次命中`tick=1210`(約day5)——不是「長期停在0」的紅燈情境。

## ③規律驗證(算術證明)：成立，但有明確上界(符合設計非bug)

count=1→2→3(=COUNT_CAP)的mult：0.800→0.600→0.400，嚴格遞減。**count=4以上plateau在0.400不再降**——ticket原句「第N+1次嚴格小於第1次」只對N<COUNT_CAP成立，超過COUNT_CAP後不再嚴格遞減，但這完全符合code自己的註解意圖(「連撞加深但有上限→不會永久封殺」)。★★另外獨立驗證了FLOOR(0.25)在count獨自作用下永遠打不到(0.2×3=0.6，1-0.6=0.4>0.25)，跟code註解「INTENSITY×COUNT_CAP刻意<1−FLOOR」完全吻合。

## ④反面驗證：code結構+經驗數據雙重佐證

`key()`把structural_id與target串成單一字串當dict key，exact match查詢——沒有跨target聚合路徑。★引用同slice先前的exact-pair-hitrate量測：team11對build_workshop:resource的45次輸分成2個distinct target各累積33/12次——若count跨target共用，不可能看到兩個不同數字，獨立證實per-target count分開累積。

## ★★★⑤§7三條+outpost普查：明確regression

| | main baseline | branch |
|---|---|---|
| collect.no_outpost_no_camp_zero_food | 1042 | **886**(改善-15%) |
| camp.built/abandoned | 24/20(83.3%棄置) | 30/27(**90.0%**棄置，惡化) |
| outpost.l0_to_l1 | 1 | **0**(counter整條缺席，report裡連印都沒印) |
| outpost day0/day90/新增 | 11/12/新增1 | 11/**8**/新增**0** |

**branch的day90(8)不只低於main(12)，還低於自己的day0(11)——這90天淨態是倒退的，不是幅度小，是實質變差。** 且中途新增=0(main那輪還有1次文明化事件，branch這輪一次都沒有)。

## ★誠實邊界

磚本身的機制(覆蓋率/suppressed分佈)看起來健康且達到設計目標，但世界層§7指標(尤其outpost存量/新增)明顯比main baseline差。**我沒有做因果診斷**——只呈現這個對照，供你判讀是否為磚的副作用(例如紮根/建設類option被suppress得比預期更用力，抑制了原本能成功的重試)，還是run-to-run隨機差異。建議下一步：查紮根/建設候選在branch這輪的suppress次數是否顯著高於main對應行為。

## specimen

`docs/measurements/breed-deathcause/failure-memory.specimen.jsonl`(6663 entries)，outpost regression是behavior因果宣稱⇒已直寄QA，建議挑day0~day90間main有但branch沒有的outpost流失/新增缺席案例。

## ★順手修一個工具bug

implementer預警`godot-detach.ps1`的`ADHOC_DAYS`/`PERF_OUT`只有WARN機制、沒有真的加入白名單(第二次同型血證)——已補上，純加名字不改設計，file維持ASCII-only，PowerShell parse驗證過。

## 落地

`.measure.json`：`docs/process/verdicts/failure-memory-brick-acceptance.measure.json` @534791ac(main) 2026-08-25
