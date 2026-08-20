#!/usr/bin/env bash
# PostToolUse hook（Bash|PowerShell）：偵測「長跑 sim」完成 → 注入工作流硬規則提醒「此長跑必經 QA 故事稽核才可下 behavior 因果結論/spec」。
# 用戶定 2026-07-22：長跑才是成本所在，付了成本就該取 QA 價值；綁 hook 非 session 記憶（記憶不可靠——當日 3 次翻案佐證）。
# stdin = 工具呼叫 JSON。無 jq → grep 撈 command。
# 長跑 = godot 跑 sim bed（warring/game_sim/world_sim/specimen/economy/despladder/detach/大窗）。
# 豁免（快跑，非長跑，不需 QA）：--import / headless_test / constitution_gate / observability_gate / *_test.gd / ui_flow / probe_ / control-scenario 秒級床。
cmd=$(cat)
# 只看 command 欄
line=$(printf '%s' "$cmd" | grep -oiE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
# 非 godot 呼叫 → 不管
printf '%s' "$line" | grep -qiE 'godot' || exit 0
# 快跑豁免 → 不注入
printf '%s' "$line" | grep -qiE '(--import|headless_test|constitution_gate|observability_gate|_test\.gd|ui_flow|probe_stats|tracer_completeness)' && exit 0
# 是 sim --script（或 detach/背景長跑）→ 長跑，注入 QA 硬規則
printf '%s' "$line" | grep -qiE '(--script|detach|WARRING|SPECIMEN|game_sim|world_sim|seeded_warring|_bed\.gd|despladder|economy)' || exit 0
printf '%s' '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"★長跑 sim 完成——工作流硬規則（用戶定 2026-07-22，綁 hook 非記憶）：此長跑**必附 specimen trace（SpecimenDumpHelper，非只 aggregate JSON——光聚合 QA 履不了職）→ 送 QA 故事稽核**（讀 motive→action→outcome）才可下 behavior 因果結論 / 鎖 spec / 餵 blueprint。禁跳 QA 自讀 metric/樣本自判（當日 3 次翻案：食物聚合誤讀 / facility-argmax 因果 / GateA divert-metric，全因結論建在未經 QA 故事驗證的 metric 上；metric/工具會騙）。純聚合 metric（determinism/doom% release-gate）不下 behavior 因果者可免。沒長跑=不需 QA。"}}'
exit 0
