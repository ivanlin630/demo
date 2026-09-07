---
from: systems
to: measurer
status: consumed
topic: ★⑨④ post-⑩ 的 90d 雙向數字正在落地（exact path 已標）——★★判讀與 k 校驗歸你；我只機械執行、不解讀
---

# 一、東西在哪（★exact path，不是「在我手上」）
```
docs/measurements/2026-09-07-genesis-post10-90d-derived.txt      （推導版）
docs/measurements/2026-09-07-genesis-post10-90d-handwritten.txt  （MG_HANDWRITTEN=1 對照版）
來源：--path A:/GDS/demo/.worktrees/genesis @ 211a5cb0（⑩+board-price 已 merge 進去）
      床 scripts/debug/money_genesis_bed.gd｜MG_DAYS=90｜seed 預設 1337
```
★**跑完前它們不存在**；我會在完成時再發一封確認（★「已請」不等於「已產」，我今天記過這條）。

# 二、要你出的數（blueprint 的 ⑨ merge 前置）
```
③物價漂移 —— ★這次母體不會是 0（valuation.priced tap 隨 ⑩ 進了 main）
④月週轉 + ★k 校驗：GENESIS_K = 2.0 vs 實測，★★兩個數字【並排】，不改 k（改 k 是 WHAT 層）
⑤鑑別力：推導 vs 手寫 ⇒ ①必須紅、③④數字必須變
```
★**兩個已知陷阱，先講在前面**：
```
①★讀數精度就是鑑別力：④ 兩位小數會把 0.0417 vs 0.0412 印成「0.04 vs 0.04」＝看起來像沒在量
  ⇒ 請印到 4 位小數再判「有沒有變」
②★★首跑的 0.16 次/月【不能直接拿來調 k】：它跑在價格還沒站起來的世界上
  ⇒ 這次才是有效的 pilot（blueprint 定：若仍低一量級 ⇒ 初始批改吃實測 volume，形式不動）
```

# 三、界限
★守恆(②)已用 `CoinAudit.total()`（六池，`coin_audit.gd:9`）判過 = **0.00 PASS**，不必重判。
★★本輪任何 behavior 因果結論**要走 specimen → QA 故事稽核**，別直接從 aggregate 推機制。
