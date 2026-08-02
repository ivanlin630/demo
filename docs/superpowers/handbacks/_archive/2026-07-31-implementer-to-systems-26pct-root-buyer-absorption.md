---
from: implementer
to: systems
status: consumed
topic: "[done·重診 26% ceiling·★真根=買方吸收量非賣方·+deliver_cargo key-fix(原一直被 bypass)] feat/peaceful-economy-bed edae66fe。trajectory 定根:全 porter 滿載到市場(loaded==material_at_deliver 64/37/37/33,源 100% 私產 vault_pre=0)→無 FETCH 載 0/無 en-route 丟。2 sell_no_surplus=假因(bail_delta 連 settled convoy 都升=多單市場 noise);真=買方 material buy 單被前 convoy 填滿(rem=0→skip)→後續賣不出。settled sold 12/33<loaded=買方 order/coin cap。∴26% 根=買方吸收量(order qty~64+coin)非賣方 reserve/cargo。★發現 key-bug:_resolve 讀 task_extra_data.cargo(不存在)→deliver_cargo 一直被 bypass(explains 前 byte-identical)→修 res==cargo_res→dc=cargo_qty。驗:convoy_delivery_test 5/5+determinism 三跑 byte-identical(C8DEC191)+不凍(attrition1.80% teams100 convoy70 settled4)+headless 3=baseline。"
branch: feat/peaceful-economy-bed
commit: edae66fe
base: 613d763d (local main HEAD)
measurements:
  - docs/measurements/2026-07-31-peaceful-econ-bed-cargo-trajectory-edae66fe.txt
  - docs/measurements/2026-07-31-warring-seed1337-convoy-keyfix-determinism.json
---

# 重診 26% ceiling：★真根＝買方吸收量（非賣方），+ 發現 deliver_cargo key-bug

per-convoy cargo trajectory（measure、非斷言）。純觀測 + 1 key-fix。

## ★★trajectory 定根（和平床，`docs/measurements/2026-07-31-peaceful-econ-bed-cargo-trajectory-edae66fe.txt`）
```
FETCH:全 porter 滿載 porter_loaded==load_target(64/37/37/33)、源 100% 私產(vault_pre=0) → 無 FETCH 載 0
DELIVER:material_at_deliver==loaded(64/37/37/33) → 滿載到市場、無 en-route 丟
  porter12 loaded64 → sold12 settled   (賣 12<64)
  porter12 loaded37 → sold33 settled   (賣 33<37 近滿)
  porter12 loaded37 → sold0  sell_no_surplus  ←滿載卻賣 0
  porter13 loaded33 → sold0  sell_no_surplus  ←滿載卻賣 0
bail_delta={sell_no_surplus:2} 連 settled convoy 都升 = 假因(多單市場賣無持有 res 的 noise)
```
**真根（measure 定，二個候選皆排除）**：
- **非 (a) FETCH 載 0**：全滿載（源私產充足）。
- **非 (b) en-route 丟**：material_at_deliver==loaded。
- **是 (c) 買方吸收量飽和**：2 bail convoy 滿載到市場卻 sold=0——買方 material buy 單（qty~64）已被前 1-2 convoy 填滿（order rem=0 → `_resolve` loop `rem<=0 continue` 跳過 → porter material 單根本沒 attempt → 只 attempt 他 res 單 → spurious `sell_no_surplus`）。settled convoy sold 12/33 < loaded = 買方 order_rem/coin cap 限。
- ∴ **26% ceiling 真根 = 買方吸收量**（buy order qty ~64 + owner coin），賣方 surplus(400+) >> 買方需求 → 多數 cargo 隨 porter RETURN merge 回。**非賣方 reserve/cargo/FETCH**。

## ★發現 key-bug（順修）
`_resolve_market_at_outpost` 原讀 `task_extra_data.get("cargo",{}).get(res)`——但 task_extra_data 存 `cargo_res`/`cargo_qty`（無 "cargo" dict）→ **deliver_cargo 一直傳 -1 = refine 從頭被 bypass**（explains 前兩次 determinism byte-identical、send-rate 逐筆不變＝refine 根本沒執行，我前份「reserve≈0 no-op」分析部分錯）。修：`res==cargo_res → dc=cargo_qty`。修後 warring convoy **59→70、teams 90→100**（deliver_cargo 活化真影響 warring，reserve 在有 outpost 的 warring 隊確有咬）；和平床 send-rate 仍 26%（買方限、非 reserve 限，refine 對和平床無關）。

## 驗（全綠）
- `convoy_delivery_test` **5/5**、headless **3=baseline(0-new)**。
- **determinism 三跑 byte-identical**（MD5 `C8DEC191`；hash 變自 key-fix 活化 refine=真行為變但 self-identical）。
- **不凍** attrition=**1.80%≠0**、teams=100、convoy=70、settled=4（warring）。
- 純觀測 + key-fix；inert-已修 deliver_cargo **保留 branch 未 merge**（待 systems 定真 fix）。

## 待（systems 定真 fix 方向，我不臆斷）
真根＝**買方吸收量**：
- (i) 26% 是否「正確經濟」（買方只需 64、已滿足；賣方餘 surplus 留=合理）→ 若是則非 bug，flow 需**更多/更大買方需求**（多 established 缺料隊 / 大 build 需求）。
- (ii) 或 convoy 過載（load=min(surplus, buyer order_rem) 而非 surplus 全上）→ 少載不浪費 porter run。
- (iii) 或多 convoy 撞同買方（throttle 只管賣方側，不管買方飽和）→ deliver 決策該看 buyer order rem。
★交真根 + 候選，不下 fix 結論。convoy 三驗收線本身仍 PASS（fulfilled>0 真）。卡 fix 方向等 systems。
