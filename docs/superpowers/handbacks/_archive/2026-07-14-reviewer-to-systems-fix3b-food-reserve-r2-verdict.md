---
from: reviewer
to: systems
status: consumed
topic: "[R②判決] Fix3b 食物戰略備糧對稱化：CLEAN（一條 home 建議，非阻塞）"
---

# R② 判決：CLEAN

verdict: clean
premise_contradiction: false

## factcheck
- `terms.gd:106-111`（buyfood_drive 現況）：只有旅費折扣 base 0.5-1.0，**無 hunger/security 驅力項**——你「白做」警告坐實，加 security-gap 項必要。
- `terms.gd:203`（致富 intent 貿易/囤貨 boost，`food_days>=SURPLUS_FOOD_DAYS`）：確認只給貿易/囤貨，買糧無對稱戰略項——不對稱根坐實。
- `options.gd:133-137`（買糧 applicable 現況）：`food_days<DESPERATION(3)`，maxf 擴充語意正確接上現碼。

## 逐點 refute 回應

1. **security-gap runaway**：`_gap=(threshold-food_days)/threshold` 本身隨 food_days 逼近 threshold **單調趨零**——自然負回饋，非結構性 runaway。food_days 補到 threshold 後 gap→0，drive 退回純旅費 base，不會維持 lockstep。機制上安全，實際係數（SECURITY_STOCK_DRIVE 多大才不 over-buy）留量測校，不阻塞。
2. **maxf(DESPERATION,threshold) 語意**：MIN=2<DESPERATION=3 確保賭徒地板不降於現況——核對正確，無退化風險。
3. **esteem/buyfood 兩面打架**：檢查方向一致非衝突——`food_days<threshold` 同時使 `food_ready<1`(esteem 不鬆懈) 和 `security-gap>0`(買糧驅動)，**兩者同指向「先補糧」**，非拉鋸。同源論證成立。
4. **owner 單一性**：建議 **home=DecisionTerms**（非 need_hierarchy）——`options.gd`/`terms.gd` 已是 buyfood applicable+drive 所在，`food_security_threshold` 主要消費端在那；need_hierarchy 若要用，import DecisionTerms 方向乾淨（need_hierarchy 依賴 decision 層常數已有先例如 `DESPERATION_DAYS`），反向 import 才會繞。implementer 定案時採此方向即可，非阻塞。
5. **與 Fix2-v2 交互**：買糧視窗提前（maxf 擴大）理論上**降低**觸底頻率（隊伍更早補糧，不易跌到 crisis 深度）——與 Fix2 漸進重評方向一致互補，非放大風險。已含在既有 headline 條件（#1/#2）內，不需額外測項。

## 條件（沿用前輪，未增新阻塞項）
Fix3b 併入同一輪驗收，前次已提三條件（bisect 隱含判準 / attrition+reeval 雙報 / 謹慎隊長期升階抽驗）**適用範圍自動涵蓋 Fix3b**（同一 `food_security_threshold`），另加：
- 驗收⑦「經濟扭曲」守（spec 已列，糧價/coin 流無異常暴走）——measurer 標準床本有糧價/coin 觀測，順手看。

## 回報
CLEAN → hold 到 measurer v2(Fix2+Fix3) 回，隱含 bisect 訊號後再 dispatch Fix3b。你排的時序（先驗 v2 再併 Fix3b）合理，同意。
（寄件永遠 open，你讀後改 consumed。）
