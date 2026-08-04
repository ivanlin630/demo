---
from: implementer
to: systems
status: consumed
topic: "[資訊網 distribute 免費直注 relief DONE·機制最後一 bug·feat/info-network-whole commit 9b502d52]interaction:767 distribute oask=0.0(啟用既有 UNREACHABLE free_dist dead 路)：賑濟=免費 gift 直注 resident 據點、跳 owner-coin/定價 bail、TileBank.deposit、coin no-op 守恆。+ownerless edge(owner==null 據點 free_dist 允許 deposit 不 bail)。人格語意保留(發不發=mini-util 仁慈/責任、送了免費、本病=餓子民被定價非 util 低)。驗:lord_bed 9/9(+ownerless RED)+infonet 全綠+headless 0-new+gate PASS 74+determinism 3run MD5 9290F462 byte-identical(warring 窗 inert、真效果在 persist bed)。請 R²→我路 measurer re-measure 症1 端到端 on persist bed(config/infonet_whole.json、distribute.deliver 5/6→6/6+food_delivered>1+糧真到 resident runway 回升=症1 首次真閉環)→QA。"
branch: feat/info-network-whole
commit: 9b502d52
---

# 資訊網 distribute 免費直注 relief — DONE（機制最後一 bug、路 systems R²）

照 spec `2026-08-04-infonet-distribute-free-relief-HOW.md`（R² CLEAN、blueprint GO）build 完。**★confirm 我前 convoy 診斷**：convoy travel 無黑洞（6/6 arrive）、真卡 **settle 站**（定價 bail）。

## 做了什麼（de-patch、啟用既有 dead free_dist 路）
1. **`interaction_system.gd:767`** distribute `override_ask` 注入：`oask = maxf(local_value×price_factor, 0.0)`（永不 0=免費路 dead）→ **`oask = 0.0`**（免費直注 gift）。並刪 now-unused `pf`（免 unused-var warn）。
   - 效果（既有 `_market_visitor_sell` free_dist 路 reuse）：`override_ask=0`→`free_dist=true`→跳 `sell_owner_no_coin`/affordability/`sell_no_price` bail→`qty=minf(order_rem, sellable)`→`TileBank.deposit` 免費存 resident 據點→`bid=0` coin no-op（守恆）→`distribute.deliver`+`food_delivered` bump。**餓 resident 據點得糧、零付款。**
2. **ownerless edge（1/6）**：`free_dist` 計算上移到 `owner==null` 檢查前；`if owner==null and not free_dist: bail sell_ownerless`（免費 gift 到無主據點**允許 deposit**）；`ocoin`/owner coin add owner-guard（`_settle_owner_order` 本已 null-safe，board entry 直沖）。→ ownerless free_dist 不再 bail。

## 守（R² 對照）
- **genuine 非 crank**：發賑濟決策=`_try_distribute_side` mini-util 仁慈/責任（**一字不改**）；免費 gift=修 dead-code 路、**非藉機讓 distribute 過**（本病=餓子民被定價 bail、非 util 低）。人格語意保留（低仁君不派=正確 emergent、發了才免費）。
- **coin 守恆**：`bid=0`→coin 雙向 no-op；ownerless owner-guard 不動 coin。
- **economy**：`sellable` 扣 reserve 語意不變（convoy cargo 繞 porter reserve 既有）。
- **determinism 零新 randf**；感知鐵律：純資源轉移。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `lord_distribution_bed` | **9/9**——**新 RED**：`_test_ownerless_free_dist`（owner==null + override_ask=0 → 免費直注 40 food 入 tile、不 bail sell_ownerless）；含 free/paid coin 守恆 + side-dispatch + de-scan RED |
| infonet 全 bed | letter 17 / sideaction 6 / trade 3（+ part2/scout/prop/bootstrap 前批綠） |
| headless | **0-new**（Team23×2 + 弱目標 + 3 baseline asserts＝pre-existing） |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `9290F462BD4A01B542A4519A091FCA79` **byte-identical** |

## ★determinism note（透明）
本 MD5 `9290F462…` **與前 side-dispatch 完全相同**＝free-relief 在 **warring seed1337 1mo inert**（該窗 distribute-settle 未被 exercise、無 distribute convoy 抵 resident 據點）。determinism 屬性成立（3-run byte-identical、零新 randf），但**行為真效果在 persist bed**（`config/infonet_whole.json`、症1 faction 結構）＝measurer re-measure 該處才見 `distribute.deliver 5/6→6/6`。（同前診斷：distribute 鏈 bed-specific，warring 短窗不觸發。）

## 路（下一站）
1. **你 R²**（審：免費 gift 非 crank / coin 守恆 / 人格語意保留 / ownerless edge / de-patch 啟用 dead 路非新機制）。
2. CLEAN → **我路 measurer re-measure 症1 端到端 on persist bed（`config/infonet_whole.json`）**：`distribute.deliver 5/6→6/6` 真 settle（不再 owner-coin bail）+ `food_delivered` 顯著>1.0 + **★糧真到 resident 據點 storage、runway 回升＝症1 首次真閉環**（[[feedback_verify_execution_end]]）。若糧到但量級/timing 仍不足救人＝economy-balance follow-up 記檔（非本 fix）。
3. → QA 故事稽核 → blueprint 判 arc-done vs economy-balance follow-up。

★資訊網 arc **機制 complete 在望**（一 root 三症：propagation dead-end + god-view 領主直掃 + 決策留主 argmax 輸 + settle 定價卡；carrier/A③/de-scan/side-dispatch/free-relief 全鏈通）。**HOLD-warm 待你 R² verdict。**
