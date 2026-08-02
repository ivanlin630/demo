---
from: systems
to: implementer
status: consumed
topic: "[實作·持守統一 Slice 3·try_set 持守-aware 門檻式(執行層核心真持守)·Slice2 merged(0f62884f gate74)·spec=2026-07-28-persistence-decision-layer-HOW.md §6·非危機committed persist>THRESHOLD擋搶班+危機tier原封守命+latch反例避開(單點門檻非skip硬鎖)·persist_strength progressive-only已保證只progressive動作有值] Slice 1/2 merged(persist_strength欄+隨進度新鮮)。Slice 3=執行層try_set門檻式。★別破現有PRIO/危機axis+別凍世界。"
branch: feat/persistence-slice3-tryset-threshold
---

# 實作：持守統一 Slice 3（try_set 持守-aware 門檻式）

Slice 1/2 merged（persist_strength 欄 + 隨進度新鮮）。**Slice 3 = 執行層 try_set 門檻式**（§6 R²訂正門檻式，非 new_util 比較）。★這是核心（執行層直接派工的 committed 動作真持守，A1 rank-only 修不到的那類）。

## spec
`docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md` **§6（try_set 持守-aware 門檻式）+ §9 憲法**。

## Slice 3 scope（try_set 內部門檻，§6）
`TaskArbiter.try_set`（task_arbiter.gd:38）加持守門檻：
```
try_set(new_task, new_prio):
    # 現有 combat_lock/crisis-immunity guard 全留(在前)
    if 危機 axis（new_prio 或 current.task_priority ≥ PRIO_THREAT）:
        現有整數 tier 嚴格大於（守命，persist 不介入）   # 危機原封不動
    elif 非危機 and team.persist_strength > PERSIST_HOLD_THRESHOLD:
        return false   # ★committed 動作 persist 高→擋非危機搶班(完成優先)
    else:
        現有整數 tier 嚴格大於（原行為）
```
- `PERSIST_HOLD_THRESHOLD` = 新常數（TEST VALUE，slice 調；persist_strength ∈[0,0.3]，THRESHOLD 定在能分固執/務實的位置）。
- **persist_strength progressive-only 已保證**（Slice 1）：只 progressive committed 動作有值（非 progressive=0<THRESHOLD 不擋）→ 門檻自然只作用 committed progressive 動作。
- **危機 axis 原封不動**：combat_lock(task_arbiter:40)/crisis-immunity(:45)/≥THREAT tier 全留、在 persist 判斷之前。

## ★硬約束（latch 血證 + reviewer 提醒）
- **別破現有 PRIO/仲裁**：加維度非砍 tier。危機永遠過（守命/背水一戰）。
- **★★別凍世界**：persist 是**單點門檻擋一次搶班**（return false），被擋的搶班者下 tick 照常再評、committed 隊自己照跑決策/完成就釋放——**非 latch 那種施工隊 skip reeval 凍死**。★世界不凍是硬回歸驗。

## ★TDD + 驗
- try_set 門檻單測：非危機 persist>THRESHOLD 擋、persist<THRESHOLD 過、危機 tier 一律過（守命）。
- **★★世界不凍**（latch 反例，最關鍵）：specimen-off seed1337/42 teams/pop churn、attrition 兩者皆活（別做出凍世界的東西）。
- 危機仍即時打斷（committed 隊被真敵人壓境→逃/戰，背水一戰保住）。
- committed 動作不被非危機搶（persist 高的施工/campaign 隊黏住）。
- 閘：headless 0-new + gate 74（try_set 門檻是新 site？看 gate 偵測，若命中須 `# gate-ok` 註 legit=util 門檻非硬 gate）+ determinism 3跑 byte-identical。

## 交付
handback `to:systems` → R²（Slice 3）→ merge → Slice 4（A1 手不聽腦收，驗 construct.complete_build>0 真完工）。whole-system-first。★execution-verified（committed 真黏+危機真打斷+世界不凍）。material PARK。
