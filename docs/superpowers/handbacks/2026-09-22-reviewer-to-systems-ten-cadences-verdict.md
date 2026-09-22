---
from: reviewer
to: systems
status: open
slice: 10 處 cadence 改走 CadenceStagger（世界改變窗 #3）
topic: verdict=clean（附一項已解決＋一項非阻塞加碼建議＋一項認可）｜②tile_id穩定性★已核實解決——world_generator.gd:69-72純座標推導,誠實限可撤;①20%門檻均勻性前提建議加一支便宜的獨立單元檢查(不要求,可先放行);③A5不設門檻理由紮實,認可
---

# 先核事實

```
CadenceStagger.next_tick()／_mix() 逐行讀過(cadence_stagger.gd全檔)：純整數算術零RNG,
  offset=_mix(team_id,cycle_index)%cadence，跟§1描述一致。
§2 十處抽驗5處(faction_ai_system.gd:630/4379、labor_system.gd:162、
  decision_context.gd:614、goal_resolver.gd:28)全部逐字match「current_tick + CADENCE」型式 ✅
```

# ②tile_id 穩定性——★不是「可接受但未驗」,是【已驗,穩定,問題不存在】

```
scripts/simulation/world_generator.gd:69-72：
  var ox: int = qx + radius
  var oy: int = oy = ry + radius
  tile.tile_id = ox * 1000 + oy   ← ★純座標推導,不吃RNG
  state.world.tiles[tile.tile_id] = tile
```
`tile_id` 是**座標的確定性函式**（跟 `tile_pos.x*1000+tile_pos.y` 同一種編碼,這個 repo 到處在用），
不是序列計數器也不吃亂數 ⇒ **同一座標,任何 seed、任何一次重生成,tile_id 永遠算出同一個值**。
⇒ ★這比「同一次跑穩定」更強——它**跨 seed 都穩定**。你 §6③ 的誠實限可以整條刪掉，
不是降級成「可接受」，是**這個前提原本就不成立的疑慮本身消失了**。

# ①A2 的 20% 門檻——寬鬆margin的推理對,但建議加一支便宜的直接檢查堵住那個「未驗前提」

```
你的邏輯：期望值~2%,20%門檻留了10倍margin,「均勻」就算不完美也大機率過得了門檻——這個防禦本身站得住。
★★但這個防禦是【間接的】：要等一整輪sim(8天窗/2 seed)跑完才知道_mix實際分佈好不好。
```
**建議**：加一支不依賴完整 sim 的**獨立單元檢查**（成本極低,幾秒鐘）——
直接呼 `CadenceStagger._mix(team_id, cycle_index) % cadence`，對一段合理範圍的 `team_id`
（例如 1~200，涵蓋這個世界規模常見隊數上限）× 幾個 `cycle_index` 值，統計每個 bucket 落點數，
斷言**最大 bucket 佔比不超過某個倍數的均勻期望值**（例如 <3×，比 A2 的 10× margin 更緊，
因為這裡是直接測分佈，不是測整個 sim 的下游後果）。
⇒ 好處：①它比 A2 更快抓到（不用等完整量測跑完）②它把「均勻」從**推論**（A2 過了⇒大概率均勻）
變成**直接量到的事實**，跟你自己在 §四／§8.1 那次「靜態讀不出哪條路會走到」同一個教訓
——這裡對應的是「讀了註解說會打散,不代表真的均勻」。
不是要你重挖 A2，是**多加一格，用更便宜更直接的方式驗同一件事，A2 留著當 sim 層級的交叉驗**。

# ③A5 不設門檻——認可,理由紮實

```
「11+桶77.4%/82.6%未凍結」＝必要非充分,是你自己的量測結果不是推論。
在這個前提下設一個freeze-drop的門檻，門檻本身才是真正的推論偽裝成預註冊——你自己講的
「設一個我推出來的門檻會把推論偽裝成預註冊」完全命中，不用改。
```
不擋這格，只補一句非阻塞建議：§6①已經誠實標「不保證凍結消失」，若這輪落地後 A5 的數字
沒有讓凍結顯著下降，交件信除了報數字，順手寫一句「下一步該去查那 77.4%/82.6% 未凍結的子集跟
已凍結的子集有什麼系統性差異」——讓這格觀察不是終點，是留一個乾淨的下一步問題（不強制，
你們的節奏我不裁）。

# 其餘（§3/§5）——沒有異議

```
零新旋鈕/tile_id不手抄座標拼裝/§5禁閘+陽性對照(修法前10處必須紅)——都對。
「這個病躲過兩輪靜態掃,只能靠機械」呼應了本輪同族的兩次教訓（TPD-alias／Probe.enabled閘控），
機械閘是對的方向,不需要我再打。
```

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "②是真發現(誠實限③可撤——world_generator.gd:69-72,76核實tile_id=ox*1000+oy純座標推導,跨seed/跨重生成永遠穩定，不只是降級成可接受)，順手改掉即可，不必回審。①是非阻塞加碼建議(加一支便宜的獨立單元檢查直接驗_mix分佈，比等sim跑完更快更直接)，採不採不擋放行。③A5不設門檻認可，理由跟本票自己的誠實限一致。§2/§3/§5抽驗核對無誤，設計方向對。放行，implementer可解hold。" }
```
