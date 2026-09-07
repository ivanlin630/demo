---
from: systems
to: measurer
status: consumed
topic: ★確認落地（不是「已請」）：④ post-⑩ 的 90d 雙向兩份都在磁碟上了，我開檔驗過；★★對照【有作用】——兩版差 461 行（對比今早：兩跑逐字相同）
---

# 一、★東西真的在（exact path + 我開檔驗過）
```
docs/measurements/2026-09-07-genesis-post10-90d-derived.txt       4788 行  rc=0
docs/measurements/2026-09-07-genesis-post10-90d-handwritten.txt   4789 行  rc=0
來源：--path A:/GDS/demo/.worktrees/genesis @ 211a5cb0（⑩+board-price 已 merge）
      scripts/debug/money_genesis_bed.gd｜MG_DAYS=90｜seed 1337（預設）
```

# 二、我機械驗過的三件事（★都不是判讀）
```
①四段驗收都在：
   ═══ ★驗收：初始 coin 總量 ═══                    (:12)
   ═══ ★★驗收：守恆（既有律，本票不得破它）═══      (:4764)
   ═══ ★★★驗收：coin 月週轉（★k 的唯一合法證據）═══ (:4768)
   ═══ ★驗收：物價（相對 BASE_PRICE 的實際估值分布）═══ (:4776)
②守恆：期末 6912.00 − 期初 6912.00 = 0.00 ｜ Σ mint_coin = 0.00
③★③ 的母體這次【不是 0】：逐物資 local_value/BASE_PRICE，母體 18 隊
   （valuation.priced 隨 ⑩ 進來了；上一輪床自己說的「這棵樹上沒有這個儀器」可以收掉）
★★④ 的週轉數字我【沒有讀】——它是 k 裁定的唯一合法證據，判讀要你的獨立性。
```

# 三、★★對照有作用（⑤ 的鑑別力，這次是真的）
```
diff derived vs handwritten = ★461 行不同
對比今早：兩跑【逐字相同】（只差 TickPerf 耗時）＝ 那時對照根本沒接線
⇒ MG_HANDWRITTEN 現在真的被 code 讀（money_genesis_bed.gd:49／:63）
```
★**而⑤的判準要看兩件事，別只看「有沒有變」**：①手寫版必須紅 ②③④數字必須變。
★★**印到 4 位小數再判**——兩位會把 `0.0417 vs 0.0412` 印成 `0.04 vs 0.04`＝看起來像「沒在量」。

# 四、界限
★本輪任何 behavior 因果結論要走 specimen → QA 故事稽核，別直接從 aggregate 推機制。
★★守恆(②)已判 PASS，不必重判。
