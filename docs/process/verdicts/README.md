# verdicts/ — verification-gate verdict schema

用戶 rule（2026-07-18）：**有 sim 量測 → QA 故事稽核必跑（fail-closed，沒 QA verdict 不准 merge）；沒 sim 量測 → 免（量測 discretionary）**。
`verification_gate.gd` 結構強制此 coupling（sibling of `constitution_gate.gd`）。只堵「sim 量測了卻沒 QA 讀故事」的 attrition 誤讀衰減，不強制量測。

## 檔案格式

### `<slice>.measure.json`（measurer 寫）
既有欄 + **★`is_sim: bool`（必設）**：
```json
{
  "slice": "<slice-name>",
  "is_sim": true,                     // ★organic/seeded sim 跑=true；char-bed/byte-identical-only/純結構=false
  "measured_at_head": "<commit-hash>",
  "raw_logs": "docs/measurements/<slice>.log",
  "...": "既有 metric 欄留"
}
```
- **`is_sim: true`** = 跑了 organic/seeded 模擬（seeded_warring / game_sim / multi-seed）→ **必需對應 `.qa.json` verdict:PASS**。
- **`is_sim: false`** = char-bed / byte-identical-only / 純結構重構（無模擬行為量測）→ **無 QA 要件**。
- **★active verdict 缺 `is_sim` 欄 = gate FAIL**（強制 schema 前進，measurer 必設）。

### `<slice>.qa.json`（QA 寫，going-forward 唯一 QA 格式）
```json
{
  "slice": "<slice-name>",
  "verdict": "PASS",                  // "PASS" | "THRASH" | "FAIL"（非 PASS 不可 merge）
  "read_measure": "<slice>.measure.json",
  "story_audit": {                    // 故事性稽核（motive→action→outcome 鏈）
    "thrash_criteria": "餓死❌ / 窮死✅ / idle❌ …",
    "...": "…"
  },
  "note": "…"
}
```

## gate 用法
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/verification_gate.gd                    # 全 active verdicts
.\tools\godot.ps1 --headless --script scripts/debug/verification_gate.gd -- --slice=<name>  # branch-scoped（免 stale 誤擋）
```
- FAIL exit（非零）= 有 sim-measure 缺 QA PASS / active 缺 is_sim。
- WARN = is_sim=false 但 raw_logs 含 sim 關鍵字（疑漏標）。

## `_archive/`（grandfather）
gate **只檢 active（非 `_archive/`）verdicts**。部署時既存 pre-gate verdicts（`.measure.json` + 5 副檔名 QA）一次性 move → `_archive/`（歷史不追溯擋，新 slice 從乾淨起）。

## 部署時序（★R² 提醒）
1. **archive 搬遷先於/同 commit gate 啟用**（既存缺 is_sim 不誤擋）。
2. **QA `.qa.json` 格式通知先於/同步 hook 生效**（QA session 採此格式）。

溯源：`specs/2026-07-18-verification-gate-sim-qa-coupling.md`；blueprint 結構修法（fail-closed vs 意圖衰減）；[[feedback_qa_inversion]]。
