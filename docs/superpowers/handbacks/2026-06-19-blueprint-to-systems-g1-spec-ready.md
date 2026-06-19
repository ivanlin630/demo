---
from: blueprint
to: systems
status: open
topic: G1 供應鏈 spec ready → 請寫 plan（脊椎②）
---

# G1 供應鏈 spec 完成，移交系統寫 plan

Spec: `docs/superpowers/specs/2026-06-19-g1-supply-chain-design.md`（藍圖已 review 定稿）。

擬真審計第二脊椎（經濟的因果脊椎）。上游 ①G2 archetype 生需求 → G1 接。

## WHAT 摘要（細節見 spec）

- **湧現式區域市場**：分工鏈 + 訂單系統 + 既有 message_system = 市場自己湧現。**無中央撮合 / 無全域價格表 / 無市場實體**。價格 local、知識靠殘缺消息傳。
- **訂單系統**：雙向（買單+賣盤）、走既有 message 傳播（distort/delay 複用）、coin 或 barter 計價（複用 evaluate_offer）。
- **履約風險 = 吃癟有代價**：壞情報撲空 → 既有 local_value glut 壓價 → 真虧 → 準情報值錢。**複用既有定價，不新做。**
- **物物交易**：base layer，雙重巧合摩擦 → barter 本地化、coin 全域化。不另做 barter 系統。coinless 不被踢出。
- **貨幣生產（W8）= 實物幣 specie**：金銀礦挖 + 鑄幣配方（ore→coin，**等值換形，coin_eq 守恆**）、**任何有鑄幣設施的隊可鑄（無立國 gate）**。face value 維持有效（金屬背書、礦量卡供給、免通膨模型）。
- **生產看需求**：朝已知訂單/在地短缺生產，不盲造。

## 關鍵設計理由（避免 plan 走偏）

- **specie 而非信用幣**：信用幣（money=信任=資訊）會破 face-value/coin_eq 守恆閘 + 需信任建設 → 是**魂**，移出，歸 ③G3 後「貨幣信用」spec。基底用 specie：守恆安全、修 W8、不憑空造價值。
- **鑄幣守恆是硬驗證**：coin_eq delta=0 必須過——鑄幣是 ore_gold(值10)→等值 coin，非無中生有。

## 給你的 HOW 決策點（spec §11）

訂單訊息型別+生命週期 / 訂單接 message 傳播 / 生產讀訂單-短缺 wiring / 鑄幣（ore_gold/silver harvest + ore→coin 配方 + 既有鑄幣廠）/ 商隊(商業 archetype)履約-套利決策（接 G2 + 殘缺情報）/ 履約撲空走既有 local_value glut / 估值複用 evaluate_offer。

## 驗收（spec §12）

回歸閘 headless + **coin_eq delta=0（specie 鑄幣守恆硬驗證）**。行為可見：訂單發-傳-履約鏈 / 分工鏈湧現(礦→冶→武器→軍) / coin 被鑄(W8 解) / barter 在 coinless 區主導 / 履約撲空虧損案例。

寫 plan 中有 WHAT 疑義走本 channel 回呈。建議 G2 脊椎核心(G2b)穩定後再排 G1，因 G1 需求方靠 G2。
