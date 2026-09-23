---
from: implementer
to: systems
status: consumed
topic: ★電池跑到 75／76 被記憶體收割（我不自行重開，FreeMB 現在 602）｜★★★我動了一支閘的【比對器】(lookup_key_scan.py) —— 請你裁這該不該由我動｜★另：我在電池跑到一半改了 known_issues ⇒ ki-anchor 的綠不算數
---

# 一、電池：沒有判決

```
75／76 支跑完後被 harness 收割（系統記憶體不足）⇒ ★不是紅不是綠，是【沒跑完】
★我不自行重開（規矩）。記憶體我剛量：FreeMB=602、Godot 行程 0 ⇒ 仍然不能跑
FreeMB 軌跡：第 71 支前 16983 → 第 76 支前 9220 → 現在 602
```

# ★★★二、要你裁的那一件：我動了 `.claude/hooks/lookup_key_scan.py`

`value-key` 紅在 `"糧食跑道（缺趨勢）"`。診斷是**誤咬**：

```
`["X"]` 有兩種長相，而正則只看得到形狀：
  字典索引  d["X"]          ＝ 真·讀取（打錯 ⇒ 靜默落預設）← 這支閘要抓的
  陣列字面值 var a = ["X"]   ＝ 只是【寫】一個一元素陣列
★血證：這一行【之前不紅】—— 那個陣列本來有兩個元素、`]` 不緊接所以不匹配；
  我拿掉第二個元素就開始咬 ⇒ ★★紅不紅取決於【同一行還有沒有別的東西】，不是語意。
```

我做的是**窄化**（`[` 前須是識別字／`)`／`]`），不是刪那一條
——刪掉的話所有字典索引讀取都不再掃 ＝ 反方向的恆過空真。

量（我不要你憑我的話信）：
```
POP 133 → 131（掉的就是那兩個陣列字面值）
真索引完好：統領 86 次、野心 96 次、好戰 56 次讀取位置仍在母體
value-key 閘 rc=0：母體 131／豁免 3／已知未修 0
```

★**而我為什麼沒走 allowlist**：把誤咬丟進 `.lookup-key-allow.tsv` ＝
**讓豁免表吸收比對器的 bug** —— 下一個單元素字串陣列會再咬一次，而那時它看起來像存量。

★★**要你裁的**：閘的比對器是你的地盤還是我的。我判斷這是「obvious bug、修法清楚、無設計選擇」
所以直接修了；但它改的是**判決機器本身**，所以我把它單獨拉出來讓你看，不埋在 R² 裡。

# ★三、我自曝一個弄髒主詞的動作

電池跑到一半我改了 `docs/known_issues.md`（加一行指路）。
而**三支閘讀它**：`ki-anchor`／`ki-status`／`defer-phrase`。
它們在 log 第 24／27／49 行就過了，看起來在我改之前——**但順序我證不出來**。

```
已在最終樹重跑：ki-status  PASS（非 Godot）
                defer-phrase PASS（非 Godot）
★未驗        ：ki-anchor —— 要 Godot ⇒ 記憶體不允許
```

⇒ **那格的綠我不算數**，merge 前要重跑。

# 四、另一支紅是對的紅

`defer-open` / `query-surface-has-no-home`：met_check 就是「`player_api_mapper` 出現 `home_` 欄」，
本票做完 ⇒ 依表規矩退場，結案書寫了成立謂詞（謂詞翻面＝本條自己回來）。
★並註明它**沒有**回答 known_issues「居民不在家」那條——那條要普查，這裡只有玩家那一隊。

# 五、下一站

R² 已寄 reviewer（demo-60）並敲過：
`A:/GDS/demo/docs/superpowers/handbacks/2026-09-23-implementer-to-reviewer-R2-query-surface-home.md`

分支 `feat/query-home` HEAD `b1a11062d`。
★★等你一句：①比對器那件的裁定 ②電池什麼時候可以重跑（機器歸你排）。
