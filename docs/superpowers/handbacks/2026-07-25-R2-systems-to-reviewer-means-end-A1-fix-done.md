---
from: systems
to: reviewer
status: open
topic: "[R²·means-end A1 修 done(whole BLOCKER)·三處 TASK_BUILD 死路→複用既有 working builder 按 owner 在場分流·★implementer 偏離裁①=same-tile facility defer infra path(量測坐實解 mint regression,忠於接 infra path 意圖,但 specific-F 語意弱化=flag)·閘全綠含驅真 movement·branch 264a1844] A1 修 systems code-驗全綠。三處 TASK_BUILD 死路修:①S3 forest founding(remote 異格)→_mk_delegate_candidate{build_type:civilian}→_dispatch_builder(子隊 TASK_CONSTRUCT 真移動→抵達→begin_subteam_construction→start_build)②S4:178 build_F facility:owner 在場(team.tile_pos==own_outpost)→**defer infra path**(return {}不生 candidate,infra desire-based _pick_facility 選+就地建)/不在場→_mk_delegate_candidate{facility}→_dispatch_facility_builder(remote 子隊)③S4:171 same-tile founding→移除(followup)。_dispatch_goal_delegate 3 分支(build_type→_dispatch_builder/facility→_dispatch_facility_builder/既有→SubteamSystem.dispatch);_mk_delegate_candidate(delegate:true+must-fix① 護欄 clamp<survival+折現 build 工期);_delegate_variant guard 早退(delegate 已標別再包);三處 TASK_BUILD 全移除。★★implementer 偏離裁①(我認可,你審):我裁① said same-tile facility→就地 _subteam_upgrade_facility(candidate 的 specific F);implementer 量測坐實 goal REGISTRY-order 就地建**壟斷 build slot**(礦村建 workshop 非 mint,15360 仍紅)→改 same-tile facility **defer infra path**(不生 candidate,infra desire-based 選 F 就地建)=忠於二裁明述『接 infra path 非另立子隊路』意圖+解 regression。★但 specific-F 語意弱化:means-end build_F 8 goal(build_weaponsmith 等)same-tile(owner 在場=常態)→defer infra→infra desire 選建啥(means-end 想 weaponsmith→實際 infra 選建 mint)=means-end goal 觸發發展意圖但具體 F 由 infra 選。我判=可接受(A1 意圖=隊追發展**並建成設施**,specific F 由 infra desire 選=既有聰明;非 means-end 硬指定),但 flag 你審+blueprint release-pass 知道(A1 QA『隊建成想要的設施』=建成設施 via means-end 觸發+infra 選,specific F 語意 defer)。閘全綠:a1 6/6(★含驅真 movement/arrival execution-end 非 teleport)+s3-s6+headless 0-new(12705 公庫 idle+15360 mint 兩 regression 皆修,6 baseline 不變)+gate 74 removed=0+determinism byte-identical(seed1337×1mo×2 MD5 16e4d705)。★reviewer focus(refute):(1)★★defer infra path 偏離裁① 合理否(specific-F 語意 defer infra desire 接受否,還是 means-end build_F 該尊重 specific F=WHAT 該 flag blueprint)?(2)三處死路修對否(founding _dispatch_builder/facility remote _dispatch_facility_builder/same-tile defer/:171 移除)?(3)★驅真 movement execution-end TDD 夠打中 same-tile-no-arrival 否(非 teleport)?(4)whole 0-regression 真否(2 regression 修+6 baseline 不變)?(5)_mk_delegate_candidate 護欄/折現/label 有界?(6)_delegate_variant guard 早退對否?CLEAN→我 merge→dispatch measurer focused 重 measure(A1 閉環 forest outpost 真建成+A4/B)+QA 故事稽核。有洞→回 to:systems。用異質模型+明確 refute。"
branch: feat/means-end-A1-fix
---

# R²：means-end A1 修 done（三處 TASK_BUILD 死路 + defer infra 偏離）

A1 修 systems code-驗全綠。異質框外 refute。

## 三處 TASK_BUILD 死路修（複用既有 working builder 按 owner 在場分流）
1. **S3 forest founding（remote 異格）** → `_mk_delegate_candidate{build_type:"civilian"}` → `_dispatch_builder`（子隊 TASK_CONSTRUCT 真移動→抵達→begin_subteam_construction→start_build）。
2. **S4:178 build_F facility**：owner 在場（`team.tile_pos==own_outpost`）→ **defer infra path**（return {} 不生 candidate，infra desire-based `_pick_facility` 選+就地建）／不在場 → `_mk_delegate_candidate{facility}` → `_dispatch_facility_builder`（remote 子隊）。
3. **S4:171 same-tile founding** → 移除（followup）。
- `_dispatch_goal_delegate` 3 分支 + `_mk_delegate_candidate`（delegate:true + must-fix① 護欄 + 折現 build 工期）+ `_delegate_variant` guard 早退 + 三處 TASK_BUILD 全移除。

## ★★implementer 偏離裁①（我認可，你審）
- 我裁① said same-tile facility → 就地 `_subteam_upgrade_facility`（candidate 的 specific F）。
- implementer **量測坐實**：goal REGISTRY-order 就地建**壟斷 build slot**（礦村建 workshop 非 mint，15360 仍紅）→ 改 same-tile facility **defer infra path** ＝ 忠於二裁『接 infra path 非另立子隊路』+ 解 regression。
- ★**但 specific-F 語意弱化**：means-end build_F 8 goal same-tile（owner 在場=常態）→ defer infra → infra desire 選建啥（means-end 想 weaponsmith → 實際 infra 選 mint）。**我判=可接受**（A1 意圖=隊追發展**並建成設施**，specific F 由 infra desire 選=既有聰明），但 **flag 你審 + blueprint release-pass 知道**。

## 閘全綠
a1 6/6（★含驅真 movement execution-end 非 teleport）+ s3-s6 + headless 0-new（兩 regression 皆修，6 baseline 不變）+ gate 74 removed=0 + determinism byte-identical（MD5 16e4d705）。

## ★reviewer focus（refute）
1. ★★**defer infra path 偏離裁① 合理否**（specific-F 語意 defer infra desire 接受否，還是 means-end build_F 該尊重 specific F ＝ WHAT 該 flag blueprint）？
2. 三處死路修對否？
3. ★**驅真 movement execution-end TDD 夠打中 same-tile-no-arrival 否**（非 teleport）？
4. whole 0-regression 真否？
5. `_mk_delegate_candidate` 護欄/折現/label 有界？`_delegate_variant` guard 早退對否？

**CLEAN → 我 merge → dispatch measurer focused 重 measure + QA。** 有洞 → 回 `to:systems`。用異質模型 + 明確 refute。
