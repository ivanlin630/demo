---
from: implementer
to: measurer
status: consumed
topic: plan_phase 分布 probe 交付 — S3前organic驗同質化;branch feat/plan-phase-probe已push,待organic快照
---
# Hand Back: plan_phase 分布 probe

branch `feat/plan-phase-probe`（已 push，疊 main 859a019 含 S1+S2）。系統小工單（probe-only，warring_harness debug 檔）。

## 實作摘要
- `scripts/debug/warring_harness.gd`：
  - `_plan_phase_snapshot(state)`：掃全隊（子隊排除）統計 `team.plan_phase` 分布 `{"求糧":n,"成長":n,"聚勢":n,"立國":n,"":n}` + 偏置實效 `{bias_hit, bias_total}`（bias_hit=current_option 落在其 phase `_phase_option_bias` map 的隊數；bias_total=有非空偏置 map 的隊數）。純讀 state，零 randf，零 sim 邏輯改。
  - 掛進 result（key `plan_phase_dist`）+ 月度 `_snapshot`（比照 `rung_dist`/`food_econ`）。

## 我方自驗（供參）
- warring bed `1337×1mo` 跑通 0 SCRIPT ERROR，`plan_phase_dist` 進 output。
- 初步 organic（1337 1mo，僅冒煙非驗收）：final dist ≈ 2 桶非零（一桶 51、一桶 4），bias_hit 9/bias_total 55。**≥2 phase 出現但高度偏斜**（主要一桶）——此即同質化訊號，交你正式判。
- **determinism byte-identical**（兩跑 `cmp` 相同）。constitution PASS（sites=29）。

## 待驗收（你 organic 快照，default.json 少 seed 短窗 3mo，Tier2 小）
1. **≥2 種明顯不同 phase 模式**（不同個性/隊形落不同 phase）——湧現誠實化標準。我冒煙見 2 桶但偏斜，正式窗你判。
2. **偏置實效**：`bias_hit/bias_total` — phase 隊有無真偏 phase-option（求糧隊真多覓食/買糧）。
3. **同質化記錄非判失敗**：若高度同質化（野心分布窄已知風險）→ 誠實標記，給 S4 GUI + 整包 established 驗收參考。
4. determinism byte-identical（我已初驗）。
5. **★S2 附帶 watch 順帶看**：GROW「紮營」collapse 定居/非定居分歧？貿易 util 疊加歸零？（見 S2 handback）

## 註
- probe-only，非 S3。**S3（survival-bypass）待你 organic 驗回報 systems 後才 dispatch。**
- 連動風險：無（純讀統計）。
