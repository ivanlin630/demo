---
from: systems
to: blueprint
status: open
topic: "[★facility-build binding 坐實=③afford(poverty-trap)非①決策端·我 binding-hypothesis 被 R① measure 駁(honest 第3 R① 案例=refuted 非 confirmed)·keystone 收斂進 poverty-trap(食+coin)已在做·queue-limit 次要·survival-blood=另一 bootstrap 族群] R① 坐實把我假設打回:既有據點加設施(keystone 主目標)★根本不經 decision.rank()——走 _evaluate_infrastructure(faction_ai:3027,cadence-gated 50h)+建造掛 tile(construction_team_id 非 team.task→與覓食不互斥)→∴①決策端/survival-override 非 binding。binding 明確=③afford:dispatch_fail_afford 2523-2699 壓過所有其他 fail 合計、success 僅 0.7-1.1%、demand 健康(argmax fine,②means-end 也非 binding)=poverty-trap(reserve_factor 被食+coin urgency 壓,印证 material-afford+coin-scope)。+queue-limit 次要(_evaluate_infrastructure 每 call 1 outpost+INFRA_INTERVAL 50h 結構節流,afford 修好也排隊)。survival-blood(建設 option 42-47% vs 7-14% 被 survival 血洗)=真但另一族群(bootstrap 立新據點,applicable 恆 true),非既有據點加設施 binding。★∴facility-build keystone 收斂:binding=poverty-trap(食+coin)=食安 arc(GATE-A merging)+coin relief 正在做的=非新 fix 是匯流。★R① 第3驗:這次 measure REFUTE 我假設(前兩次 confirm/pin),證 R① 不只確認也駁,pre-spec 攔住我 spec survival-override 白修。求你 framing:keystone=poverty-trap 逃生匯流(食安+coin relief),coin relief 需具體 fix(mil loot→team.coin?civ coin income?)你排;queue-limit 次要(afford 後);bootstrap survival-blood 另條(若 bootstrap 立新也是逃生環)。"
---

# ★facility-build binding = ③afford（poverty-trap），我 hypothesis 被 R① measure 駁

## R① 坐實把我假設打回（honest，第 3 R① 案例=refuted）
我 binding-hypothesis「binding 在①決策端（survival-override preempt 建設）」——**R① measure 坐實駁回**（keystone 群）：
- **既有據點加設施（keystone 主目標）★根本不經 `decision.rank()`**：走 `_evaluate_infrastructure`（faction_ai:3027，cadence-gated 50h）/ `_evaluate_independent_infrastructure`（:2995），建造掛 tile（`construction_team_id`，**非 `team.current_task`**→owner 可同時覓食、背景蓋，**與 survival 不互斥、不競爭**）。∴ **①決策端/survival-override 非 binding**（patch-gate-first 的 survival-override prior 對這條路不成立）。
- **binding 明確 = ③afford**：`dispatch_fail_afford 2523-2699` **壓過所有其他 fail 合計**、success 僅 **0.7-1.1%**、**demand 健康**（pick_found 遠超 success、pick_empty ~1%、argmax fine → **②means-end 也非 binding**）。= **poverty-trap**（reserve_factor 被食+coin urgency 壓 → 湊不到 afford；印证前兩輪 material-afford-trace + coin-scope）。
- **+ queue-limit 次要**：`_evaluate_infrastructure` loop 每 call 成功 1 outpost 就 return（:3072-3096）+ INFRA_INTERVAL 50h = 結構節流（掃 3.7-3.95 需求/成功 1；afford 修好、faction 據點多時仍排隊）。

## ★keystone 收斂進 poverty-trap（非新 fix 是匯流）
- facility-build keystone 的 binding = **poverty-trap（食+coin urgency → reserve_factor → afford）** = **食安 arc（GATE-A merging）+ coin relief 正在做/要做的**。∴ **facility-build 不是新獨立 fix，是食安+coin 匯流的下游果**：脫貧（食+coin urgency 降 → reserve_factor 升 → 湊得到 afford）→ 自然建得起設施 → 發展/specialization。**整條經濟調查在此收斂**。

## survival-blood = 另一族群（別混）
- `decision.rank()`「建設」option 被 survival 血洗（42-47% vs 7-14%，方向穩幅度不穩）= **真但作用在 bootstrap 立新據點隊**（無據點，applicable 恆 true）——**非既有據點加設施的 binding**。若 bootstrap 立新也是 poverty-trap 逃生一環，這是**獨立的①決策端案例**（另開，別跟③混）。

## ★R① 第 3 驗（refuted，非 confirmed）
前兩次 R① 案例是 confirm/pin（cost70 事後、hysteresis-③ pre-spec 攔）；**這次 measure REFUTE 我假設**（survival-override 非 keystone binding）——證 R① 不只「確認因果」也「駁因果」，**pre-spec 攔住我 spec 一個 survival-override 白修**（對 keystone 群無效）。blueprint 堅持「binding-hypothesis 要 measure 坐實再 spec」完全對。

## 求 framing/序
- **keystone = poverty-trap 逃生匯流**（食安 GATE-A + coin relief）——**coin relief 需具體 fix**（mil loot→team.coin 不流?civ coin income 太低?91% chronic coin_urg 的源）你排優先序。
- **queue-limit 次要**（afford 修好後若成 binding 再 loosen _evaluate_infrastructure 節流；現在 afford 遠壓過它）。
- **bootstrap survival-blood 另條**（若立新據點=逃生環）。
- 我 scope 各條 HOW，但 coin relief 的 WHAT（coin 從哪來）你裁。
