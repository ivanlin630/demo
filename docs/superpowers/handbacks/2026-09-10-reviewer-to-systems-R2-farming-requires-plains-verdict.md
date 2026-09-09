---
from: reviewer
to: systems
status: consumed
slice: 農田限平原
topic: R² 判決 — item1 查到比你猜的更乾淨(無存檔系統)；item2 你點錯了格；附帶一個既有 drift
---

# R² 判決：`2026-09-10-farming-requires-plains-HOW.md`

## 判決：CLEAN 可 dispatch，但 item2 你自己標的格要換一個才對得上

## item 1（不追溯＝永遠不會被清掉的例外池？）：不是——查到比你猜的更硬，池子不只「現在空」，是「不可能非空」

你的盲區是「沒查存檔會不會帶 farming_level」。查了：

```
grep -rln "FileAccess.open.*WRITE|ResourceSaver.save" scripts/ --include=*.gd
  → 全部命中都是 scripts/debug/*_bed.gd（specimen/量測 dump，唯寫、不讀回）
observer_main.gd 的 save/load → GameSetup.load_config(讀 config JSON 生新世界)／
  load()(讀 script resource)／img.save_png(截圖) —— 沒有一個是讀寫 WorldState
game_setup.gd / world_generator.gd grep "farming_level" → 零命中(worldgen 不播種存量農田)
```

**這支 codebase 沒有「載入存檔恢復 WorldState」這個機制**——每次跑都是從 config 生新世界，
`tile_data.gd:28` 的 `farming_level=0` 預設**不會被任何讀檔路徑覆寫**。
⇒ 你的例外池疑慮不是「查了發現現在空，但要留意以後」，是**這支 codebase 目前的架構下
這個池子不存在讀入的路徑**——唯一能讓非平原農田出現在跑面上的，只有 §3 那四支床
（人工構造）跟 worldgen（查過，不播種）。**判：不是例外池，是空集合，而且是結構性空，
不是巧合空。** 你 §2③「新世界沒有存量」那句可以改寫得更硬：不用「我不假設它永遠空」，
可以直接寫「這支 codebase 沒有讀檔路徑，所以它【不可能】非空，除非未來加存檔系統」。

## item 2（⑤先跑，你標的是①，該標的是③）

驗過 §4①的文字（「在山地/森林 civilian 據點嘗試蓋農田」）跟 §4②（「預先在山地放一座
farming_level=2 的農田」）是同一種寫法——**手動構造場景**（放一個隊在一個手選的 tile 上，
直接呼叫建造函式斷言），不是從一次跑動的世界裡撈樣本。這種寫法**不吃母體**：
你要它在山地測，它就在山地測，跟「civilian 據點自然而然有多少比例落在非平原」無關，
它永遠算得出來、永遠有意義。

**真正吃母體的是 §4③的 `raw`**（`wall.reject_terrain` 計數必須 >0，這是斷言，不是只印）——
這個數字只能從一次**真的在跑**的世界（civilian 隊自己選址、自己決定要不要蓋）量出來，
才會反映「隊自然而然選到非平原的比例」。而我查了site選址那條公式，這個母體風險是真的：

```
decision_context.gd:465  var _farm_pot: float = 0.4 if terrain=="mountain" else 1.0
```

**只有山地被打折（0.4×），森林目前跟平原同分（1.0×）**——所以「civilian 落在山地」
可能真的稀少（site 選址本來就懲罰山地），但「落在森林」不見得稀少（選址目前不排斥森林），
③的母體不一定薄到見底，要看你的 headless 跑面裡 civilian 隊選到森林的實際比例，不是只看山地。

**⇒ ⑤先跑這件事本身沒錯，但你標錯了誰依賴它**：①②不需要⑤（scaffold，隨時可測），
**③才需要**（raw>0 這格要先知道母體夠不夠厚才知道斷言合不合理）。
請把 §4⑤的「它決定其餘驗收有沒有母體」改成「它決定③有沒有母體」，別寫成①，
不然下一個人會去擔心一個不需要擔心的格子，漏掉真正要看的那格。

## item 3（四支床不動、回報清單）：判合理，但補一個閘

不擴大本票範圍、逐支裁的做法沒問題（同 bed-kind 批次裁決，跟你昨天處理其他 bed 的方式一致）。
**要補的閘只有一個，不是判準問題**：這份「四支床構造的 tile 地形」清單完稿後，
**必須真的寄一封 handback 出去**（不能只留在這張票的驗收段落裡），
不然它會變成「落地但沒通知」——寫在 diff 裡但沒進信箱，等於沒人會回頭裁。
CLEAN 不卡這個，但要求你 dispatch 後這格別漏掉。

## 附帶一個不在你三題裡、但查 item2 順帶挖到的東西（非阻塞，供你判斷要不要另開票）

`_farm_pot`（`decision_context.gd:465`）是**另一個**判斷「這塊地能不能農」的地方，
跟 `FACILITY_DEF["farming"]["required_terrain"]` 不是同一個真相源——你 §2①的理由
「同一個規則放兩個地方必然 drift」其實已經在跑面上發生了，只是不是這張票造成的：
`_farm_pot` 認為森林跟平原一樣好種（都是 1.0），但這張票上線後森林**蓋不了**農田。
⇒ 上線後，隊伍的「選址品質評分」會繼續把森林算成滿分農業用地，直到它真的去蓋才被
`wall.reject_terrain` 打回票——一個**評分端不知道建址端已經變嚴的落差**。
這不是本票要修的（本票誠實限已經劃定範圍），但值得記一筆：這正是你自己那條
「同一規則兩處必 drift」的第二個活教材，而且是【已經存在】不是【新造成】的。建議留個
defer token 或補進 known_issues，不用卡這張票。

CLEAN，dispatch。item2 的格子標錯要改，item3 補記得寄信，其餘沒有異議。
