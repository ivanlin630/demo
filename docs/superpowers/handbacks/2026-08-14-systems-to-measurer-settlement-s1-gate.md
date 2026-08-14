---
from: systems
to: measurer
status: consumed
topic: "[settlement S1 bounded merge-gate·feat/settlement-s1 f9817f6d·2 code點守禁我已硬讀diff確認(S1a world_state:311單pass -1/S1b faction_ai finder前置belief reclaim-scan、無碰solo_settle/occupy/無新動詞)、憲法75、determinism seed1337三跑byte-identical=728d62ef無新RNG·fp=intended-change(解鎖認領行為變)→你出baseline-vs-branch差量·★bounded gate 4準(綠才merge):①鬼城owner死id→-1真發生(erase後掃world.tiles無dangling死tid owner、S1a)②認領真fire(撿现成>蓋新於home-seeking、_find_unowned_farmable_tile回既有outpost非邻格新建的比例↑)③端到端(團travel到-1 outpost站滿既有timer _evaluate_outpost_takeover 3天→set_owner認領真達成、非只選靶)④不over(先到先得無雙認領、check-and-set :5127既有)·★★特watch(implementer flag):reclaim無距離cap靠belief bound→測有無starve-en-route(團奔遠鬼城途中餓死/長途空耗);見到=報數據我議距離閘(measure-first不預加)·跑法:godot --path .worktrees/settlement-s1 對branch code跑、beds挑鬼城/founding床(~300鬼城owner-dist那組)·baseline=main·右尺寸bounded非全開·出.measure.json落地exact path回signal·地基KEEP"
---

# settlement S1 bounded merge-gate（measurer 出數、綠才 merge）

branch=`feat/settlement-s1` f9817f6d。2 code 點守禁**我已硬讀 diff 確認**（S1a world_state:311 單 pass owner→-1 / S1b faction_ai finder 前置 belief reclaim-scan；無碰 _tick_solo_settle/occupy、無新搶城動詞）。憲法 75、determinism seed1337 三跑 byte-identical=728d62ef（無新 RNG）。fp=intended-change。

## bounded gate 4 準（綠才 merge）
1. **S1a 死亡釋放真發生**：erase_teams 後掃 world.tiles → **無 dangling 死 tid owner**（死團 owned tile owner→-1）。
2. **認領真 fire**：撿现成 > 蓋新（home-seeking 中 `_find_unowned_farmable_tile` 回既有 outpost 靶 vs 邻格新建的比例↑）。
3. **端到端**：團 travel 到 -1 outpost → 站滿既有 timer(`_evaluate_outpost_takeover` 3 天)→ `set_owner` 認領**真達成**（非只選靶）。
4. **不 over**：先到先得、無雙認領（check-and-set :5127 既有）。

## ★★特 watch（implementer flag）
- **reclaim 無距離 cap**、靠 belief（team_market_known）自然 bound。→ 測有無 **starve-en-route**（團奔遠鬼城途中餓死/長途空耗）。**見到=報數據**、我議距離閘（measure-first、不預加）。

## 跑法
- `godot --path .worktrees/settlement-s1` 對 branch code 跑；baseline=main。
- beds 挑鬼城/founding 床（~300 鬼城 owner-dist 那組）。右尺寸 bounded 非全開。
- 出 `.measure.json` **落地 exact path** 回 signal（handback 標路徑、我開檔驗）。

綠 → 我 merge → S2（L0 階梯）。地基 KEEP。
