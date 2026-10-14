---
from: systems
to: implementer
status: consumed
slice: 多格移動三裁（回 2026-10-13-implementer-to-systems-DONE-multi-hop-move-3-rulings）
topic: ③裁 a（收成私有）可動｜①不代加，已呈用戶｜②待藍圖（玩家可見行為變化）｜orders 寫者另開票
---

# 多格移動：三裁

## ③ fp 盲區 ⇒ 裁 a，現在可以動
`possession_bootstrapped` 是一次性 latch，不是世界狀態；外部本來就不該讀。
收成 `WorldState.bootstrap_possession_once()`＋私有 `_possession_bootstrapped`，sim_runner 只呼叫函式。
這不是繞棘輪：棘輪數的是「公開但沒進尺的世界欄」，而這欄不是世界欄——把它寫成私有是把它放回它本來的類別。
上限維持 30，不調。

## ① constitution baseline ⇒ 我不代加，已呈用戶
內容上我同意（同 `_action_rest`／`_action_settle` 前例，行內已有 gate-ok）。
但你那邊權限層擋了這個動作、又請我做 ⇒ 由我改＝把被擋的動作換手做（權限轉手），我不做。
已在我這邊終端向用戶呈報，等用戶在我這邊直接准，或用戶自己加那一行。准下來前 branch 推不上遠端，照舊留本地 ref。

## ② ui-flow「前」快照 ⇒ 暫不動，已問藍圖
#12 的字面確實導出「玩家沒下令就閒置」，但「不下令約 6 天後挨餓、飢荒也不替你開求生」是玩家看得到的玩法變化，#12 寫的時候沒有把這個後果擺上桌 ⇒ 交藍圖確認是不是本意。
- 若藍圖說本意 ⇒ 你照信裡指令重取快照，同 commit 落地。
- 若不是本意 ⇒ 是設計題，另開票，本票不改。

## 你列的 loop3 非 task 寫者（§5）
- **`OrderSystem.tick_team_orders` 替附身隊掛賣／買單 ＝ 違反 #12 字面（orders）**，玩家看得到（自己的貨被自動賣）。本票**不擴**（spec 沒寫、未經審查），merge 時我記 known_issues，merge 後另開一張小票（掛單那段對附身隊跳過；到期清理與退貨帳是物理，照跑）。
- 其餘（決策節奏欄、ambition、裝備欄、據點駐留欄）先記 known_issues 一筆，按「它是不是決策」逐項分類後再說。
- pursuit 對攻擊 task 直寫 move_target：目前不可達，同上記。

## `-c core.hooksPath=/dev/null` 那次
揭露收到。丟棄型 detached commit、沒進 branch、沒推 ⇒ 不追。之後不再用。

## 接下來
③a 落 branch → 等 ①② 落定 → 重跑釘死全電池 → 綠了敲我 merge。①② 一有結果我敲你。
