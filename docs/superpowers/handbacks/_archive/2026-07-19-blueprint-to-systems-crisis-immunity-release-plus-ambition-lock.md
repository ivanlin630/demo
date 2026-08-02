---
from: blueprint
to: systems
status: consumed
topic: "[crisis-immunity release-pass=靶三隊PASS·但team=-1000000 ambition-lock開問·裁身分+starve計數provenance+併不併merge] QA故事稽核:team1/19/13(免疫窗靶)COHERENT,免疫修達成目的,PASS。但trace新撿team=-1000000連續300tick task=建設reason=ambition food=0 survival_dispatch_would_succeed=true全程未轉求生(手不聽腦,同stall-gap家族但ambition task非crisis-override涵蓋範圍)。★你裁:(a)-1000000是anon pool聚合體or真隊(b)是否計入starve分母(影響seed1337=0這數字誠不誠實)(c)merge b71647ab現在放行+-1000000另開追蹤,還是先查清再merge。我不裁HOW/實體模型,但release數字要乾淨才能用。"
---

# crisis-immunity release-pass + team=-1000000 ambition-lock 開問

## 判決一：靶三隊 PASS（QA 故事稽核 COHERENT）
QA 讀 `docs/measurements/2026-07-19-crisisimmunity-seed1337-lockpoint-b71647ab-decoded.log`，判 team1/19/13（免疫窗瞄準的三隻卡死隊）**COHERENT**：
- team1：CrudeCamp→Outpost farming Lv1→Ambition rung 0→3 商業。
- team19：CrudeCamp→Ambition rung 0→2→Outpost stable Lv1。
- team13：CrudeCamp→Outpost stable Lv1→Ambition 商業→市場成交（後折 1 anon，隊存活）。

motive→action→outcome 鏈完整，免疫窗對它瞄準的失敗模式（release-then-instant-recommit）**真的有效**。**這部分我 release-pass**（免疫修達成設計目的）。

## 判決二：team=-1000000 ambition-lock ＝新開問，我不裁（HOW/實體模型）
Trace 撿到 1 隻逐 tick 破故事死隊：
- **log:13018–13318，連續 300 筆快照全同**：`task=建設 prio=10 reason=ambition food_days=0.00 pop=1 survival_dispatch_would_succeed=true` → 死。
- **決定性**：`survival_dispatch_would_succeed=true` 行數=300、`reason=ambition` 行數=300（awk 全掃，全 log 唯一 ambition-lock 死隊）；其餘死隊（62/68/72）皆 `reason=survival/unified`+`would_succeed=false`（真求生不成/逃/戰死＝合法悲劇）。
- **為何是問題**：food=0 快餓死、求生 dispatch 當下可成，卻 300 tick 一直選 `task=建設 reason=ambition`、從不轉求生。**ambition task(疑似 prio=10/AMBIENT)硬 pre-empt 掉可用的 survival(80)**——若真如此，同「補丁閘優先查」通則（先查是不是 gate/優先權沒接對，非猜 tuning）。
- **身分未定**：該 team 打仗(Combat Start)、反覆「從匿名晉升新領袖」(統領 0.04/0.17/0.07)、買糧——QA 疑似**荒野/無屬 anon pool 聚合體**，非一般定居隊。**這是實體模型問題，我不裁**（HOW 你定）。

## 待你裁三件事
1. **team=-1000000 身分**：anon pool 聚合記帳體，還是真隊？
2. **starve 分母 provenance**：若計入 → seed1337 實際非 0（漂亮數字有洞）；若排除（負百萬 sentinel id 特殊處理）→ 需確認排除規則合理（非意外漏計真死隊）。
3. **merge 時機**：b71647ab（免疫修）現在 merge（靶三隊 PASS 已夠格）+ -1000000 另開追蹤票，還是先查清 1/2 再 merge？**我傾向前者**（免疫修本體乾淨、達成目的，不該被一個不相干的新發現卡住；但 starve=0 這數字在 -1000000 provenance 查清前，不可引用為「seed1337 完全健康」——僅供內部追蹤，不進 baseline 宣稱）。你若判斷 -1000000 與免疫修有因果糾纏（例如免疫窗改變了它的 task 分派路徑），則優先序反過來，你裁。

## 若 -1000000 是真隊 → 新 stall-gap 變體，接你正在做的家族
若判定是真隊，這是 crisis-override 泛化沒涵蓋到的第 6 種 stuck-task（原 5 種＝等待新領主/建設@50/外交@70/併入@80/FLEE，現+ambition@10）。是否併入同一 outcome-based 安全網機制（crisis-override 的 release→survival re-rank 邏輯），或需要不同修法（priority table 本身沒把 ambition 排進 preemption 鏈）＝你 HOW 判。

## 溯源
`2026-07-19-qa-to-blueprint-crisis-immunity-story-verdict.md`（故事判決+新撿死隊，已 consumed）；`2026-07-19-measurer-to-blueprint-crisis-immunity-remeasure.md`（聚合數字，已 consumed）；00_roles.md 量測→QA故事稽核→藍圖鏈（2026-07-18 用戶戳，此輪守住沒跳）；[[feedback_qa_inversion]]。
