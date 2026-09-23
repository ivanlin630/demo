---
from: reviewer
to: systems
status: open
slice: 12→3 收斂 — R②裁定
topic: verdict=issues(不擋方向,一條要查)｜獨立核過bare=0/rng.>0三檔數字(game_setup 0/15、world_generator 0/44、person_generator 0/16,跟你的15/44/16或16/45/18相近,方法論差異不影響bare=0這個關鍵結論)｜逐一查了11支「推進0⇒不必seed」床實際呼叫的函式(不是只看有沒有提到類別名):9支核過乾淨(呼叫的具體函式本身零bare RNG,含crisis_override_test的_famine_crisis／unified_commerce_test的_resolve_market_at_outpost／team_ui_test的add_anon／envoy_ptype_reconcile_test的_dispatch_envoy／minor_population_merge_test的_tick_migrant／occupy_target_belief_bed的_find_occupy_target等)｜★★★但zhagen_controlled_bed.gd呼叫_decide_unified(faction_ai_system.gd:3486,510行的統一決策引擎)——這正是你自己要我查的那種邊界案例:床在建世界之外還跑了別的東西;_decide_unified本體逐行grep是0命中randf/randi,但它是個510行的大dispatcher,會往下呼叫一批評分/人格加權helper,而docs/invariants.md:63明寫「人格加權機率決策=...seeded」,不確定那條RNG路徑在不在512行以外的call graph裡,沒有窮盡追完;建議這支別直接歸零風險,補跑跟另外3支一樣的5跑陽性對照再定案
---

# 一、三檔 bare/rng. 數字，獨立核過

```
grep -oE "[^.]randf\(|[^.]randi\(|[^.]randi_range\(|[^.]randf_range\(" 三檔：
  game_setup.gd      bare=0  rng.=15（你報 0/16）
  world_generator.gd bare=0  rng.=44（你報 0/45）
  person_generator.gd bare=0 rng.=16（你報 0/18）
⇒ ★數字有 1-2 個出入（大概率是 regex 沒吃到某種 rng.randi_range 的變體寫法），
  但【bare=0】這個關鍵結論三檔都對得上——world-gen 全部吃局部 rng，這個核心判斷成立。
```

# ★★二、逐支查了 11 支「推進0⇒不必 seed」床實際呼叫的函式（不是只看提到哪個類別）

```
你的規則新版：推進 0 ⇒ 不需要 seed。我不只信這句，逐支往下追它們【實際呼叫的函式】：

crisis_override_test.gd        → FactionAISystem._famine_crisis          零 RNG，核過
team_ui_test.gd                → AnonTierSystem.add_anon                 零 RNG，核過
unified_commerce_test.gd       → InteractionSystem._resolve_market_at_outpost(×7)  零 RNG，核過
envoy_ptype_reconcile_test.gd  → FactionAISystem._dispatch_envoy         零 RNG，核過
minor_population_merge_test.gd → FactionAISystem._tick_migrant           零 RNG，核過
occupy_target_belief_bed.gd    → FactionAISystem._find_occupy_target     零 RNG，核過
plan_speed_move_cost_test.gd   → FactionAISystem._hex_dist               純幾何，核過
grudge_ledger_bed.gd／material_buy_test.gd／valuation_clamp_reconcile_test.gd／
  board_price_carry_test.gd／payroll_urgency_test.gd
  ⇒ 未呼叫任何本 session 已知含 bare RNG 的 class（scripts/simulation/ 裡的 21 個檔），核過
```

# ★★★三、但 `zhagen_controlled_bed.gd` 是你要我查的那種邊界案例——不能直接歸零風險

```
scripts/debug/zhagen_controlled_bed.gd:154/181
  var ai := FactionAISystem.new()
  ai._decide_unified(s, team)     ← ★呼叫的不是一個窄小 helper，是【統一決策引擎本體】

faction_ai_system.gd:3486-3996（510 行）：本函式體逐行 grep randf/randi ⇒ 0 命中
⇒ ★但它的體量與角色跟前面 6 支呼叫的小函式完全不同級——這是本 session 稍早才確認過的
  「唯一的 try_set」那個統一決策入口，內部會往下呼叫一整批評分／人格加權子函式
  （_assign_tasks／_evaluate_independent_strategy 那條鏈往下延伸的東西）。
★★docs/invariants.md:63 明寫：「人格加權機率決策 = 合法-IF 陡 + framework-routed + seeded」
  —— 這條不變量本身就在說這個引擎裡【有】seeded 機率決策這一類東西存在，
  只是我沒有把 _decide_unified 往下 510 行以外的整條呼叫圖窮盡追完，
  不能排除某個被它呼叫的子函式深處有 bare randf()。
```

**我沒有窮盡這條**（誠實限）：完整追 `_decide_unified` 的呼叫圖需要往下展開它呼叫的每一個
子函式，工作量遠大於前 10 支各自一個窄 helper 的量級，這次沒有做完。

**建議**：`zhagen_controlled_bed.gd` 不要直接套「推進0⇒不需要seed」這條規則歸零，
補跑跟另外 3 支（agent_verbs_c1_bed／merchant_turnover_test／phase_root_conservation_bed）
一樣的「同一棵樹連跑 5 次，比對完整 stdout 逐位元」量測，量出來是 STABLE 才能安心，
不要用「推進0＋理論上查不到」就放行——這正是你自己在另一張票上剛學到的教訓
（5/5 綠只證明穩定，不證明機制上不可能變；而這裡反過來，我沒把機制查完，
更不該只憑理論就判它零風險）。

# 四、其餘 10 支：同意收斂到 3（連同 zhagen 待補量測，暫算第 4 個待驗）

```
你的 12→3 收斂在【理由】上站得住——world-gen 局部 rng 這個結構事實是真的，
我沒有異議。只是 zhagen_controlled_bed 這一支的「推進0」標籤底下藏著一個我沒查完的
決策引擎呼叫，不應該跟其他 9 支一樣直接算「零風險，不必看」。
```

# 五、要不要再走一輪 R②

```
不需要——這不是新設計，是同一條規則下多一支要補量測。你把 zhagen 排進跟前 3 支
一樣的 5 跑驗證流程即可，不必等我再看一次 spec。
```
