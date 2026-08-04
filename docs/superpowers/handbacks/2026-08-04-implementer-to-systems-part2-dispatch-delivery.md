---
from: implementer
to: systems
status: consumed
topic: "[資訊網 Part2 dispatch-fix 交付·①spawn-ability applicable gate 治 regression ②求援 herald→anon 1 人 empty-handed 信使 修 dispatch=0·feat/info-network-whole 85edc4f6·TDD part2 7/7+herald 9/9+scout 9/9·headless 3=baseline·constitution 74·determinism 3 跑 byte-identical 2B7A0A5·util 一字不改 genuine·anon 零特權空手守 5 界]。can_send_herald=pop>=2/can_send_scout=named>=2 gate;dispatch_anon_messenger(leader_id=-1、1 anon pop、零 res carry)。待你 R² 融合驗→measurer re-measure whole(herald_dispatched>0+distribute>0+seed1337 regression 消+scout spare-named 假設)→QA。"
branch: feat/info-network-whole
commit: 85edc4f6
base: main（續 whole build）
---

# 資訊網 Part2 dispatch-fix — ①applicable gate + ②anon 信使（修 dispatch=0）

root（re-measure）：bootstrap 修好 applicable 但 **dispatch=0**——`_dispatch_help_herald` 需 spare NAMED subteam-leader、小餓 resident（症1 主角）無 spare named → 送不出。+ seed1337 regression（unexecutable-but-applicable option 進 rank 擾動）。

## ① applicable gate（look-before-leap、治 regression + 誠實）
- `decision_context`：`can_send_herald = population >= 2`（可分 1 anon 信使；pop 1 自己走 relocate）/ `can_send_scout = named_members.size() >= 2`（spare named 派斥候 subteam）。
- `options` 求援 applicable += `can_send_herald`；偵察 += `can_send_scout`。→ **unexecutable option 永不進 rank**（治 seed1337 regression：can't-send 隊 neutral、不擾軌跡）+ option 誠實（applicable=真能執行、同 買糧 has_buyable_food 前例）。

## ② 求援 herald = anon 1 人 messenger（≠subteam、無 named leader、村莊派個人求救）
- `subteam_system.dispatch_anon_messenger`：建 1-pop team `leader_id=-1`（無 named；population getter 不計 phantom→pop=1）、只搬 1 anon pop、**★empty-handed 零 resource carry**（R² tracking：餓 resident 任何 res 流失都在乎，**不沿 dispatch() proportional-split** 搬母隊全部 res 類型）、TAG_SUBTEAM、`current_task=HERALD reason=help_call`、gate `pop>=2`。
- `_dispatch_help_herald` reframe：`_pick_subteam_leader`（spare named）→ `dispatch_anon_messenger`。tick 沿既有 `_tick_help_herald`（belief-pos 物理走+delay、抵達 co-located deposit distress 進目標 team_known、途中可死走既有 encounter/attrition 不特赦）。
- **偵察保留 named subteam**（領主較大應有 spare named）——★re-measure 驗 `scout.dispatched>0`；若領主也普遍無 spare named→標 tracking 未來 scout 亦 anon 化。

## 守（R² 硬守）
- **util 一字不改 genuine**（真病=dispatch 不了、非 util 低；非 crank 讓 fire；per-option 分化保留：務實 0.640>傲 0.102、統領 0.800>野心 0.160）。
- **anon carrier 零特權**（不讀 target live state、只送 simple distress；名冊 target_pos 仍 position-only 組織常識）守 5 界。
- **determinism 零新 randf**（spawn/travel 確定性、死走既有 encounter 結算）；economy/pop 成本 1 真扣自限。

## 驗（全綠）
- TDD **part2 7/7**（anon spawn leader_id=-1 pop1 / ★empty-handed 零 res carry 母隊 food 不流失 / 端到端小餓 resident 全 anon→herald 送出=修 dispatch=0 根 / pop<2 不送）+ **herald 9/9**（+can_send gate look-before-leap）+ **scout 9/9**（+can_send_scout gate）。
- whole gate：**headless 3=baseline**、**constitution PASS 74**、**determinism 3 跑 byte-identical MD5 2B7A0A5**（≠前 E87F455=anon herald 真 dispatch + gate 治 regression；零新 randf）。

## ★待你 / 交 measurer（re-measure whole、canonical harness）
- **`help.herald_dispatched > 0`**（小餓 resident 現能送 anon 信使、bootstrap+dispatch 皆通）。
- **症1 解**：`distribute.dispatch / food_delivered > 0`（信使送 distress 達領主 team_known→distribute fire→convoy 送糧）。
- **seed1337 regression 消**（gate 後 can't-send 隊 neutral；attrition/starve 回穩）。
- `scout.dispatched`（驗領主 spare named 假設）+ 人格分化保留 + Part1+3 不退 + fog + economy 不爆 + ⚠attrition 健康性 + hub 效應。
- canonical WarringHarness 掛 specimen（中性、observer-RNG clean、禁手寫 loop）→ QA 故事稽核（回溯三因果+whole verdict ref）→ blueprint JUDGE → 用戶驗收。

★誠實 measured 才宣稱（[[feedback_verify_execution_end]]）。待你 R² → measurer whole → QA → blueprint。
