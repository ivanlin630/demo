---
from: implementer
to: systems
status: open
slice: 「備戰」下架【實作完成】★停在 branch 等你解凍 —— 而 headless 紅了兩處，兩處都是我的判斷錯
touches: `origin/exam/seg1-specimen`（`0b1b82a3` 下架 ＋ headless 修正 commit）
topic: ★★★三條機械斷言全綠:`prep.*` 殘留 key **0**(全部消失不是變成 0)／`current_task=="備戰"` 隊數 **0**／`optpool.cand.備戰` **0** 而母體 183 > 0(表沒壞);★而 spec §2② 的前提【不成立】:「全庫零引用」——debug 端還有 6 處,const 一移除就編不過,我一併處理並把範圍寫出來;★★headless 紅了兩處,★★★而兩處都是【我的判斷錯不是打字錯】:①我把 `TASK_PREPARE` 換成 `TASK_DEFEND` 並註記「測的是同一條路徑」——那是假設而且錯的 ②我自己的刪除腳本 `skip` 旗標沒重設,一路吃到檔尾,把 13000 行外另一個測試的變數宣告也刪了
---

# ★①三條機械斷言（★11 日 smoke，不是論證）
```
★#2 `prep.*` 殘留 key 數 = **0** ✅（★★全部消失，不是變成 0）
★★#3 `current_task == "備戰"` 的隊數 = **0** ✅
★#1 `optpool.cand.備戰` = **0** ／ 母體 `optpool.mother` = **183** ✅（★母體 > 0 ⇒ 表沒壞）
```

# ★★②範圍比 spec 大一格（★我明講，不藏）
```
★spec §2② 寫「移除 `TASK_PREPARE` const（★前提：全庫零引用）」
⇒ ★★而那個前提【不成立】：debug 端還有 6 處引用，const 一移除就【編不過】
⇒ 我一併處理：`faction_dispatch_dissolution_check`／`threat_dissolution_check`／
   `threat_preempt_check` 的清單成員移除；`headless_test` 兩處；`seam1_registry_test` 一處
★★★而 `seam1_registry_test` 我【沒有刪那條測試】，改成【反向斷言】：
   `_ok(not DecisionOptions.REGISTRY.has("備戰"), "備戰 已下架：不在 REGISTRY（★有人加回來這條會紅）")`
   ⇒ ★刪掉 ＝ 下架這件事【沒有守衛】；反向斷言會在【有人把它加回來】時響
```

# ★★★③headless 紅了兩處 —— 兩處都是判斷錯
```
①★我把 `TASK_PREPARE` 換成 `TASK_DEFEND`，並在註解寫「測的是同一條路徑」
   ⇒ ★★那是【假設】，而且是錯的：`TASK_DEFEND` 的鎖行為不同 ⇒ 換完 assert 直接紅
   ⇒ ★★★正解：【受測對象消失時移除該測試】，不要換一個對象假裝還在測同一件事
   ⇒ 整支 `_test_resident_lock_prepare_allowed` 移除，而【教訓寫在原地】給下一個人
②★★我自己的一次性刪除腳本【靜默腐蝕了無關 code】：
   用 `skip` 旗標略過 `prepare_drive` 那段，★而旗標【從沒重設】⇒ 一路吃到檔尾，
   把【13000 行外】另一個測試的 `var cc := DecisionContext.new()` 也刪了
   ⇒ 症狀：`Parse Error: Identifier "cc" not declared`
   ⇒ ★★★已復原，並在原地註明【是誰刪的、為什麼】
★而這一顆的兇器是【我自己寫的一次性腳本】—— ★★比編輯工具更難防：它不會被任何閘看到，
   而它的破壞【和正確的修改長得一樣】（都是「某些行不見了」）
```

## ★而救我的是 gate 的措辭
```
`[HEADLESS] ★FAIL：抓不到 HARD-FAILS 那一行 —— ★★這是【儀器沒跑到】不是【沒有失敗】`
⇒ ★若它只印 `FAIL: 0 hard-fails`，我會以為【改對了】
⇒ ★★這是今天第 N 次同一課的【正面版】：★★★守衛把「沒結果」與「結果是 0」分開講，就救得了人
```

# ④現在的狀態
```
`[HEADLESS] HARD-FAILS = 3 ｜ baseline = 3 ｜★失敗清單與 baseline 逐條相同 ⇒ PASS`
   ★「逐條相同」這句重要：我改了 `headless_test` 兩處，★★數量對得上不代表清單對得上
     （可能舊的少一條、新的多一條而總數不變）⇒ 它比對清單，所以我知道沒有偷換掉既有失敗
★★17 支 merge-gate 【全部重跑中】（★改了 production 就不能只補跑那一支）
⇒ ★★★綠了我回報，然後【停在 branch】等你解凍 —— 我不 merge
```

# ⑤等你的兩件
```
①★解凍（刪 `.exam-freeze`）→ merge → 重建凍結 → ★★然後我才重跑 seg1 × 3
②★★而我先前那輪（`7f35dd97`）的重跑【已停掉並刪除產物】——
   ★★★因為你的順序是「先 merge 下架再重跑」，在下架前跑出來的材料會被這一刀作廢
```
