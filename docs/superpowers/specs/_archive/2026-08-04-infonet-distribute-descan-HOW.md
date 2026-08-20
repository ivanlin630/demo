# 資訊網 distribute de-scan — HOW spec（arc 最後一哩）

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint de-scan GO 無保留） | **branch**: `feat/info-network-whole`（續）
**root（RE-measure #4 confirmed）**：letter-carrier 根治交付（delivered 8/8、領主真聞 need_deposited=2）**但 distribute.dispatch 仍 0**——`_distribute_candidates`（`goal_resolver:168-169`）讀 received_buy_orders（belief ✓）**但 `:168 _resident_food_runway(resident)` 直讀 resident LIVE state=god-view + `:169 DISTRIB_DEFICIT_DAYS=4.0` 死常數門檻**（T1 runway 4.58>4.0 skip）。**＝用戶當初否定的「領主直掃自家居民」殘留 + 死常數雙違**（letter 蓋好門口卻還開後窗）。
**WHAT 裁**：blueprint de-scan GO——執行用戶已裁兩原則（領主 act on heard belief 非 god-view + 人格非死常數）、非新 WHAT。

## 修（de-scan：讀送達 belief + 人格、移 god-view live-read + 死常數）
`_distribute_candidates`（`goal_resolver.gd`）：
1. **移除 `:168` `var runway = _resident_food_runway(state, resident)`**（god-view 直讀 resident LIVE population+effective_food）。
2. **移除 `:169` `if runway >= DISTRIB_DEFICIT_DAYS: continue`**（死常數門檻閘）。
3. **relief severity 改源自送達 belief（buy-order qty）非 live runway**：
   - `:182` `deficit_severity` 刪（live-runway-based）→ 改 **`need_signal = clampf(eff_rem / DISTRIB_RELIEF_NORM, 0, 1)`**（buy-order 剩餘 qty=領主**聽到的** need 訊、belief；`DISTRIB_RELIEF_NORM`=典型 food 買單量 scale、**非門檻閘**）。
   - `relief_term = need_signal × (0.3 + honor)`（人格 義氣/仁慈/責任 weigh 賑濟；honor 高→救子民傾向強）。
   - `coin_term` **不變**（`price_factor × food_val × qty × (0.3+greed) / DELIVER_PAYOFF_NORM`）。
   - `u = relief_term + coin_term`（人格連續 weigh、無死常數門檻）。
- **applicability 剩（全 belief/surplus-based、零 live-runway）**：buy-order food + intra-faction resident（`faction_id==team.faction_id` + `is_resident_static`=faction 結構、非 live state）+ food_surplus（自己餘糧）+ `mpos != team.tile_pos`（同格直給免 convoy）+ eff_rem>0（未被在途 convoy 認領滿）+ qty>=1。
- **★領主 act on heard belief**：buy-order 存在=子民**表達了** need（letter 送達的訊/或既有傳播）；領主憑聽到的+人格決定賑濟。belief stale（子民已恢復）→ 可能多送=**fog 成本可接受**（非偷讀 live 補正）。

## 守（reviewer R²）
- **★感知鐵律（我 invariant、完成 arc）**：distribute **不再直讀 resident live runway/food/pop**（god-view 殘留根除）——只讀送達 belief（received_buy_orders）+ faction 結構（is_resident_static=組織常識 position/membership、非 live 動態態）。`constitution_gate` 該綠（移一個 god-view live-read）。
- **★人格非死常數**：移 `DISTRIB_DEFICIT_DAYS` 門檻閘；relief 走人格連續 weigh（honor/greed）。`DISTRIB_RELIEF_NORM`=scale 非 gate、**calibration 錨真值**（典型 food 買單量 DERIVED、同 idle-labor PER_HAND 紀律、非 invent 能 fire 常數）。
- **genuine 非 crank**：relief base=真 need 訊（buy-order qty belief）、人格 MODULATE。per-team util dump 驗。
- **determinism 零新 randf**；economy 不爆（food_surplus 守 reserve 不變）。

## 驗收（re-measure 症1 端到端 on FACTION bed）
- **`distribute.dispatch / food_delivered > 0`**（領主聞 distress→de-scan 後憑 belief+人格賑濟→convoy 送糧）。
- **★糧真到 resident runway 回升**（端到端真效果、[[feedback_verify_execution_end]]）。
- 人格分化（honor 高領主救子民 vs 低）+ **`constitution_gate` 綠（god-view live-read 移除）** + determinism + Part1+3+scout 不退 + economy 不爆。

**路 reviewer R²（審 god-view live-read 真移除/死常數真移/relief belief-sourced genuine+RELIEF_NORM calibration/de-patch 非增殖）→ CLEAN → build（續 `feat/info-network-whole`）→ re-measure 症1 端到端（糧真到 resident）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。**
