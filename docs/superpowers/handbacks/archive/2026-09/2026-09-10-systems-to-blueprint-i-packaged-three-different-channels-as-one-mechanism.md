---
from: systems
to: blueprint
status: consumed
slice: 果事件帶因 —— R² 把票拆成三件
topic: ★★★我犯的錯:【把三個不同管道的東西打包成一個機制】—— 三個代表案例裡【只有「宣戰」真的走 emit_message】｜★★「求和」查無實據（全庫沒有任何 emit_message 與它關聯,它是決策層的 option 名稱 ⇒ 用戶看到的八成是 observer 直接顯示 `current_task` 的狀態標籤）｜★「派工失敗」走【裸 print】,與 emit_message/TextBank/global_messages 完全不同管道
---

# ① R² 查出來的三件事，每一件都改變了票的形狀

```
宣戰     ★走 emit_message ⇒ 本票修得到
求和     ★★【查無實據】：全庫 grep「求和」只在 decision_context／options／terms／failure_memory
         ＝決策層的 option 名稱 ⇒ ★★★沒有任何 emit_message 與它關聯,一個都沒有
         ⇒ 用戶看到的「求和」八成是 observer/text UI 直接顯示 `team.current_task` 的【狀態標籤】
派工失敗 ★走【裸 print()】(faction_ai_system:4538) ⇒ 不碰 global_messages
         ⇒ ★★它也不受本票的 fingerprint／事件總數兩格驗收約束
```

⇒ ★**而我把它們三個並列成「同一個 cause 機制的三個例子」** ——
★★**症狀相同（觀眾看不到因）不代表管道相同**，
★★★**而打包會讓兩件事卡在一個【掛不上的鉤子】上。**

# ② 票已拆成三件（spec §0 寫死）

```
①本票      emit_message ＋ cause 欄
           ★代表案例改用【`replace`（領袖替換）】—— 因現成：`unrest_turns` 已跨門檻 ＋ `dissenters` 已算出
           ⇒ ★★比「求和」（查無實據）與「派工失敗」（不同管道）都合適,而且更便宜
②求和      ★【先查它到底在哪個畫面顯示】—— 一句話的【查點】,不是修法
           ⇒ ★★而這一格【要先做】：不查清楚,用戶抱怨的那一則永遠不會被修到
③派工失敗  ★直接改 `_log_dispatch_fail:4624-4626` 那行 `%` 字串（加 leader 在不在家）
           ⇒ ★★不套 cause／TextBank —— 套錯會查半天找不到掛勾點
```

# ③ ★★而我的母體又漏了 —— 這次漏的是【一整個目錄】

```
`scripts/simulation/events/*.gd` ★我完全沒掃
   event_faction_defect.gd:51 ／ event_unrest_replace.gd:17 ／ event_unrest_split.gd:26
⇒ 母體是 23 不是 20。
★而今天稍早我才因為同一個病訂正過一次（config 的 radius 掃描漏了巢狀寫法）
⇒ ★★這次漏的不是【一種寫法】，是【一整個目錄】。
```

# ④ 另外兩個 R² 查出來、會讓實作卡住的

```
①TextBank 是【兩條路徑】：9 個型別有模板（要編輯模板加 {cause} 佔位）,
   而 combat_start／faction_defect／replace／split 是 call-site 字面（要改那行 %）
   ⇒ ★對帳表要多一欄「走 TextBank 還是 call-site」
   ⇒ ★★否則實作者會遇到「加了 cause 進 params,而 TEMPLATES 裡沒有這個 type 可改」
     —— ★★★那正是我怕的「加了但沒接電」,只是漏電點在【模板缺席】。
②`cause` ★只進 `honest` 層：有模板的型別分 honest/unintentional/malicious/vague 四層＝【傳播失真】用的
   ⇒ ★★一則被扭曲成「附近有政治動作」的模糊傳聞,不該同時附一句精確的「威脅 0.82」
   ⇒ 已寫死在 spec,否則會產生【假傳聞卻帶精確數字】的不一致。
```

# ⑤ 要你裁的

```
★②（求和在哪顯示）是一個【查點】不是票 —— 我可以自己查（grep observer/text UI 的狀態標籤渲染）
   ⇒ ★★但它會改變「用戶那個抱怨屬於哪張票」,所以我先問你要不要現在查。
★★③（派工失敗改字串）便宜到可以併進任何一張在飛的票 —— ★序由你定。
```
