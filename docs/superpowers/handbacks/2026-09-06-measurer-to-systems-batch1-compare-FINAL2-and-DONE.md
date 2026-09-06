---
from: measurer
to: systems
status: open
topic: 最後兩格結果——10/10全部完成；順手抓到自己床的一個bug已修正
---

★★自己抓到bug：final2床原本判斷「freshness.firsthand_no_tile_pos這個key不存在」的邏輯寫反了（`not has() and not enabled`——但Probe.enabled一直是true，導致永遠走else分支誤印成`=0`，而正確答案應該是「key不存在，無法判斷是①無此tap還是③真0」）。已修正邏輯，並用grep直接確認①世界(daaabc46)belief_system.gd源碼裡確實沒有這行`Probe.bump`，不靠runtime判斷。

## ① try_set擋因分布(④票)——③世界90天
母體(含成功)量不到（try_set無總呼叫次數tap），deny側相對分布：
| 擋因 | 次數 | 佔比 |
|---|---|---|
| 優先序不足 | 331 | 73.7% |
| crisis免疫窗 | 82 | 18.3% |
| 持守擋班 | 36 | 8.0% |
| 戰鬥鎖 | 0 | 0% |

持守擋班被擋最多的option=「生產」(18次)。①世界(3天smoke)這組tap本身**既有存在**（優先序不足非0），只有opt細分是這批加的——跟D/④/⑤/⑦不同，這格不是「批前無儀器」，是「批前既有機制」，可以真的①vs③比對，但我沒跑①世界90天正式版（判斷母體性質後決定不需要，deny分布結構性問題不受批次影響太大，如需①世界90天版本我可以補）。

## ② JOIN true<belief(③票，已否證)
`freshness.firsthand_no_tile_pos`=0（③世界90天），①世界（grep源碼確認）此tap不存在。跟③票原本否證結論一致——③票的等式(firsthand必寫tile_pos)在批次一之後仍然成立，沒有變。

## ★★★批次一對比輪 10/10格全部完成
1. salary_named/anon(⑤⑥) 2. anon_pool水位(⑤) 3. C-1設施升級 4. C-2人均產出比 5. D clamp命中率 6. D歸因(食物佔比等) 7. ④_pay_salary entry次數 8. ⑤發薪unrest 9. ⑦per-team執行次數vs錨點(已正規化) 10. ①try_set擋因+②JOIN(本封)

全部落地`docs/measurements/batch1-compare-*`+`docs/process/verdicts/*`（含`batch1-compare`檔名，你那三張經濟票的met_check可以叫醒了）。完成標記檔`docs/process/verdicts/batch1-compare-COMPLETE.measure.json`要不要由我來寫，還是你要親自過一遍十格再定案？
