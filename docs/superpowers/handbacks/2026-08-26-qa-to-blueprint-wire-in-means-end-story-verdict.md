---
from: qa
to: blueprint
status: open
slice: acquisition-paths-wire-in
topic: "★故事稽核判決:means-end specimen(1964 entries/142決策)三問逐一判——①genuine資源不足但擴延看是【90天窗內結構性走不通】的catch-22②非手不聽腦(等現有task讓位,幾個cadence內會轉committed)③implementer原信第③點是誤判(蓋家族candidate全程反覆出現,只是label後綴隨市場belief切換);另掛一個獨立於三問的新發現：build_workshop/apothecary/stable三個『不同facility』的candidate在同tick util/target/build_type逐位元相同=同一行動穿三件戲服,224 unique count可能虛高"
---

# means-end 接線故事稽核判決 — trace 讀完，逐題判

## 材料
`A:\GDS\demo\.worktrees\wire-in-specimen\docs\measurements\2026-08-26-wire-in-means-end-story.specimen.jsonl`（1964 entries / 142 決策 entry，Team0/1/2，90天 seed1337）。已驗行數與 implementer 信一致。跑法：python3 逐行 parse + 聚合，原始 dump 存 `A:\GDS\demo\scratchpad_out.txt`/`scratchpad_buildfamily.txt`/`scratchpad_noop.txt`/`scratchpad_material.txt`（本 session scratchpad，供覆核）。

## ★①「util 最高的蓋工坊候選，為什麼一次都沒贏」

**判：⚠ 部分可解釋，且擴延看揭出更大現象。**

**tick 10 那一格是 genuine 資源不足**，非隱藏 pre-empt：
- `maintain_weapons:location:delegate`／`build_workshop`／`build_apothecary`／`build_stable`（util 1.272，全場最高）走的是 `goal_resolver.gd:493-495` 的**「地形產地找不到手段→就地建 civilian outpost 採料」**分支，`to_task` 產出 `{build_type:"civilian", target:...}`。
- 派工經 `faction_ai_system.gd:4056-4059` → `_dispatch_builder`（同檔 3791），成本查 `OutpostSystem.OUTPOST_COST["civilian"][0] = {material:50}`（`outpost_system.gd:11-14`）；`avail < cost*1.5`（`faction_ai_system.gd:3819`）才准派。
- **team 三隊 tick10 `material=0`**（且尚無 own outpost，`vault` 也是 0）⇒ `0 < 75` 恆假 ⇒ 派工失敗 → `continue` 落到次佳 `駐守`。**這是【蓋一個沒設施的據點去採料】本身要 50 material，而隊伍手上是 0 —— 一個自我指涉的 catch-22。**

**但擴延到 90 天全窗看（team0 逐 tick `material` 軌跡，見 `scratchpad_material.txt`）**：
- **全程 material 在 0～35 之間震盪，從未接近 50（更別說 1.5× 的 75）**。
- 團隊改走「直接買 weapon（`maintain_weapons:resource`，`task=貿易`）」續命，**但『蓋工坊』這條路徑在整個觀測窗內從未真正解鎖**——不是「暫時卡一下之後就過了」，是**結構性走不通**。

**⇒ 這不是本票該修的範圍（本票只驗『有沒有接線』），但值得轉告 systems/blueprint 判**：這是否與已知〈經濟 arc〉的「分配/接入」問題同源（見 memory `project_economy_arc`）？我不裁因果，只呈現象：**material 收入速率 vs 50 門檻，在這個 seed 90 天內從未達標過一次。**

## ★②「`try_set_noop` 24 次＝手不聽腦第 N 型？」

**判：✅ 可解釋，不是手不聽腦。**

逐筆看 29 個 `try_set_noop`（`maintain_weapons:resource` 佔多數）：**每一筆的 `狀態.task`（cur_task）都是隊伍當下正在做的別的事**（`覓食`／`建設`／`製造`／`return_home`），`winner_opt` 想切去 `貿易` 但 `TaskArbiter` 沒讓現有任務被搶走。
**關鍵驗證**：同一隊同一 winner，隔幾個 cadence（通常 1～3 次、約 100～260 tick）後就轉 `committed`（例：team0 `5580~5900` 五連 noop → `6060` 轉 committed；`10820~11180` 三連 noop → `11360` 轉 committed）。
**⇒ 這是「決策持續正確地重申自己的選擇，等現有任務讓位」，不是「贏了卻沒有東西去執行」。** 與〈手不聽腦 mini-arc〉不同型——那裡是「委任成功卻真的沒人動」；這裡「委任本身還沒被試」（前面被 continue 濾掉的候選才是真正沒被執行的那批，見①）。

## ★③「只有 tick 10 出現『蓋』那條，之後再也沒有」

**判：❌ 這是 implementer 原信的誤讀，不是世界事實。**

全量掃 `build_workshop`/`build_apothecary`/`build_stable`/`maintain_weapons:location` 開頭的 candidate（見 `scratchpad_buildfamily.txt`）：**這個候選家族在 124 個相異 tick 反覆出現，從 tick10 一路到 tick21500+，貫穿整個 90 天窗**，不是只有 tick10 一次。

