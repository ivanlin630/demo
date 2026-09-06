---
from: systems
to: implementer
status: open
slice: 單據帶價：★spec 已落地，但【在 R² 審查中，先不要動手】
topic: ★spec = docs/superpowers/specs/2026-09-07-board-declared-price-HOW.md,blueprint 已核可;★★但我把它送 R² 了(新機制=新欄位+新傳播,照規矩 R² 每 slice 必過)——★而這一站我今天前面一直沒走,因為前面都是既有票內的小裁定,這張是新 spec,所以要走;★★★spec 裡有兩件你會關心的實測:①【沒有 bid_price 函式】,bid 就是 local_value(buyer)(:1137)⇒ 本案零新函式,同一條公式只改【算的時刻】②中繼重建 entry 的兩處欄位是【明列】的(order_system:317-320／faction_ai:2033-2035)⇒ 新欄位不會自動跟著走,而漏掉它們失去價格的正好是【遠處的單】=最需要價格的那些;★在 R² CLEAN 之前:⑩ 只做 headless 那條 `trader coin 應減少`(拆機制斷言+正數),套利兩邊都先擱著
---

# ★一、spec 在 R²，先不要動手
```
docs/superpowers/specs/2026-09-07-board-declared-price-HOW.md（blueprint 已核可）
★而我送 reviewer 審設計了 —— 規矩:R² 每 slice 必過,CLEAN 才 dispatch
★★而這一站我今天前面【一直沒走】:因為前面都是既有票內的小裁定(改比較運算子、拆斷言),
   ★★★而這張是【新機制】(新欄位 + 新傳播路徑)⇒ 它該走
```

# ★★二、spec 裡兩件你會關心的實測
```
①★【沒有 bid_price 函式】—— bid 就是 local_value(buyer)(interaction_system.gd:1137)
   ⇒ ★★本案【零新函式、零新常數】:同一條公式,只改【算的時刻】與【誰看得到】
②★★★中繼重建 entry 的兩處欄位是【明列】的:
   order_system.gd:317-320（信使中繼）／faction_ai_system.gd:2033-2035（信使代掛）
   ⇒ 新欄位【不會自動跟著走】,而漏掉它們,失去價格的正好是【遠處的單】
      —— 也就是這整件事的理由(近的單你到場就能算)
★已驗:`_sync_board` 只改 qty_remaining 且沿用同一 dict ⇒ 不會洗掉價格,不必動它
```

# ★三、在 R² CLEAN 之前，⑩ 只做這一格
```
★headless 的 `trader coin 應減少` ⇒ 照你自己的形狀:拆成【機制斷言 + 正數】,不是放寬
★★套利買邊、賣邊【都先擱著】—— 你查出兩半都不可行,而修法要等單據帶價
★★★`food 過剩 N.N×` 那條【維持「未分流」】,不要為了讓閘變綠去動它
```
