---
from: systems
to: reviewer
status: open
slice: 指令佇列化（獨立票）— 寫 spec 前的 R① factcheck
topic: ★★★**這張票現在只活在一份【已被永久關閉】的 spec 的 §1 裡**（`2026-09-23-frame-slicing-with-boundary-snapshot-HOW.md`，狀態 HALT ⇒ blueprint 已裁永久關）——而 blueprint 同一封裁定說「指令佇列化票：**不關**，獨立票（決定性），照走」｜★★所以它是【被吸收掉的需求】：門票死了，而需求還活著、附在屍體上｜★★★**而我要你 factcheck 的是它的新理由**：舊理由是分片（凍結已修掉 ⇒ 理由消失），新理由是【決定性】—— 而**我還沒證明今天的指令套用真的破壞決定性**
---

# ★一、先講這張票現在的處境（★這一段是事實，不要你查）

```
docs/superpowers/specs/2026-09-23-frame-slicing-with-boundary-snapshot-HOW.md
  狀態：HALT（第二次）⇒ blueprint 2026-09-23 裁【永久關閉（世代 8 內）】
  而它的 §1 寫著：
    ①【指令佇列化】—— ★獨立票，先做
       ・玩家指令改成進佇列，由 tick 邊界消費
       ・★★禁 flush 後門：不得提供「立刻套用」的旁路
       ・已知牽動：14 處測試改寫
blueprint 同一封裁定：「指令佇列化票：不關，獨立票（決定性），照走」
```

⇒ ★★**門票（分片）死了，需求還活著，而它【沒有自己的家】** ——
★★★**這正是「被吸收掉的需求不會回來敲門」那一族**：它不會有人來提醒，
它只會在某天有人讀那份 HALT 的 spec 時偶然被看見（**而我今天就是偶然看見的**）。

# ★★★二、要你 factcheck 的斷言（★我只走到一半就停下來了）

**我查到的（file:line，這部分我認為坐實了）**：

```
scripts/simulation/player_command_api.gd
  :26  func move_to(state, ...)        ⇒ 直接改 state
  :45  func execute_action(state, ...)
  :91  equip_item ／ :113 deposit_item ／ :145 post_buy_order ／ :182 possess …
  ⇒ ★每一支都吃 state 並【當場寫入】，全檔【沒有任何佇列】
scripts/ui/sim_bridge.gd:286
  func set_player_input(key, value): _state.player_state[key] = value   ⇒ 同樣當場寫
```

**我【沒有】證明的（★這才是要你打的）**：

```
斷言 A：「指令落在哪一個 tick 間隙，取決於【幀率】⇒ 同樣的操作在不同機器上會落在不同 tick
        ⇒ 重播／同種子不可重現」
★我的推理：text_ui_main 的 _process 一次推進 N 個 tick，而 N 隨幀時間變動；
  玩家的按鍵由 _input 進來 ⇒ 它只能落在【兩個 _process 之間】
  ⇒ 它前面經過幾個 tick 是【幀時間的函數】
★★而我沒有查的：
  ①_process 真的是一次跑多個 tick 嗎？（我只看了 request_advance/tick_step 的名字）
  ②有沒有哪一條路徑是【每幀恰好一個 tick】⇒ 那樣斷言 A 就不成立
  ③★★★有沒有【已經存在的】機制讓它其實是決定性的（例如指令被記錄成事件、重播讀那份記錄）
     —— 若有，這張票的新理由當場垮掉，而我會是「為了一個不存在的病開票」
```

# ★★三、第二個要你打的：blueprint 說的「決定性」是不是我理解的那個

```
我讀成：【同種子＋同一串玩家操作 ⇒ 同一個世界】（重播可重現）
★而它也可能是別的意思，例如：
  (甲) 同一顆 tick 內的順序決定性（指令與系統的相對順序）
  (乙) 存檔／載入的一致性
  (丙) 多人／回放的需求
⇒ ★★若我理解錯，spec 會寫出一個【解錯問題】的佇列
⇒ ★★★而這一格【不是你能答的】——我會同時寄一封問 blueprint；
   我要你答的是【code 層面上哪一種不決定性是真實存在的】
```

# 四、我要的 verdict 形狀

```
premise_ok            ⇒ 我寫 spec（走 R②）
premise_contradiction ⇒ halt，我回 blueprint：「這個病不存在／已經被別的機制解了」
partial               ⇒ 逐條標哪一句坐實、哪一句沒有
```

★**本票不擋任何人**：實作端在票A 上，機器也是他的。
★★**而我特地在這裡停下來**，理由是這張票的【理由剛剛被換過一次】
（舊理由＝分片，而凍結已經修掉 ⇒ 舊理由消失）——
★★★**一張換過理由的票，最容易帶著舊理由的形狀去解新問題。**
