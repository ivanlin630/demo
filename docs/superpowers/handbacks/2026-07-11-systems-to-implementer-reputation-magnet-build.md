---
from: systems
to: implementer
status: consumed
topic: [名聲磁鐵 開工] protector_rep軸+道德事件喂+決策讀;R② CLEAN;疊S-A worktree
---

# 實作工單：名聲磁鐵 slice（R② CLEAN）

spec `specs/2026-07-11-reputation-magnet-slice.md`（R② CLEAN；reviewer 補硬理由：known_reputations 餵 `belief_system:64` 情報信任，混道德事件會污染認知數學→β 分軸=防跨子系統語意污染）。**疊既有 S-A worktree**（consolidation 全 carry forward）。這是 consolidation arc 的解答=名聲 pull 繞征服死結。

## 改（§1~3）
1. **`team_data.gd` +`protector_rep: Dictionary`**（key=protector team_id，default 0.5，clamp 0~1，accessor）。**★語意獨立 known_reputations**（protector_rep=值不值託付/道德；known_reputations=情報信任，別混、別讀錯軸）。
2. **閉環 2 — 道德事件喂 protector_rep**（既有加邊點 `npc_ai:84 gratitude/:86 protect/:29 feud` + killed）：**同時**更新觀察者隊對 subject 的 protector_rep——protect/gratitude→`+REP_GAIN(~0.1)×intensity`、feud/killed→`-REP_LOSS(~0.15)×intensity`（跌快於漲）。
   - **★subject→team 映射**：relation_edges 在 person(leader)、protector_rep 在 team。**先確認 subject_id 型別**（person or team）——person 則 resolve 其 team 當 key、observer=該 person 的 team。**跑不順/映射不清 → 標明回 systems，別猜。**
3. **閉環 3 — 決策讀名聲**：
   - `terms.gd join_drive` × 名聲加成：`join_drive × (1 + protector_rep[host] × REP_MAGNET_W(~1.0))`——高名聲 host 投靠翻贏逃。中性(0.5)加成小。
   - `_find_strong_neighbor`（`faction_ai:3238`）偏好高 protector_rep（強×名聲好，避投奔強暴君）。
   - `decision_context.gd` +`best_protector_id`/`best_protector_rep`（finder 選的高名聲保護傘），join_drive 讀。
   - **FLEE 公式不改**（靠投靠 util 升過即可）。**★build 確認投靠/FLEE 可競秤**（投靠 survival / FLEE threat 不同 rank 集→升了也沒用）；卡則標回 systems。

## 守則（blueprint 硬）
- **主觀非全知**：讀 per-observer protector_rep，禁全域真值。
- 不動征服平衡（只碰 join_drive，攻擊/征服 term 不觸）。複用既有，禁重造。

## 驗（measurer 磁鐵測，核心假設）
- **弱隊湧向高 protector_rep 保護傘、長聯邦？** protector_rep 真波動（脫 0.5，護/背驅）→ 高名聲 host 吸投靠 dispatch/complete>0 → 聯邦成形/隊聚合。
- 磁鐵動 → 回 blueprint 投 gossip；不動 → 回 blueprint 重估（weight 量級/卡點）。
- **mega-blob（reviewer 點）併入隊數/最大隊 pop 佔比觀察**（同 §HOW-7，measure-only；高名聲仁君別滾成吞世界一坨）。
- 附：高名聲仁君 vs 低名聲暴君分化「自願聯邦 vs 征服帝國」。gate#1 非搬餓 + determinism + 三端不退化。
- 大窗 `godot-detach.ps1`+`WARRING_RESUME`（03b SOP）；worktree rebase 最新 main。

## 卡點
設計不明/映射不清/可競秤有疑 → **寫 to:systems handback**（我 ~20s 接），別猜、別問 user。merge 閘=reviewer diff CLEAN + measurer 磁鐵數字 to:blueprint 判動不動。
