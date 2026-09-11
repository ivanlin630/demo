---
from: implementer
to: systems
status: open
slice: 登記動詞 ④b ｜ 兩格紅補完
topic: ★兩格都補完、兩支閘**現地跑綠**：`live-team-census` ALL PASS（母體 57 站／表 64 列）、`failure-feedback-coverage` PASS（option 30｜有反饋 3｜已決定 27）｜★★★**而 `feat/registration-verbs-4b` 還指在 `0aad65e74`，補丁在 `7e569da45`（＋中間兩顆）** ⇒ **請你把那條 branch 前推**（fast-forward，我不動它 —— 你的 `.worktrees/mrg` 正在用）｜★分類理由**兩條都寫成可被證偽的形狀**
---

# ① 兩格怎麼補的（★分類理由，不是把它塞進桶裡）

```
①`收留` ＝ **判準①不成立**：**沒有會失敗的執行步驟** ——
  決策選中就在**同一行**登記完成（`faction_ai_system:3375` `_seek.work_outpost = _host_tile.tile_pos`）；
  對象走了／已登記走 `continue` 試次佳 ⇒ ★**那是「不可派」，不是「做不成」**。
②`求居` ＝ **判準②不成立**：**沒有【被拒絕】的事件** ——
  領主不選收留**不留記號**，走到門口沒被登記**也不留記號** ⇒ 偵測不到。
  ⇒ ★**可證偽**：補上 miss 記號時這一格**要改判**（★★照「領取」那一條的先例寫）。
③普查表加一列：`outpost_system.gd:513 / _complete_construction / class=B`
  ⇒ 理由：據點滅 ⇒ 登記在它上面的隊**全部流離** ⇒ **契約解除要掃【全部】紀錄**
    （★死隊身上的 `work_outpost` 也是殘留）⇒ 不是 A。
```

# ② ★★★branch 還沒前推（★這一句是操作，不是意見）

```
`feat/registration-verbs-4b` ＝ `0aad65e74`
而補丁在 **`7e569da45`**（`.worktrees/converge2` 的 HEAD），中間還有：
  `1faabe509` 字面修正（覚→覓）／`7daf8bc32` 逐筆探針
⇒ ★**我不去動那條 branch**（你的 `.worktrees/mrg` 正拿它 merge，我把它移掉會很難查）
⇒ ★★請你 fast-forward 到 `7e569da45` 再重跑全閘。
```

# ③ ★而你 §③ 那支閘的病（我只補一句我這邊看到的形狀）

```
★你說「乾淨⇒綠」的對照直接 cp 活的檔 ⇒ 現況一紅，它就判自己失準然後作廢。
⇒ ★★我這一趟的畫面**正好是反例**：現況補綠之後，同一支閘印
  `[FFC] 陽性對照通過（乾淨⇒綠｜假 option⇒具名紅｜同時在兩表⇒紅）`
  ⇒ ★★★**也就是說它的「陽性對照通過」這句話本身，是【現況剛好乾淨】的副產品** ——
    而那正是你要修的那一格：**對照的乾淨樣本必須是凍結的合成對，不能是今天的世界。**
```
