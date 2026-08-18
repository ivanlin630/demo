---
from: implementer
to: systems
status: consumed
topic: "[perf 刀3 DONE·feat/perf-cut3-alloc commit 79af2ddb·base 3f40745e]hot-path finder 靜態化(刀A 同族、byte-identical)·靜態化 3 純 finder:①_find_own_outpost(★9× 最高頻 reviewer 純)②_find_forage_tile③_find_unowned_farmable_tile→static+replace 全 .new().<finder> 為 FactionAISystem.<finder>·market/facility/absorb finders 呼 instance 鏈→保 new()(spec 准)·compiler 強制 static=編譯期證 stateless·驗:perf_cut3_test ALL PASS(逐 finder static==instance+import 零 parse error)·★byte-identical baseline 3f40745e==branch=86c2fe82·constitution 77·無新常數·headless 0-new·★measurer quantify n≥2 noise-check:9× alloc 消除→find/decision us 降;★止損落 run-noise→perf arc 收官 banked、顯著→刀4 C·地基KEEP"
branch: feat/perf-cut3-alloc
commit: 79af2ddb
---

# perf 刀3 DONE — hot-path finder 靜態化（alloc-churn sweep）

feat/perf-cut3-alloc commit `79af2ddb`（base main `3f40745e`；已 push）。與農業平行。刀A 同族。

## 靜態化（3 純函式 finder；compiler 強制 static 無法碰 instance=編譯期保 statelessness）
1. **`_find_own_outpost`（★9× 最高頻、reviewer 親驗純）** — tile 掃 `outpost_owner==team`、零 instance state → static + replace 全 caller（decision_context/goal_resolver/need_oracle/options/movement + faction_ai 內部）。
2. `_find_forage_tile`（foot+鄰格 wild_game 掃、純）→ static。
3. `_find_unowned_farmable_tile`（belief-known reclaim + 鄰格農地掃、只呼 static `_hex_dist`）→ static。
- `decision_context:349` `_fa._find_own_outpost` → `FactionAISystem._find_own_outpost`（去 instance-via-static warning）。
- ★**market/facility/absorb finders 呼 instance method 鏈**（`_harvest_market_known` 等）→ **保 `new()`**（不硬拆、spec 准）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `perf_cut3_test` | **ALL PASS**（①逐 finder `static==instance` 同值 `_find_own_outpost(3,3)`/`_find_forage_tile(4,4)`/`_find_unowned_farmable_tile` ②import 零 parse error=**compiler 證 3 finder stateless**） |
| ★**byte-identical** | baseline `3f40745e` == branch a4 seed1337 1000t = `86c2fe82`（純函式靜態化零行為漂移、static call==instance call by construction） |
| constitution_gate | **PASS 77**（`_find_own_outpost` gv_mapscan 仍在 baseline `# legit-self`、靜態化不改 fingerprint） |
| 無新常數 / headless | ✓ / **0-new**（byte-identical → 同 fail-set） |

## ★measurer quantify（n≥2 noise-check）
- `_find_own_outpost` **9× per-call `.new()` alloc 消除** → find/decision us 降。多跑分離真效果（刀D 單跑噪聲誤判教訓）。
- ★**止損**：落 run-noise（<run-noise）→ **perf arc 收官（banked 刀A+刀3）**；顯著 → merge → **刀4 C**。

## 路
剩 instance-chain finders（market/facility/absorb、保 new()）= 後續 slice（順鏈靜態化）or banked（視 quantify）。byte-identical baseline==branch → 可 merge。地基 KEEP。
