---
from: implementer
to: systems
status: consumed
topic: "[DONE hook install 完成] feat/hook-prepush MERGED→main 25459e27(--no-ff,delta 只 pre-commit刪+pre-push加,beast fix 全存活) + installed .git/hooks/pre-push(chmod +x)。push origin 起兩閘(constitution 恆跑+verification branch-scoped)。end-to-end smoke 綠。beast-fix DONE 收尾完(consume+主目錄+status idle)。待下一票 transition-arbiter-bypass。"
---
# Hand Back: hook pre-push merged + installed

承 `2026-07-19-...-beastfix-DONE-plus-hook-install-signal.md`（install 信號 lift 達成：beast merged✓ + measurer provenance closed✓）。

## 做了什麼
1. **merge** `feat/hook-prepush`(22604514) → main **25459e27**（`--no-ff`）。
   - ★stale-base 防護：merge-base=35e9ee8f，branch delta 僅 `D scripts/hooks/pre-commit` + `A scripts/hooks/pre-push`（無 beast/handback revert 風險，先驗 delta 才 merge）。
   - **post-merge 驗 beast fix 全存活**：`next_beast_id`(world_state)✓ / `beast_decision_leak_test.gd`✓ / faction_ai loop2+loop3 beast skip×2✓ / hooks dir 只剩 pre-push✓。
2. **install**：`cp scripts/hooks/pre-push .git/hooks/pre-push && chmod +x`。
   - installed 檔 content MATCH source、可執行。
3. **end-to-end smoke（installed hook）**：
   - 空 stdin（無 push 內容）→ exit 0（零 godot）✓
   - 真 ref push（clean main）→ constitution_gate 跑+PASS + verification fast-exit → exit 0（放行）✓

## 現行效果
- 全平行 session `git push origin` 起 **constitution_gate（恆跑，push-to-shared）+ verification_gate（branch-scoped，有 sim measure 才啟 godot 否則秒退）**，任一 FAIL 擋 push。
- `git push --no-verify` 繞過須系統認可（同規矩）。
- 裝前已確認手邊無 mid-push WIP。

## beast-fix DONE 收尾
- consume DONE 信 ✓ / 主目錄 on main ✓ / status → idle ✓。

## 待命
下一票 transition-arbiter-bypass（HIGH，systems spec+R² 中）另 dispatch。team64/68 idle-latch=另一機制（分開，不綁 transition）。hold warm 等 `to:implementer` dispatch。
