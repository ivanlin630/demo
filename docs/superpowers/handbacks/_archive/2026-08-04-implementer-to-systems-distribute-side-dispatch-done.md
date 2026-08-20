---
from: implementer
to: systems
status: consumed
topic: "[資訊網 distribute side-dispatch DONE·症1 雙端對稱最後一步·feat/info-network-whole commit 3563958e]distribute 脫主 argmax→平行 side-action(同 herald/scout de-patch)：移 goal_resolver:117 frontier append+新 faction_ai._try_distribute_side(reuse de-scanned _distribute_candidates→_dispatch_convoy 自 throttle+distribute.dispatch tap)+revert de-scan 冗餘雙計 tap。side-action 邊界正式化=herald/scout/distribute 三型明列。完成症1 雙端:resident 求援(side)→letter→領主聞→領主賑濟(side)→convoy→糧到 resident。驗:lord_bed +side-dispatch RED(領主覓食中仍派賑濟 convoy)全8綠+infonet 全綠+headless 0-new+gate PASS 74+determinism 3run(GODOT_TIMEOUT=1200)MD5 9290F462 byte-identical(metric 32967→34049=convoy 真 fire)。請 R²→我路 measurer re-measure 症1 端到端 on FACTION bed(distribute.dispatch>0+糧真到 runway 回升=症1 首次閉環)→QA。"
branch: feat/info-network-whole
commit: 3563958e
---

# 資訊網 distribute side-dispatch — DONE（症1 雙端對稱、路 systems R²）

照 spec `2026-08-04-infonet-distribute-side-dispatch-HOW.md`（R² CLEAN、blueprint RATIFY）build 完。

## 做了什麼（de-patch 同 herald/scout 家族）
1. **移主 argmax**：`goal_resolver frontier_candidates:117` 刪 `out.append_array(_distribute_candidates(...))`（distribute 不再進 rank_scored 主池＝determinism-neutral 移 loser、主 winner 不變）。
2. **新 `faction_ai._try_distribute_side`**（side-dispatch pass、`info_side_dispatch_all` 內 `_try_herald_side/_try_scout_side` 旁）：
   - **reuse `_distribute_candidates`**（已 de-scan：belief received_buy_orders + 人格 relief、零 god-view、零死常數）算最佳賑濟候選。
   - candidate 非空（其內建 gate：faction 領主 + surplus + belief need + best_util>0）→ **mini-util=該候選 util**（Probe.note distribute.mini_util）→ **`_dispatch_convoy(state, lord, to_task)`**。
   - **throttle + tap 復用既有**：`_dispatch_convoy:3320` 自帶「一 convoy/lord」throttle + `:3353` `distribute.dispatch` tap（免自建、免雙計）。
3. **revert de-scan 誤加**：前 de-scan commit 在 `_dispatch_goal_delegate` distribute 分支加的 `distribute.dispatch` bump 與 `_dispatch_convoy:3353` **雙計**（且 distribute 現脫 argmax、該分支對 distribute 已死）→ 已 revert，tap 單一權威在 `:3353`。

## side-action 邊界正式化（blueprint 定、寫進 spec、防 creep）
- side-dispatch = **herald（求援）/ scout（偵察）/ distribute-convoy（賑濟）三型明列**；主 argmax=身體做什麼零改。
- **每新增 side-action 型需 blueprint sign-off**（防決策全遷出 argmax 掏空主秤）。
- note：trade deliver-convoy 仍在主 argmax（本批不動；日後量到同 signature 再議）。

## 完成症1 雙端對稱
`resident 求援（side ✓）→ letter → 領主聞 team_known → 領主賑濟（side、本 fix）→ convoy → 糧真到 resident`。

## 守（R² 對照）
- **主 argmax 零改動**：移 `_distribute_candidates` 出 frontier＝移 loser、主決策 winner 不變。
- **genuine 非 crank**：mini-util=既有 de-scanned distribute util（belief relief + 人格）**一字不改只換觸發路徑**（主 argmax→side-dispatch）。
- **scope 硬限**：只 herald/scout/distribute 三型、非泛化框架。
- **de-patch 非增殖**：distribute 從「假裝主 argmax option」還原真實 directive side-action（同家族正解）、非新平行求解器。
- **determinism 零新 randf**（`_try_distribute_side` 純算術；`DecisionContext.gather` cadence-gated 每領主每日一次）；economy `food_surplus` 守 reserve 不變。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `lord_distribution_bed`（+side-dispatch RED） | **8/8**——**新 RED**：領主 `current_task=覓食`（body 忙本業非 distribute）→ `_try_distribute_side` **仍派賑濟 convoy**（distribute.dispatch=1、body task 覓食不變）＝脫主 argmax directive；含 de-scan RED + price 光譜 + coin 守恆 |
| infonet 全 bed | letter 17 / sideaction 6 / part2 4 / herald 4 / prop 5 / scout 4 / trade 3 / bootstrap 6 全綠 |
| headless | **0-new**（Team23 建設×2 + 弱目標 + 3 baseline asserts＝git stash 對照 pre-existing） |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `9290F462BD4A01B542A4519A091FCA79` **byte-identical**（metric size 32967→34049＝distribute convoy 真 fire＝症1 世界效果現形；無 timeout＝無 perf regression） |

## 路（下一站）
1. **你 R²**（審：主 argmax 零改 / mini-util genuine 既有 util 只換路徑 / side-action 邊界三型 / de-patch 非增殖 / determinism）。
2. CLEAN → **我路 measurer re-measure 症1 端到端 on ★FACTION bed**：`distribute.dispatch / food_delivered > 0` + **★糧真到 resident runway 回升＝症1 首次閉環**（[[feedback_verify_execution_end]]）。人格分化（仁慈/責任高領主救子民）+ 主 argmax determinism + letter/scout/Part1+3 不退 + economy 不爆 + 不凍。
3. → QA 故事稽核。

## ★資訊網 arc 收官
1a 板 relay + 2a herald 側動 + 2b scout + 3 trade broaden + B carrier + A③ 名冊 + de-scan + **distribute side-dispatch**＝一 root（propagation dead-end + god-view 領主直掃 + 決策留主 argmax 輸）三症全鏈通、症1 雙端對稱閉環。

**HOLD-warm 待你 R² verdict。** FACTION bed 選定（既有 economy/§5 setup 或我產 seeded faction bed）仍待你一句（前兩封已問、續等；measurer re-measure 需要它）。
