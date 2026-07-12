---
from: systems
to: implementer
status: consumed
topic: [裁定 T1] 13破按類處理:A機械更新值/B優先注入urgency保invariant(非直接放寬)/真regression停報;逐測列
---

# T1 回歸裁定：三類處理（applying 裁A政策 + 更嚴的 invariant 保全）

你分類正確。這是 coeff-era 裁 A 政策的 base-term 延伸（已有政策，不再升藍圖=屬 HOW 測設計權）。但比你建議**更嚴**——Class B 不直接放寬，優先修 fixture 保 invariant 覆蓋。逐測按下分類處理，每測列 handback（不靜默）：

## 類 A：hardcode 舊 eval 值（obsolete）→ 機械更新為 T1 新值
如 `_test_survival_magnitude` 前段 `eval("survival_pressure")==4.0` / `restock==4.5` / `threat_pressure==0.0`。**設計性改公式必破，更新斷言為新公式值 = 機械對齊，非改語意。** 授權更新。

## 類 B：survival-dominance / argmax invariant → ★優先注入 urgency，非放寬
這些是**真 invariant**（餓隊→覓食、TC2 糧0→survival-class、半餓不亂跑）。你指出 unit 手構 ctx 無 need_urgency→coeff=1.0→純 base 比→survival 不自動壓。**但正解不是放寬斷言，是修 fixture 讓測跑真架構**：
- **優先**：fixture 注入 `ctx.need_urgency`（手設如 `[1,0,0,0,0]` 餓態，或呼 gather 讓它算）→ 測 `base×coeff` 真路徑 → 斷言 survival 仍 argmax 贏。**保 invariant 覆蓋於 unit 層**（比 organic-only 強）。
  - 若測走 `DecisionEngine.decide/rank`(內部 gather)→ ctx 自帶 urgency，可能本就該綠；查為何破（是否 fixture food 值使 urgency 不足）。
  - 若測直呼 `rank_scored_ctx(手構ctx)`→ 手構 ctx 補 need_urgency 欄。
- **僅當**注入 urgency 後仍無法讓 invariant 綠、或該測本質 close-call（無明確 survival 態）→ 才放寬為結構斷言 + 標 `# organic-verified(T1)`。
- **★真 regression 閘**：若某 survival-dominance 測**注入正確 urgency 後仍紅**（coeff 沒撐住 survival dominance）→ **停，handback to:systems**（這是 coeff 撐力真失效，非 obsolete，需回查 coeff/urgency 公式，非放寬）。

## 類 A/B 之外
- 3 pre-existing(p2a/beg_join/strategic_reads) 不動。
- 若有測看不出 A/B（如純 term 值變動連帶 argmax 翻但非 survival invariant）→ 歸類註明，close-call 放寬、真行為變注入 urgency 驗。

## 回報
逐測處理 + 分類表(A機械更新/B注入urgency/B放寬/真regression) 列 handback → 融合閘綠 → to:measurer（organic 驗 survival-dominance/TC2/半餓不亂跑/9-zero部分lift/determinism）。**任何真 regression（注入 urgency 仍紅）即停報**，別放寬掩蓋。守：不 pre-tune、不問 user。

## 註
T1 code + `_test_term_normalize_t1` 保留（綠）。分類是機械+測設計工，你執行；語意/invariant 判準已在此裁定，無需再逐測問我（除非撞真 regression）。
