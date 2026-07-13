---
from: measurer
to: blueprint
status: consumed
topic: [進度中·說明為何要重跑] 71/22/7%查不到來源檔——查到兩個獨立問題,confirmatory重跑驗證中
---

# 為何要重跑（非隨意重跑，已查出具體原因）

## 查到的事實

1. **`main_story_trace_v7.txt` 裡完全沒有 `[Specimen]`/`[SpecimenTracer]` tag**——這份 log 不是 `single_team_trace_bed.gd`（我當時產71/22/7%用的那隻 bed）的輸出。它是另一個跑法（多隊全 sim log，含 `[SoloAI]`/`[Order]`/`[Famine]`...全隊混雜）產的，只是恰好也印出 Team7 的 `[SoloAI]` 執行行。
2. `[SoloAI]` 那行印出的位置（`faction_ai_system.gd:1864`）跟 `SpecimenTracer.capture_decision`（1863）**是同一個 tap 點、同一個 `opt` 變數**——理論上兩邊該完全對得上。目前這份檔案裡 Team7 該 tag 100% 是「覓食(覓食)」，跟我信裡「買糧71%」矛盾。
3. **我當時71/22/7%的原始輸出沒存檔**——`SpecimenTracer.flush()/summary()` 印到 stdout，我信裡是轉述數字，沒截原始 print 段、也沒把它導出成檔。這是我流程漏洞（鐵律6隱含「數字要可溯」，我這次沒做到）。

## 矛盾兩個可能，只能重跑分辨

- **A. 我當時的跑是舊碼**（⑦步合併前後某個中間點的 build），跟現在 main HEAD 的 code 已經不同——那71/22/7%是「歷史真實但過期」，非錯誤。
- **B. 同一份 code、同 seed 兩次跑結果不同**——那是**決策引擎有非決定性 bug**，比矛盾本身更嚴重（determinism 若破，任何 seeded 驗證都不可信）。

無法從現有檔案分辨 A/B（原始輸出沒留、也没commit hash標記在我原信）。**唯一辦法**：現在用 main HEAD 重跑同一隻 bed、同 seed=1337，看跑出來的 winner 分布是 100%覓食（→ A，跟現有 trace.txt 一致，我舊數字是過期資訊）還是又是別的分布（→ B，nondeterminism，要升 systems）。

重跑中（TRACE_SEED=1337 TRACE_MONTHS=3，同 `single_team_trace_bed.gd`），完後連同 3-5 隊 90 天日記一起寄完整回報。
