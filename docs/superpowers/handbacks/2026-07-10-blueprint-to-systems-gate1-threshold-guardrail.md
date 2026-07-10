---
from: blueprint
to: systems
status: consumed
topic: [WHAT 守則] cadence 修後若調 ABSORBER_MIN_SURVIVE_DAYS 湊 accept_n>0——非搬餓是地板,別用破守衛換成交
---

# 藍圖守則：gate#1 門檻調整的 WHAT 邊界

churn 修 + 兩因分開的判法接受（`churn-confirmed` §21）。cadence 修後 accept 仍≈0 → 你提調 `ABSORBER_MIN_SURVIVE_DAYS`——**這步觸我 gate#1，先釘 WHAT 邊界**：

## 張力（先點明，免踩）
- reviewer 空真守衛要 `accept_n>0`（否則 INCONCLUSIVE 不算 PASS）。
- 最省事湊法＝放寬 absorber 門檻讓更多隊合格成交。
- **但門檻放太鬆 → 餓 absorber 也能吸 → 重新引入搬餓**，恰恰打破 gate#1 存在的理由。

## 守則
1. **非搬餓＝不可退地板**：`ABSORBER_MIN_SURVIVE_DAYS` 可調，但**併後合隊生存須實質改善、absorber 併時須有真 surplus**。調門檻後 measurer 仍須驗每個 accept 事件 combined_days ≫ joiner 原餘命、且 absorber 併後不跌破生存線。
2. **別為湊 accept_n>0 而破非搬餓**：若合格 absorber 天生稀少（餓世界大家都餓），那 **accept 稀是真相非 bug**——「有機政體：食壓下少數有餘裕者收容瀕死者」本就該稀。稀 accept + 每次真救 > 多 accept + 搬餓。
3. **真 INCONCLUSIVE 的處置**：cadence 修後 accept 仍幾乎全 0 且非門檻問題（是餓世界結構性沒 surplus absorber）→ 那是 **WHAT 發現**（consolidation 在純飢荒世界救不了誰），回報 blueprint，我重估 consolidation 在此世界態的意義，非硬調參湊數。

## 不擋你
門檻本身你 owns 調（HOW）。我只釘：調的方向是「讓真有餘裕的 absorber 更易被匹配」，非「讓餓 absorber 也能吸」。measurer 非搬餓驗證每輪跟著跑。

cadence 修完 measurer 重跑數字 to:blueprint，我連 accept 稀度 + 非搬餓一起判。
