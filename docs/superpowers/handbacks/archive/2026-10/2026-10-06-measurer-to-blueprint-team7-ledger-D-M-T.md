---
from: measurer
to: blueprint
status: consumed
slice: Team7 結案信三個「要量」：D（守恆）／M（material誰搬的）／T（徵收間隔）
topic: ★回應 systems 派工（`2026-10-06-systems-to-measurer-team7-ledger-reasons-and-tax-interval.md`）：三題都答了，D 順手撞到一個更根本的帳本儀器缺陷（set_amt 的 record_driver 傳錯值），T 的答案比預期更有料（message vs ledger 不對帳）。先驗 driver_ledger 開/關逐位相同已過，且世界 fp 跟 observation-30day 那份完全一致（獨立確認同一個世界）。副本：systems（SendMessage 已敲）。
---

# 一、先驗：driver_ledger 開/關是否改世界

```
決策序列 hash：A=B（1cd22872...e383508e，逐位元組相同）
世界 fp(sha256)：A=B=f1d9b750ca17ea61701916bdf31f76a08069c0b4e5c7ca39f85b086918bd934d
★附加確認：這個 fp 跟 observation-30day.specimen.jsonl 那次跑出來的 fp【完全相同】
  ⇒ 不只是「這次開關一樣」，是「這次整個世界」跟你結案信讀的那個世界是同一個，不是另一個種子/另一棵樹。
窗口完整性：Team7 food 帳本最早一筆 tick=98（逐 tick drain+clear，結構上不會被環形緩衝丟棄）
```

# 二、D（守恆，最重要）—— 答案：不是同 reason 互抵，但撞到別的真缺陷

```
窗 t28630–29340 內 Team7 food 帳本 77 筆。reason 分組：
  barter_give_in  ｜+1筆 +11.00
  eat_team        ｜+12筆 +4251.36（★見下，這組不可信）
  l0_forage       ｜+12筆 +3.68
  trade_goods_in  ｜+27筆 +5746.00
  trade_goods_out ｜-25筆 -5220.00

★★★結論：沒有任何 reason 同時出現顯著的 + 與 -——trade_goods_in／trade_goods_out 是【兩個
不同 reason】，各自單邊（+5746/-5220，方向一致於「有買有賣」）⇒ 你問的「±200-550 鏡像」
就是這組：★不是缺陷，是真流動（Team7 這段在頻繁買賣 goods，金額級距正好落在 200-550）。

★★★但量 D 時順手撞到一個不在你題目裡、更根本的帳本儀器缺陷：
  `eat_team`（scripts/simulation/resource_system.gd:229）走 `ResourceBank.set_amt()`，
  而 `set_amt()`（scripts/simulation/resource_bank.gd:48-53）寫給 `record_driver` 的是
  【絕對新值 amt】不是【真delta amt-prev】——
  ★第 49 行自己的註解逐字寫著「不能當成『流入amt』，那會把吃飯記成收成」，
  第 52 行 `_tally_food` 真的用了 `amt-prev`（做對了），但緊接著第 53 行
  `record_driver(team,res,amt,...)` 卻傳了 `amt`（沒跟上）——同一個函式兩個寫入口，一個對一個錯。
  ⇒ ledger 裡任何走 set_amt 的 reason（已知至少 eat_team、raid_out 兩個）的 delta 欄位不可信，
  窗內 eat_team 那些「+142~+759」不是真的食物流入 142~759，是 `team_food-from_team` 這個
  算式的【絕對值】被誤記成 delta。
  ★我沒有動 production code（resource_bank.gd 不是量測員的格）——交 reviewer/systems 判要不要修
  那一行（`record_driver(team, res, amt - prev, reason, "resource")`）。
```

# 三、M —— 答案：窗內只有 1 筆，不是 tribute 迴圈

```
窗 t28630–29340 內 Team7 material 帳本只 1 筆：tick=29340, delta=+15.00, reason=claim_goods
★確認你的推測：tribute 迴圈只動 food/goods/coin，material 的變化不是它搬的，是 claim_goods
（具體是什麼情境下觸發交你/QA判，我只量到帳本這一筆）。
★母體邊界：如果結案信裡「~45%」指的是別的時間窗/別的算法，這份答不到——我用了跟 D 相同的窗，
這是我的操作選擇不是信裡逐字指定的，請核對是否命中你要問的那個數字。
```

# 四、T —— 答案：訊息數遠大於真實轉移數（★這題意外地最有料）

```
方法：同一 tick 內 tribute_out 的付方／tribute_in 的收方都恰好各 1 個才配對（模糊的 0 筆捨棄）。

Team7 涉及的 global_messages type="tribute"（逐 tick 掃，TTL=14天不漏）＝16 筆：
  Team4 ×5（tick 2520/2580/2640，rate=0.01；tick 13740/13860，rate=0.00）
  Team5 ×8（tick 18420/20160/20220/25260/25320/27660/31200/31680/31800，rate=0.45）
  Team39×1（tick 26640，rate=0.45）／Team36×1（tick 27360，rate=0.45）

★★★ledger 確認的真實轉移配對只有 5 筆——全部是 Team4 那 5 筆（ticks=[2520,2580,2640,13740,13860]，
間隔=[60,60,11100,120]）。Team5 的 8 筆、Team39／Team36 各 1 筆，一筆都沒有對應的
tribute_out/tribute_in 帳本entry。

★推論（不是驗過的事實，交你/QA判要不要追）：`_resolve_tribute` 對每種資源算
`amount = stock*base_rate`，`amount<=0` 就 `continue` 跳過那筆 ResourceBank 呼叫——
Team4 的徵收發生在 Team7 還健康的早期（tick<14000），rate 雖小但 stock 夠、amount>0；
Team5／39／36 的徵收發生在 Team7 經濟已崩（tick>18000，同期 coin 從 298 跌到 44.7）之後，
rate 雖高（0.45）但 stock 可能已經壓到讓三種資源的 amount 全部 ≤0 ⇒ 訊息照常發「rate=0.45」，
但三個 ResourceBank.add 全部被 continue 跳過，一分錢都沒轉移。
★★若這個推論成立：你要判的「節律是不是問題」這個問題本身可能要先拆成兩半——
「訊息節律」（看起來頻繁）vs「真實抽血節律」（可能幾乎是 0），兩者不是同一件事。
```

# 五、落地

```
commit：5ffb6f3dc（已 push）
床：scripts/debug/team7_ledger_reasons_and_tax_interval.gd
產物：docs/measurements/team7-ledger-D-M-T.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/team7_ledger_reasons_and_tax_interval.gd
```
