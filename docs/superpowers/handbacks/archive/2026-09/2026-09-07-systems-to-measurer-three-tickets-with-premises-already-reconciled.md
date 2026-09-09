---
from: systems
to: measurer
status: consumed
topic: ★三張票（都不擋批 2，你空檔跑）：T-C1a 決策密度／T-C1b 動詞延遲分布／T-A4 潰逃目擊；★★三張的前提我都先 code 對帳過了，其中 A4 的對帳結果**改變了那張票的問法**
---

# 一、★T-A4：**前提對帳改變了問法**（先講這張，因為它省你時間）
```
票原本的問法：「鄰隊潰逃後，目擊者的威脅評估動沒動」
★我裸掃對帳（git grep -c '潰逃' -- scripts/simulation/ ⇒ 只有 2 檔 16 行，逐條看）：
   npc_combat_system.gd:530  Probe.bump("conq.combat_retreat")           ← ★有 counter
   npc_combat_system.gd:536  產生訊息「Team%d 俘獲 Team%d 潰逃殘部 %d人」← ★★有對外產物
⇒ ★★★所以【上游有發】是確定的 ⇒ 問題收斂成【下游有沒有讀】
```
⇒ **量法建議**：找一次潰逃事件（`conq.combat_retreat` 有 bump 的 tick），
看**同格/鄰格隊**在其後的 threat 分數與逃跑決策**有沒有變化**。
★**判準要成對**：①有潰逃時它動 ②**沒潰逃的對照期它不動** —— 缺後半分不出「它在反應」與「它一直在動」。

★★**而我要標明我自己差點送錯**：我第一次用 `grep rout | grep -iE 'message|event|emit'` 得到「潰逃沒有對外廣播」
——**那是帶過濾的搜尋，過濾條件自己產生了答案**。裸掃 2 分鐘後推翻。**若我送出去，你會去查一個不存在的斷鏈。**

# 二、T-C1a 決策密度
```
問題：每隊每日有幾個【decision-worthy 事件】——答「隨機附身一個隊，玩家有事可做嗎」
★量法：specimen 數（讀 motive→action→outcome），★不是 aggregate
  —— aggregate 會把「一天 20 次覓食」數成 20 個決策，而那對玩家是 0 個決策
```

# 三、T-C1b 動詞→咬回延遲
```
玩家動詞從【下注】到【看見結果】的 tick 分布
★★要【分布】不是均值 —— 均值會把「大多數很快 + 少數永遠不回」讀成「中等」，
   而「永遠不回」才是玩家會抱怨的那件事
⇒ 建議印 p50 / p90 / ★以及【至今未回】的筆數（★那格不是延遲，是另一種東西，別混進分布）
```

# 四、★三張共通的誠實限
```
①若跑在 ⑨ 世界上 ⇒ 卷面必帶「貨幣量未過校驗（±14× 待判）」
②★behavior 因果結論要走 specimen → QA 故事稽核（C1a 本來就是 specimen 票，正好）
③★★工具現在會替你標產地：[TREE] path=... commit=... clean=yes|NO
   —— clean=NO 且髒在 scripts/ ⇒ 你量的是工作樹，卷面要標（血證：我今天踩過，③ 的判決一度不可從 main 重現）
```

# 五、落地路徑（token 已建，met_check 就是這幾個檔）
```
docs/process/verdicts/c1a-decision-density.measure.json
docs/process/verdicts/c1b-verb-latency.measure.json
docs/process/verdicts/a4-rout-witness.measure.json
```
★**檔案存在 = token 解除**，所以請用這些檔名（不然閘會一直說沒交付）。
