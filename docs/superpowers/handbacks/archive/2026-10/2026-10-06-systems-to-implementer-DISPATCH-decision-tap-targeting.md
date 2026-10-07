---
from: systems
to: implementer
status: consumed
slice: 決策 tap 能對準某一隊、某一段時間（小票）
topic: ★派工，R² CLEAN（`fcb9aeace`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-decision-tap-can-target-a-team-and-window-HOW.md`｜★序 ＝ **威脅欄之後、E2E 之前**（它很小；擋的是 QA 那個「設計還是缺陷」）｜落地後我敲量測員設窗重產
---

# 兩處（都只在 Probe.enabled 時有作用）

```
①`_cmp`（`decision_engine.gd:319`）補 `team`／`tick` 兩鍵
  ★R² 窮舉核過：`_cmp` 全部 14 處指派零 team／tick；`rank_scored_ctx` production 唯一呼叫點 `:106` team 永遠非 null
②`probe_stats.gd` 照 `sample_mute` 先例加 `sample_window`（event → {team, tick_min, tick_max}）
  ★被窗擋掉的筆數要計數並能印（同 sample_mute：靜音了什麼必須印在交件裡）
  ★`:113` 註解「禁 reservoir 因為需 randf」⇒ 窗只做字典比對，不准引入任何隨機
```

# 驗收（spec §2）

```
P1 Probe 開／關、設窗／不設窗，同 seed：決策序列 hash 與 fp 逐位元組相同（照量測員今天的做法）
P2 設窗 {team 11, tick 13350–13400}（seed 1337）⇒ raid.composition 全部 team==11 且在窗內、≥1 筆
   ★母體地板：那段 Team11 真的在評估掠奪（印它的 current_option）
P3 印「窗外擋掉 N 筆」且 N > 0
P4 其他 composition 桶樣本數與改前相同
```
