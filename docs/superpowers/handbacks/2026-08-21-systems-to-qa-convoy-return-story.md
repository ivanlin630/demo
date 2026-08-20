---
from: systems
to: qa
slice: convoy-return-conservation
status: open
topic: "[QA 故事稽核·convoy RETURN 收尾(長跑+behavior 因果結論=你這站不可跳)·★specimen 已落地 exact path(我開檔驗過存在):.worktrees/convoy-return-conservation/docs/measurements/2026-08-21-convoy-return-closure-peaceful.specimen.jsonl(1701 行/1.8MB;branch feat/convoy-return-conservation @7810bf06 內亦有)·要你判的故事:porter 送完貨→回家這段,motive→action→outcome 讀不讀得通·★特別盯三處:①『追家』(convoy.rehome)看起來是自適應還是鬼打牆(母隊移動 porter 追,追到哪裡算合理) ②歸建那兩隻的路徑像不像『回家』而不是『碰巧同格』 ③在途那隻的貨還在身上=守恆,但它的行為像被困住還是像正常在途·★我自己的預測被實測推翻過一次(我以為是 persist time-proxy,真根因是 merge_queue 繞過仲裁 release),所以【別信我的框】,照 trace 自己讀·樣本小(歸建者僅 2 隻)請標信心"
---

# QA 故事稽核：convoy RETURN 收尾

**這是長跑 + 下 behavior 因果結論的票 ⇒ 你這站不可跳**（`00_roles §量測→QA 故事稽核→藍圖`）。

## specimen（★已落地 exact path，我開檔驗過存在）
```
.worktrees/convoy-return-conservation/docs/measurements/2026-08-21-convoy-return-closure-peaceful.specimen.jsonl
```
**1701 行 / 1.8MB**；branch `feat/convoy-return-conservation` @ **`7810bf06`** 內亦有同檔。

## 要你判的故事
porter **送完貨 → 回家**這一段，**motive → action → outcome 讀不讀得通**。

**特別盯三處**：
1. **「追家」（`convoy.rehome`，共 7 次）**：母隊會移動、porter 去追。
   看起來像**自適應**，還是像**鬼打牆**？追到哪裡算合理？
2. **歸建的那兩隻**：路徑像不像**「回家」**，而不是**「漫遊到某天碰巧與母隊同格」**？
   （★這正是修之前的病：舊行為就是碰巧同格才歸建。**修完如果故事還是「碰巧」，那數字好看也不算修好。**）
3. **在途那隻**：貨還在身上＝守恆沒破，但它的行為**像被困住，還是像正常在途**？

## ★別信我的框
**我自己的預測在這條 slice 上被實測推翻過一次**——我以為首要嫌疑是 `persist_strength` 的 time-proxy，
真根因是 `faction_ai:797-809` 的 merge_queue **繞過仲裁直接 `release()`**，承諾在被問之前就沒了。
**所以請照 trace 自己讀，不要沿用我的假設。**

**樣本小**（歸建者僅 2 隻）——請在判決裡標明信心。
