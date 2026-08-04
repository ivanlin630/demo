---
from: implementer
to: systems
status: consumed
topic: "[資訊網 distribute de-scan DONE·arc 最後一哩·feat/info-network-whole commit 39b7b33d]移 goal_resolver:168-169 god-view live-read(_resident_food_runway 直讀 resident live pop/food=領主直掃殘留)+死常數門檻;relief 改憑送達 belief(need_signal=eff_rem/DISTRIB_RELIEF_NORM,buy-order qty=領主聽到的 need)×(0.3+honor)人格 weigh,coin_term 不變,無死常數;NORM=DESPERATION×FOOD_PER_DAY×5=12 DERIVED scale 非 fire gate;DISTRIB_DEFICIT_DAYS 保留(unrest 自讀線);補 distribute.dispatch tap(全觀測缺口)。★透明 flag:前 carrier 報 MD5 06D9B76D 是 stale-file(godot.ps1 default 360s 超時 kill 未 dump→hash 舊檔),已 fresh 重驗 GODOT_TIMEOUT=1200=9ACAC8D7 3run byte-identical,determinism 屬性真成立。驗:lord_bed +de-scan RED 綠+infonet 全綠+headless 0-new+gate PASS 74+determinism。請 R²→我路 measurer re-measure 症1 端到端 on FACTION bed(distribute.dispatch>0+糧真到 resident runway 回升)→QA。"
branch: feat/info-network-whole
commit: 39b7b33d
---

# 資訊網 distribute de-scan — DONE（arc 最後一哩、路 systems R²）

照 spec `2026-08-04-infonet-distribute-descan-HOW.md`（R² CLEAN、blueprint de-scan GO）build 完。

## 做了什麼（de-scan：讀送達 belief + 人格、移 god-view live-read + 死常數）
`_distribute_candidates`（`goal_resolver.gd`）：
1. **移 `:168` god-view live-read**（`_resident_food_runway(resident)` 直讀 resident LIVE population/effective_food＝用戶否定的「領主直掃自家居民」殘留）。
2. **移 `:169` 死常數門檻閘**（`runway >= DISTRIB_DEFICIT_DAYS continue`）。
3. **relief 改源自送達 belief**：`need_signal = clampf(eff_rem / DISTRIB_RELIEF_NORM, 0, 1)`（buy-order 剩餘 qty＝領主**聽到的** need 訊、belief）；`relief_term = need_signal × (0.3 + honor)`（義氣 weigh 賑濟）；`coin_term` 不變；`u = relief_term + coin_term`（人格連續 weigh、無死常數門檻）。
4. **`DISTRIB_RELIEF_NORM`（calibration-anchor、DERIVED、非 fire gate）**：`= DESPERATION_DAYS × FOOD_PER_PERSON_PER_DAY × 典型居民pop(DISTRIB_RELIEF_REF_POP=5) = 12.0`。錨定依據＝典型小型定居居民絕境窗全額 food 買單量（PER_HAND 紀律：per-capita 絕境食量 2.4 × 典型居民規模）。**★非門檻**：任何 `qty>=1` 仍 fire，NORM 只影響 relief 強度梯度。
5. **`DISTRIB_DEFICIT_DAYS` 保留**（`_tick_resident_unrest:3300` 居民**自讀**自己 runway 回升安全線＝自讀非 lord god-view scan；`_resident_food_runway` helper 亦保留供此自讀 caller）。
6. **補 `distribute.dispatch` tap**（全觀測缺口：`warring_harness` 列此 metric key 但源碼從未 bump＝tap-gap；`_dispatch_goal_delegate` distribute 分支真派出→bump）。
7. 訂正 `:122` 舊 comment（「intra-faction deficit＝合法非 god-view」自辯已被用戶資訊網 arc 否定→改註 belief-only）。

applicability 剩全 belief/surplus-based：buy-order food + intra-faction resident（`faction_id==team.faction_id` + `is_resident_static`＝faction 結構非 live 態）+ food_surplus（守 reserve）+ 同格免 convoy + `eff_rem>0` + `qty>=1`。

## 守（R² 對照）
- **★感知鐵律（完成 arc）**：distribute **不再直讀 resident live runway/food/pop**（god-view 殘留根除）——只讀送達 belief（received_buy_orders）+ faction 結構。`constitution_gate` 綠。
- **人格非死常數**：移 `DISTRIB_DEFICIT_DAYS` 門檻閘；relief 走人格連續 weigh。`DISTRIB_RELIEF_NORM`＝scale 非 gate、DERIVED。
- **genuine 非 crank**：relief base＝真 need 訊（buy-order qty belief）、人格 MODULATE；NORM DERIVED 非 invent-to-fire。
- **determinism 零新 randf**；economy `food_surplus` 守 reserve 不變。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `lord_distribution_bed` +de-scan RED | 全綠——**新 RED**：resident food=999（runway≈250 >> 舊門檻 4.0）**仍 fire distribute**＝證 god-view runway gate 真移、憑 belief fire |
| infonet 全 bed | letter 17 / sideaction 6 / part2 4 / herald 4 / prop 5 / scout 4 / trade 3 / bootstrap 6 全綠 |
| headless | **0-new**（Team23 建設×2 + 弱目標 + 3 baseline asserts＝git stash 對照 pre-existing） |
| constitution_gate | **PASS sites=74 removed=0**（distribute call 移＝belief-only；helper 留給自讀 caller） |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `9ACAC8D7092EB9A77E5807E636A2C324` **byte-identical**（carrier+de-scan 合併 stack） |

## ★透明 flag（determinism 方法學修正、measure 誠實）
前 carrier handback 報的 MD5 `06D9B76D…` 是 **stale-file artifact**：`godot.ps1` default timeout **360s**，warring 1mo 實需 ~900s → process 被 kill → 未 dump WARRING_OUT → `Get-FileHash` hash 到磁碟殘留的**舊 means-end 檔**（3 個舊檔 trivially 相同→假 pass）。本次 de-scan 用 **`GODOT_TIMEOUT=1200`** fresh 重跑，驗證輸出檔真新（size 32967、mtime 今日）＝`9ACAC8D7…` 3-run 真 byte-identical。**carrier code 本就零 randf＝確定性**（determinism 屬性成立、只前次證據 invalid）；合併 stack 現已真證。→ 建議 measurer/canonical 跑 warring 類 bed 一律帶 `GODOT_TIMEOUT>=1000`（360s default 對 1mo warring 必超時，靜默 kill＝易再中招）。

## 路（下一站）
1. **你 R²**（審：god-view live-read 真移除 / 死常數真移 / relief belief-sourced genuine + NORM DERIVED / de-patch 非增殖）。
2. CLEAN → **我路 measurer re-measure 症1 端到端 on ★FACTION bed**：`distribute.dispatch / food_delivered > 0`（領主聞 distress→de-scan 後憑 belief+人格賑濟→convoy 送糧）+ **★糧真到 resident runway 回升**（端到端真效果）。人格分化（honor 高救子民 vs 低）+ gate 綠 + determinism + Part1+3+scout 不退 + economy 不爆。
3. → QA 故事稽核。

**★資訊網 arc 收官在望**：1a 板 relay + 2a herald 側動 + 2b scout + 3 trade broaden + B carrier + A③ 名冊 + de-scan＝一 root（propagation dead-end + god-view 領主直掃）三症全鏈通。

**HOLD-warm 待你 R² verdict。** FACTION bed 選定（既有 economy/§5 setup 或我產 seeded faction bed）仍待你一句（前 carrier handback 已問、續等）。
