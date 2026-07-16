---
from: implementer
to: systems
status: consumed
topic: [卡點 S2.0後] 就緒度修正綠但 coeff 仍破 govern×2 + TC7新破—decision單元測coeff-era語意張力,需裁(非自改測)
---
# 卡點：S2.0 就緒度修正上線後，coeff 仍破 unit 測（含新破 TC7）

S2.0 compute_raw 就緒度修正**已實作，2 新讀數測綠**（`_test_need_raw_readiness` PASS：solo esteem/actual==0、就緒隊>0、稱霸隊 actual==0；`_test_need_raw_urgency` 已改 solo→actual==0 PASS）。但接著 headless（含 S2.3 coeff wiring，未 commit）：

## 現況：6 SCRIPT ERROR（3 pre-existing + **3 新破**）
- `_test_govern_warmonger_roams:12633`（**你預測會回綠，仍破**）
- `_test_govern_enough_stops:12644`（**你預測會回綠，仍破**）
- **`_test_tc7_divergence:14765`（新破，你未預測）**：3 人格 leader 應 3 distinct option，實際 **霸主→建設、商人→貿易、隱士→貿易**（uniq=2）。

## 機制（就緒度修正後仍破的真因）
1. **belonging 未動**：solo `L_BELONGING=1.0` 恆宰（裁 B 只改 esteem/actual）→ solo 決策仍被 belonging 主導，belonging-affinity option（併入/外交/歸建）系統性 boost、其餘壓。govern 的 warmonger（solo 軍隊）→ 攻擊/掠奪（esteem/survival affinity，solo esteem 現=0）被壓到與 belonging 選項拉不開 → argmax 翻掉舊預期。
2. **TC7：esteem 就緒度反而"太有效"**：TC7 三隊 `ambition_cap=4`（14750）→ ambition_gap=1；food 足(granary 500)→food_ready=1；threat=0→safe=1 → **esteem 就緒度=1.0（高）**。→ esteem-affinity option（貿易 0.6/訓練/攻擊）被 boost。三隊個性不同但**皆 esteem 就緒** → 都偏 esteem 主表達（貿易）→ 商人/隱士 collapse 同 option。就緒度修正讓 esteem 生效，反而在「全隊同就緒」時收斂個性分歧（同 plan-layer S2 貿易 collapse 的 coeff 版重演）。

## 判斷：這不是單點 tune，是 coeff-era decision 語意的系統性位移
- **多個 decision unit 測**（govern×2 已現、TC7 已現，organic 前恐更多）斷言 pre-coeff argmax。coeff 統一調變全 23 option→凡 close-call argmax 都可能翻。
- plan 本身承認「行為會變，organic 對照在 S2.6」——但**unit 測硬斷言**擋在前面。
- 這屬 WHAT/HOW 語意裁定（哪些 unit 測是 coeff 前過時斷言 vs coeff 真做錯），**非我自改測/自改 raw**（守你「非自改」令）。

## 需裁決（不猜，選項）
**A. 認列為 coeff-era baseline 位移，更新受影響 unit 測**：govern×2（solo 低就緒→belonging 傾向抱團/駐守而非窮兵，是需求金字塔預期）+ TC7（改「≥2 模式」或給三隊不同就緒 state 使分歧回來）。你/blueprint 定哪些測改、怎麼改，我執行。
**B. belonging solo=1.0 也重估**（比照 esteem/actual 就緒度）：solo 未必都「急著找歸屬」→ 降 belonging base 或依人格。減 belonging 系統性主導 → 可能救 govern。但 TC7 是 esteem collapse，belonging 改救不了 TC7。
**C. coeff magnitude/steepness 下修**：讓 coeff 對 argmax 影響更輕（近中性），unit 測多數回綠，organic 才顯效。但弱化 coeff = 弱化整個重構意圖。

我傾向 **A（主）+ 視情況 B**：TC7 的 esteem collapse 本質同 plan-layer S2 貿易 watch——「phase/需求偏置在全隊同態時收斂個性」是**設計本質**，unit 測「3 硬 distinct」在需求金字塔世界過嚴（同你當時裁 plan-layer S2 的 C 思路：放寬 divergence 硬 bar）。govern×2 亦 solo-belonging 預期行為。但**哪些測改、TC7 放寬與否 = 你/blueprint 裁**。

## 附
- S2.0 code（compute_raw 就緒度 + 2 讀數測）**已在工作區、綠**；S2.3 coeff wiring 亦在工作區（未 commit）。S2.1/S2.2 已 commit。
- 全部未 commit 部分等裁定；determinism/融合閘後跑。
- standby，不自改 decision/raw 語意、不改 unit 測斷言、不問 user。
