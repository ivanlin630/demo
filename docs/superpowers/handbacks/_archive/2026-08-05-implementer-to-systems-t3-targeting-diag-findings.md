---
from: implementer
to: systems
status: consumed
topic: "[T3 錯位診斷真值·measure-first 定 root·feat/info-network-whole commit e2870543]★root 非 distribute、在 UPSTREAM GameSetup faction 指派錯亂:3-station tap 證 distribute candidate/convoy-target/settle 三站全正確(T2 fac1 聞 T1 fac1 gate_same_fac TRUE→選 T1 同勢力 OK→settle terminus=T1=tile_owner OK)·真 root=game_setup.gd:577-578 create_faction 給 SEQUENTIAL in-sim id(0,1)非 config faction_id(1,2)+:580-586 非 leader 用 config faction_id 字面查→T1(cfg fac1)誤入 T2 faction(insim fac1)、T3(cfg fac2)factions.has(2)=NO→orphan fac-1→無 lord 賑濟→死 day42·in-sim map:T0=fac0 T1=fac1 T2=fac1 T3=fac-1(≠config)·distribute 機制無 bug=arc 正解、症狀=fixture faction 佈線 bug·blast radius:改 GameSetup faction 映射影響所有 explicit config 床→你定 root(GameSetup 映射修 vs config 慣例)。dump docs/measurements/2026-08-05-t3-crossfaction-targeting-diagnostic.json。"
branch: feat/info-network-whole
commit: e2870543
measurements: docs/measurements/2026-08-05-t3-crossfaction-targeting-diagnostic.json
---

# T3 cross-faction relief 目標錯位 診斷真值（measure-first、定 root、別下修結論）

3-station tap（Probe-gated 零行為）+ `t3_targeting_diag_bed`（`config/infonet_whole.json` seed 1337 inline、純觀測）。**★root 非 distribute——在 UPSTREAM GameSetup faction 指派。**

## ★★真 root：GameSetup faction 指派錯亂（config faction_id 未被 honored）
**in-sim faction map ≠ config**：
| team | config faction_id | **in-sim faction** |
|---|---|---|
| T0（lord1、is_leader） | 1 | **0** |
| T1（resident1、非 leader） | 1 | **1**（=T2 的!） |
| T2（lord2、is_leader） | 2 | **1** |
| T3（resident2、非 leader） | 2 | **-1**（orphan） |

**機制（`game_setup.gd`）**：
- `:577-578` leader → `state.create_faction(int(t_cfg["id"]))`；`create_faction` 給 **SEQUENTIAL** in-sim faction_id（`_next_faction_id` 0,1,2…），**非 config `faction_id`**。→ T0 create→insim **fac0**、T2 create→insim **fac1**。
- `:580-586` 非 leader → `fid2 = 字面 config faction_id`；`if state.factions.has(fid2): set_team_faction(team, fid2)`：
  - **T1 cfg faction_id=1** → `factions.has(1)`=YES（那是 **T2** 的 insim fac1！）→ **T1 誤入 T2 的 faction**。
  - **T3 cfg faction_id=2** → `factions.has(2)`=NO（只建了 0,1）→ skip → **T3 orphan（faction_id 留 -1）**。
- ＝config faction_id（grouping key 1,2）與 create_faction sequential id（0,1）**off-by-one 錯位**、非 leader 佈線全錯。

**後果（症1 端）**：T2(insim fac1) 聞 T1(insim fac1) `gate_same_fac=TRUE`→正確賑濟 T1（機制對）；**T3 orphan 無 lord→從不被賑濟→死 day42**。measurer 看到的「T2 relief 鎖 T1 非自家 T3」＝T1 確實在 T2 faction（指派錯）、T3 根本不在任何 faction。

## 逐站卡站表（distribute 機制**全正確**、無 bug）
| 站 | tap | 結果 |
|---|---|---|
| ①candidate | `diag.dist_heard` | T2(fac1) 聞 rid=T1(fac1) `gate_same_fac=true` opos=(18,14)——gate 正確評 same-faction（因 T1 真在 fac1） |
| ①pick | `diag.dist_pick` | T2 選 rid=T1(fac1) mpos=(18,14)＝**同勢力 OK**（gate 未被繞、選對「自己 faction 的 resident」——只是該 resident 被指派錯） |
| ③settle | `diag.dist_settle` | porter terminus=T1 → 實際 tile_owner=T1(fac1) tile=(18,14)＝**收貨=terminus OK**（settle 無撿 co-located 錯人；T1/T3 tile 不同格） |
| survival | — | T1 存活（pop 10→2）；**T3 death_tick day42**；`distribute.dispatch=5 deliver=9 food_delivered=58` |

→ **systems 預判的 2 root（gate 繞 / settle 撿錯人）皆排除**；真 root 是**第三處＝GameSetup faction 佈線**（config faction_id 未 honored）。**distribute/carrier/de-scan/side-dispatch/free-relief 全鏈機制無 bug＝資訊網 arc 正解、被此 fixture bug 遮蔽。**

## 待你定 root（別下修結論、blast radius 大）
- **修法選項（你 HOW 定）**：(A) **GameSetup 映射修**——create_faction 時建 `config_fid→insim_fid` 對照 dict、非 leader 用它查（honor config faction_id 為 grouping key）＝正解但**影響所有 explicit config 床**（每床 faction 佈線會變、需回歸各床）。(B) config 慣例——要求 explicit config faction_id 用 0-indexed contiguous 且對齊 create 順序（脆、治標）。
- ★**blast radius**：(A) 改 GameSetup 動全 explicit-config 世界的 faction 結構＝非 surgical、需你裁 + 可能回歸掃。故我 **HOLD 不逕修**（守診斷 scope + 避免大 blast 未授權改）。
- 定 root 後 dispatch：我可做 (A)（GameSetup config_fid→insim_fid 映射）或 (B)（改 infonet_whole config faction_id）。

★measure-first、只交真值（[[feedback_verify_execution_end]]、[[feedback_structural_audit_complement]]＝症狀下游、根在上游 GameSetup）。3-station tap 零行為（`Probe.bump_sample` 純觀測、`terminus_team_id` 欄 inert、determinism 不受影響）。dump 全樣本落地。**HOLD 待你定 root。**
