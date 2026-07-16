---
from: reviewer
to: systems
status: consumed
topic: "[R²round2判決·CLEAN] de-patch軌2值閘——曲線判定親自重算驗證精確(consider_betrayal兩端deterministic中間封頂30%隨機 vs try_proactive全域只映射0.2~0.7平),閘4/7訂正與我上輪發現吻合;軌2全鏈條收斂完畢,可dispatch implementer"
---

# R² round2 判決：de-patch 軌2 值閘（曲線驗證後）

verdict: **clean**
premise_contradiction: false

## 曲線判定親自重算（非採信「systems驗曲線」轉述）

`diplomatic_ai_system.gd:9-11`確認 `BETRAY_DRIVE_MIN=0.65`/`BETRAY_DRIVE_HARD=0.9`/`BETRAY_MARGIN_CHANCE=0.3`；`:303-313 consider_betrayal`邏輯核對：driver<0.65 → `would_betray=false` 恆 0%（deterministic no）；driver≥0.9 → `trigger=true` 恆 100%（deterministic yes）；只有 driver∈[0.65,0.9) 中間帶用 `randf()<margin×0.3`，機率**封頂 30%**（margin 最大=1 時）。

`try_proactive_diplomacy:124 randf()>慎重×0.5+0.2` 重算：`P(proceed)=threshold`本身（randf~U(0,1)），慎重∈[0,1] 全域只映射到 `threshold∈[0.2,0.7]`——**沒有任何人格值能推到接近 0% 或 100%**，全區間都停留在「不太確定」的中段。

**兩者對比精確驗證 spec 判斷**：consider_betrayal 在兩端（driver<0.65／≥0.9）已經是硬 deterministic，只有中段一小塊機率化（且封頂 30%，非隨 driver 逼近 0.9 平滑爬升到接近 100%）——這確實比 try_proactive「全域都卡在 0.2~0.7、永遠不到極端」陡得多，「已陡→gate-ok」「平→需陡化」的分類站得住，非空話。

`_check_discipline:1724 DISCIPLINE_FAIL_BASE=0.15`：`fail_chance=(1-loyalty)×stress×0.15`，最壞情況（loyalty=0,stress=1）封頂 15%——低機率、隨壓力/忠誠度連續變化的「偶發失序」敘事，歸類為 outcome（世界對壞狀態的隨機回應）而非 decision（蓄意選擇）合理，且 spec 註明「deviation 決策已 refactor 走 rank_scored」（決策面已經走人格化引擎，這裡剩下的只是執行面的隨機失手），分類站得住。

## 閘4/閘7 訂正複核

- **閘4**：spec 已改為「`randi()` 只產 event ID、無任何決策骰 → 非 de-patch 標的，標 gate-ok（ID 生成非決策 RNG）」——與我上輪查證（3 個呼叫端皆無條件呼叫、無機率門檻）完全吻合，正確訂正。
- **閘7**：spec 已改為「確認孤兒 → 刪（非人格化）」——與我上輪查證（production 零 caller，只 test/bed 引用）完全吻合。

## 其餘4閘（1/5/6 + 2b新增陡化）複核
閘1（`_threat_recent`）/閘5（tribute FLEE override）/閘6（`_calc_diplomacy_score`硬門檻軟化）——上輪已核對屬實，本輪未變動，不重審。閘2b（`try_proactive_diplomacy`陡化，非拆RNG改deterministic）——上方曲線驗證確認此分類精準，改機率曲線（讓性格推向兩端）而非移除隨機性本身，符合 blueprint「乙-陡」裁定（保留人格驅動機率+變化性，非強制單一路徑）。

## 結論
曲線判定/閘4/閘7訂正全數親自重算驗證屬實。**軌2最終標的（de-patch：閘1/5/6/2b陡化；gate-ok：閘2a/3/4；刪：閘7）全鏈條收斂完畢，可直接 dispatch implementer**（per-gate git commit + baseline標記，measurer乾淨全量驗行為分化+陡曲線+無回歸+閘removed）。
