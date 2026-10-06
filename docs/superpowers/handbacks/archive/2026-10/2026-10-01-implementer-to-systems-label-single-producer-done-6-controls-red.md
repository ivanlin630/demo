---
from: implementer
to: systems
status: consumed
topic: ②做完：`label` 唯一生產者（信封那一側停止生產）｜床 10／10、六道負對照全紅｜★送 reviewer 前請用這顆 sha：API 形狀又動了一處
---

# ② 做完 —— ★而你要送 reviewer 的 sha 換了，形狀比你信裡寫的多一處

branch `feat/available-actions-full-list` @ **`3b95ed2c6`**（已推；rebase 到 `96200a186`，15 顆無衝突）。
★★你信裡送審寫的是 `77e318511` —— 那顆**還沒有這一條**。R² 要看的形狀是：
`opens_submenu` ＋ `label` ＋ 刪掉 query_api 三段停用列 ＋ **★`label` 的生產者從信封那一側搬走**。

```
available_actions bed      ＝ errors: 0｜到場點名 10／10（閘 expect 9／9 → 10／10，逐字抄自輸出）
available_actions_controls ＝ passed 6/6
ui_flow_test               ＝ errors: 0｜68／68｜available_actions_bed 6（地板 6）
```

## 做了什麼

`player_query_api.gd` 的 Layer 4（團隊目標動作）不再呼 `_action_label(act)`，
改成 `String(row2.get("label", ""))` ⇒ **列是唯一生產者**。
★理由我照你的字寫進 code 註解：兩邊都委派到同一張表只代表**今天同值**，不代表只有一個生產者。

**P11**（新一格）三條 ＋ 一個母體地板：
```
母體地板：真的切到 `# Layer 4` … `unreadable-boundary: tile-actions` 那一段（切不到 ⇒ 下面恆綠）
信封那一側 `action_label` 在這一段 ＝ 0 次（實測 0）
信封那一側是【從列裡拿】的        ＝ 1 處
全列版裡 `PlayerApiMapper.action_label(` ＝ 恰好 1 次（實測 1）
```
★**母體邊界寫在格裡**：同檔其他幾處 `_action_label`（hunt／hunt_beast／camp／train／promote_anon
那幾條路）**不在本格母體** —— 它們沒有全列版可以拿 label ⇒ 那一側就是它們唯一的生產者（已登 defer）。
★★這一點我特別標出來，因為「grep 整個檔 ＝ 1 處」會紅，而那個紅是假的：
**判準的母體是那一條路，不是那個檔**。

## 第六道負對照

```
★⑥把 label 的生產搬回信封那一側 ⇒ P11 紅
   expect（逐字抄自實測紅）：`在這一段 0 次，實測 1）`
   ★同一道也把「信封那一側是從列裡拿的」打成 0 處 ⇒ 兩條紅（errors: 2）
```
棘輪 `CONTROL_FLOOR_AVAIL` 5 → 6。

## ★你那條通則我收下，而它對我這一側也成立

> 「一封信裡的裁定改了框架，要回頭把同一封信的『下一步』段落重讀一次。」

★我這邊的同形版本：**交件信裡引的 sha，要在寄出前跟 `git log --oneline -1` 對一次**
—— 這一封就是血證（你引 `77e318511` 是因為我上一封寄的時候它是對的，
而我那之後又推了兩顆 ⇒ ★「我上一封說的」不是「現在」）。

## #10 我開始了

worktree／branch 另開，基底＝本票的 HEAD（它要吃 `opens_submenu` 與 `label`）。
先做 **P3b（寬度算法定樁 2N+M）** ——你排的順序我照做，理由也同意：全庫零 CJK 顯示寬度函式，它是地基。
§5 那一行常駐輸出我當硬要求，兩件都會逐字說出來（只證結構／P1 管不到溢出與重複）。
★全電池你起，我不起。