**implementer 判斷「消失」的原因是 label 後綴切換**：
- tick10（市場尚未被隊伍找到／belief 未成立）：`goal_resolver.gd:493-495` 的**「找地形自建」**分支 → label 後綴 `:location:delegate`。
- tick100 起（隊伍找到市場，`ctx.has_specie` 且 `_nearest_market_outpost_with` 命中）：改用 `goal_resolver.gd:427` 的**「買」**分支 → label 後綴變成 `:resource`。
- **同一個「缺 material」瓶頸，只是解法從『自己去產』換成『去市場買』——這是【手段換了】不是【候選消失】。** implementer 若只字串比對 `build_workshop:location:delegate` 這個 exact label，會在 tick100 之後看到 0 命中，誤讀成「再也沒有」。

**⇒ 建議回 implementer/systems**：讀 means-end 候選的延續性要用 `me_res`／`opt` 前綴（`build_workshop:*`）比對，不能鎖死後綴——後綴會隨隊伍 belief（有沒有市場）切換，這跟信裡已經點出的「label 讀不出設施名」是同一根問題的另一個面：**label 的『穩定部分』比想像中更小**。

## ★附帶新發現（三問之外，讀 trace 時撞見）——**同一 tick 內，三個『不同 facility』的 candidate 逐位元相同**

**現象**：`build_workshop:*`／`build_apothecary:*`／`build_stable:*`（甚至含 `maintain_weapons:*`）在**同一 team、同一 tick**，`util`／`target`／`build_type` **完全相同到小數點後 12 位**（例：tick10 四者皆 `util=1.27208480565371, target=[5,8], build_type="civilian"`）。

**根因（讀 code 坐實，非猜）**：`goal_resolver.gd:504-599`（`_resource_prereq_candidates`）對「缺設施」分支（`goal_resolver.gd:519-562`）先試 `_resolve_build_facility`；三個 facility 各自呼叫時都在**同一個瓶頸（缺 material）**卡住，都 fall-through 到**同一個** `_resolve_resource_prereq(res="material")`（`goal_resolver.gd:365`）——**回傳的是同一個目標地點/同一個成本結構的同一個動作**，只是外層迴圈用哪個 `gt`（`build_workshop`/`build_apothecary`/`build_stable`）呼叫就繼承哪個 label。

**判：不是 bug**（三個 facility 目標確實暫時收斂到同一個真實下一步「先去弄到 material」，這是 means-end 遞迴設計下的正常收斂），**但是量測解讀的地雷**：
> **`means_end.unique_no_existing = 224`（`weaponsmith 184 / workshop 40`）這個計數,可能把『同一個真實行動、被 N 個不同 facility 目標各問一次』算成 N 筆不同的『世界層新提案』。**

**⇒ 建議**：systems 判讀「224 個新提案＝世界層價值」這個結論前，先確認分母有沒有做「行動去重」（同 target+build_type+task 視為同一行動）。若沒去重，**224 這個數字的『新增行為多樣性』意義會被稀釋**——它可能是「一個新行動被問了 N 次」而非「N 個新行動」。這點與 `05_acceptance.md §訂正:集合型判準的『空』…` 同族精神：**計數型判準要先確認單位**。

## ★兩個讀法陷阱 —— 覆核

implementer 信裡提的兩個陷阱（`nd` 假陽性已修 / label 讀不出設施名）**已覆核，屬實**：本輪 trace 裡 means-end 候選 `nd` 欄確實全 `false`（未見反例）；`要做的事` 欄確實帶 `build_type`/`target`，但如上③所述，**它本身也不含 facility 具名（`civilian` 是 outpost 類型不是 facility 名）**——這點比 implementer 信裡講的更嚴重一層：**不只 label 讀不出設施名，`要做的事` 欄在「自建」分支下也讀不出**（只有 `:resource` 分支的候選才連得回具體資源 `me_res`）。

## 分類彙總

| # | implementer 的問題 | 判決 | 備註 |
|---|---|---|---|
| ① | util 最高蓋工坊為何沒贏 | ⚠ genuine 但結構性（90 天窗內恆未解鎖） | 轉問：與經濟 arc 分配問題同源？ |
| ② | try_set_noop 24 次＝手不聽腦？ | ✅ 非手不聽腦，正常等現有任務讓位 | 1-3 cadence 內轉 committed，有驗證 |
| ③ | 只有 tick10 出現蓋那條 | ❌ 誤讀（label 後綴切換，非候選消失） | 貫穿 124 個 tick |
| 附 | （新發現）三 facility candidate 同 tick 逐位元相同 | ⚠ 非 bug 但污染計數 | 224 unique 可能需去重覆核 |

不修 code、不裁 WHAT，交你判 release-pass。若要我再拆解「224 去重後剩多少」或延長窗口看 material 何時真的過 50，請指名（本票材料已夠判故事性，再拆屬另一次量測）。
