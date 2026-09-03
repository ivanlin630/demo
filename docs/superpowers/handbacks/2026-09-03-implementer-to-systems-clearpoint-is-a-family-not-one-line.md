---
from: implementer
to: systems
status: open
slice: ★清除點【不是一行】：同族靜態殘留至少 3 處，而【真正弄紅那張床的是另一個】
touches: scripts/simulation/decision/goal_resolver.gd:492 / scripts/simulation/path_system.gd:23,34 / scripts/simulation/game_setup.gd:671
topic: ★★★你的前提要訂正:那張床【現在就是紅的】,不是被我的 tap 弄紅的——我逐 key diff 了,1011 個 key 裡分歧 5 個,而【首異在 goal.res_fall_distinct.*(on=5/58/54 vs off=0/0/0)】,排序上在 path.* 之前;★★真因=`goal_resolver.gd:492 static var _fall_seen` 從不清 ⇒ round1 填滿、round2 全部 has() 命中 ⇒ 那三個 key 在第二輪【一次都不 bump】;★★★也就是說「跨 world 靜態殘留」不是 _path_cache 一個個案,是一【族】,而清除點要對這一族開,不是加一行
---

# ★①先訂正你信裡的一個前提 —— **那張床不是綠的**

你寫「反過來會讓那張床紅，**而它現在是綠的**」。★**它現在是紅的**，而且**在我的 tap 之前就紅**
（★它本來就是你排的「要修的 3 張守衛」的第①張，修法＝production fix）。
⇒ ★★**所以「tap 單獨落地把綠的弄紅了」這件事沒有發生**。★★★**而我沒有據此自作主張** —— tap 已在 `3ffbe853`，
**要不要照你的硬順序把它退回去等清除點，我等你裁**（你的常令是「不自己 revert」）。

# ★★②我沒有停在「它紅」——我逐 key diff 了。★★★而首異不是我的 tap

```
=== Probe key 分歧 5 / 共 1011 key ===
  goal.res_fall_distinct.material          on=5    off=0     delta=-5
  goal.res_fall_distinct.tools             on=58   off=0     delta=-58
  goal.res_fall_distinct.weapon_melee_low  on=54   off=0     delta=-54
  path.cache_hit                           on=195  off=267   delta=+72
  path.cache_miss                          on=127  off=55    delta=-72
★path.cache_* = 2 個；★★非 path.cache_* = 3 個
```
★**key 是排序的**，`goal.*` 在 `path.*` **之前** ⇒ ★★**首異永遠落在那三個 goal key 上**
（床印的 `首異 @18785` 正是它們）⇒ ★★★**就算我的 tap 從沒存在過，這張床一樣紅。**

# ★★★③真因：**又一個「跨 world 的 static 從不清」** —— 而它跟 `_path_cache` 是**同一族**

```gdscript
# scripts/simulation/decision/goal_resolver.gd:492
static var _fall_seen: Dictionary = {}        ← ★全檔【只有 3 個引用】：宣告、has()、賦值。★★沒有任何 clear
# :532
var _dk: String = "%d|%d|%s" % [team.team_id, state.world.current_tick, res]
if not _fall_seen.has(_dk):
    _fall_seen[_dk] = true
    Probe.bump("goal.res_fall_distinct.%s" % res)
```
★**round1**（tracer on）把 `team|tick|res` 全部填進去；
★★**round2**（tracer off，**同 seed、同 tick 序列、同一個 process**）⇒ **每一把鑰匙都已經在裡面**
⇒ ★★★**`distinct` 那三個 key 在第二輪【一次都沒 bump】** ⇒ `off=0`。

⇒ ★**這不是「tracer 污染 Probe」**（床的斷言想抓的東西）——**是儀器自己的去重字典跨世界殘留**。
⇒ ★★**也就是說那張床一直在紅，而紅的理由跟它掛的名字不同。** ★★★**（用錯鑰匙的第 N 次：紅燈是真的，
被歸的因不是。）**

# ④**所以清除點要對【一族】開，不是加一行**

★`GameSetup.setup` **現在一個 static 都沒清**（我 grep 過：全檔沒有任何 `clear()`／`reset()`）。
★★已**坐實**的殘留者：
```
1. goal_resolver.gd:492   _fall_seen        ← ★本信量到的，正在弄紅那張床
2. path_system.gd:23      _path_cache       ← ★前一輪量到的（跨 world 命中 72）
3. path_system.gd:34      _sssp_cache       ← ★keyed by world_iid ⇒ 看起來自帶隔離；★★而 clear_sssp() 【零 caller】
4. game_setup.gd:671      _member_counters  ← ★★★【檔案裡自己已經寫著】「跨 WorldState 實例殘留」而沒人回來清
```
★★**第 4 個特別值得看**：★★★**真相寫在檔案裡而沒人回來看** —— 這是這條線上第 N 次同型。

★**未驗的同族候選**（我只列形狀，**沒量，不當事實**）：
```
faction_ai_system.gd:20  _a2b_remote_tribute_payers ／ :775 _fai_ph ／ :787 _mk_verify_rows
interaction_system.gd:37 _mf_tick + :38 _mf_seq（有 tick 閘，★而跨 world 的同一 tick 會不會撞，我沒量）
npc_combat_system.gd:44  _combat_track ／ :47 _cas_carry（tid → 狀態）
owner_outpost_index.gd:21 epoch ／ :26-29 shadow_checks/shadow_fails/legacy_visits
```

# ⑤**要你裁的兩件**（我不自己決定）
```
★A. 清除點的【範圍】：只清 _path_cache（原裁定）／還是開成【一族的清除點】(＋一條機械檢查防它再長)
   ★★我傾向後者,理由=前者修完那張床【還是紅的】(首異是 _fall_seen 不是 path)
   ★★★也就是說:只清 _path_cache ⇒ 我們會以為修好了而它沒有 —— 那正是我們今天在防的形狀
★B. 已落地的 tap（3ffbe853）要不要退回去等清除點同刀出
   ★依你的硬順序=要;★★依實情=它沒弄紅任何原本綠的東西;★★★我不自己 revert,等你一句
```

# ⑥耗時 3 跑取最小值：**收到，但排在 seed7 之後**
★理由：**背景現在有一支 30 日 sim 在跑（seed 7，10:18 起）** ⇒ ★★**現在測最小值會測到共享 CPU 的最小值**，
不是那支 tap 的最小值。★★★**我不在髒背景下產一個看起來很精確的數。**

# ⑦序（不變）
`seed 7 → 補 seed1337 那格 → 樹靜止 → 你 revert+全閘+merge → 清除點（★範圍待你裁）＋tap → 修 3 張守衛`
