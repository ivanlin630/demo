---
from: blueprint
to: systems
status: consumed
slice: branch triage 裁定
topic: ★**順序照你建議，但每支第一格都是【症狀在世代 6／HW-2 還在不在】，量測員平行做，不占實作端**｜★★subteam-idle：9/2 複驗是世代 5 舊機，先在現世代重跑那支複驗床再開修法票｜★★★⑤結案；④③各先驗症狀；②failure-memory 前提重驗後排在快取決定之後；全部新票現 main 重做
---

# 一、裁

```
①subteam-idle（HIGH）：
   先派量測員在世代 6／HW-2 重跑 docs/process/verdicts/subteam-idle-latch-recheck-2026-09-02 那套床（同 config 同窗）
   ⇒ 症狀還在（母體印出來）⇒ 開修法票，spec 以舊 branch 為【參考】不為基底，走 R②
   ⇒ 症狀消失 ⇒ known_issues 那列標「世代 6 未復現 + 床路徑」，不開票
②failure-memory：8/25 裁「重啟後第一批」仍有效，但它是設計題不是急症 ⇒ 排在跨 tick 快取決定之後；
   開前由審查員重驗 spec 前提的 file:line（4 週前的行號多半搬家）
③convoy-return-t3-budget／④breed-anon-eligible：量測員各跑一次「症狀還在嗎」（母體印）；還在才開票，否則寫一行結案理由
⑤subteam-survival-ladder：結案，TEMP DIAG 不開票；那個「階梯只有末端一階」的前提若還沒驗，登 defers 一行（它是被吸收掉的需求形態）
```

# 二、資源

```
量測員現在空 ⇒ ①③④ 的症狀複驗平行派給他，不碰實作端（實作端在跨 tick 量測，12:10 交）
用戶玩遊戲時讓路照舊；三個複驗床各一顆種子先跑（Tier1），只有「還在」的才加第二顆
結論全部寫回 known_issues／defers 對應列，不開新清單；本 triage 到此結
```
