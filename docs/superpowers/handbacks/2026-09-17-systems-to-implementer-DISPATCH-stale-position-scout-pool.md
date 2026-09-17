---
from: systems
to: implementer
status: open
slice: 過期位置 → 偵查分池 ｜ **DISPATCH（R² issues 已補完）**
topic: ★**spec**：`docs/superpowers/specs/2026-09-17-stale-position-goes-to-scout-pool-HOW.md`（★**§5 是 R² 補的三點，開工前先讀那一節**）｜★★★**一句話**：`pick_recon_target` 的 `if _rpos == Vector2i(-1,-1): continue`（`decision_context.gd:335-336`）**把「位置過期」的目標丟掉了** —— **而偵查的存在理由【正是】去解決它**｜★★**兩道攻擊性的門逐字不改**（放寬＝隔空作用，違反感知鐵律）｜★**而 R² 抓到一個我寫錯的地方**：`freshness_factor` 的速度要傳**目標**的 team，**而旁邊那一行現有呼叫傳的是觀察者** —— **兩個呼叫長得一模一樣而意思相反**
---

# ① 改哪裡（★一處，而它是【單一選擇點】）
```
`decision_context.gd:335-336`（`pick_recon_target`）
  現在：`var _rpos = BeliefSystem.belief_pos(...)`；`if _rpos == (-1,-1): continue`
  改成：**位置取 last-known（不經新鮮度閘）＋ 年齡 `_rage = now − claim.tick`**
        **只有【真的沒有任何 claim】或【從未有過 `tile_pos`】才 `continue`**（★兩者要分開計數，見 §5③）
★**而檔頭自己寫著「單一選擇點：gather 與 `to_task` 共用這一支」** ⇒ **改一處兩邊一起改**
⇒ ★★**好事，但也表示改錯會一次錯兩邊** ⇒ **驗收要同時看【秤上的目標】與【派出去的目標】是同一個。**
```

# ② ★★年齡進【價值】不是進【門】
```
`_rval = _prior × δ^days × freshness_factor(_rage, <目標的移速>)`
★**單調遞減、永不歸零** —— ★★**歸零＝又做出一道靜默的門**（★今天我自己做過一個恆真的靜音，被打回）
★★★**速度傳【目標】的 team**：`GoalResolver._tiles_per_day(state, **target_team**)`
   —— **而 `decision_context.gd:326` 現有那一行傳的是觀察者（算「我要走幾天」）**
   ⇒ ★**不要照抄它**：本票要算的是「**它三天可以跑多遠**」。
```

# ③ 驗收（spec §3 五格 ＋ §5③ 拆成的 2a/2b，★每格能紅）
```
\u2460 過期位置的目標**出現在偵查候選集裡**       ／ 不出現 ⇒ 還在被 continue 掉
\u2461a 沒有任何 claim 的目標**仍不在**候選集
\u2461b ★**有 claim 但從未有過 `tile_pos` 的目標【也不在】** ⇒ **tap：`recon.skip.claim_without_pos`**
    ★★**這一類必須有名字** —— **它與「位置過期」在畫面上長得一模一樣，而兩者的下一站相反**
\u2062 年齡越大 ⇒ 價值越低，**而永不為 0**                ／ 歸零 ⇒ 又變成靜默的門
\u2063 **絕境那 6 筆**：偵查**上場**（★不要求它贏）         ／ 仍不在候選 ⇒ 本票沒打中
\u2464 **掠奪／攻擊那兩道門逐字未改**                       ／ 改了 ⇒ 越界
```
★**母體要報**：每格「樣本數 ／ 母體」。★★**而交件帶 `[TREE] HEAD=<sha>`**。
