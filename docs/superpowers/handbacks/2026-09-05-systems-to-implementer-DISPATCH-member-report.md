---
from: systems
to: implementer
status: open
slice: 成員位置回報 ★派實作（R² CLEAN，零 payload）
tier: slice
topic: ★R² 把我標的未驗前提【直接查掉了】,而答案是【我們自己前一刀讓它成立的】:envoy 創建那 tick 趕不上 vision,而【下一 tick】它仍與母隊同格 ⇒ 吃到共位必見的 dist==0 保證 ⇒ record_claim ⇒ 帶著那筆 claim 上路 ⇒ 抵達時 _exchange_intel 雙向轉交 ⇒ ★★【零 payload 要加】;★★★而控制床必須在 dispatch【+1 tick 之後】查 belief —— 同 tick 查會得【偽陰性】
---

# 派工（spec = `docs/superpowers/specs/2026-09-05-member-report-envoy-HOW.md`）
```
★只做 (a):在【位置級大事】時由成員派 envoy 給領袖 —— 複用既有 `_dispatch_envoy`
★★三種事件(blueprint 指定):落腳建營／遷移完成／瀕危求援
★★★零新語意:不新增訊息型別、不新增投遞路徑、★【零 payload】—— 只是在既有事件點呼既有函式
```

# ★★①而「零 payload」的理由值得記（★兩刀複合）
```
★envoy 創建那 tick 趕不上 vision（SYSTEMS 順序:vision 在 faction_ai 之前）
★★下一 tick envoy 仍與母隊【同格】⇒ ★★★吃到【共位必見的 dist==0 保證】⇒ record_claim
⇒ envoy 帶著【它親眼看到母隊的那一筆】上路 ⇒ 抵達時 `_exchange_intel`（雙向）交給 leader
⇒ ★所以我們不必設計「回報內容」—— ★★信使自己就是載體,而共位必見讓它【看得見自己要送的東西】
```

# ★★★②控制床的關鍵時序（★R² 點名，否則偽陰性）
```
★【不要】在 dispatch 同一 tick 查 belief —— 那時 claim 還沒產生 ⇒ 會讀成「沒回報」
⇒ ★★必須在 dispatch【+1 tick 之後】查
⇒ ★★★而這正是今天記過的那條的變體:【走不到目標行的驗證，對那一行零證據力】—— 這次是【時序】上走不到
```

# ③驗收（★#3 是防修過頭，別漏）
```
1 ★控制床:孤立成員觸發大事 ⇒ envoy 派出 ⇒ 抵達後 leader 的 known_member_states[該員] 有位置
   （★★在 dispatch+1 tick 之後查）
2 ★★徵收「無目標」下降（現況 31/31 ＝ 100%）；★不要求歸零
3 ★★★【失聯仍然可能】:存在【從未回報且從未相遇】的成員 ⇒ leader 對它仍是 (-1,-1)
   ⇒ ★R² 已確認兩條真失聯路徑仍在(envoy 死於途中／母隊從未觸發大事)
4 envoy 發送頻率的【數字】:每 seed 每 90 日總數 ＋ 分事件類型（★「不塞世界」要有母體不是宣稱）
5 determinism 三跑一致（fp 會變）＋ 零 RNG
6 憲法閘 ＋ 17 支全綠
7 ★零新語意:diff 證（沿用你上次那個 74 insertions / 0 deletions 的形狀）
```

# ④★而凍結仍在
```
★做完【停 branch】—— ★★pre-push 現在會擋世界路徑,那是預期行為
★★★而我交出該段判定後才解凍 ⇒ 屆時 merge → 17 支 → 重建凍結 → 重跑
```
