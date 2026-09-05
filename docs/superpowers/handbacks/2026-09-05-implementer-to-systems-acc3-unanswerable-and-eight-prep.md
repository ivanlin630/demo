---
from: implementer
to: systems
status: consumed
topic: ★驗收③【答不了】不是紅也不是綠——兩個盟從未進過「守成」，而線索指向 `_rebuild_goals:1436` 的缺糧提前 return｜★★determinism 1vs2 逐位元相同，而「不同」是我自己過濾器的洞（假紅）｜★★★⑧ 前置窮盡搜索已做，含 spec 沒點名的 `cross_run_reset`
---

# 一、驗收③：★**答不了**，而這是我第二次差點把假紅送出去

## 第一版（錯的）
```
f0(貪0.39義0.43 eff=1949) 期望22.2 實得0 比值0.00
f1(貪0.37義0.38 eff=1933) 期望22.3 實得0 比值0.00
[FAIL] H：最差偏離 1.00
```
★我拿「窗長 ÷ eff = 22.2 次」當期望 —— ★★**而那假設這個盟【整個窗都在守成】**。
徵收排程只長在 `_rebuild_goals` 的 `"守成"` 分支裡；盟在打仗／擴張時**那段 code 根本不執行**。
⇒ ★★★**我拿一個【假設的母體】去判一個【可能沒有母體】的格子** ——
   跟今天所有「0 底下住著兩種東西」是同一件事，**只是這次我站在製造它的那一邊**。

## 第二版（補了母體 tap `levy.branch.byfaction`）
```
f0(貪0.39義0.43 eff=1949) ★【從未進過「守成」】⇒ 不可判（不是 0 次，是沒有母體）
f1(貪0.37義0.38 eff=1933) ★【從未進過「守成」】⇒ 不可判
[FAIL] G：★母體非空（可判的盟 0）—— ★★0 的話下面【答不了】不是通過
```
⇒ ★**兩個盟在 43200 tick 內一次都沒進過守成分支。**
⇒ ★★**所以 ⑦ 對 `faction_ai:1499` 的修法在這個世界【無法驗證】** ——
   ★★★**不是沒修好，是那條 code path 在這個世界是死的。**
   （★而床現在**拒絕給判決**，不印假紅也不印空綠 —— 我認為那是對的行為，若你要別的形狀請裁。）

## ★★★而它指向另一個東西（**我只報線索，不自己開票**）
```
faction_ai_system.gd:1436  食物不足 ⇒ f.strategy = "緊急徵收"；_emit_goal(...); return
                                                                              ↑★在 `match itype` 【之前】
⇒ ★盟若長期缺糧，【整個意圖分派段根本到不了】⇒ 守成分支自然是死的
⇒ ★★而這【不是⑦的病】—— 是「盟是不是永遠處在缺糧 override 裡」的問題
⇒ ★★★我已加印【盟實際選到的意圖分布】(`intent.sel_*`)：★母體是 0 的時候卷面要說【它們去哪了】，
   否則「不可判」只是另一個沒有內容的字。數字回你。
```

---

# 二、determinism：★**1 vs 2 逐位元相同**，而「不同」是**我自己過濾器的洞**

```
第一次比：run1 sha=b809272e ／ run2 sha=cb6de7d6  ← 不同！而【行數一樣是 4003】
逐行 diff：60 行差異【全部是】 [TickPerf] day=N avg=2300us max=615932us ... teams=18 factions=2
                                                                          ↑★teams/factions 完全相同
⇒ ★我的過濾器抓 `usec`，而它印的是 `us`
補上 `TickPerf|FaiPhase` 之後：run1 sha=3c80b5fc ／ run2 sha=3c80b5fc  ★逐位元相同（3973 行）
```
⇒ ★★**世界本身是確定性的；不確定的只有量測儀器自己印的耗時。**
⇒ ★★★**而我上一封才剛警告過「假紅」，然後洞就出在我自己的過濾器裡** ——
   若我沒去看那 60 行、只看到 sha 不同，這會被結論成【⑦ 破壞了 determinism】。
   ★**假紅的代價跟假綠一樣大，只是方向相反：假綠讓人不查，假紅讓人不再看這支閘。**

★第三跑另有 2 行尾巴雜訊（`L` ＋空行，`\r\n` 結尾），**來源未定 ⇒ 我不宣稱三跑通過**。
   ⑧ 落地後要重跑（spec §4-5 要求「在不會被編輯的樹上跑」），那時一併查。

---

# 三、⑧ 前置：★窮盡搜索已做（**驗收① 的證據我先給**）

```
player_pos  全庫 65 處（scripts/ 全掃、無 head、無 glob 截斷）：
   scripts/simulation/ ── 只有 sim_runner.gd（13）  ★你與 R² 的負斷言我獨立驗過，成立
   scripts/ui/         ── 22（world_map_view 7／text_map_renderer 7／sim_bridge 4／encounter_view 2／bottom_bar 2）
                          ★憲法 §5③ 明文允許（表現非模擬）—— ★★分開列，不混在一起
   scripts/debug/      ── 30
_hex_distance(  全庫 3 處，★全在 sim_runner.gd（:601 near／:612 far／:615 定義）
force_full_hd   全庫 65 處：sim_runner 4 ＋ ★★★cross_run_reset 2 ＋ 約 24 支床
```

## ★★★spec 沒點名的那一顆：`cross_run_reset.gd`
```
cross_run_reset.gd:48   _FLAG_DEFAULTS = { "SimRunner.force_full_hd": false, ... }
cross_run_reset.gd:104  match name: "SimRunner.force_full_hd": return SimRunner.force_full_hd
⇒ ★spec §2④-b 只點名「sim_runner 的宣告與讀取點」與「debug 床的賦值」
⇒ ★★刪掉旗標會讓這兩處【編不過】
⇒ ★★★我會一併處理並在回信具名 —— ★而我【不當作沒看到】，也不自己擴大票的其他部分
```

---

# 四、我現在**沒有動刀，也沒有跑 perf**

★前一支 acceptance 還在跑 ⇒ **兩個 godot 同時跑會污染 perf 數字**，
而那是我今天才在別人身上抓到的那一類（**儀器改變被觀測物**）。等它結束再依序做。

★★而 perf 對照我打算這樣拿（**動刀前一次跑就同時得到 before 與 after 的投影**）：
```
`lod_perf_bed`  pass A = 現行 LOD（＝before）
                pass B = 全高清（＝★⑧ 之後的世界就是這個）
⇒ 不必等改完才知道代價；★★★而改完要【再跑一次真的】對帳，不是拿投影交差
```
