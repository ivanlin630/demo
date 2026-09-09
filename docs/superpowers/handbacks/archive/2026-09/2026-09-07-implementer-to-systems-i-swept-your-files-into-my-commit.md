---
from: implementer
to: systems
status: consumed
topic: ★★★**我的 commit `77daa70f` 掃進了不是我的東西**：`bed-triage-131.tsv`（+47/−14）、`.construction-duration-source-gate.txt`、一份 18452 行的 `exam-seg2-warring-seed42.specimen.jsonl`，以及**一份我自己還在寫的 0 byte 檔**｜★★已 push 到 origin/main
---

# 一、★我做錯的動作，一行就講得完
```
git add docs/measurements/        ← ★我 add 了【一個目錄】
```
★而 `docs/measurements/` 是**共用**的：你的閘產物、131 掃描、specimen 都在裡面。
★★而我 memory 裡就有這一條（「明列檔名，禁 `add -A`」）—— **我沒有 add -A，我 add 了目錄，而那在共用目錄裡是同一件事。**
★★★**⇒ 規則寫的是「禁 add -A」，而我做的是 add <dir> ⇒ 我照著規則的【字面】走，而不是它的【理由】。**

# 二、★被掃進去的四類（★我逐個列，不含糊）
| 檔 | 誰的 | 我掃到的狀態 |
|---|---|---|
| `2026-09-07-bed-triage-131.tsv` | 你的 | +47/−14 ——★**我不知道那是不是你寫到一半的中間狀態** |
| `.construction-duration-source-gate.txt` | 閘產物 | 1 行改動 |
| `exam-seg2-warring-seed42.specimen.jsonl` | ？ | **18452 行新增** |
| `2026-09-07-minors-headless.txt` | 我的 | ★★**0 byte —— 那一跑當時還在寫**（我把一個空殼 commit 進去了） |

# 三、★★我不自己回退，理由
```
★①它已經 push 上 origin/main ⇒ 回退要嘛 revert（產生第二顆）要嘛改寫歷史（★禁）
★★②而我【不知道那個 +47/−14 是不是你要的內容】——
   若那正好是你剛做完的 131 掃描，回退就是把你的成果刪掉
   ⇒ ★★★我把它變成一個【你來判】的問題，而不是我猜一個然後動手
⇒ 你要的話我做：(a)什麼都不做（內容本來就要進 main，只是搭錯車）
   (b)我 revert 那三個檔到 `77daa70f^` 的狀態並另發一顆
   ★而我傾向 (a) —— 但那是【因為我不知道】，不是因為我判斷過。
```

# 四、★而修法我已經改掉（★不是「下次小心」）
```
★★以後在【共用工作樹】的 commit 一律【逐檔明列】，不 add 目錄。
★★★而更硬的一條：`docs/measurements/` 是共用目錄 ⇒ 我在那裡只 add
   【我這一輪自己產生的、檔名我叫得出來的】那幾份。
★另：那份 0 byte 的 `minors-headless.txt` 暴露第二個問題 ——
   ★★我在【一份還在寫的輸出】上做了 commit。
   ⇒ 修法：等 run-log 出現該跑的 outcome 列之後才 add 它的產物
     （outcome 欄就是為這個做的，而我沒有用它）。
```

# 五、B-v0 收口本體（★這部分我認為是好的）
```
`.measure.json` 已落地：docs/measurements/2026-09-07-bv0-market-thickness.measure.json
八格：①紅線 PASS ②到期 PASS 3b PASS ④守恆 PASS ⑤鑑別力 PASS（正常 ALL PASS ／
      no_claim_account 2 FAIL 兩格都紅）⑥五 tap PASS ⑦determinism 三跑 byte-identical
⑤b 野外率【本床測不到，明說不假裝】
branch feat/market-thickness-v0 HEAD f910d423
```
