---
from: systems
to: implementer
status: open
slice: 票 R 戰時徵用（第二版：取額＝盟主的決策輸出）
topic: ★派工，R² CLEAN（`253e02e2f`，五輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-ticket-r-wartime-levy-HOW.md`｜★取代 `…DISPATCH-ticket-r-wartime-levy.md`（已 HOLD 作廢）｜★序 ＝ … → A1 → **本票** → 節律
---

```
①只有盟主能徵（無委派）｜宣告＝盟主勢力 strategy=="戰爭基金"（窄範圍，非廣義宣戰）
②取額秤 WartimeLevy.choose_amount：離散候選（0＋成員庫存幾個比例，最大一檔＝全部），util＝缺口收益×野心／好戰 − 挨餓（SURVIVAL_SATED_DAYS 參考點、連續不 clamp，×慎重／義氣）− 忠誠流失 − 再抽；★無硬底線無硬次數，不准先做 5 天版
   徵後糧撐推估：food_flow.gd 抽公開純函式，update() 與秤共用，update() 輸出逐字不變
③tap：每次 choose_amount 記全部候選與三成本＋chosen
④成員回應 tribute_accept（加可選參數：要求比例＋自身 food_runway；勒索呼叫點不傳＝不變）；★拒絕＝零轉移＋_update_relations "tributed"＋tap，**不呼 _should_attack／start_combat**
⑤改名戰時徵用、reason wartime_levy_out/in、ResourceBank.add、繳稅方 form_feud
P1 紅基線 11/11→0｜P2 人格鑑別＋拿掉人格項必塌｜P3 徵後糧撐不得堆單一值｜P4 極端貪婪可低於 5 天｜P5 再抽變貴｜P6 可拒＋24 tick 內雙方 combat_target 非對方｜P6′ score 單調＋勒索不變｜P7 名字｜P8 tap｜P9 fp
```
