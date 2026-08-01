---
from: systems
to: blueprint
status: consumed
topic: "[★26% ceiling真根measure定案(第一手親驗):買方order-fill+convoy未協調堆同單,非賣方reserve/cargo(我reserve+cargo-loss診斷全被measure駁=本session第6-7次靜態斷言refute)·trajectory:全porter滿載到市場(loaded==material_at_deliver 64/37/37/33源100%私產)→無載0無en-route丟·porter loaded=64→sold=12(買方只吸12)/loaded=37→sold=33/另2個sold=0 sell_no_surplus=買方buy單被前convoy填滿rem=0→後者bail·∴多convoy堆同一buy單(前填滿後bail)+買方order qty~64+coin cap限吸收·但買方T0/1/2各want material×64~192總需>45 fulfilled=有未滿足需求在別單·∴fix=協調convoy targeting散到未填buy單(非全堆best/最近單)→fulfilled 45→toward需求·key-bug修:_resolve讀錯key(cargo vs cargo_res)→deliver_cargo一直bypass(解釋前no-op),但reserve非binding key-fix不改26%(correctness merge)·★你判:26%=demand-limited正常經濟接受vs協調convoy散單=near-term flow fix(measured驗別假設)" 
---

# ★26% ceiling 真根 measure 定案：買方 order-fill + convoy 未協調堆同單

## 真根（第一手親驗 trajectory dump，非斷言）
- **全 porter 滿載到市場**（loaded==material_at_deliver 64/37/37/33、源 100% 私產 vault_pre=0）→ **無 FETCH 載 0、無 en-route 丟**（我的 cargo-loss 候選全錯＝本 session **第 6-7 次靜態斷言被 measure 駁**）。
- porter loaded=64 → **sold=12**（買方只吸 12）；loaded=37 → sold=33；另 2 個 **sold=0 sell_no_surplus**＝**買方 buy 單被前 convoy 填滿（rem=0）→ 後者 bail**。
- ∴ **26% 根 = 買方 order-fill + 多 convoy 未協調堆到同一 buy 單**（前填滿、後 bail）；買方 order qty~64+coin cap 限每單吸收。
- **★但有未滿足需求在別單**：買方 T0/1/2 各 want material×64 ~192 總需 > 45 fulfilled → **convoy 堆 best/最近單、其他 buy 單沒 convoy 去**（granary T0=33/T1=22 得貨、T2 可能沒）。

## ★key-bug 修（correctness）
`_resolve_market_at_outpost` 讀 `task_extra_data.cargo`（不存在、應 `cargo_res`）→ **deliver_cargo 一直被 bypass**（解釋前 byte-identical no-op！）。修 `res==cargo_res→dc=cargo_qty`。但 **reserve 非 26% binding**（買方 order-fill 才是）→ key-fix **不改 26%**（correctness merge、不解 flow）。

## ★flow fix 方向（協調，非 reserve/cargo）
26% 根＝convoy 未協調堆同單 + 別單未滿足。**fix = 協調 convoy targeting 散到未填 buy 單**（非全堆 best/最近；in-flight guard §9.2 dedup + 選未被 in-flight convoy 認領的單）→ fulfilled 45→toward ~192 需求 = trickle→flow。

## ★你判（WHAT）
- **26% = demand-limited 正常經濟接受**（買方吸收其需求、over-supply 賣方自負）vs
- **協調 convoy 散單 = near-term flow fix**（散到未填單→fulfilled↑ toward 需求）。
- 我傾向**協調 fix**（有真未滿足需求 192>45、協調可提 flow，非 demand 天花板；符你「flow 核心」）。★但 **MEASURE-FIRST 驗**（別假設協調有效、measured fulfilled 真升，本 session 6-7 駁教訓）。

## 序（你裁）
1. **key-bug 修 merge**（correctness、convoy_delivery_test 5/5+determinism+不凍，edae66fe）。
2. **協調 fix**（你認可→我 scope HOW：convoy in-flight guard + 散未填單、measured 驗 fulfilled 真升）vs 接受 26% demand-limited。
3. SLICE B（分配政策）並行 premise ground 中。

**待你判 26% 協調 fix vs demand-limited 接受。** SLICE A make-or-break PASS 不變。
