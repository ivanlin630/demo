---
from: implementer
to: systems
status: consumed
topic: "[build done·install 待信號] pre-push hook 折兩閘 build 完 → feat/hook-prepush@22604514 pushed。constitution_gate 恆跑 + verification_gate branch-scoped fast-exit,任一 FAIL 擋 push。刪舊 pre-commit(遷移非新增)。★未 install(.git/hooks)——等 systems 信號(starvation 落地+schema 穩)。你判 merge hook script。"
---
# Hand Back: pre-push hook 折兩閘（build done）

承 `2026-07-18-systems-to-implementer-hook-prepush-update.md`（blueprint 裁 pre-commit→pre-push、折 constitution_gate+verification_gate、install 待信號、build 現可做）。

## 實作摘要
branch `feat/hook-prepush@22604514`（off main 35e9ee8f = crisis-override merge）已 push origin。
- **新 `scripts/hooks/pre-push`**：折**兩閘**，任一 FAIL → 擋 push（exit 1）。
  - **constitution_gate**：★恆跑（每次 push=push-to-shared；補「手動=可跳=零殘留綠衰減」洞）。
  - **verification_gate**：branch-scoped fast-exit——只在本 branch slice 有 sim `.measure.json` 時才啟 godot；否則秒退零開銷。
  - **skip 路徑（零 godot）**：stdin 空（無 push 內容）／純刪 ref（local sha 全 0）→ exit 0。
- **刪 `scripts/hooks/pre-commit`**：其唯一職（verification-gate）已折入 pre-push。留著=誤裝風險（commit-time gating 正是 blueprint 否決的「擋每 WIP commit」）→ 遷移非新增，故刪。

## HOW 決策（你格，供審）
- **兩閘各開一次 godot**（未合跑）：verification 無 measure 時 fast-exit → 一般 push 只 constitution 一次 godot 開銷；slice 有 measure 才 +1。blueprint 接受「只 push 時跑」。若你要更省可後續合跑（現保清晰=每閘獨立 script）。
- **slice 推導**：`git rev-parse --abbrev-ref HEAD` 去 `feat/` 前綴（沿用舊 pre-commit 法）。
- **godot exe**：repo `tools/godot/...exe` 優先、fallback `A:/GDS/demo/tools/...`（worktree 無 exe→走 fallback，已驗）。exe 找不到 → 印警告放行（不硬擋，但 flag systems）。

## 驗證（worktree feat/hook-prepush）
- **A** 空 stdin → exit 0（零 godot）✓
- **A2** 純刪 ref → exit 0 ✓
- **B** 真 push + clean tree → constitution PASS + verification fast-exit → exit 0 ✓
- **C** verification FAIL（造 is_sim:true measure、無 qa.json）→ exit 1 擋 push + 印修法 ✓（fixture 已清）
- headless `=== DONE ===`，3 assertion fail = baseline 0-new（hook script 改不動 sim）。

## ★install 待你信號（沒做）
`cp scripts/hooks/pre-push .git/hooks/pre-push && chmod +x`——blueprint 裁**等 starvation fix 落地 + schema 採用穩**（現裝擾 active implementer/measurer commits）。我**只 build 未 install**。install 時機到 → 你發信號我再做（或你直接裝，一行 cp）。

## 連動風險
- **既有 `.git/hooks` 空**（未裝任何 hook）——本次不改 .git/hooks，零現行 workflow 衝擊。
- **install 後全平行 session push origin 都過兩閘**——blueprint 已 flag 用戶 workflow 衝擊。install 前無影響。
- `git push --no-verify` 繞過須系統認可（comment 已註，同 constitution/verification 規矩）。

## 待確認（你裁）
1. hook script 設計 merge OK？（R② 你判是否升 reviewer；此 slice 純 tooling 無 world model/新概念大框，R① 免）。
2. 兩閘各開一次 godot vs 合跑——現分開（清晰）；要合跑省 perf 我可改。
3. install 時機信號等你（starvation 落地後）。
