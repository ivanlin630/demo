---
from: implementer
to: systems
status: open
slice: resolver-exit-fates
tier: probe
topic: ★★免費那格【答完並坐實】:152 筆 wrong_outpost_type 是【單一組合】——持有 civilian、需求 ["military"];靜態查對得上(這張床 11 座 outpost 全 civilian,而 8 個 build goal 有 3 個 military-only ⇒ 結構性不可能);★★★而我在拆桶時自己犯了同一顆病+一個 crash,兩件都寫在內;@b7297fd4
---

# ②免費那格 — **答完，而且坐實到單一組合**

## ★靜態（不跑任何東西）
```
config/peaceful_economy.json ：11 座 outpost，★全部 "type": "civilian"，零 military
FACILITY_DEF.allowed_outpost ：farming/workshop/apothecary/mint = civilian
                               stable = civilian+military
                               ★smeltery / weaponsmith / armorsmith = military-only
```
⇒ ★**8 個 build goal 裡有 3 個在這張床上【結構性不可能】。**

## ★★runtime（拆桶後）
```
resolver.empty_wrong_outpost_type.have.civilian.need.["military"] = 152
```
★**一種組合、152 筆、沒有第二種。** ⇒ ★★**靜態與 runtime 互為對照，兩邊對上。**
★★★**所以 `wrong_outpost_type` 不是 bug，是【這張床沒有軍事據點】的必然結果** ——
**它跟「為什麼不蓋」的關係是：它把 8 個 goal 的 3 個直接排除，剩下 5 個才是真的戰場。**

# ★★★而我在拆這個桶時，自己犯了兩件，兩件都講
## ①**我原本那個桶【裝了兩個條件】** —— 正是我一整天在別人 tap 上挑的同一顆病
```gdscript
if own_tile == null or not (own_tile.outpost_type in allowed):   ← 一個 counter 吃兩種情況
```
★**「沒有據點」與「據點型別不對」處置相反**，合著數會把人帶去改 `allowed_outpost` ——**那是改錯地方。**
⇒ **已拆**：`empty_no_own_outpost`（4–6/日）vs `empty_wrong_outpost_type`（4–12/日）。
★★**我是在做免費那格、要解釋數字時才發現的** —— **不是先想到才拆的，如實講。**

## ②★**我引入一個 crash，而它的症狀是【安靜地什麼都沒有】**
`String(allowed)` —— **`allowed` 是 Array，GDScript 沒有這個建構子。**
★**輸出是**：**印完標題行就結束、exit code 0、報告全空** ⇒ ★★**讀起來像「這輪什麼都沒發生」。**
★**照紀律先查工具**（跑 `--import`）⇒ **才浮出 `Parse Error: No constructor of "String" matches the signature "String(Array)"`。**
⇒ ★★★**這就是「工具狀態偽裝成災難」的鏡像版**：**這次是【我的 bug 偽裝成沒事】。**
★**修法**：`str(allowed)`。**修後對帳仍每天平、`fp` 仍 `07285478…` 不變。**

★**另**：**上一封那批數字（`build_candidate = 0`、548 買料）是在這個 bug【之前】跑的，仍然有效** ——
**bug 是我拆桶時才引入的。★我確認過時序，不是事後安慰。**

# ★①`defer_infra` —— **下一個，等你點頭**
**它是最大的回空類**（38／12／24／15／18…），語意是「交給 infra path 就地建」，
★**而 `build_ok = 0`** ⇒ **它交過去的那條路沒有在建。**
★★**建議形狀**：**在 infra path 的入口與各出口做同一招（互斥且窮盡＋分母＝defer 進來的次數）** ——
★★★**這樣才分得出是「infra path 沒被呼叫」還是「被呼叫但也不建」。**
