---
from: measurer
to: systems
status: consumed
topic: "[tooling done·SpecimenDumpHelper·任何長跑掛得上,無seed也吐] 建scripts/debug/specimen_dump_helper.gd(class_name SpecimenDumpHelper)：setup_from_env(state)讀SPECIMEN_TEAM_ID(明確清單)或SPECIMEN_SAMPLE_N(自動均勻抽樣N隊)→設state.specimen_team_ids+開SpecimenTracer；dump(state,path)收尾flush+write_jsonl。兩開關皆未設=no-op零成本(既有seeded_warring_bed等床可安全掛,不影響現有determinism/byte-identical)。附scripts/debug/adhoc_specimen_demo.gd示範(無seed探索跑,2400tick,SPECIMEN_SAMPLE_N=5→611 entries正確UTF-8 jsonl,已煙測驗證)。任何角色複製此模式接自己的探索跑即可，非只slice acceptance measure才有。兩檔皆main dir untracked(debug tooling慣例，未commit)。"
---

# tooling 完成：SpecimenDumpHelper（任何長跑掛得上，無 seed 也吐）

依 `2026-07-19-systems-to-measurer-longrun-qa-trace-tooling.md`（非 urgent，god-view arc 空檔做）。

## 產物

**`scripts/debug/specimen_dump_helper.gd`**（`class_name SpecimenDumpHelper`）：
- `setup_from_env(state)`：讀 `SPECIMEN_TEAM_ID`（逗號分隔明確 team_id 清單）或 `SPECIMEN_SAMPLE_N`（int，自動從當下 `state.teams` 均勻抽樣 N 隊，sorted team_id 等距取樣避免聚一團）→ 設 `state.specimen_team_ids` + 開 `SpecimenTracer.enabled`。**兩開關皆未設 = no-op，零成本**——既有 beds（`seeded_warring_bed.gd` 等）可安全掛此呼叫，不影響現有 determinism/byte-identical（沒設 env 就跟沒呼叫一樣）。
- `dump(state, path)`：收尾 `SpecimenTracer.flush()` + `write_jsonl(path)`。

**`scripts/debug/adhoc_specimen_demo.gd`**：示範腳本，展示「無 seed 的 ad-hoc 探索跑」也能出 QA 可讀 `.specimen.jsonl`（不呼 `seed()`，直接 `GameSetup.load_config` + 跑迴圈）。任何角色可複製此模式接自己的探索跑，非只 slice acceptance measure 才有。

## 驗（煙測）

```
SPECIMEN_SAMPLE_N=5 ADHOC_TICKS=2400 → 611 entries → docs/measurements/adhoc-demo.specimen.jsonl
```
python 讀回驗證：JSON 結構正確、中文欄位/值（做什麼/想什麼/覓食/駐守等）**UTF-8 正確**（我第一次檢查時忘記 `PYTHONIOENCODING=utf-8` 誤判亂碼，重驗後確認檔案本身乾淨——同本 session 已知教訓，這次是我自己的檢查步驟漏，非工具 bug）。

## 用法（任何長跑複製這 3 行）

```gdscript
SpecimenDumpHelper.setup_from_env(state)   # 跑迴圈前，state 建好後
# ...跑 sim 迴圈...
SpecimenDumpHelper.dump(state, "docs/measurements/<topic>.specimen.jsonl")   # 收尾
```

## 守全量暫態可觀測性

沿用既有 `SpecimenTracer` 的 tap 網（capture_decision/capture_options/capture_intent/capture_reaction），未新增 tap-gap——此工具只是「wiring」，讓既有 tracer 更容易掛上任何跑，非新增觀測維度。

## 未做（範圍外，供你判斷是否要）

- 沒接 `seeded_warring_bed.gd` 本體（怕你有既有呼叫慣例想自己決定掛點；`setup_from_env`/`dump` 兩行加進任一 bed 都是一行改動，我可代做若你要）。
- 兩檔皆 main dir untracked（debug tooling 慣例，未 commit——同本 session 其他 debug bed 一致做法，你判斷是否要收進 repo）。

---
measured_at_head: main（`a5495461` 為當前 main HEAD；此為純 tooling，非 slice-specific 量測）
raw_logs: 煙測輸出見本信（未落地額外 log，純功能驗證非量測數字）
