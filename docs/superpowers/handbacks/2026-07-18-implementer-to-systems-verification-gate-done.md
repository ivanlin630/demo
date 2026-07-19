---
from: implementer
to: systems
status: consumed
topic: "[verification-gate build done] S1 verification_gate.gd(sim-measure→QA fail-closed,branch-scoped,is_sim cross-check WARN)+archive grandfather(23 檔→_archive)+verdict schema README。S2 hook=tracked scripts/hooks/pre-commit(fast-exit,★未 auto-install 到 .git/hooks 免擾平行 session,你協調啟用)。gate 6 case 測綠。branch feat/verification-gate HEAD e7cb5c4a。★2 premise flag(見下)。this slice is_sim=false 自證 rule 免 QA。"
---
# Hand Back：verification-gate build（結構強制 QA，用戶 rule）

**branch** `feat/verification-gate`（已 push）**HEAD `e7cb5c4a`**，off origin/main。

## 交付（spec §交付 + §部署裁定）
- **S1 `scripts/debug/verification_gate.gd`**（sibling of constitution_gate，headless）：
  - 掃 active `verdicts/*.measure.json`（`_archive/` grandfather 不掃）。
  - `is_sim:true` 缺 `.qa.json` or verdict≠PASS → **FAIL**；active 缺 `is_sim` 欄 → **FAIL**（裁定#2 強制 schema）；`is_sim:false` → PASS(無 QA 要件)。
  - **branch-scoped**：`-- --slice=<name>` 只查該 slice（免 stale 誤擋，裁定#4）。
  - **cross-check**（裁定#5）：`is_sim:false` 但 raw_logs 含 sim 關鍵字（seeded_warring/game_sim/organic/warring）→ **WARN** 疑漏標。
  - **★測 6 case 全對**：empty→PASS / is_sim=true-no-qa→FAIL / +qa-PASS→PASS / THRASH→FAIL / missing-is_sim→FAIL / is_sim=false+keyword→WARN+PASS。
- **archive migration（裁定#1，同 commit）**：既存 23 檔（18 `.measure.json` + 5 QA:`.qa.json`/`.qa.raw.txt`/`.qa_final_verdict.md`/`.qa_verdict.md`）`git mv`→`_archive/`。含近期 seam1/2/3/threat-oracle verdicts（pre-gate grandfather，缺 is_sim 不追溯擋）。
- **verdict schema**：`docs/process/verdicts/README.md`（`.measure.json` +`is_sim` / `.qa.json` 格式 + gate 用法 + 部署時序）。
- **S2 hook `scripts/hooks/pre-commit`**（tracked）：branch slice 有 measure verdict 才啟 godot（fast-exit 免每 commit 開銷）；FAIL 擋 + `--no-verify` 系統認可。

## ★2 premise flag（R² 未覆蓋的部署現實）
1. **無既存 pre-commit hook**：spec S2 假設「constitution_gate 已在 .git/hooks/pre-commit=運輸層」——**實際 `.git/hooks/` 只有 .sample，無 active hook**（constitution_gate 是**手動**跑，CLAUDE.md「merge 前跑」）。∴「運輸層」尚不存在。我建 hook script 但**未 install**（見 2）。
2. **★未 auto-install 到 `.git/hooks/`（刻意，需你裁啟用時序）**：worktrees 共享 main `.git/hooks`→install 一裝**全平行 session（measurer/QA/blueprint/systems）當下 commit 都受影響**（godot ~2-5s/merge-commit + 可能擋）。spec 部署時序#2「QA `.qa.json` 格式通知先於/同步 hook 生效」——∴ hook 啟用該在**你發 QA/measurer schema 通知後**。我交 tracked script + install 指令（`cp scripts/hooks/pre-commit .git/hooks/pre-commit && chmod +x`），**你協調時機 install**（或我收指令再 install）。
   - 若要 constitution_gate 也進同 hook（真「fail-closed 運輸層」），另議（它現手動）。

## 部署時序（★R² 提醒，你協調）
1. **archive 搬遷 = 同本 commit gate 啟用**（已一起 commit，既存不誤擋）✓。
2. **QA/measurer schema 通知先於/同步 hook install**：你發（QA 採 `.qa.json`、measurer 設 `is_sim`）。通知到位 → install hook。

## 下一站
- **你**：發 QA/measurer schema 通知（採 `.qa.json` verdict / `.measure.json` is_sim）→ 協調 hook install 時機。判 merge。
- this slice **is_sim=false**（純 tooling，無 sim 行為量測）→ **自證 rule 免 QA**（正好 dogfood：gate 對自己 PASS）。gate 本身 byte-identical（不動 sim）。
- constitution_gate 不動（sibling）；constitution_gate 跑確認未受影響（verification_gate 在 scripts/debug，非其 scan 範圍 scripts/simulation）。

## 溯源
dispatch `...verification-gate-build-go.md`（R² CLEAN REVISED）；spec `2026-07-18-verification-gate-sim-qa-coupling.md`；用戶 rule sim→QA；[[feedback_qa_inversion]]；constitution_gate 先例。
