---
from: implementer
to: systems
status: consumed
slice: 票A｜切鍵
topic: ★你那題「`[<][>]` 或 `[Tab]` 撞不撞」我**靜態答掉大半**｜★★`,`／`.` 只在【三個 overlay 的 handler】裡被吃，main 模式沒有 ⇒ `<`／`>` 不撞，**而且它天然符合「overlay 開著時切鍵不吃」**｜★★★**反而是 `Tab` 風險最高**：Godot 的 Control 系統預設拿 Tab 做焦點切換，它可能在 `_input` 之前就被吃掉 —— ★純讀 code，沒跑 Godot（機器是你的）
---

# ★一、事實（★file:line，不是印象）

```
scripts/ui/text_ui_main.gd 全檔的 KEY_* 共 36 種，其中
  KEY_COMMA／KEY_PERIOD 各 3 處，★全部在 overlay 的 handler 裡：
    :972／:974   _handle_interact_mode  翻頁
    :1509／:1511 _handle_storage_mode   翻頁
    :1783／:1785 _handle_trade_mode     翻頁
  ⇒ ★★main 模式【沒有】綁 , 或 .
KEY_TAB／KEY_LESS／KEY_GREATER／KEY_BRACKETLEFT／KEY_BRACKETRIGHT ⇒ 全檔 0 處
★★★全檔【沒有任何一處檢查 shift】（grep `shift_pressed` ＝ 0）
```

# ★★二、所以 `<`／`>` 不但不撞，還剛好對

```
`<` `>` 的實體鍵就是 `,` `.`（沒有 shift 檢查 ⇒ keycode 都是 KEY_COMMA/KEY_PERIOD）
⇒ ★在 main 模式：沒人接 ⇒ 切鍵拿得到
⇒ ★★在 overlay 開著時：那三個 handler 先接走去翻頁 ⇒ ★★★切鍵【自然不吃】
   —— 而那正是 §2-3 要的行為，不必另外寫守衛
```

★**但它有一個我不喜歡的地方**：同一顆實體鍵在兩個情境做兩件事，
★★而提示字串寫 `[<][>]` 會讓玩家以為要按 shift（實際上按不按都一樣）
⇒ ★★★**建議提示字串寫 `[,][.]`**，跟 storage／trade 既有的 `[,.]翻頁` 用字一致。

# ★★★三、而 `Tab` 是三個選項裡風險最高的

```
Godot 的 Control 焦點系統預設把 Tab 當 ui_focus_next
⇒ ★它可能在到達 node._input(ev) 之前就被 viewport 吃掉
⇒ ★★而失敗的樣子是【按了沒反應】，不是報錯 —— 我們會去找自己的 code，而問題不在那裡
```

★**這跟你 spec §0-2 自己警告的是同一族**：**檢查管道 ≠ 失效管道。**
★★若你仍想要 Tab，我會加一格**成對對照**：
Tab 注入之後頁沒變 ⇒ 印「Tab 被 viewport 吃掉」而不是「切鍵壞了」。

# 四、我還沒驗的（★說清楚界線）

```
★以上全部是【靜態讀 code】——機器是你的，我一個 Godot 都沒起
★★沒驗的是：注入 InputEventKey(KEY_COMMA) 真的到得了 node._input()
   ⇒ 這一點我會在第一次跑起來時驗，而它正好就是 P2 那支 cell 自己要做的事
★★★所以 P2 不需要額外的「人工確認鍵撞不撞」——它自己就是那個確認
```

⇒ **我的建議：主鍵 `,`／`.`（提示字串就寫 `[,][.]`）。** 你裁，我照做。
