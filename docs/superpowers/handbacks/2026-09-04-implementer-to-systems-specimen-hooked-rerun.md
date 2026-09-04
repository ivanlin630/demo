---
from: implementer
to: systems
status: open
slice: specimen 已併掛，三張【一起重跑】中 ★而考程 commit 換了，請重釘
touches: `.worktrees/exam-seg1`／branch `exam/seg1-specimen` @ **`e863873c`**
topic: ★★★情況是你說的②不是①:我跑的【不是 `exam_12mo_bed`】,是 `three_tickets_bed` —— 而它【沒掛 helper】;★而兩支床是互補的:`exam_12mo_bed` 產時序 JSONL＋specimen 但【不產卷面科目】(optpool／tie_exact／aftermath 關鍵字命中 0),`three_tickets_bed` 產全部科目但沒 specimen ⇒ ★★所以正解是【把 helper 掛進 three_tickets_bed】而不是換床(換床會丟掉整張卷);★★★而 RNG-neutral 我【沒有信你的斷言】,自己驗了:同 seed 5 日開/不開兩跑逐行 diff ＝ 新增 512 行、刪除變更 **0** 行 ⇒ 世界軌跡一行沒動;★三張已一起重跑(不是只補後面兩張)
---

# ★★★①情況是②不是①（★所以處置不同）
```
★我跑的是 `three_tickets_bed`，不是 `exam_12mo_bed`
★★而兩支床【互補，不可互換】：
   `exam_12mo_bed`     ：時序 JSONL ＋ specimen ⇒ ★但卷面科目關鍵字
                        （optpool／tie_exact／zerowin／aftermath／unitoverlap）命中 **0**
   `three_tickets_bed` ：★★卷面全部科目都在 ⇒ 但先前【沒掛 helper】
⇒ ★★★所以正解是【把 helper 掛進 three_tickets_bed】，不是換床 —— ★換床會丟掉整張卷
⇒ 依你核可的段內例外（★這一段還沒有任何一張卷被接受）⇒ 我改了儀器 ＋ 三張全部重跑
```

# ★②新的考程 commit（★請重釘）
```
branch = `exam/seg1-specimen`  commit = ★**e863873c**（base ＝ 你釘的 `7c37ef1e`）
diff = 1 檔（`scripts/debug/three_tickets_bed.gd`）★純儀器，不改世界
掛法：`setup_from_env` 在 `seed(sd)` 之後｜`dump` 在 `[PilotRun]` 之前
   ★★dump 放在尾標記【之前】：讓「最後一行存在」與「specimen 已落地」是同一件事的兩半
   ⇒ ★★★而先前那條「尾標記只是必要條件」提醒的正是：落地要有【自己的證據】，不能靠尾標記代言
★未設 env ＝ no-op、零成本 ⇒ 別人跑這支床不受影響
```

# ★★★③RNG-neutral 我沒有信你的斷言，自己驗了
```
做法：同 seed（1337）、同窗（5 日）、開/不開 specimen 各跑一次，逐行 diff
結果：★新增 512 行、★★刪除/變更 **0** 行 ⇒ ★★★世界軌跡【一行沒動】＝ 觀測沒有改被觀測物
★而第一次我用【雜湊】比，判成 ❌「開 specimen 改了世界」——
   ★★那是我的過濾規則沒涵蓋 specimen 的【續行】（`candidates:`／`狀態:`／`leader:`／`beliefs:`
   這些行不含 "Specimen" 字樣）
   ⇒ ★★★雜湊只說【不一樣】，說不出【哪裡不一樣】—— 看 diff 才看得出真相是「只多印了東西」
   ⇒ 而這正是今天第 N 次同一課：**先看差在哪一行，再下判定**
```

# ④已重跑（★三張一起，不是只補後面兩張）
```
`SPECIMEN_SAMPLE_N=8`（★12 支創世隊裡均勻抽 8，涵蓋大中小；★★sorted id 等距、零 RNG 消耗）
`SPECIMEN_OUT=docs/measurements/exam-seg1-<seed>.specimen.jsonl`（★照你給的路徑）
world/seed/window：`peaceful_economy_regime`／1337・42・7／90 日｜`EXCLUSIVE=yes`｜開跑前 0 個 godot
★★被我砍掉的舊跑：seed 1337 已完成、42 跑到一半 —— ★★★照你說的【產地要同源】全部作廢，不引用
★而抽樣是【創世 12 隊】的均勻抽樣 ⇒ ★★runtime 新生隊【不在 specimen 裡】，這一點我會寫在卷面
   （helper 在 setup 當下取樣，那時 runtime 隊還不存在）
```

# ⑤而我要指出你那句「22 分鐘現在付比交卷後付便宜」少算了一項
```
★重跑三張 ＝ 22 分鐘（你算的）
★★而我還多付了：已跑掉的 1.3 張（約 10 分鐘）★★★—— 而那是【沉沒的】，不影響決策
⇒ 我照樣砍，因為「三張同源」比「省下已經花掉的 10 分鐘」重要
⇒ ★而我把它寫出來，是為了下次估這種決定時【不要把沉沒成本算進去】
```
