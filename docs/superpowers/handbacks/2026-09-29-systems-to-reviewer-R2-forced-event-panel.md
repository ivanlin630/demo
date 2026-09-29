---
from: systems
to: reviewer
status: open
slice: 強制事件面板＋生命週期（第二輪回饋 #7）
topic: ★R② 審設計。spec = docs/superpowers/specs/2026-09-29-forced-event-panel-and-lifecycle-HOW.md｜★★我核出一個【很可能的真因】（`propose_alliance` 不在 `_accept_diplomacy` 的 match 裡，而同一行註解顯示同一個 bug 修過 tribute 那一半）—— 請你打它；★★★而我【刻意不把它寫成已確認】，因為 blueprint 裁的是「先量後修」
---

# 一、主張

```
①面板缺的是【事件本身的人話】而不是選項：`_forced_label` 有人話，
  而 `player_api_mapper.gd:304` 把 `proposal` **原樣印**
②★`proposal` 的母體【不是封閉集】：兩個寫入者兩套詞彙
   ·diplomatic_ai_system:174 → {demand_tribute, propose_alliance, propose_trade}
   ·interaction_system:294   → npc.order_task（任意字串）／fallback "alliance"
③★★★很可能的真因：`_accept_diplomacy`（:1159）只認 alliance/surrender/tribute/demand_tribute
   ⇒ `propose_alliance` 落到 `return {ok:false, "未知提案類型：%s"}`
   ★而同一行註解寫著同一個 bug 修過一次（「原只認 tribute」）⇒ **修了一半**
④我加的第四個候選：**措辭撞車** —— 玩家看到的「被拒絕」可能是【佇列的拒絕句】
   （<動作>：被拒絕（原因）），而他讀成【外交事件被拒絕】
```

# ★★二、請你打這三處

```
(甲)★★★③那個推論。我讀的是 match 的字面與兩個寫入者的字面，
    ★而我【沒有跑】—— 若 `propose_alliance` 其實在別處被正規化過，整段作廢。
(乙)②的母體判斷：我說「不是封閉集」的依據是 `interaction_system:294` 傳 `npc.order_task`。
    ★請驗 `order_task` 的值域是不是其實有限 —— 若有限，那「未知 id」那一格的必要性會變低
    （★但我仍然主張留著：兩個寫入者就是兩套詞彙，這件事本身已經成立）。
(丙)★§4 P4 的形狀：我把它寫成【指認】而不是【通過】——
    床把四個候選各自的證據欄都印出來，由卷面挑。
    ⇒ 請判這是不是在逃避判斷（我認為不是：blueprint 明裁先量後修，而我核出來的那條
      正好是四個候選之一 ⇒ 我若寫進 spec 當結論，等於用我的靜態閱讀取代那支床）。
```

# 三、我自己知道的洞

```
・沒跑 Godot，全靜態。
・(d) 措辭撞車這個候選是我【從措辭推出來的】，不是從卷面——連它存在都還沒被證。
・P4 的母體地板我有寫（先斷言到達真的發生）；★但我沒有想出「逾時競態」的獨立製造法，
  床可能得靠 tick 序的 print 才分得出 (a)。
```

# 四、下一站

```
CLEAN ⇒ 我 dispatch 給 implementer（第二輪第一張）。
打回 ⇒ 我改 spec。
```
