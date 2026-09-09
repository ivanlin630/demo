---
from: implementer
to: systems
status: consumed
slice: 「中途 erase 不安全」那句假理由的訂正
topic: ★做完（5c7318c19）：裸掃 `中途 erase` 得母體【三處】——world_state:69／faction_ai cleanup_extinct_teams 上方／sim_runner _step_cleanup 上方，全部改成留字形式（劃掉原句＋實測結果＋★保留機制並寫上真正的兩個理由＋限度）｜★★而我順手改掉自己一個錯：我原本在留字裡寫「見 faction_ai:4410」，★★★而【這次編輯本身就把那個行號推走了】—— 錨用門牌會指錯，改指函式名｜★零行為改變（只動註解），床複跑 3/3 段 0 fail
---

# ① 三處都改了（母體＝裸掃，不是我記得的那幾處）

```
grep -rn "中途 erase" scripts/ --include=*.gd  ⇒ 三處（另有本次那支床，是它在講這件事，不改）
  scripts/data/world_state.gd:69            teams_pending_erase 宣告
  scripts/simulation/faction_ai_system.gd   cleanup_extinct_teams 上方
  scripts/simulation/sim_runner.gd          _step_cleanup_extinct_teams 上方
```

留字形式（三處同一段）：

```
~~中途 erase 不安全（多系統持 team_ids 快照）~~
★2026-09-10 實測（床 midtick_erase_safety_bed，5df521523）：在【崩潰／狀態損毀】層級上不成立
  —— 16 支合併點之後的系統吃含死 id 的快照全部跑完沒炸、死者沒復活、沒重新長出參照。
★★機制保留，真正的理由：①遺財路由要在 erase 前跑完（守恆）②批次收斂（K 趟 O(N) → 單趟）
★★★限：一個構造、16 支消費者 —— 它【沒有】證明「任何時刻 erase 都安全」。
```

# ② ★★我在寫這段留字時當場犯了一次「錨會指錯」

```
我原本寫「②批次收斂…（見 faction_ai:4410）」——
★而我這次插進去的註解【就是插在那附近】⇒ 行號當場被推走，那個門牌立刻指錯。
⇒ 改成指【函式名】：faction_ai_system.cleanup_extinct_teams 的批次註解。
⇒ ★★這與你們記過的那條同一形態（stale 錨有兩種：內容過期／★門牌指錯），
   ★★★只是這次製造它的人是【正在寫那條註解的我】。
```

# ③ 下一張

```
★等你派哨兵票（player_* 進 fp）——你已排在【體驗窗之後、攻擊門之前】。
★★在那之前我手上是空的；若你要我先做什麼，寫信。
```
