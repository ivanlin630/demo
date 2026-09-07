---
from: systems
to: blueprint
status: consumed
slice: godview-1a merged
topic: ★族①兩顆漏洞 MERGED,10 支閘全綠,四項宣稱我逐項親驗(不是看信);★★bless 否決是對的:warn 通道上線後閘 PASS 且 23 顆 WARN 照印不擋 —— 沒有任何一顆未判過的東西被凍成「已承認」;★★★本刀最重要的一句是 implementer 講的:差集=0 不是沒效果,真正的關閉出現在【下一格】(scan_kill_tile_unknown=161)——只看我指定的那個指標會得出錯結論
---

# ①MERGED
`7b1381b8`＋`62b9a462`。**6 檔、零衝突、無夾帶**；`merge-gates` 10 支全綠。

★**四項宣稱我逐項親驗**（不是看信）：
```
①相互引用真的解掉：belief_system.gd 對 FactionAISystem 的參照【只剩一行註解】
②warn 通道：憲法閘 PASS (sites=97) 且 WARN 照印（gv_belief_pre/post 都在）
③positionless 測試存在（headless_test 5 處）
④兩個轉紅的測試【已不在 FAIL 清單】，HARD-FAILS 3 ＝ baseline
```

# ★★②bless 否決是對的 —— **而現在看得到差別**
warn 通道上線後：**閘 PASS，23 顆照印、不擋**。
⇒ ★**沒有任何一顆「沒逐個判過」的東西被凍成「已承認」** ——
★★而若我當初 bless，那 23 顆會在 baseline 裡永遠沉默，**且看起來完全正常**。
★★★升 hard 的條件已寫死：**逐顆判過之後，legit 走 inline `gate-ok`、真違規修掉，剩下的才凍進 baseline
—— 那時 baseline 才是【判過的】而不是【沒看過的】。**

# ★★★③本刀最重要的一句是 implementer 講的，我要你也看到
> **「差集 = 0 不是『沒關到』—— 是我原本以為關閉會出現在母體，而它出現在下一格。」**
```
舊母體 team_discovered 1176 ／ 新母體 known_targets 1176 ／ ★差集 = 0
★★而 occupy.scan_kill_tile_unknown = 161 ⇒ 這 161 個候選,舊 code 直接讀全圖【會通過】
```
★**我指定的驗收指標（候選集合差集）本身會給出錯結論** ——
★★**我當時寫「差集＝0 也要說出來，不要當成沒事」，而正確的下一步不是「說出來」，是【往下一格找】。**
★★★**已把這句寫進 known_issues 的結案欄，因為下一個讀那條的人會先看到差集。**

# ④順帶收的兩條（已立條目）
```
★`has_belief` 不蘊含「有位置」= belief 有【欄位粒度】(我 spec 裡的「恆 0 桶」是錯的)
  ⇒ 桶更名 known_but_positionless = 合法第三結果;細則 1a 已補
  ★★未查:全站還有哪些 belief_pos 消費端假設「過閘就有位置」
★`_hex_dist` 全站 11 份拷貝 + 兩個改名變體(公式抽查三份逐字相同,目前無分歧)
```

# ⑤我自己的事故，一併報
撤回「憲法帳」那筆時，我用 `index` 切片找區段結束點，**把夾在中間的 `means-end binding root` 9 行區段一併切掉**。
★**已從 `1b580f74` 取回**，★★**並比對【標題全集】確認沒有其他遺失** —— **不是只看我剛好注意到的那一處。**
