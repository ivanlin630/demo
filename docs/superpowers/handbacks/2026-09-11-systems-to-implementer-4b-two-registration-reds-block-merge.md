---
from: systems
to: implementer
status: consumed
slice: 登記動詞 ④b ｜ merge 前的兩格紅
topic: ★**④b 還不能進 main**：merged result 跑全閘 ＝ 3 紅，扣掉 main 既有的 `bed-arm`，**兩格是 ④b 帶進來的**，而**兩格都是「新東西沒登記」**｜①`收留`／`求居` 兩個 option **兩份失敗反饋表都沒有**（`options.gd:220/233` 新增）②`outpost_system.gd:_complete_construction` 是**新的 `state.teams` 迭代站點**沒進普查表｜★★而我順手撞到一個**閘自己的病**（§③，我名下，不用你修）：`failure-feedback-coverage` 的「乾淨⇒綠」對照**直接 cp 活的檔** ⇒ **世界一旦真的紅，它就判自己失準然後作廢**
---

# ① 兩格紅（★都是機械的，不是設計問題）

```
①`failure-feedback-coverage`：{ 兩邊都沒有:收留, 兩邊都沒有:求居 }
  ⇒ 新 option（`scripts/simulation/decision/options.gd:220` 收留／`:233` 求居）
    要**剛好進一份表**：`FailureMemory.OPTION_FAIL_KEY`（有失敗反饋）
    或 `NO_FAILURE_FEEDBACK`（已決定不需要／待接，★理由要寫成可被證偽的那種）
  ⇒ ★理由若寫「已有等價機制」⇒ 閘會要求**指名 `Symbol.method` 並驗它還在**。
②`live-team-census`：`scripts/simulation/outpost_system.gd`／`_complete_construction`
  ⇒ 新的 `state.teams` 迭代站點沒登記（母體 57 站／表 63 列）
  ⇒ ★閘明說「它需要活著的還是全部的？**逐站判，別留白**」。
★兩格補完 ⇒ 我重跑全閘 ⇒ 綠就 merge，然後發信給你 rebase 那張票。
```

# ② 這一輪的其他 53 支（★給你當背景，不用動）

```
55 支｜總時 451s｜FAIL ＝ bed-arm（★main 既有基線紅，25/26 床的床層債，刻意留著看得見）
  ＋ 上面那兩支 ⇒ ★**除了你新加的東西，這棵樹沒有帶進別的紅**。
```

# ③ ★★★閘自己的病（**我名下**，寫出來是因為它會誤導你讀今天的輸出）

```
`.claude/hooks/failure-feedback-coverage.sh:110-113`：
    cp "$OPT_DEFAULT" "$d/opt.gd"; cp "$FM_DEFAULT" "$d/fm.gd"
    r="$(check_pair ...)"; if [ "$r" != "OK" ]; then echo "★對照失準：乾淨的一對被判紅"
⇒ ★它的「乾淨」**就是活的現況** ⇒ **現況一旦真的有紅，對照必然失準** ⇒ `exit 3` 本輪作廢。
⇒ ★★所以今天它的畫面是：**先印出真發現（收留／求居），再宣布這一輪不算數。**
⇒ ★★★而它作廢的樣子長得像【儀器壞了】，不像【世界壞了】——
  而那正是我記過的那條：**「世界壞了」與「我的儀器壞了」是兩個結論**，
  一支把現況當基準的對照**永遠分不出這兩個**。
修法（我出票）：乾淨那一格改用**床裡凍結的最小合成對**（兩個 option、各進一表），
  ★而**假 option⇒具名紅** 與 **同時在兩表⇒紅** 那兩格是對的（它們不吃現況），照留。
```
