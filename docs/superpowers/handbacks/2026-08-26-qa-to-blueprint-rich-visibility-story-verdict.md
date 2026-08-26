---
from: qa
to: blueprint
status: open
slice: rich-point-visibility
topic: "★故事稽核判決:rich-point-visibility specimen(1185筆,team=[4,3,1,2,6])兩題皆有解——①Team3/4零汲取=genuine無需求(起始material370,全程未觸發means-end candidate,facility是farming非材料設施,非『忙別的』)②attempt 70/81集中在Team6一隊=同一catch-22重複被同一cost閘擋下(非many隊各試一次);②與wire-in判決①同型,互相印證"
---

# rich-point-visibility 故事稽核判決

## 材料
`A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-26-rich-visibility-story.specimen.jsonl`（1185 筆，specimen=[4,3,1,2,6]，peaceful_economy/seed1337/30天）。implementer 交件前已自查兩缺陷（對帳裸key/Team6漏名單）並修正，落地乾淨。

## ★①「6 座有據點的老熟林，`(0,14)`／`(10,14)` 累計汲取仍是 0——那兩隊在幹嘛？」

**判：✅ 可解釋——genuine 無需求，不是「忙別的」。**

- **Team4／Team3 全程只出現 4 種 candidate opt**：`駐守`／`建設`／`覓食`／`生產`——**掃過兩隊全部 246+246 筆，means-end 的 material 相關 candidate（`maintain_material:*`）從未出現過一次。**
- **起始 `material=370`（tick10）**，此後只有「賣」的訂單（`sell material ×155`／`×83`），到 tick7200 仍有 `170`／`159`——**存量始終遠高於任何『需要更多 material』的門檻，所以 `_resolve_resource_prereq`（`goal_resolver.gd:417`「前置滿→不生 candidate」）從第一刻就判定滿足，means-end 從未被觸發去問「要不要去老熟林採」。**
- **兩隊各自的據點是 `farming` 設施**（`[Outpost] Team3/4 設施施工 farming → Lv1`）——**farming 產食物，不是材料開採設施**。牠們坐在老熟林旁邊，但據點的功能跟森林的材料存量無關。

**⇒ 正確故事**：**這兩隊不是「有意圖但被擋」，是「材料期初就給夠了，從未產生想去採的念頭」。** 這跟②不是同一種「卡住」——這裡連候選都沒生成過，不是候選生成了卻執行失敗。若這是期初資源分配刻意讓某些隊「不需要」某項資源，那是 WHAT 層設計；若非刻意（隨機起始值造成部分隊天生不會摸到這個新機制），值得回頭問設計：**起始 material 差距是不是讓「富點可見性」這個新機制對某些隊形同虛設？**

## ★②「`attempt 12→81` 而 `accepted` 只 23→28——集中在一隊反覆試，還是很多隊各試一次？」

**判：⚠ 集中在一隊反覆試，而且是①的同型現象——material 收入速率追不上 cost 門檻。**

- **Team6 一隊吃掉 70/81（86%）**，其餘三隊（Team1:3／Team9:6／Team10:2）各只試個位數次。**這不是「很多隊各試一次」，是「一隊被同一道閘反覆擋」。**
- **Team6 material 起始 `=0`（跟 Team3/4 的 370 天差地遠），30 天內只緩慢爬到 `35.5`**（tick7100），**task 全程卡在 `覓食`（10 筆真決策 entry 全部 `task=覓食／winner=覓食`，無一次變動）**；同時段有 **70 筆 `phase=heartbeat／reason=no-decision`** 貫穿整個窗口，數量與 attempt 次數相同（★這兩個 tap 是否同源我沒有 file:line 坐實，只呈現「同數量、同隊、同窗口」這個相關性，不下因果——若要確認需 implementer/systems 補一個交叉引用）。
- **⇒ 這與我上一票（`wire-in-means-end-story`）判決①「build candidate 贏 argmax 後付不起」是同一型故事**：**Team6 一直想蓋（或一直想累積到能蓋的門檻），material 進帳速度遠不夠，於是每個 cadence 都重新撞同一道 `material < 1.5×cost` 的閘。** 兩票互相印證：**「有錢/有料的隊快速滿足不再理它（①）；沒錢/沒料的隊卡在同一道閘上反覆試（②）」——是同一個經濟分佈的兩個尾巴。**

## 分類彙總

| # | systems 的問題 | 判決 | 備註 |
|---|---|---|---|
| ① | (0,14)/(10,14) 為何零汲取 | ✅ genuine 無需求，非忙別的 | 起始 material 370 全程過剩，means-end 從未觸發 |
| ② | attempt 集中度 | ⚠ 集中一隊反覆試 | Team6 佔 86%，與 wire-in①同型（cost 閘擋下） |

## ★交回一個問題（我不裁，轉你/systems 判）
①②合看，這條 arc 揭出的不是「機制沒接上」，是**「起始 material 分配的貧富差」直接決定了這個新機制對誰有意義**：material 富的隊（370 起手）永遠不會去用它，material 窮的隊（0 起手）想用但用不起。**這是不是符合設計意圖（窮隊本來就該掙扎），還是起始分配需要重新看？** 我只呈現象，不下裁決。

不修 code、不裁 WHAT。materials 夠判故事性，release-pass 交你。
