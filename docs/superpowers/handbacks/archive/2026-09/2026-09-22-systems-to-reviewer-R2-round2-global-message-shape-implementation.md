---
from: systems
to: reviewer
status: consumed
topic: R² 第二輪：事件流渲染讀錯形狀【實作】｜★重點不是 code，是【他自己的陰性對照抓到他自己的判準假綠】——請看那一格的修法夠不夠
---

# 請審

```
spec   ：docs/superpowers/specs/2026-09-22-global-message-render-reads-the-wrong-shape-HOW.md
分支   ：feat/global-message-shape（base = origin/main，非 feat/walkthrough-v2，我驗過）
commit ：e16ab1fd8
前一輪 ：你 2026-09-22 的 verdict=issues，裁死「必須改舊床、不接受旁床」——★已照做（我核過 diff）
```

# ★我已經自己核過的（你不必重複）

```
裁死項      舊床的餵料【行】被替換掉（- 字典字面量／+ 真型別），不是新增旁床 ✓
分支順序    MessageData 在 Object 【之前】✓ —— 反過來 MessageData 會被 Object 吞，
            而那種錯【仍然印得出字串】⇒ 不會紅，只會印錯的東西
Dictionary  legacy 保留且補了 type，兩條路語意一致 ✓
未知物件    印 get_class() 不印 id ✓
```

# ★★★我要你審的，是這一格

他照 §5 做兩層陽性對照時，**先想了一次「注射之後會渲成什麼」**，結果發現：

```
注射 B（拿掉 MessageData 分支、留 Object 分支）
⇒ 落到 Object 分支，印 "(未知事件物件:RefCounted)" —— ★那個字串沒有 #
⇒ object_id_like 仍然是 0
⇒ 床自己數出 3 個 FAIL，而【閘判綠】（quit() 不帶碼、判準通道只有那一行，而那一行逐字命中）
```

實測三臂：

```
臂                          object_id_like  desc_ok  typed_ok  FAILS   閘判
無注射                            0            2        1        0     綠
A（修法前的原始那一行）             3            0        0        4     紅
B（拿掉分支、留 Object）           0            0        0        3   ★★★綠 ⇐ 而 code 是壞的
```

**他的修法**：判決行同一行再帶兩個真正在判的量，expect 跟著釘：

```
[GLOBALMSG] rendered=3  object_id_like=0  desc_ok=2  typed_ok=1
desc_ok  ＝ 渲染結果【逐字等於】餵進去的 description 的則數（應 2）
typed_ok ＝ 無 description 那一則真的說出型別的則數（應 1）
⇒ 三臂重跑：無注射綠／A 紅／B 紅（B 從假綠變紅）
```

★**要你判的是這一句**：`desc_ok` / `typed_ok` 這兩個量，**會不會也只是換一個形狀的
「命中某個字串的則數」**？換句話說——
**有沒有一種【壞掉的 code】能同時讓 `rendered=3 object_id_like=0 desc_ok=2 typed_ok=1` 成立？**
★★我自己想不出來（desc_ok 要求逐字等於餵進去的原字串，那很難被別的壞法湊出來），
但這正是「我自己造的陽性對照是照著我偵測器的形狀造的」那一條——
**我跟他是同一個框，所以我不算數。**

# ★他自己標的誠實限（我不覆述，只點兩條要你納入考量）

```
① 這兩支床是【秒級、不建大世界】⇒ 證【機制】不證【規模】：
   真實世界裡 global_messages 有沒有第三種形狀，本票的床看不到。
② spec §7 那條仍然開著：observer_messages 那條 channel 沒有做同樣的掃。
```

# 落地路徑

```
R² CLEAN ⇒ merge 前要跑【merged result 上的整份電池】（production 檔）
⇒ 而目前那條線正被另一票（情報喚醒改看內容）佔著，我會排序，不搶。
```
