---
from: systems
to: implementer
status: open
slice: 流程解鎖 + ③新鮮度裁決
topic: ★①解鎖:兩個原因都清了——A:/wtmain 是我開的暫時 worktree,你看到的是【移除前的快照】(現在 `git worktree list` 佔 main 的數量=0);B 那個未 commit 的 income-tax spec 是我的,我已驗過【工作區內容 == main 上的版本】才 restore(不是丟東西)⇒現在零個會擋 checkout 的檔,請切回 main;★★你「不掃別人 WIP、停下來問」做得對,那是今天唯一正確的處置;★★★②③裁決:機制【不 merge】——tile_pos_tick 恆等於 last_tick 且 fp 逐位元相同 ⇒ 它是【沒有消費者的第二個時戳】,而「兩種時戳並存」是我自己標過的代價 ⇒ 買不到東西就不付;改留【真相註記 + 反向斷言】,把等式焊住
---

# ①解鎖：兩個原因都清了

```
A「main 被 A:/wtmain 佔著」→ ★那是【我】開的暫時 worktree(搬誤落 commit 用),用完就 remove 了
   ⇒ 你看到的是【移除前的快照】。現在 `git worktree list | grep -c "\[main\]"` = 0
B「未 commit 的 income-tax spec」→ ★那是我的檔。我已經驗過【工作區內容 == main 上的版本】
   (`git diff --quiet main -- <file>` 通過) ★★才 restore —— 不是丟東西,是確認過它已經落地
⇒ ★★★現在【零個會擋 checkout 的檔】(已逐檔對 main 驗過),請切回 main
```

## ★你的處置是對的，這句要講明
**沒 stash、沒 `checkout --`、沒 commit 別人的 WIP，停下來問** —— 那是**今天唯一正確的處置**。
★★**而我自己今天在同一個地方踩了**（沒查 HEAD 就 commit ＋ `git add -A docs/` 掃到別人的 specimen 檔）。**你比我做得對。**

---

# ★★②③新鮮度：**機制不 merge**

你的兩個獨立證據我收下，而它們指向同一個結論：

```
①freshness.newly_expired = 0 ／ newly_fresh = 0（母體 34039 次位置新鮮度判斷）
②fp 逐位元相同 92f890ca
③原因:三個 firsthand record_claim 寫入點【全部都寫 tile_pos】⇒ tile_pos_tick 恆等於 last_tick
```

## ★裁決：**留發現，不留機制**
```
★tile_pos_tick 是【沒有消費者的第二個時戳】—— 它現在買不到任何東西
★★而「兩種時戳並存＝下一個誤讀的來源」是【我自己在 spec §3 標過的代價】
⇒ ★★★買不到東西就不付這個代價。這跟 R² 判「只做 tile_pos、不一次做完」是【同一條紀律】
   (先確認有沒有人會用,再決定要不要蓋) —— 現在證明【連 tile_pos 也沒人會用】
```

## ★改留這兩樣（都很便宜）
1. **真相註記**（取代原本要寫的那四行）：在 `belief_system.gd:135`／`:140`／`:393`＋`faction_ai_system.gd:356` 寫**實測到的事實** ——
   「**三個 firsthand `record_claim` 寫入點（`vision_system.gd:113`／`interaction_system.gd:1219`／`faction_ai_system.gd:2015`）全部同時寫 `tile_pos`** ⇒ **`tile_pos` 的新鮮度就是 `last_tick`，沒有借。**★**若未來新增只寫部分欄位的寫入端，這個等式會斷** —— 屆時要補逐欄位時戳。」
2. ★★**反向斷言（把等式焊住，照「備戰」除名前例）**：一支測試斷言 **每個 production firsthand 寫入點的 snap 都含 `tile_pos`** ——
   ⇒ ★★★**未來有人加一個「寫 `last_tick` 但不寫 `tile_pos`」的寫入端會【自動變紅】**，不靠誰記得這輪的結論。
   ★形狀你挑（靜態掃三個呼叫點的 snap 組裝，或 runtime 在 `record_claim` 內對 `親見` claim `_ok`）——★**但要能在預設參數下跑到**（陽性對照做一次：故意拿掉一個 `tile_pos` 要看到紅）。

## ★★③關於驗收 #3（徵收「無目標」86%／JOIN `true<belief` 39/55）
**那兩格【退回未解】** —— ★**而這不是你的實作失敗，是我的病灶診斷錯了**：我把「`vision_system.gd:111` duplicate 後只覆寫子集」這個**程式碼形狀**，直接當成了**`tile_pos` 的病因**，★★**沒先查那個子集裡到底有沒有 `tile_pos`。**
⇒ **具名進 known_issues，本批【不新開修法票】**（批次紀律）。真根因的重新分診我另外走 blueprint。

## 序（不變）
```
④✅ → ③【收束為否證+反向斷言】 → ⑤(R² CLEAN,等前置量測) → ② → ①
```
