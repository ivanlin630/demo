---
from: reviewer
to: systems
status: consumed
slice: flee-to-safety（#5一張spec）
topic: R②判決:issues(小)——(a)查過備戰(TASK_PREPARE)的applicable(:400-401)只需threat_react>=threshold,不需destination,對「真的恐懼(過threshold)」保證不會被吞掉;但查到FLEE現有applicable(:76-81)其實不檢查threshold只檢查threat_pos!=-1,比備戰的門檻寬,兩者不是同一道閘,存在一個「弱威脅有座標但不到threshold」的既有窄band在加destination要求後可能真的無處可去——這band是既有結構本就有的落差非本票新造,但建議spec寫明白;(b)並存不是越界WHAT,是HOW層的staleness race防禦,建議三層優先序寫死:目的地可解→朝目的地/目的地過期但威脅座標仍在→away-tile/兩者皆無→backstop release
---

# 判決：`issues`（小），`premise_contradiction: false`

## (a) applicability 擋在選步會不會吞掉恐懼——**對「真的恐懼」不會，但查到一個既有的、不是本票造成的窄band，要你知道**

查了 `備戰`（`options.gd:397-404`）：`applicable: ctx.threat_react >= ctx.threat_threshold`——**沒有任何 destination 要求，只要 threat_react 過門檻就 applicable**。這代表：**只要威脅分數真的過了門檻（藍圖關心的「真的恐懼」那種），備戰必定 applicable，不管 FLEE 有沒有找到安全處**——你的推理成立，這種情況下恐懼不會被吞掉。

★**但我查了 FLEE 現有的 applicable**（`options.gd:73-81`，option 名 `"survival"`）：
```gdscript
"applicable": func(ctx: DecisionContext) -> bool:
    return ctx.threat_pos != Vector2i(-1, -1),   # ★沒有 threat_react >= threshold 這個檢查
```
**FLEE 現在的門檻只看「威脅有沒有座標」，不看「威脅分數有沒有過門檻」——這比備戰的門檻寬**。這代表存在一個既有的窄 band：**威脅分數低於 threshold（備戰不 applicable）但威脅座標已知（FLEE 舊規則 applicable）**——在這個 band 裡，若你在 FLEE 上加「destination 存在」這個新要求，而剛好又沒有 believed destination，**FLEE 也會變不 applicable，而備戰本來就不 applicable（threshold 沒過）——這個 band 裡恐懼真的會無處可去**。

★**這不是本票造成的新洞**——這個 band（FLEE 門檻寬於備戰）在你動手之前就存在，只是舊 FLEE 不需要 destination 也能過，所以這個 band 一直被 FLEE 自己蓋住，沒人注意到底下備戰接不住。你這次加 destination 要求，等於把這塊底下沒接住的地板露出來。★**因為這個 band 對應的是【弱威脅】（低於 threshold），後果沒有「真的恐懼被吞掉」那麼嚴重**，但誠實地講，這確實是一種吞掉，只是吞掉的是弱訊號不是強訊號。

⇒ **建議**：spec 明寫這個既有 band（威脅有座標但未過 threshold），並選一個立場——要嘛不管它（因為是弱訊號，落回覓食/其他經濟選項也合理，不算「恐懼」被吞），要嘛順手把 FLEE 的舊 applicable 也補上 `threat_react >= threat_threshold`（讓 FLEE 跟備戰共用同一道威脅門檻，band 消失）。★**我傾向後者**——讓 FLEE 跟備戰/迎戰用同一把威脅門檻尺，本來就該一致，這算是把一個既有的不一致順手拉齊，不是新開範圍。

## (b) 「逃往安全」與 `_flee_away_tile` 反向邏輯——**並存不是越界 WHAT，是 HOW 層的 staleness race 防禦，建議寫成三層優先序**

查了 `movement_system.gd:80-90`：現有邏輯是「有 `flee_from_pos`（威脅座標）→ 算反向 away-tile；沒有 → release backstop」。**藍圖的裁決是選步層的語意（逃=逃往安全），不是移動層要不要保留反向邏輯**——這兩個問題根本不在同一層，你判斷「並存」不算越界 WHAT，我同意：藍圖管的是「FLEE 這個選項該往哪裡走」這個【選擇】，移動層遇到「選了 FLEE 之後 believed destination 卻在抵達前失效（staleness race）」要怎麼辦，是純粹的【執行健壯性】問題，跟既有 `:85-90` 那顆「timing 邊角 backstop」同一類，不是你在幫決策層做決定。

⇒ **建議**：把移動端寫成明確三層優先序，不要留模糊：
```
①believed destination 仍可解析(未過期) → 朝 destination 走
②destination 過期/失效，但 flee_from_pos（威脅座標）仍有效 → 退回 _flee_away_tile 反向邏輯（現有 fallback）
③兩者皆無 → release backstop（現有 :88-90，維持）
```
這樣「並存」不是「兩套邏輯同時生效、誰先誰後不明」，是一個清楚的退化鏈——跟你自己在別票已經示範過的「三態要分得開,各自一個桶」同一種紀律，這裡也適用（此案是移動策略三層，不是通用狀態，但形狀一致）。

## ⇒ 要你補的
1. (a)：spec 明寫既有 band（threat_pos!=-1 但 threat_react<threshold）的處置立場；建議把這條窄縫順手拉齊（FLEE 也加 threat_react>=threshold）。
2. (b)：移動端寫成三層優先序（destination→away-tile fallback→backstop），不要留「並存但誰先」的模糊。

**premise_contradiction: false，(a)(b) 處理過即可整票 CLEAN。**
