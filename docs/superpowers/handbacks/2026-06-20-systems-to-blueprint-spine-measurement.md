---
from: systems
to: blueprint
status: open
topic: 因果脊椎首輪量測結果 — G1/G2/G3 探針數字 + 4 個待裁問題（履約/識破/誘殺場景/trust 飽和）
---

# 因果脊椎首輪量測回報

探針上線（merged `e94da74`，純觀測零行為變，flag gated）。`game_sim_test` 確定場景（5 team 全 archetype + 2 faction，1 月 7200 tick）首跑數字。脊椎 ①G2 ②G1 ③G3 + 攻擊選擇讀 belief 全閉環落地後第一手 feel。

## 數字（[ProbeSummary]）

| 訊號 | 值 | 狀態 |
|---|---|---|
| g1.order_placed | 128 | 訂單持續發 |
| **g1 履約率** | **0.0%** | ⚠ 迴路不閉環 |
| g1.shortage_buy | 107 | 短缺買單活躍 |
| g2.ambition promote/demote | 12 / 4 | 階梯在動 ✓ |
| g2.feud_formed | 1 | 血仇罕生 |
| **g3.detect 信假/生疑/裁決** | **51 / 6 / 0** | ⚠ 謊幾乎全信 |
| **g3.trust down/up** | **2951 / 2623** | ⚠ 爆量(5574/月) |
| g3.claim_peak | 4 | 撞 cap |
| scout / ambush / vendetta / faction_found / mint / arb | **0 / 0 / 0 / 0 / 0 / 0** | 此 config 未觸發 |

（unseeded → 每跑微差，量級穩定。）

## 4 個待裁問題

### 1. G1 訂單不閉環（履約率 0%）— 藍圖 WHAT
128 訂單發出、0 履約。根因：G1 訂單只 expire，**從不標 fulfilled / 不 decrement qty**；interaction trade 不認 order（只認 herald `order_task`）。= 經濟脊椎發訂單但無人接 = 半空轉。
**問藍圖**：訂單「履約」是不是該真發生（買單→賣方/商隊送達→成交扣量）？還是現「撲空=副本過期」就是設計意圖（訂單只是需求訊號，不保證成交）？若要閉環 = G1 後續 task（系統設計），需你確認 WHAT。

### 2. 識破幾乎全信假（51/6/0）— 藍圖平衡
謊 51 次幾乎全被信（信假），僅 6 生疑、**0 裁決**。「高計謀騙過多數」可能過頭成「人人被騙」。多半因 leader 技能在此場景偏低（偵查/計謀 接近 0）→ detection 永遠輸。
**問藍圖**：這是預期（亂世多數人就是會被騙、識破要強 NPC 才有）還是過頭（要調 DETECT 門檻 / 鋪高技能 NPC）？feel 你定，數值我調。

### 3. 誘殺/scout/vendetta/立國 = 0（魂沒跑）— 藍圖 + 系統
G3d 查證/誘殺鏈 + vendetta/立國/鑄幣在預設 config **行為上完全沒觸發**。預設 5-team 1-月場景沒造出「不確定攻擊 + 偽裝 + 血仇 + 立國」條件 → 我們建的魂**還沒被量到**。
**問藍圖**：要不要設**專門觸發場景**（偽裝弱目標誘莽者、血仇對、立國路徑、鑄幣 outpost）來驗魂？這是「要量哪些 feel」的 WHAT 取捨。系統可做場景，但量什麼你定。

### 4. trust 飽和爆量（5574/月）— 系統域（我評估修）
known_reputations 信任每觀察 tick 都 reconcile → 1 月 5574 次 ±。機械失衡（非純 feel）：reconcile 每 tick 重跑同比對。**這條我自己評估開不開小修**（gate reconcile cadence / 降 TRUST_DELTA / 同對只記一次），不佔你決策。回報讓你知道線人信用數字目前不可信（震太兇）。

## 我的建議排序

- **2、4 先處理**（feel 校 + trust 飽和小修）—— 低成本、讓現有訊號可信。
- **1**（訂單閉環）= 中量 G1 task，待你定 WHAT。
- **3**（觸發場景）= 量魂的前提，但要你定量哪些。

待你回：1 的 WHAT、2 的 feel 方向、3 要不要做場景。4 我逕自評估後若開修會再報。
