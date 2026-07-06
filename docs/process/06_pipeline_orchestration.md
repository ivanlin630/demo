# 06_pipeline_orchestration.md — 全 pipeline 工作流（草案，待藍圖+用戶過目）

> 藍圖 `pipeline-workflow-adopt`（用戶定案）落地。系統擬 HOW；WHAT（藍圖 orchestrator/用戶只談藍圖）藍圖已定。**切點=決策模型接線脊椎開軌時**（憲法 arc+序7/8/probe/gen 落完後，不中途，防雙寫手 race）。**切換前不動現狀**（`00_roles`/`01_architect`/`03_implementer` 現行有效）。

## 1. 為何切（用戶要更自動）
現狀：用戶當人肉訊息匯流排，在藍圖↔系統↔實作間穿梭轉述（每 slice 貼 spawn 指令、回報「好了」、轉 handback）。全 pipeline=拿掉跑腿，用戶留在單一對話只跟藍圖談 WHAT。

## 2. 新流程（角色接力→orchestrator fan-out）
```
用戶 ──WHAT──> 藍圖(orchestrator, 持久人工 session)
                 │ 一裁定定案
                 ├─spawn─> 系統 subagent (ephemeral)：讀 doc→寫 spec/plan→回 doc
                 ├─spawn─> 實作 subagent (worktree)：讀 plan→建+測→handback doc
                 ├─spawn─> QA subagent (獨立 adversarial)：讀 diff/handback→判決 doc
                 └─串回─> 藍圖 彙整→回報用戶
```
- **git doc = 共享大腦**：handback + `game-design`/`invariants`/`progress` = 持久狀態。ephemeral subagent 現讀 doc 即得 context，不需長期 session。
- **下游全自動**（spec→build→measure→judge→回報）；用戶單一對話。

## 3. 替換非疊加（★硬約束：不能兩個系統寫手）
持久系統 session + orchestrator spawn 的系統 subagent 同寫 `invariants`/spec = race。∴**持久系統/實作/QA session 退場，subagent 接**。
- **單一 owner 規則的新形態＝orchestrator 序列化寫入**：藍圖 orchestrator 逐一 spawn、逐一收回、逐一落 doc＝天然單寫（無並發寫者）。owner 表（`00_roles §2`）語意不變（誰的 doc），但「寫手」從常駐 session 變 orchestrator 調度的 ephemeral step。
- **auto-memory 單寫者重指派**：系統 session ephemeral 後，memory 寫入歸 **orchestrating 藍圖 session**（它持久、序列化、看全局）。或設專步（memory-scribe subagent，藍圖 spawn）。**草案取前者**（藍圖 session 寫 memory＝最少活動件、序列化天然單寫）；`00_roles §auto-memory` 改「orchestrator 藍圖 session 單寫」。

## 4. 自動化拿掉跑腿，不拿掉檢查（★釘死保留）
1. **QA 獨立性（事故級規則，`04_qa`/`05_acceptance` 不破）**：orchestrator 執行，但 QA=**獨立 adversarial subagent**（skeptical prompt、非藍圖自蓋自判、maker≠checker）。**用戶仍最終驗收權威**（交用戶前 QA 綠＝硬閘不變）。
2. **深工深度**：ephemeral subagent 比 arc 老兵淺。**機械 slice（probe/param/溶）OK；深架構（決策模型脊椎）餵厚 context 或用重 agent**——orchestrator 對深 slice 附完整 spec+相關 doc+前 slice handback，別假裝 ephemeral 免費。
3. **doc audit trail**：關鍵裁定仍寫 `game-design`/`invariants`（持久記錄）；省的只是 handback-relay 人肉轉述 overhead（subagent 直讀 doc）。
4. **憲法閘 enforcement 新形態**：pre-commit（arc-period 硬擋）→ orchestrator 在實作 subagent handback 後、merge 前 spawn 一步跑 `constitution_gate`（+全融合驗+framework），綠才 merge＝**常駐鏈由 orchestrator 序列化保證**。撤 `.git/hooks/pre-commit`（本地 arc-temporary）併此步落地。

## 5. handback channel 在新模型
`00_roles §跨角色 handback` 的 git doc channel **保留**（=共享大腦本體），但「並行 session 不能對話→人肉橋」的原因消失（orchestrator 直接串）。handback 仍寫（audit trail），status open/consumed 由 orchestrator 管。

## 6. 切換 checklist（2026-07-06 執行）
- [x] 憲法 arc + 序7/8 + probe slice + gen（readiness kill knob，food defer）全落 merged（在飛的零滿足；gen readiness 軌駁倒轉脊椎②，非在飛）。
- [x] 本 doc + `00_roles` 更新指向 orchestrator（角色職責/owner 表不變，session 形態變；`01_architect`/`03_implementer` 職責本體仍有效，被 orchestrator 調度）。
- [x] CLAUDE.md「Session 工作流」段改（用戶核准照落）+ 常用指令 constitution_gate 註改 merge-gate。
- [x] auto-memory 單寫者改藍圖 orchestrator（`00_roles §auto-memory` + CLAUDE.md）。
- [x] 撤 `.git/hooks/pre-commit`（arc-temporary）；憲法閘=orchestrator merge-gate 步（CLAUDE.md 常用指令 + 本 doc §4.4）。
- [ ] **首個 pipeline slice = combat_decisive=0 診斷（藍圖 execute-switch 指定 dogfood）**——由 orchestrator spawn，驗流程。**此後系統/實作/QA 走 subagent，用戶只跟藍圖。**

**★切換完成後（本 commit）：持久系統 session 交棒 orchestrator。下一個動作起，藍圖 orchestrator 調度 subagent。**

---

## 附：CLAUDE.md「Session 工作流」段改草案（protected，交藍圖→用戶過目才落）

> 現行「兩個並存設計腦+worktree 實作」→ 改「藍圖 orchestrator + ephemeral subagent」。以下為**建議替換文字**，未落 CLAUDE.md。

```
## Session 工作流（全 pipeline，2026-07-XX 切）

用戶只跟**藍圖 orchestrator**（持久人工 session）談 WHAT。藍圖裁定後 spawn subagent 執行下游：
- **系統 subagent**：spec/plan（讀 invariants/game-design doc）。
- **實作 subagent**（worktree）：建+測，handback。
- **QA subagent**（獨立 adversarial）：判決。用戶=最終驗收。
- git doc（handback + invariants/game-design/progress）= 共享大腦；owner 表不變，寫手=orchestrator 序列化。
- auto-memory 單寫者 = 藍圖 orchestrator session。
- 憲法閘/融合驗/framework = orchestrator merge-gate 步（撤 pre-commit）。
細節見 docs/process/06_pipeline_orchestration.md。
```

**待藍圖/用戶**：本 doc 是 HOW 草案。藍圖過目→給用戶過目 CLAUDE.md 段→定案落。切點前不動現狀。
