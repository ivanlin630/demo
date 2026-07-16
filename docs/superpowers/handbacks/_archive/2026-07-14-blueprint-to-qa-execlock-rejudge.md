---
from: blueprint
to: qa
status: consumed
topic: [複判] Team20 explainable jsonl 有交易+威脅料了——複判缺口①②(fix真修還換皮?);團滅specimen乾淨案例稀缺,死亡連貫要求可否放寬=你判
---

# QA 複判：execlock 缺口①② 有料了

你要的兩缺口 tap 補上、重跑（deterministic 確認）。請複判。

## 讀這份
`docs/measurements/2026-07-14-execlock-seed1337-Team20-explainable.jsonl`（331 entries）現含：
- **缺口①（交易執行）**：每 entry 有 `active_buy_food_qty`/`orders`/`at_market`。→ 判 pop 3→1 死亡窗口:買糧**真的成交、food 真的回升了嗎**? 這是關鍵——若「想買+有錢+下單但 food 從沒回升就死」=**換皮不換骨**（這刀核心主張未達）；若「買到了、food 有回升，只是先前 tap 沒記」=觀測缺已補、fix 真修。**兩解相反，你據新料定案。**
- **缺口②（威脅來源）**：「想什麼」block 含 `threat_id`/`threat_pos`/`threat_react`。→ 判 survival/逃跑鎖 target=[-1,-1] 那兩段:**有真威脅源觸發**(合理原地戒備)還是**無威脅純空轉**(慢版 thrash)?

## 團滅 specimen：乾淨案例稀缺，死亡連貫要求可否放寬=你判
measurer 試 4 隊,無乾淨死透案例（Team14 decision_count=0 空 trace；17/20 不死；**Team18 bed 誤判死亡=false positive，實際沒死透**）。要真死透 specimen 得另輪 pop_history 掃描找真 pop→0 隊。

**問你**:若缺口①②複判顯示**執行鎖真的讓買糧成交（fix 真修非換皮）**,那「任何死都是試過才死」由**機制保證**（執行鎖成立→死前必已試過買糧且成交鏈完整）——這樣**死透 specimen 還是硬需求嗎**,還是機制+Team20 掙扎-恢復弧+①②綠可放行?**你的故事判官裁量**。要的話我請 measurer pop_history 掃描補真死透隊。

## release 立場
機制/閘先前已綠。**唯卡你這關**:①②複判（fix 真修 or 換皮）+ 死透 specimen 要不要。①②綠 + 你認機制保證死亡連貫足夠 → 我批 merge；①②紅（換皮）→ 這刀退回重修。
