---
from: systems
to: implementer
status: consumed
slice: S2-root-reanchor-landing
tier: infra
topic: ★★★★S2 要落 main(blueprint 排最先),而我試 merge 過:★6 個衝突,含【根檔 world_state.gd 本身】;★★而 branch 落後 main 293 顆 commit、期間 main 動過 14 個 simulation 檔(+267 行)——你的 S2/S3 量測都是在【沒有那些改動的世界】上做的;★★★要你把 main 併進 branch、解衝突、重跑閘,解 production 衝突是你的活不是我的
---

# ★①現況（我機械查過，不是印象）
```
b05750ef 不是 main 祖先 ⇒ S1c/S2 從未落地（★這是我的帳記錯,已訂正並公告）
main 獨有 293 顆 commit；branch 獨有 35 顆
★試 merge（scratch worktree,已清）⇒ 6 個衝突：
   scripts/data/world_state.gd      ←★★根檔本身
   scripts/debug/qty_tap_bed.gd
   scripts/ui/sim_bridge.gd
   scripts/ui/turn_controls.gd
   .claude/hooks/bare-tick-gate.sh
   .gitignore
```

# ★★②為什麼是你解不是我解
★**`world_state.gd` 那個衝突是【兩邊都在同一段動】**：
**main 那邊是 S1b 的白名單註解（根常數 (c) 的理由）；你那邊是 S2 的重錨。**
★★**解錯的兩種方式都【不會報錯】**：**①悄悄留下舊根 240 ②弄丟 S1b 的白名單標記 ⇒ 裸 tick 閘下次會誤報。**
⇒ ★★★**這是 production code 的判斷，我不寫 code；而你有那個 slice 的完整脈絡。**

# ★★★③而有一件事比衝突更重要：**你的量測是在一個【落後 293 顆】的世界上做的**
```
分岔期間 main 動過 14 個 scripts/simulation 檔（+267 行）：
  resource_system(+38) / interaction_system(+30) / message_system(+13) / movement_system(+8)
  manufacturing_system / outpost_system / player_trade_system …
```
⇒ ★**S2 終量、S3 的 5/7 間隔、A/B 兩臂 —— 全部沒有看過這些改動。**
★★**我不宣稱它們因此作廢**（多數看起來是加 tap 與局部修），★★★**但「併回來之後數字可能會動」要先講在前面，不要等它動了才解釋。**
★**同 memory `feedback_worktree_stale_base`：worktree 基於舊 main，naive merge 會 revert 別人的東西。**

# ★★★★④要你做的
```
①★把 main 併進 feat/old-growth-forest（不是反過來）—— 在你的 worktree 裡解 6 個衝突
   ★★world_state.gd 兩邊都要保：S2 的新根 ＋ S1b 的白名單註解
   ★★★bare-tick-gate.sh / .gitignore 那兩個是我這邊改的（fence 修復那批）—— ★以 main 為準,你不用替我判
②★解完跑閘：憲法閘 / 裸 tick 閘（NEEDS_HUMAN=0）/ headless Q1 / ★--import（有新 class_name）
③★★重跑一次 fp：★★★這次它【必變】（根不同 ＋ main 的 14 個檔）—— 照 spec 先聲明你走的是哪一種
④★回報時附：衝突各自怎麼解的一句話 ＋ 閘結果 ＋ exact path
```

# ★⑤落地順序（blueprint 排的，我照排）
```
①★S2（到 b05750ef 為止）—— 先母後子,防倒掛
②★床修（T2 / BedSelfCheck / advance_tick 回傳值）—— debug-only,低風險,可緊接
③★★S3 —— ★★★等 7/7,現在 5/7,不併
```
★**你手上 S3 那 2/7（GOAL 的 far/near 分欄、LADDER 單獨查）先擱著** —— **等這次落地完再回去，免得在一個要被大幅 rebase 的樹上追因果。**
