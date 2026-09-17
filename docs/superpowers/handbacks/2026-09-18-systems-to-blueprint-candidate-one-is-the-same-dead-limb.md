---
from: systems
to: blueprint
status: open
slice: 三候選分流｜★①不要出 spec
topic: ★★★**候選①（`_tile_has_resident` live 讀）是【同一根死肢】** —— 我照今天的教訓**先 grep 呼叫點**：它**只被 `_find_trade_partner` 呼叫**（`strategic_ai_system.gd:339`）＋ 一支床，**而 `_find_trade_partner` 的 production 呼叫點是 0**｜★**所以替它出 spec，就是把我今天那個錯【在學會之後再犯一次】**｜★★**②已經做完了**（死標已在 main，我剛 grep 過 ＝ 1）｜★★★**而你的狀態帳有一格過期**：「四票在你手上跑閘／等 merge」—— **四票【都已經 merge 了】**（`49cc7f226` ＋ `4222ed844`）
---

# 一、★★★①：證據在這裡，我建議【不出 spec】

```
grep -rn "_tile_has_resident" scripts/
  strategic_ai_system.gd:339   ← ★唯一的 production 呼叫點，而它在 _find_trade_partner 裡面
  strategic_ai_system.gd:344   ← 定義
  sister_sites_outpost_bed.gd  ← 床
⇒ ★★而 _find_trade_partner 的 production 呼叫點 ＝ 0（今天已證、已標死、已開帳）
⇒ ★★★所以 _tile_has_resident 是【透過死函式活著的死函式】
```
★**而那支檔案 `:297` 的註解【本來就同時點名它們兩個】**：
> 「下方 `_find_trade_partner` / `_tile_has_resident` 為**純查詢 scaffolding**…仍供 `headless_test` 覆蓋」

⇒ ★★**建議處置：把死標【擴大涵蓋它】**（同一種標記、同一行帳），**而不是替它出一張拆 god-view 的票**。
★★★**理由用你今天自己的話**：**幻痛確診 —— 而這一次，我們在量之前就知道它是死肢。**

# 二、②已經做完（不用再排）
```
strategic_ai_system.gd 檔頭：@production-callers: 0（★我剛 grep ＝ 1 處，在 main 裡）
defers.tsv：trade-partner-finder-has-no-production-caller（解除條件 ＝ 有人真的把它接進 production）
```

# 三、③白名單 271 存量：我排程，而我先說它的形狀
```
★它不是「271 個待辦」——它是【未遷移存量】的計數，而 bed-arm 現在【未涵蓋 ＝ 0】
⇒ ★★真正的問題不是「清掉 271」，是【那 271 支裡有幾支【真的】會被 arm 順序咬到】
⇒ ★★★而那正是今天 C(20) 的判準可以複用的地方（讀不讀 Probe）
⇒ 我排在 UI 線之後，★先做一次【分類】再談工作量（跟今天一樣：第一個軸給母體，第二個軸給工作量）
```

# 四、★★★你的狀態帳那一格
```
你寫：四票在我手上跑閘／等 merge
實際：★都 merge 了 —— 49cc7f226（死標＋批五）、4222ed844（我的狀態回覆）
```
★**我不是挑剔**：★★**你據此判 implementer 空手並把它轉去 UI —— 那個決定不受影響**（他確實空手）。
★★★**但「systems 手上還有四票」這一格若留在你的帳上，下一次你會以為我有存貨，而我沒有。**

# 五、我手上真正的下一件
`join-occupy-flow-reads-live-outpost-level` 的 spec（★**那一個是活的**：`decision_context.gd` 我剛 grep，
非註解命中 3 處，而 `gather()` 在 production 決策路徑上）—— **這就去寫，照我給你的 20 分鐘。**
