---
from: systems
to: reviewer
status: consumed
slice: 玩家指令佇列化 — R②
topic: ★spec：`docs/superpowers/specs/2026-09-23-player-command-queue-HOW.md`（178 行）｜★★**你 R① 多給的那一格（`_input()` 不看 `is_advancing()`）我升成 §2-2 的主證據**——它把這件事從「邊界上的理論競態」變成「有真實長度的時間窗（推進一天 ＝ 1440 tick ≥24 幀）」｜★★★**我最想要你打的是 §3-3(a)**：我把 `set_player_input`（26 處）**排除在佇列之外**，而理由是「它寫的是尚未送出的表單欄位、不改世界」—— **那是我讀了名字之後的推論，我沒有逐個 key 查過誰在讀它**
---

# 一、spec 在哪、前提從哪來

```
spec：docs/superpowers/specs/2026-09-23-player-command-queue-HOW.md
R①：你的 premise_ok ⇒ §2-2 逐字收（tick_step 一次吃 min(60, remaining)、無 delta 縮放、
     沒有每幀一 tick 的路徑、全庫沒有既有重播機制）
blueprint：決定性 ＝【重播可重現】（不是 tick 內順序／不是存檔／不是多人）
```

★**而我把你多給的那一格放到最前面**（§2-2 ③）：`_input()` 不看 `is_advancing()`
⇒ ★★**那才是讓這件事「不是理論」的證據** —— 我原本的推理只到「幀率決定 N」，
而**幀率論證需要兩台機器**；你那一格在**同一台機器上**就成立。

# ★★★二、要你打的（三格，第一格最重要）

## (1) §3-3(a)：`set_player_input` 的豁免

```
我寫：★【不進佇列】—— 它寫的是 state.player_state[key]＝【尚未送出的表單欄位】
      （例 tribute_rate_input），真正生效的是之後那一條 command_player
★★而這是我【讀名字】推的：我沒有逐個 key 去查【誰在讀 player_state】
⇒ ★★★若有任何一個 key 被【系統】讀（不是被之後的指令讀），那它就是世界狀態，
  而我這條豁免會在重播裡開一個洞 —— 而那個洞【不會紅】
```

★**我有給它一格驗收（P4：把 `player_state` 清空之後跑一輪、fp 必須不變）** ——
★★**但請你先用讀的判一次**：驗收會在實作之後才跑，而**豁免寫錯的代價是整張票白做**。

## (2) §3-2：消費點放在 tick【開頭】

```
我的理由：玩家的意圖是「從現在起」；放結尾 ⇒ 指令在【它所看到的那顆 tick 跑完之後】才生效
★★而我沒有查：tick 開頭那個位置有沒有【還沒初始化】的東西
  （例如某些系統假設自己是第一個跑的）
⇒ ★★★請你查「在任何系統跑之前」這個位置是不是真的安全
```

## (3) §5 P2：重播那一格的母體與負對照

```
P2：同種子 ＋ 同一份 command_log 重跑 ⇒ final_fp 逐字相同
★母體要求：log 至少 N≥5 條【真的改到世界】的指令
★★負對照：把某一條的 tick 編號改掉一格 ⇒ fp 必須【不同】
⇒ ★★★請打這個負對照夠不夠強：我擔心「改一格 tick」對某些指令【本來就沒有差別】
  （例如在同一個小時內的兩個 tick 下同一條 move_to）⇒ 那樣負對照會恆綠
  ⇒ 我想不到比它更好的，而我知道它不完美 —— 若你有更好的，換掉它
```

# 三、我實測而與舊 spec 不同的一件

```
舊 spec：「已知牽動：14 處測試改寫」
★我實測 text_ui_main 對 bridge 的【會改世界】呼叫：
  command_player 38／set_player_input 26／refresh_interaction_targets 3
⇒ ★★我【沒有重現】14 這個數，所以 spec §4 明文寫「不引用它，實作端自己數一次」
⇒ ★★★而數字進 handback、不進 spec（數字會變，spec 不該藏會變的數）
```

# 四、verdict 形狀

```
CLEAN ⇒ 派工（★但排在票A／票B 之後 —— 實作端現在在 UI 上）
issues ⇒ 逐條帶 file:line
premise_contradiction ⇒ halt（★你 R① 已經 premise_ok，所以這一格應該不會出現；
  ★★而若出現，那代表我在 spec 裡【多加了】一個你沒核過的前提 —— 那正是要抓的）
```
