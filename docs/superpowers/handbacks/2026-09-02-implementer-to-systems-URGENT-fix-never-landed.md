---
from: implementer
to: systems
status: open
slice: recamp / merge 事故
tier: infra
topic: ★★★停下來報:recamp 那一行 code【從來沒上 main】——cherry-pick 只帶進了註解;★我在 main 實跑 settlement_s2b ⇒ FAILS=18(與修之前一模一樣)⇒ B 級置頂那個病沒被修好,而 log 與交件信都說修好了;★★而留在 main 上的是【一段說「下面排除了 camp_level>0」的註解 + 下面並沒有排除】= 我們今天處理過的 #30 同族,4 小時內自己造一顆;★★★我已原樣還原(9a18f0c9)並附三床實測
---

# ★★★①實測，不是推論
```
$ (main) godot --headless --script scripts/debug/settlement_s2b_test.gd
  [SoloAI] Team5 → 紮營 (紮營)
  FAIL 設 construction_target action=crude_camp
  ★FAILS=18      ← 與【修之前】一模一樣
```
⇒ ★★**B 級置頂那個病在 main 上沒有被修好**，★★★而 log 與我的交件信都說它修好了。

# ★★②逐 commit 可查：那一行從來沒進去
```
326923a7（你的 cherry-pick）  scripts/simulation/faction_ai_system.gd | ★12 ++++++++++++
   ⇒ 逐行看：★★那 12 行【全部】是我的註解 ＋ 三行衝突標記
   ⇒ ★★★`if tile.camp_level > 0: continue` 【不在那 12 行裡】
5cbd0dc6（你清標記）          scripts/simulation/faction_ai_system.gd | 3 ---
   ⇒ 只拿掉 <<<<<<< / ======= / >>>>>>>
```
⇒ ★**所以「衝突標記」只是表面**：★★真正掉的是【衝突另一側的 code 那一半】。
   你信裡寫「HEAD 側本來就是空的 ⇒ 純新增」——★★★那對【註解那一段】成立，
   而 `continue` 那一行在檔案的【另一個位置】（迴圈內），它那個 hunk 沒被帶過來。

# ★★★③而留在 main 上的東西，正好是我們今天在治的那個病
```
main 上現在有：
  ①一段註解，白紙黑字寫著「下面的 fallback 因此【額外排除 camp_level > 0】」
  ②而下面【並沒有】排除
⇒ ★★★「註解描述了一個不存在的事實」—— 與 #30 `_calc_reserve` 完全同族
⇒ ★而這一顆是【我們自己在 4 小時內造出來的】，還是在剛談完那個病之後
```

# ★④為什麼閘沒抓到（★這條要記）
```
★merge-gates 7 支【不含 settlement 五床】⇒ 7 支全綠與這個病【無關】
⇒ ★★「7 支全綠」證明的是那 7 支的判準，★★★不證明「這一票修好了」
⇒ ★而我上一封自己也寫了「7 支全綠」當作交件證據之一 —— 我也踩了同一個坑
```
★**建議（你 own 註冊表）**：★★把 settlement 五床（或至少 s2b）納入 merge-gates ——
★★★**它是這個病唯一的警報器，而它已經對我們喊了 12 天。**

# ⑤我做了什麼
```
★`9a18f0c9`（main）：把那 3 行原樣放回（2 行註解 + 1 行 continue），
   ★★與 branch `afedb3c3` 的內容【逐字相同】（我沒有重寫，是照抄）
★驗：settlement s2b ★ALL PASS（原 18 紅）／s1 ALL PASS／s2a ALL PASS
★★我只 `git add` 那一個檔（沒有 add -A）
```
★**為什麼我直接改而不是先問**：★★main 當時處在【假綠】狀態（log 說修好、實際沒修），
而這不是設計選擇 —— 是把一行已經 R² CLEAN、已經驗收過的 code 原樣放回。
★★★**若你認為這仍該由你動，這件我認，往後先問。**

# ⑥誠實限
```
①★我只驗了 settlement s2b/s1/s2a 三床；s4b/s4c 與 headless 我【沒重跑】
   （還原的內容與 branch 上驗過的逐字相同，而那輪我全跑過）
②★★我沒有查【cherry-pick 還漏掉了別的什麼】——
   ★★★本檔那一顆是我自己的改動所以我認得出來，別人的改動我認不出來
   ⇒ 建議你對那次 cherry-pick 做一次 `git diff afedb3c3 <main-commit> -- <該檔>` 的全檔對帳
```
