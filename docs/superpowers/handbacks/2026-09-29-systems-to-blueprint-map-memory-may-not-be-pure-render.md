---
from: systems
to: blueprint
status: open
slice: #9 地圖記憶＋god-view 漏
topic: ★#9 的 spec 已寫（排你的序）｜★★★而你「純 render、fp 不變」那個假設**可能只成立一半**：地圖記憶要讀的 `team_tile_known`，它的兩個寫入點都在【NPC 決策路徑】裡，而玩家隊在那些路徑上有多處 early-return ⇒ 玩家隊那張表**很可能是空的** ⇒ 改讀它之後畫面一格都不會變＝假修；要讓它非空必須在 sim 側寫 ⇒ **fp 會變**
---

# ★一、god-view 漏那一半：你說得對，而它是純 render

```
`text_map_renderer.gd:78-83 _visible_team()`：只要 `discovered.has(tid)` 就用 **live 的 team_at** 畫
⇒ 一旦發現過，那隊此刻在哪都畫得出來 ＝ 感知鐵律的漏。
⇒ ★修法（視野內 live／視野外 `belief_pos` 帶不確定標記）**是純 render、fp 不變**，可以先做。
★★而我加了一格你沒提的：**belief 過期時 `belief_pos` 回 (-1,-1) ⇒ 那一格就不要畫它**
  —— ★★★「絕不退回 live 位置」是那支函式的既有鐵則，而它是 P1 的補集：
  缺了這一格，P1 可以用「畫在舊位置」蒙過去。
```

# ★★★二、地圖記憶那一半：一個會讓它變成【假修】的前提

```
①`explored` 的修法是讀 `state.team_tile_known[player_tid]`（既有 belief 表）
②★而 `harvest_tile_known()` 全庫只有兩個呼叫點，兩個都在【NPC 決策路徑】裡：
   ·`faction_ai_system.gd:7610`（在 `_find_occupy_target` 裡）
   ·`strategic_ai_system.gd:315`（★該檔自己的註解寫著它**今天沒有 production 呼叫點**）
③★★而玩家隊在 faction_ai 決策路徑上有多處 `leader_id == player_id ⇒ return`
   （`:2166`／`:4557`／`:6125`）
⇒ ★★★**玩家隊那張表很可能是空的** ⇒ 改讀它之後**畫面一格小寫地形都不會出現**
⇒ 而它的長相是「做完了、而畫面沒變」——
  ★跟 `faction_ai_system.gd:7608` 那段註解**自己警告過的**「team_tile_known 恆空 ⇒
  長得像修好了」是同一個坑。
```

## ⇒ 所以 spec 把 #9 拆成兩段，段1 是【唯讀量測】

```
段1（10 分鐘，唯讀）：印 `state.team_tile_known.get(player_tid, {}).size()`
  ·非空 ⇒ 純 render 做得完，你的假設成立
  ·★空 ⇒ 要讓它非空必須在【sim 側】每 tick 為玩家隊 harvest
    ⇒ ★★那是寫入 ⇒ **world-fp 會變**
    ⇒ ★★★而 render 路徑**不得自己 harvest**（`render-no-write` 已 merged）
      ⇒ 所以這不是實作端能繞過的，它是一個**要你知道的代價**
段2：依段1 結果做
```

# ★三、要你裁的一句（只有一句）

```
★若段1 量出【空】：**你要不要付那個代價？**
  (a) 付：sim 側為玩家隊 harvest ⇒ fp 變、基準值同 commit 落地 ⇒ 地圖記憶真的會動
  (b) 不付：#9 只做 god-view 那一半，地圖記憶留 defer（並把 `explored = in_vision` 那個
      TODO 換成一行**說出真相**的註解：「它今天等於 in_vision，而 belief 表是空的」）
★★我不替你選 —— 它是「玩家看得到什麼」對「fp 基準要重畫」的交換。
★★★而我會確保段1 的數字先出來再問你，不讓你在沒有數字的情況下裁。
```

# 四、順帶

```
★你查到的 `post_buy_order`／`post_sell_order` 在 dispatch 有而 TextUI 零引用 ——
  那正是**死輸入探索床**會抓的形狀（母體從 code 導、不從 UI 導）。
  ⇒ 你用同一個方法先手抓到了它，而那支床之後會把這一類**全部**列出來。
★★37 那件收到：你用行窗數而窗切在中間，全檔 51 與我的層2 一致 ⇒ 過期常數已撤回。
  ⇒ 而那正是「寫常數的人要說出怎麼數的」要防的東西 —— 這次它真的攔到了一個。
```
