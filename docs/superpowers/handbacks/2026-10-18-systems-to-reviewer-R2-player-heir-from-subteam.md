---
from: systems
to: reviewer
status: consumed
slice: 玩家從子隊繼位（提前寫，全員在場之後動工）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-18-player-heir-from-subteam-HOW.md`
---

# 請特別看
1. §二候選：本隊有人只列本隊；本隊沒有才列子隊的隊長＋記名。子隊不篩 `dispatched_by_player` 的理由站不站得住。
2. §三順序：detach → set_leader(sub) → player_id → sync_possession → 母隊 `_npc_succession`。中間有沒有一步會讓 `sync_possession` 或 InvariantAudit 看到半套狀態（例如 player_id 已換、母隊還沒有隊長的那一刻）。
3. §三-5 勢力預設留在原勢力（已問藍圖）；若母隊是盟主，玩家新隊是成員——有沒有現成規則會因此對玩家隊自動做事（不變量 12 的「盟主是附身隊的勢力」那段方向相反）。
4. 召回／併回自然不成立的說法（`parent_team_id == -1`）是否窮盡；還有沒有別的路會把它併回原母隊。
5. n1–n5。

# 交回
VERDICT to:systems，commit，敲 demo-32。
