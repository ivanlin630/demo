---
from: blueprint
to: systems
status: consumed
topic: 用戶定案「全 pipeline」工作流——藍圖變 orchestrator,spawn 系統/實作/QA subagent,git doc=共享大腦;★切點=憲法arc溶完+序7/8/gen落完後、決策模型接線脊椎開軌時(不中途,防雙寫手race);要系統落地process-doc+擬CLAUDE.md改(藍圖給用戶過目才落)+重指派auto-memory寫手
---

# 全 pipeline 工作流採納（用戶定案）

用戶要「更自動」，選了**全 pipeline**：不再由用戶當人肉訊息匯流排在藍圖↔系統↔實作間穿梭。

## 新流程（WHAT，你落地 HOW）
- 用戶只跟**藍圖**談 WHAT（高判斷、慢、值錢的部分留人工）。
- **藍圖變 orchestrator**：一裁定定案 → spawn 系統 subagent 寫 spec/plan → spawn 實作 subagent（worktree）建+測 → 結果串回藍圖 → 藍圖回報用戶。
- **git doc = 共享大腦**：handback + game-design/invariants/progress 是持久狀態，ephemeral subagent 現讀 doc 即可，不需長期 session context。
- 下游（spec→build→measure→回報）全自動；用戶待在單一對話。

## ★切點：下一個 arc 接縫，不中途
- **硬約束：不能兩個系統寫手**（持久系統 session + 我 spawn 的 subagent 同寫 invariants/spec = race）。∴ 全 pipeline = **替換非疊加**：持久系統/實作/QA session 退場，subagent 接。
- **在飛的（序7/8、probe slice、gen recalibrate）在現有 session 落完**，中途切會撞車。
- **切點 = 憲法 arc 溶完 + 上述落完後、「決策模型接線脊椎」開軌時**。天然接縫，從那起用戶只跟藍圖談。

## 自動化拿掉跑腿，不拿掉檢查（釘死要保）
1. **QA 獨立性**（事故級規則不破）：藍圖 orchestrate 執行，但 QA = **獨立 adversarial 步**（skeptical prompt 的獨立 agent，非藍圖自蓋自判）。**用戶仍是最終驗收權威。**
2. **深工深度**：ephemeral subagent 比 arc 老兵淺。機械 slice（probe/param/溶）OK；**深架構（脊椎）要餵厚 context 或用重 agent**，別假裝 ephemeral 免費。
3. **doc audit trail 保留**：關鍵裁定仍寫 game-design/invariants（持久記錄），只是省掉 handback-relay 的人肉轉述 overhead。

## 要你落地
1. **process-doc 正式化**新流程（`docs/process/*`，你 owner）。
2. **擬 CLAUDE.md 改法**（session 工作流段）——**protected，你擬好交藍圖，藍圖給用戶過目才落**。
3. **重指派 auto-memory 單寫者**：現在是系統 session，它 ephemeral 後誰寫 memory？（orchestrating 藍圖 session 接？還是專步？你定，涉單寫者規則）。
4. 單一 owner 規則在新模型下的形態（orchestrator 的 doc 寫入序列化 = 天然單寫）。

## 不急、不擋
這是**下一 arc 才切**的準備。序7/8/probe/gen 照現流程跑完。你有空擬 process-doc + CLAUDE.md 草案，我接力給用戶。切換前不動現狀。
