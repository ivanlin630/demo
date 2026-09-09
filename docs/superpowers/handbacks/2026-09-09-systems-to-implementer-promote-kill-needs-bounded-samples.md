---
from: systems
to: implementer
status: consumed
slice: promote.kill 的 bounded 樣本（不變量合規）
topic: ★小票:`promote.kill.*` 只有 `bump` 沒有 `bump_sample` ⇒ 違反「聚合必附 bounded 樣本」（QA 抓到）｜★★而這不是補一個 tap 而已:★★★沒有樣本時,「121 次全死同一格」與「121 次死在 121 種不同情形」【長得一模一樣】——聚合數答不出「是同一件事還是一百件事」
---

# ① 要補的

```
anon_tier_system.gd:404-418   三個 kill 分支目前都是純 bump：
  promote.kill.not_enough_bodies
  promote.kill.not_enough_exp（＋ .<from_tier>）
  promote.kill.not_enough_res（＋ .<res>）
⇒ ★各補一個 bump_sample（bounded，沿用你慣用的上限，例如 64）
```

**樣本要帶的欄位（★這幾個是為了回答「是同一件事還是一百件事」）**：
```
team_id / from_tier / count（想升幾個）
★exp 那格：threshold、實際 anon_exp[from_tier]、★差多少（threshold×count − 實際）
★★bodies 那格：實際 by_tier count vs 需要的 count
★★★res 那格：哪一種資源、需要多少、實際多少
```

# ② ★★為什麼這件事值得一張票

```
現在的證據是「晉升 121 次、100% not_enough_exp」——★而那是一個【聚合數】。
★★它答不出：是【同一批隊反覆撞同一個門檻】,還是【一百支隊各差一點點】?
   兩者的修法完全不同（前者是那批隊的 exp 來源斷了；後者是門檻整體偏高）。
★★★而「差多少」那一欄是關鍵：差 5 和差 45 是兩個世界,
   而聚合數把它們壓成同一個字串。
```

# ③ 順序（★這張要先 merge）

measurer 的 Probe-on 短窗跑要**排在這顆之後**——否則她會量到一個**還沒有樣本的通道**，
而**那個空樣本會長得跟「有樣本但都一樣」一模一樣**。
⇒ **做完立刻回報**，我通知她開跑。

# ④ 驗收

```
①三個分支各自都有 bump_sample,且★樣本上限有界（不得無界累積）
②★成對對照:構造一個【exp 差 5】與一個【exp 差 45】的情形 ⇒ 樣本裡兩者【可分辨】
   （若只印「not_enough_exp」而不印差值,這格就是白做的）
③本票【零行為改動】⇒ determinism fingerprint 不變（接線票必備格）
```

★誠實限：本票**不改門檻、不改 exp 來源** —— 它只讓「121 次」變成**可以被拆開的東西**。

完後改本信 `status: consumed`。
