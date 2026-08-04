# 資訊網 Part2 dispatch fix — ①applicable gate + ②anon 信使 — HOW spec

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint 裁 GO 2026-08-04） | **branch**: `feat/info-network-whole`（續）
**root**: RE-measure 揭 bootstrap 修好 applicable 但 dispatch=0——`_dispatch_help_herald:1446` 需 spare NAMED sub-leader、小餓 resident（症1 主角）無 spare named→送不出。+ seed1337 regression（unexecutable-but-applicable option 進 rank）。
**WHAT 裁**：blueprint `anon-messenger-ruling`——①gate GO；②(a) **信使≠subteam=anon 1人跑腿**（村莊派個人求救=用戶核心例、requiring named=subteam 機具 artifact）。

## ① applicable gate（look-before-leap、治 regression + option 誠實）
DecisionContext 加兩 flag（純算術、零 RNG）：
- **`can_send_herald` = `team.population >= 2`**（可分 1 anon 當信使；1 人隊自己走=既有 relocate 路、`help_need_severity` gate 已在）。
- **`can_send_scout` = `team.named_members.size() >= 2`**（有 spare named 於 leader 外；偵察保留 named subteam 互補）。

改 applicable（`options.gd`）：
- **求援**：`not is_subteam and help_target_id != -1 and help_need_severity > 0 and ctx.can_send_herald`。
- **偵察**：`not is_subteam and scout_target_id != -1 and scout_staleness > 0 and ctx.can_send_scout`。

→ **unexecutable option 永不進 rank**（治 seed1337 regression：can't-send 隊回 neutral、不再擾動軌跡）+ **option 誠實**（applicable=真能執行）。

## ②(a) 求援 herald = anon 1 人 messenger（≠subteam、無 named leader）
`_dispatch_help_herald` **reframe**：不再 `_pick_subteam_leader`（spare named subteam）→ **spawn anon 1-pop messenger**：
- **新 spawn 路**（`_spawn_anon_herald` 或 adapt）：建 1-pop team、**`leader_id = -1`**（無 named leader；team infra 已容 leader_id=-1，subteam_system:57/200 phantom-leader 處理）、**pop 從 mother anon 扣 1**（真 pop 成本、自限）、`current_task=TASK_HERALD`、`task_reason="help_call"`、target=help_target_pos、`task_extra_data={help_origin, timeout, distress:{res:"food", need}}`。
- **內容 simple distress**（「我餓、在 X」＝母隊 need buy-order/求援訊）、**非複雜情報**。
- **tick（沿用 `_tick_help_herald`）**：朝 help_target_pos 物理走（delay）；抵達/co-located→deposit distress msg 進目標 team_known（honest intra-faction）→ 任務畢（dissolve/歸建）。
- **途中可死 = 真風險**：1-pop 信使走路遇 encounter/attrition 正常死結算（不特赦）。
- gate：`team.population >= 2`（同 ① can_send_herald；`pop<=1→false` 保留）；target 有效。

## 偵察（保留 named subteam 互補、待驗）
- `_dispatch_info_scout` 維持 named subteam（領主較大、應有 spare named）。**★re-measure 驗領主真有 spare named**（scout.dispatched>0）——若領主也普遍無 spare named→標 tracking、未來 scout 亦 anon 化。

## 守（reviewer R²）
- **人格非常數 / genuine 非 crank**：help/scout **util 一字不改**（發不發=leader 人格秤、傲撐/務實早求不變）；① gate=可執行性 look-before-leap（同 買糧 `has_buyable_food` 前例）、非 crank。
- **②非新感知（守 5 硬界）**：anon carrier **零特權知識**（不讀 target live state、只送 simple distress；名冊 target_pos 仍組織常識 position-only）；物理走+delay；`constitution_gate` 綠。
- **determinism 零新 randf**（spawn/travel 確定性；死亡走既有 encounter 結算）。
- **economy/pop**：pop 成本 1（真扣、自限）；economy 不爆。
- **無框內平行求解器**：reframe 既有 `_dispatch_help_herald`（spawn 路換）、非增殖 option/solver。

## 驗收（re-measure whole、我路 measurer）
- **`help.herald_dispatched > 0`**（小餓 resident 現能送 anon 信使）+ **`distribute.dispatch / food_delivered > 0`**（症1：信使送 distress 達領主 team_known→distribute fire→convoy 送糧）。
- **seed1337 regression 消**（① gate 後 can't-send 隊 neutral；併驗 attrition/starve 回穩）。
- `scout.dispatched`（驗領主 spare named 假設）。
- 人格分化保留、Part1+3 不退、determinism byte-identical、economy 不爆。

**路 reviewer R²（審 ①gate look-before-leap + ②anon-herald 守 5 界零特權 + genuine + determinism）→ CLEAN → build（續 `feat/info-network-whole`）→ re-measure whole（canonical harness）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。**
