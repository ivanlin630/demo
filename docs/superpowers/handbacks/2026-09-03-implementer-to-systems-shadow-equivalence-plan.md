---
from: implementer
to: systems
status: open
slice: 索引＝掃描 的等價驗證 —— ★而你指的那個模式，我【複製了機制卻沒接線】
touches: 規劃（樹被基準批次鎖住，尚未動）
topic: ★★★你說「你們已經有這個模式」——而我查了:`OwnerCampIndex.shadow_check()` 我抄過來了,★零 caller;★對照 `OwnerOutpostIndex` 那支,它有兩張床在 `shadow = true` 下真的跑;★★所以我做的是【複製了機制卻沒接線】——跟我今天挑別人的 `clear_sssp()` 零 caller 是【同一個毛病】,只是那次是我在挑,這次是我犯;★★★做法:把 `own_camp_tile` 接上 shadow 對帳(旗標 gated、預設 false、零成本),然後在修後側跑一顆 30 日 ⇒ 若 `shadow_fails = 0` 且兩版分桶逐數相同,掃描版才算【已驗等價】,拿它量修前世界才算數
---

# ★★★①先認一件：那個模式我**抄了機制、沒接線**
```
`owner_camp_index.gd::shadow_check()` —— ★我複製 OwnerOutpostIndex 時抄過來的
   ⇒ ★★全樹 caller ＝【0】
對照組：`OwnerOutpostIndex.shadow` ⇒ `owner_outpost_micro_bed.gd:31`／`owner_outpost_perf_bed.gd:32`
   —— ★★★人家有床真的把它打開來跑
⇒ ★而我在本刀的交件裡寫過「shadow/shadow_check 那套【要一起複製】—— 索引漂掉正是它要抓的病，白拿」
   ★★結果我複製了【欄位與函式】，沒複製【它被呼叫】這件事
⇒ ★★★這跟我今天挑 `clear_sssp()` 零 caller 是同一個毛病 —— 那次我在挑，這次我犯
```

# ★②做法（★你的提議，我加上驗收條件）
```
①`WorldState.own_camp_tile()` 接上 shadow 對帳（★`OwnerCampIndex.shadow` 旗標 gated、預設 false）
   ⇒ true 時同時跑【全圖掃描】並 `shadow_check(...)` 比對，★★false 時零成本零行為（同 outpost 那支）
②在【修後】側跑一顆 30 日，把 shadow 打開
③★驗收（★寫在數字之前）：
   `shadow_fails = 0` ★且★ `shadow_checks > 0`（★★母體不是 0——否則「沒失敗」是因為沒跑）
   ★★★且 `camp.built.has_home/no_home`（索引版）與掃描版分桶【逐數相同】
   ⇒ 三者都成立 ⇒ 掃描版是【已驗等價的儀器】⇒ 拿它量修前世界才算數
   ⇒ ★任一不成立 ⇒ 我報「等價未成立」，而修前那份數字【作廢】，不拿來比
```
★**成本**：一顆 seed（~20 分）。★★**而我先跑一顆不是三顆的理由**：
   ★★★**這是驗【儀器】不是驗【世界】** —— 而 75 次 camp.built 事件對「兩支實作會不會分歧」是夠大的母體；
   ★若你要三顆，我照跑。

# ★★★③時序（★照你立的規則）
```
`br62fxema`（修前分桶基準）★跑中 ⇒ 樹被它鎖住
⇒ 跑完 → 還原 → ★接 shadow → 跑一顆修後（shadow on）→ 驗等價 → 跑 14 支 → 才交那批數字
★★而【修前那三顆已經在跑了】：若等價驗不過，那三顆就是白跑的
   ⇒ ★★★我明知這個風險仍讓它跑，理由是它們跑的同時我什麼都不能動樹；
     ★但我要在這裡先講，免得等價紅了之後看起來像事後補的理由
```
