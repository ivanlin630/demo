---
from: systems
to: reviewer
status: consumed
topic: "[R²審distribute de-scan spec(2026-08-04-infonet-distribute-descan-HOW.md,blueprint de-scan GO無保留,arc最後一哩)·root(RE-measure#4 confirmed):letter-carrier根治交付(delivered8/8+領主真聞need_deposited2)但distribute.dispatch仍0=goal_resolver:168-169 _distribute_candidates讀received_buy_orders(belief✓)但:168 _resident_food_runway(resident)直讀resident LIVE state=god-view殘留(正是用戶否定的領主直掃)+:169 DISTRIB_DEFICIT_DAYS=4.0死常數門檻·fix de-scan:移:168 live-runway god-view read+移:169死常數閘+:182 relief severity改源自buy-order qty(belief=送達need訊)非live runway(need_signal=clampf(eff_rem/DISTRIB_RELIEF_NORM,0,1)×(0.3+honor)人格weigh),coin_term不變·applicability剩全belief/surplus-based零live-runway(buy-order+intra-faction resident結構+food_surplus+同格免convoy+eff_rem>0)·★審點:①god-view live-read真移除(distribute不再直讀resident live runway/food/pop,只讀received_buy_orders belief+is_resident_static faction結構,constitution_gate該綠移一god-view)②死常數真移(DISTRIB_DEFICIT_DAYS門檻閘刪)③relief belief-sourced genuine非crank(base=buy-order qty真need訊belief,人格MODULATE honor,RELIEF_NORM=scale非gate calibration錨真值典型買單量DERIVED非invent)④de-patch非增殖(移god-view+死常數還原belief決策非加平行)⑤determinism/economy(food_surplus守reserve不變)·CLEAN→build→re-measure症1端到端(distribute.dispatch>0+糧真到resident runway回升)→QA"
---

# R² 審 distribute de-scan（blueprint de-scan GO 無保留、arc 最後一哩）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-distribute-descan-HOW.md`
**root（RE-measure #4 confirmed）**：letter-carrier 根治交付（delivered 8/8、領主真聞 need_deposited=2）**但 distribute.dispatch 仍 0**——`_distribute_candidates`（`goal_resolver:168-169`）讀 received_buy_orders（belief ✓）**但 `:168 _resident_food_runway(resident)` 直讀 resident LIVE state=god-view 殘留**（=用戶否定的「領主直掃」）+ `:169 DISTRIB_DEFICIT_DAYS=4.0` 死常數門檻。
**WHAT 裁**：blueprint de-scan GO（執行用戶已裁兩原則：belief 非 god-view + 人格非死常數）。

## 一句話修法
distribute 移 live-runway god-view read + 死常數門檻 → relief 改源自**送達的 belief（buy-order qty）+ 人格 honor**。

## ★審點（R² refute checklist）
1. **★god-view live-read 真移除（arc 核心）**：distribute **不再直讀 resident live runway/food/pop**（`_resident_food_runway(resident)` 移除）——只讀 `received_buy_orders`（belief）+ `is_resident_static`（faction 結構=組織常識、非 live 動態態）。確認**無殘留 live-state 直讀**、`constitution_gate` 該綠（移一 god-view）。
2. **死常數真移**：`DISTRIB_DEFICIT_DAYS` 門檻閘（`:169 runway>=4.0 continue`）刪、`:182` live-severity 刪。確認無死常數門檻殘留。
3. **relief belief-sourced genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：relief base=`need_signal(buy-order qty=真 need 訊 belief)`、人格 MODULATE（honor）。**`DISTRIB_RELIEF_NORM`=scale 非 gate、calibration 錨真值**（典型 food 買單量 DERIVED、非 invent 能 fire 常數）。確認非藉 norm crank。
4. **de-patch 非增殖**（框內補丁 lens）：移 god-view+死常數=**還原 belief 決策**（完成 arc 原則）、非加平行機制。
5. **determinism 零新 randf** + **economy 不爆**（`food_surplus` 守 reserve 不變）。

## 邊界
- belief stale（子民已恢復但 buy-order 未過期）→ 領主可能多送=**fog 成本可接受**（belief-consistent、非偷讀 live 補正）。子民自管 buy-order lifecycle。
- applicability 移 runway 後：每 faction resident 有 food buy-order + 領主有 surplus → 候選（人格 honor 秤是否救）。確認非過度 broaden。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ re-measure 症1 端到端 on FACTION bed（`distribute.dispatch/food_delivered>0` + ★糧真到 resident runway 回升）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡/BLOCKER → 報 `to:systems`。
