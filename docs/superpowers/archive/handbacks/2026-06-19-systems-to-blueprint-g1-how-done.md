---
from: systems
to: blueprint
status: consumed
topic: G1 HOW 設計解完 + ⚠ ore_gold 守恆值差異待你確認
ruling: (a) mint 對齊現 coin_eq 權重。「10」是 spec 舉例非設計意圖；specie 的 WHAT=守恆，與數字無關。詳文末。
---

# 回覆：G1 §11 HOW 解完（+ 一個守恆值要你拍板）

G1 HOW 設計落 `specs/2026-06-19-g1-supply-chain-how-design`，§11 全裁。拆 4 子 spec（依賴序）：
- **G1a 鑄幣(specie/W8)** — 最獨立、守恆閘最清楚 → 先做。
- **G1b 訂單系統** — order message + 生命週期 + 走 propagate。基礎。
- **G1c 需求驅動生產** — 生產讀訂單/短缺。依 G1b。
- **G1d 商隊履約/套利** — 商業 archetype(G2b 已 land)讀殘缺訂單套利、撲空走 local_value glut。依 G1b。

關鍵 HOW：訂單權威在發起隊、message 為**可失真傳播副本**（殘缺市場湧現）；履約回核對權威 = 撲空因。全復用 message/local_value/evaluate_offer。

## ⚠ 要你拍板：ore_gold 守恆值

你 spec 寫「ore_gold **值 10** → 等值 coin」。但**現碼 coin_eq 權重 = ore_gold ×5、ore_silver ×1**（faction_ai:1239）。

鑄幣守恆硬閘 = **mint rate 必須等於 coin_eq 權重**，否則 coin_eq delta≠0、specie 設計破。兩條路：
- (a) **mint 用現 coin_eq 權重**（ore_gold→+5 coin）：守恆穩、零連動，但與你「值10」認知不符。← 系統傾向（最小風險）
- (b) **改 coin_eq 權重為 ore_gold=10**：符你願景，但**動 coin_eq 定義 = 全經濟守恆基準位移**，既有守恆測試/平衡全要重驗。風險大。

這是 WHAT（金價願景）× HOW（守恆基準）交界。**我傾向 (a)**（mint 對齊既有 coin_eq，值多少不影響 specie 機制成立，純數字平衡 pass 再調）。你拍：(a) 對齊現權重 / (b) 抬 coin_eq 到 10。回標 consumed。

G1a 等你這條回覆再鎖 mint recipe；G1b 訂單不卡此，可先寫 plan。

---

## 藍圖裁定（2026-06-19）

**(a) mint 對齊現 coin_eq 權重（ore_gold→+5 coin）。**

- spec 那個「值 10」是我從 BASE_PRICE 隨手抄的**舉例**，**非設計意圖**。specie 的 WHAT = **等值換形、守恆**，跟具體數字無關 → 鑄成 5 或 10 都成立。
- (b) 為一個舉例數字位移整個 coin_eq 守恆基準 = 高風險零設計收益，否決。
- 數字本身留正式平衡 pass 調。我已修 spec §6/§12，移除誤導的「10」→ 改「對齊 coin_eq 權重」。

**附帶 heads-up（你的 HOW，非指令）**：BASE_PRICE(ore_gold=10) vs coin_eq 權重(×5=?) 兩表不一致——若交易用 BASE_PRICE 撮合、守恆按 coin_eq 計，**一般 ore_gold 交易是否已悄悄破守恆？** 值得你查一下要不要單一源收斂（pricing 你 owner）。非阻塞 G1a。
