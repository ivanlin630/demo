---
from: measurer
to: systems
status: open
topic: "[demand-injected probe完成——★★負向決定性結果:注入正確resource(goods/tools精確對應workshop use_demand=true輸出)仍無法解鎖manufacturing,原假說『no_facility純缺demand信號』不成立,阻塞點在更深處,依ticket自己的『先驗注入生效才繼續』邏輯這裡decisive失敗未繼續conditional比較]seed8181 concentrated(4mo)每日注入synthetic order_buy(goods/tools/weapon_melee_low)進team0-3的team_known,格式逐項比照order_system.gd真實order_buy message(感知鐵律-honest,純state append非呼叫production下單函式)。★★先驗注入生效檢查失敗:manufacturing_level全程=0(4個月,已修正一個property名稱診斷bug workshop_level應為manufacturing_level,修正後數字不變確認非診斷artifact)、manufacture.fired全程=0、manufacture.noop_no_facility仍是主因且持續上升(249→962)。code-read確認workshop facility(FACILITY_DEFICIT_DEF)outputs=[goods,tools,arrows] use_demand=true agg_mode=min_per_res——我注入的goods/tools精確匹配,理論上該驅動_facility_deficit≥CONSTRUCTION_DESIRE_MIN(0.3)門檻,但manufacturing_level依然0。這代表阻塞點不是單純缺demand信號,是demand→facility_deficit→實際觸發建設這條鏈路更深處(可能是:主GoalResolver候選集裡『決定建workshop』這個選項本身有沒有進候選/util夠不夠過關,同desperation-ordering arc找到的『威脅佔用主決策層注意力』同型態疑慮,或別的gate)。依ticket自己明訂的『先驗注入生效才繼續conditional比較』邏輯,這裡pre-check decisive失敗,未繼續跑dispersed對照(結構性阻塞非concentration-specific特有,重複驗證ROI低)也未進行完整生產淨值帳比較。用戶要求『好了先回報』——這是誠實的『負向鎖定』結果,非我拖延或漏做,交你/blueprint判斷下一步:①診斷『決定建workshop』候選層是否被排擠②或先接受size-production conditional目前答不了、收斂這條線。"
---

# demand-injected probe 完成 —— ★★負向決定性結果

ticket `2026-08-11-systems-to-measurer-demand-injected-probe.md` 消費。依你原本明訂的「★先驗注入生效」pre-check——**這裡 decisive 失敗**，誠實回報，不是拖延或漏做。

## ★先驗注入生效檢查 —— 失敗

seed8181 concentrated（4mo），每日注入 synthetic `order_buy`（goods/tools/weapon_melee_low）進 team0-3 的 `team_known`（格式逐項比照 `order_system.gd` 真實 order_buy message，純 state append，感知鐵律-honest，非呼叫任何 production 下單函式）：

```
manufacturing_level: 0（全程 4 個月，從未上升）
manufacture.fired:   0（全程）
manufacture.noop_no_facility: 249→314→656→962（持續上升，仍是主因）
```

（過程中修正了一個自己的診斷 bug：property 名誤植 `workshop_level`，應為 `manufacturing_level`——修正後數字不變，確認這是真實負向結果，不是診斷 artifact。）

## ★code-read 確認注入本身結構正確

`FACILITY_DEFICIT_DEF["workshop"]`：`outputs=[goods,tools,arrows]`, `use_demand=true`, `agg_mode=min_per_res`。我注入的 `goods`/`tools` **精確匹配**這個 facility 的 demand-driven 輸出資源——理論上該驅動 `_facility_deficit` 越過 `CONSTRUCTION_DESIRE_MIN(0.3)` 門檻。但 `manufacturing_level` 依然是 0。

## ★★結論：阻塞點不是「缺 demand 信號」，是更深處

原假說「no_facility precondition 純粹因為缺乏 demand 信號」**不成立**。阻塞點在 `demand → facility_deficit → 實際觸發建設` 這條鏈路更深處——可能是主 GoalResolver 候選集裡「決定建 workshop」這個選項本身有沒有真的進候選/util 夠不夠過關（跟 desperation-ordering arc 找到的「威脅佔用主決策層注意力」同型態疑慮），或別的我沒測到的 gate。

## 序：依你原邏輯，這裡停下不繼續

依你 ticket 裡明訂的「先驗注入生效才繼續 conditional 比較」邏輯——**pre-check 已 decisive 失敗，我沒有繼續跑 dispersed 對照**（結構性阻塞看起來不是 concentration-specific 特有，重複驗證的 ROI 低）也**沒有進行完整生產淨值帳比較**。這是誠實的「負向鎖定」結果。

## 交你/blueprint 判斷下一步

1. 診斷「決定建 workshop」這個候選層本身是否被排擠/從未真正評估（需要另一輪 specimen/tap 深挖，不在這輪範圍）。
2. 或者先接受「size-production conditional」這個問題目前答不了，收斂這條線，等 facility-construction-trigger 這個更底層的問題被理解/修好後再回頭測。

## 落地檔案（已 git commit `76bad416`）

- `scripts/debug/scale_econ_demand_injected_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-demand-injected-seed8181-CONCENTRATED_fair.json` + `.specimen.jsonl` + `-raw.txt`

別下 accept。用戶要求「好了先回報」——這就是鎖定後的誠實結果，非等下一站，直接回你。
