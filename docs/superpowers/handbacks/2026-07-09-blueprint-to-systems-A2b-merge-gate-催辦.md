---
from: blueprint
to: systems
status: consumed
topic: 催辦——A2b QA GREEN+用戶收,code 未進 origin/main;請跑 merge-gate 收 feat/A2b-impl→main
---

# 催辦：A2b merge-gate

## 事實（git 查證 2026-07-09）
- **QA RELEASE GREEN + 用戶已收**（「就這樣」定案）。願景放行在案。
- **但 code 未 merge**：`origin/main` 只見 docs/handback commit，A2b tactical engine code 仍留 `feat/A2b-impl`（7 commit 不在 main）：
  - `6b43ef9` refactor(A2b): leader 隊戰術執行納統一引擎（拆 _assign_tasks 手 cascade + note_bypass，leader_bypass→0）
  - `c86dfad` feat(A2b): intent 選擇 cadence-gate（1 日重選）
  - `cc364b7` feat(A2b): 守衛 A/B probe 埋點（leader 攻擊 + 遠距貢賦 dispatch→settle 對帳）
  - +spec/plan/measure/handback commits
- `git branch --merged main | grep A2b` = 無。

## 請系統做（merge = 你的職，藍圖不碰）
1. 跑 **憲法 site-freeze 閘**：`.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`（綠才 merge）。
2. 跑 **融合驗/framework 回歸**。
3. 綠 → merge `feat/A2b-impl` → `main` → push origin。

## 提醒
- **constitution_gate pre-existing bug**（measurer 第二輪撞）= 非 A2b 引入(main 自身也犯)→ 歸 `known_issues`、**不扣 A2b merge**。詳 `blueprint-to-systems-A2b-preexisting-not-guilty.md`(consumed)。
- merge 完回信 blueprint 信箱（status→consumed + 一行「A2b merged @ <sha>」）。

## 併：measurer 流程規則待寫 doc
- `blueprint-to-systems-measurer-single-complete-letter.md`(open) 仍待你寫進 `03b_measurer.md`/`07`（一次量完寄一封完整信,禁分批/append；禁 append consumed 信,修訂走新 open 信）。apply A2c 起。
