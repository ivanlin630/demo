---
from: reviewer
to: systems
status: consumed
slice: 攻擊的機會＋需要項
topic: R² 判決 — CLEAN。①的矛盾不是矛盾,是兩層：tier2有detailed food_est(interaction_system.gd:1343-1358)、tier0/1只有粗resource_scale桶(vision_system.gd:150-179,零food_est)——兩則引用都對,各自講對一半母體；而現成解法已經在跑(_belief_richness),不算新狀態；②③機械判準都站得住
---

# R² 判決：`2026-09-12-attack-opportunity-drive-HOW.md`

## 判決：CLEAN——①的矛盾解開了，不是二選一，是兩層都對；②③沒有異議

## ①（最重要）belief 有沒有「對方資產」估計：獨立驗過，兩則引用都是真的，因為它們講的是不同的子母體

追了兩個寫入端，不是只讀你引的那兩行：

```
tier2（interaction_system.gd:1343-1358 _write_tier2_intel）：
  snap["food_est"]     = float(tgt.resources.get("food",0.0))       ← 直讀真值
  snap["material_est"] = float(tgt.resources.get("material",0.0))
  snap["coin_est"]／snap["goods_est"] 同樣直讀
  ⇒ ★這一層【真的有】detailed food_est，`distortion_engine.gd:85` 操作的正是這批值。

tier0/1（vision_system.gd:150-179，一般視野觀察寫入）：
  只有 population_est／tile_pos／tags_seen／activity／in_combat／
  dist<=1 時多一個 resource_scale（0-3 粗桶,加總後分級,不是逐資源估）
  ⇒ ★★這一層【完全沒有】food_est 這個鍵，`decision_context.gd:957` 的
    「belief schema 無 food_est → 降級」對這一層是真的。
```

`best_estimate()`（belief_system.gd:144-161）回傳的是**哪一筆claim credibility最高就回哪一筆**，
可能是tier2也可能是tier0/1——所以「回傳的dict有沒有food_est」是**條件式的**，
不是schema層級的有或沒有，取決於哪一層的觀察贏了。**兩則引用都對，只是各自描述
不同子母體，不是矛盾**——你獨立查的態度是對的（不自己先下結論），但答案不是
「存在或不存在」二選一，是「視覺信任等級而定」。

**而且不需要當成新狀態去裁**：這個兩層落差**已經有現成的處理範本**——
`faction_ai_system.gd:379 _belief_richness(bel)`：
```
if bel.has("coin_est") or bel.has("food_est") or bel.has("material_est"):
    return (coin_est+food_est+material_est) / 100.0   ← tier2 精細路徑
if bel.has("resource_scale"):
    return float(bel.get("resource_scale", 0))          ← tier0/1 粗桶 fallback
return 0.0                                               ← 皆無
```
這正是你§②的鐵律③（贏率不要新造公式,走既有capability接地）同一個精神用在資產估這邊——
**不用發明新belief欄位，直接沿用`_belief_richness`這個已經在跑的降級路徑**：有tier2用
detailed值，只有tier0/1用resource_scale粗桶，皆無時0。blueprint「零新狀態」的前提
**成立**，只是要求spec明寫「機會項的資產估計走`_belief_richness`的降級形狀，不是
假設所有belief都有food_est」——這句話加進§②就夠了，不用回blueprint重裁。

## ② 「非零util的變異不得為0」：判準站得住，是必要條件不是充分條件（而那是對的）

這個判準精準命中它要擋的那個病（全部同一個數＝換一個常數的常數陷阱）。它抓不到
「有變異但變異方向跟真實資產無關」這種偽陽性——但那格不用靠它抓，你§③③已經另外
要求「窮弱→低分/肥弱→高分」的方向性成對對照，兩格加起來才是完整覆蓋（變異抓
「有沒有在動」，方向對照抓「動得對不對」）。兩個判準疊起來沒有縫，不用改。

## ③ 「無授權群util不得仍全0」：抓得到——直接測的就是「加成有沒有偷偷變回唯一來源」這個問題本身

這格不是間接推論，是直接對「四項授權形狀都拿掉之後，機會項自己還撐不撐得起
非零分數」下手——如果機會項真的只是裝飾（接了但沒接電，或者被寫成跟原本四項
一樣的if-gate），這一群會繼續全0，判準會紅。判斷成立，沒有找到會讓它誤判的情況。

## 其餘

②設計三條硬規則（belief-only資產／need oracle需求／既有capability贏率）、授權四項
降級為加成、人格調製非常數：沒有異議，跟今天全天的紀律（util必=真值/MODULATE非boost）
一致。④不做的事：範圍清楚。

CLEAN，直接 dispatch。①的發現（tier2/tier0-1兩層+沿用`_belief_richness`）建議寫進spec
§②免得下一個人重新懷疑這個「矛盾」。
