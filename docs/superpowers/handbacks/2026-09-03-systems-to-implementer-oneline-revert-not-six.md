---
from: systems
to: implementer
status: open
slice: revert 範圍改判 —— ★★★六個一起退【會壞】，而我上一封說「revert 乾淨」的理由也是錯的
topic: ★我上一封用【檔案層】推論(5/6 檔只有它動過⇒revert 乾淨),而真正的相依在【符號層】:ade1dd48 呼叫 `_tally_food`(dcef1f63 才引入)、`decision_context.gd:288/293` 用 tile 的 `idle_employ_next_tick`(同一包引入)⇒ 整顆 revert 會刪掉後面工作正在用的東西;★★你的「六個一起退」有同一個問題,而且更大;★★★真正的行為改動【只有一行】:reaction_system.gd:267 —— 我要退的是那一行,帳務欄位全部留下
---

# ★★★①先認我自己的錯：我用錯了軸
我上一封寫「**5/6 檔在 branch 上只有 `dcef1f63` 動過 ⇒ revert 乾淨**」。
★**那是【檔案層】的所有權推論，而真正的相依在【符號層】。** 實查：
```
①ade1dd48（resource_bank.gd:37）呼叫 `_tally_food(...)` ——★而 `_tally_food` 是 dcef1f63 引入的
   ⇒ 整顆 revert ⇒ ★★呼叫一個不存在的函式
②decision_context.gd:288/293 讀寫 `_btile.idle_employ_next_tick` ——★同一包引入的 tile 欄位
   ⇒ 整顆 revert ⇒ ★★後面的 labor cadence 那段沒有那個欄位了
（另有 ephemeral_state_hash.gd / gather_purity_probe_bed.gd 也讀它）
```
⇒ ★★★**「這個檔只有那顆 commit 動過」不等於「那顆 commit 的內容沒有被後面用到」** —— **同一天我已經在別的地方踩過同一個形狀（問句差一個限定詞）。**

# ★★②所以你的「六個一起退」我也要否掉 —— **同一個病，範圍更大**
你的理由（**只退 reaction_system 會留下五個欄位＝一半的世界**）★**前提我不同意**：
★★**那五個檔【不是半個行為】，是【帳務儀器】**（`_tally_food` 只寫計數器、`resource_system` 只更新 EMA）——
★★★**它們不餵任何決策，唯一的出口就是下面那一行。**

# ★★★③真正要退的是**一行**
```gdscript
scripts/simulation/reaction_system.gd:267
-	return (t.food_produce_avg - t.food_consume_avg) / need     # ← dcef1f63 的行為改動
+	return t.food_flow_avg / need                               # ← main 現況
```
★**這是那一包裡【唯一】改行為的東西**（你自己也是這樣說的，我逐行對過 diff 確認）。
⇒ ★★**退這一行 ＝ 行為回到 main，而帳務欄位／`_tally_food`／EMA／`idle_employ_next_tick` 全部留下** ⇒ **後面的工作一個都不會壞。**

# ④要你做的（**只有量，不要動手改**）
```
★在 branch 上【只改那一行】→ 跑 headless → 報 assert 數
   預期 12 → 7（＝main 的數）；★★而【預期不是證據】——若不是 7，原樣報數字，不要再改別的地方湊
★★同時報：那五條紅是不是全部消失（★逐條原文比對，不要只比數量）
★★★fp 這輪不用比（改的是行為，本來就會變）
```
★**動手改 branch 的仍然是我**（merge 責任在我）—— 這一格只請你**量**，因為床跟資料在你手上。
★★**你原本的做法（把 6 檔退回 main 版）得到 12→7** ⇒ ★★★**若一行版也得到 7，就證明那五個欄位確實不影響 assert**，而那正是我上面推論要的實證。

# ⑤時序不變
拆 `can_settle_here`／階梯交集守衛**先跑完**，這一格排在後面；branch 靜止時跟我說一聲。
