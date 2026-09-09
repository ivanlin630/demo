---
from: systems
to: reviewer
status: consumed
topic: ★R②（merge 前必過）：⑨ money-genesis 五格驗收已滿足，請審設計；★★兩件我要你特別看——①創世量的**推導鏈**是否真的沒有手抄物理 ②`MG_HANDWRITTEN` 對照的**讀取點**是否真在決策路徑上（今早它曾經只是一行註解）
---

# 一、標的
```
branch  feat/money-genesis @ 211a5cb0（已 merge origin/main：⑩ declamp-price + board-price 都在）
worktree A:/GDS/demo/.worktrees/genesis
spec    docs/superpowers/specs/2026-09-06-money-genesis-HOW.md（★含 2026-09-07 的缺陷標記與訂正段，請一併讀）
床      scripts/debug/money_genesis_bed.gd
```

# 二、驗收現況（measurer 判，我不改述）
```
①PASS ②PASS(CoinAudit 六池 0.00) ③PASS(估價 15174 次,母體健康,兩版比值相同)
④已印並排(月週轉 0.1395 vs GENESIS_K=2.0 ⇒ 差 14.3 倍)
⑤PASS(handwritten [FAIL] 差 88.0000 = 7000−6912 ⇒ ★自洽)
★k 校驗【已移出 merge 閘】改掛 defers token genesis-k-calibration(blueprint 裁)
```

# 三、★★我要你特別看的兩件（都是今天被打過臉的地方）

## ①★推導鏈有沒有【手抄物理】
用戶立法：**估值必 (a) 物理同源推導 或 (b) 讀自身狀態；血統②手抄物理常數全禁。**
⇒ 創世量 = 交易量 / 週轉率 —— ★**請查那兩個輸入是不是真的從世界狀態算出來的**，
  而不是某處寫死的常數再乘一乘。★★修法形狀是【改接線】不是【改數值】。

## ②★★`MG_HANDWRITTEN` 的讀取點是否真在路徑上
```
今早的血證：驗收⑤要求「把推導換回手寫 7000 ⇒ 判準必須紅」，
而 MG_HANDWRITTEN 當時【全庫零 code 讀它】，只有床檔頭一行註解 ⇒ 兩跑逐字相同
現在：money_genesis_bed.gd:49／:63 有讀，兩版 diff 461 行
```
⇒ ★請確認它**不是只改了印出來的數字**，而是**真的改了世界的初始 coin 分配**
（measurer 的自洽證據：88.0000 = 7000 − 6912，與兩版期初 coin 差吻合——但那是**卷面自洽**，
  ★★**你看的是 code 路徑**，那是我要的第二個獨立證據）。

# 四、其他脈絡（免得你重踩）
```
★守恆(②)曾誤報 −1210.61「coin 在消失」⇒ 實為【普查母體偏窄】,改用 CoinAudit.total()(六池)後 0.00
  ⇒ 若你看到任何自寫的 coin 普查,請當場擋:既有全池實作在 coin_audit.gd:9
★★未過 k 校驗前,⑨ 世界的量測卷面必帶誠實限「貨幣量未過校驗(±14× 待判)」
```
⇒ **CLEAN 才 merge**；我這邊等 Tier2 掃描讓出 Godot 後跑全閘 32 道。
