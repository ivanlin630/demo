---
from: implementer
to: systems
status: consumed
topic: "[care-loop scout de-patch DONE·feat/careloop-scout-depatch commit 89af4837]★修 _dispatch_care_scout vpos 三層 fallback:既有兩層(belief.tile_pos→last_known_pos)零覆蓋、其後補第三層 roster(vpos==-1→_faction_roster_pos、仍-1才 return)。守全:①兩層零覆蓋 roster 純加 final②感知鐵律 roster position-only 非 god-view(scout 仍物理走+founding_timeout+抵達親見)③own-faction only④throttle 不動⑤零 crank。驗:careloop_scout_test 3/3(roster fallback→scout 真派 care.scout_dispatched=1 破 silent-return / 村無 outpost silent / 他勢力 silent own-faction)+constitution 75(roster=既有 baselined gate-ok accessor 無新 site)+headless 0-new。★★量測差異呈報:fp 對 ce201650 3 標準床 27/27 byte-identical=roster-fallback 在標準床 DORMANT(belief/快照 populated→第三層不觸、與 dispatch 的『fp 分化 intended』預期不符);fix 行為變是 scenario-specific(belief-lost death-spiral)=unit test 坐實觸發、須 measurer seed8181 dispersed death-spiral 床才顯。determinism 保持(byte-identical、roster 靜態零 RNG)。請 R²(核三層保序+感知鐵律 roster 非 god-view+scout 真 fire)→measurer 量 death-spiral(seed8181 dispersed 45天:Team2 存活/relief_dispatched/defect 消)→QA specimen→merge。"
branch: feat/careloop-scout-depatch
commit: 89af4837
---

# care-loop scout de-patch DONE（ii relief-cluster 第一刀、補丁閘 execution-break）

feat/careloop-scout-depatch commit `89af4837`（已 push、pre-push constitution PASS 75）。

## ★修（三層 fallback、§HOW-binding 全守）
`_dispatch_care_scout` vpos：**既有兩層**（`belief.tile_pos → entry.last_known_pos` 快照）**零覆蓋**、其後**補第三層 roster**——`vpos==(-1,-1)` → `vpos = _faction_roster_pos(state, team, vid)`；仍 `(-1,-1)` 才 return。破「belief/快照皆空→領主查不了子民」silent-return execution-break。
- ①兩層零覆蓋、roster 純加 final fallback。②**感知鐵律**：roster = position-only 組織常識（領主知村靜態 outpost 位）非 god-view；scout 仍 `dispatch_anon_messenger` 物理走 + `founding_timeout` 延遲 + **抵達親見 state**（領主不因 roster 知村餓）。③own-faction only（`_faction_roster_pos` factionless/他勢力→-1 silent 保）。④throttle 不動。⑤零 crank（`_pick_care_reaction` 零改）。

## 驗
| 閘 | 結果 |
|---|---|
| `careloop_scout_test` | **3/3 PASS**：belief/last_known 空 + own 村有 outpost → roster fallback → **scout 真派**（`care.scout_dispatched=1`、破 silent-return）/ 村無 outpost → silent 保 / 他勢力 → silent（own-faction only） |
| constitution_gate | **PASS sites=75**（roster = 既有 baselined `_faction_roster_pos` gate-ok accessor、`_dispatch_care_scout` 無新 god-view/gate site） |
| headless | **0-new** |
| determinism | 保持（fp byte-identical to 3-run-stable ce201650、roster 靜態零 RNG） |

## ★★量測差異呈報（透明、非隱瞞）
fp 對 ce201650 **3 標準床（warring/peaceful/recovery）27/27 byte-identical、changed=0**——roster-fallback 在標準床 **DORMANT**（這些床 belief/快照 populated → 村位查得到 → 第三層 roster **不觸發**）。
- ★這**與 dispatch 的「fp 分化 intended（領主開始 scout）」預期不符**：標準 fp 床沒 exercise roster-fallback 路徑。
- fix 的行為變是 **scenario-specific**（belief-lost death-spiral：contact-ledger 逾時 + belief/快照過期成空 才觸第三層）——`careloop_scout_test` 已**坐實** roster fallback 觸發（belief 空→scout 真派）。
- ∴ 行為變**只在 death-spiral 場景顯**，須 **measurer seed8181 dispersed 45天**（Team2 belief 隨 dispersed 流失 → roster fallback → scout → 親見餓 → relief → defect 前得救）才量得到。標準 fp 床捕不到（非 regression、是 fix 精準對症=dormant-unless-needed）。

## 路
1. **你 R²**（核：三層保序[兩層零覆蓋+roster final] + 感知鐵律 roster 非 god-view + scout 真 fire + own-faction/silent 保）。
2. → **measurer 量 death-spiral**（seed8181 dispersed 45天：Team2 存活否 / relief_dispatched true / defect(day25) 消否 / dispersed attrition 降）——★這是行為變真顯處（標準 fp 床 dormant）。
3. → QA specimen（scout→親見→relief→defect 前得救）→ merge → re-measure scale。★staged：量 death-spiral 破否再定 2a 求援-ordering / A propagation follow-up 需不需（勿本 slice 過 fix）。

地基 KEEP。（F2 disk flag 仍待 systems prune ~115 stale worktrees。）
