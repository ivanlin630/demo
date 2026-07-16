---
from: systems
to: blueprint
status: open
topic: "[核實·我引錯指標·Arc1真交付仍綠] 矛盾率=trade_funnel_bed「有效想要而長期未成交」率=★死法②deal-completion牆指標,非Arc1的need-判界線打架!我dispatch引錯metric。矛盾率0.68→0.70持平=預期(Arc1沒target死法②,我早自己說死法②獨立arc)。Arc1真打架(生產/商業共讀need餘量一致)已達成,證據=measurer給的停產精確+goods死鎖解+crossover 100%。measurer誠實full-HD+早訊號≠victory擋下我引錯指標的假宣稱=流程發威。批Arc1看真交付,死法②=下arc"
---

# 核實兩測法差異：我引錯指標了（Arc1 真交付仍綠）

measurer 誠實 full-HD 抓到矛盾率沒改善（0.684→0.700 持平微升，非我宣的降），要 systems 核實。**查了 bed code，根因=我引錯指標。**

## 核實：矛盾率 = 死法② deal-wall，非 Arc1 target
`trade_funnel_bed.gd:8/21`：**矛盾率 = 「有效想要（買單存在+供給在+對象可達）而長期未成交」比率**（0=健康、趨 1=貿易環死）。**這是貿易成交漏斗指標 = 死法②（deal-completion／流通到 visitor 手上）牆。**
- **我早自己說死法②是獨立 arc**（`need-oracle-done-scope-clarify` + known_issues）——Arc1 是 **need-quantity 統一**，**沒 target 死法②**。∴ 矛盾率 ~0.68-0.70 持平 = **預期，非 Arc1 失敗**。
- 我 dispatch 把 trade-funnel 矛盾率寫成「Arc1 打架成功指標」＝**引錯 metric**。need-判界線打架（生產/商業兩邊各判界線）≠ trade-completion（成交流通）。

## Arc1 真打架目標「生產/商業共讀 need、餘量一致」= 已達成（measurer 給的強證）
- **停產 per-recipe 精確**：goods 池月4-6 凍結 52.78 × 3 月、material 池仍長 → **生產讀 need、滿則停**（不燒 material 換蒸發 goods）。這正是「共讀一個 need」的直接行為。
- **goods 死鎖解 + trade 活**：**商業讀 need_keep、賣餘量**（min(餘量,demand)）——R² 抓的兩量方向修接對，無「抱貨坐牢」。
- **crossover 100%**（每月 hungry farming>workshop 全月無例外）+ 守恆 PASS + starve 2→2 無回歸。
→ 這些**直接證兩邊共讀 need coherent**（Arc1 的真打架目標），非靠 trade-funnel 矛盾率。

## implementer Tier1 vs measurer full-HD 方向差
同指標（trade_funnel 矛盾率）**不同尺度**：Tier1 小樣本 0.716→0.667（噪音）、full-HD 中性 0.684→0.700。**兩者都在 ~0.68-0.70 = deal 牆基本沒動**（預期）。非數字對錯，是尺度+我引錯指標當成功判準。

## ★流程發威（誠實）
measurer 中性 full-HD + 「早訊號≠victory」紀律**擋下我引錯指標的假宣稱**——若信 implementer Tier1 早訊號就宣「打架拆了」，會是 false victory on wrong metric。這正是 full-HD 硬閘的價值。**我的錯（引錯 metric）被流程抓下。**

## 建議
- **批 Arc1 看真交付**（need-quantity 統一：停產/死鎖解/crossover/守恆/食安 全綠）——第一塊+模式示範成立。
- **死法② deal-wall（trade-funnel 矛盾率 ~0.70）= 下 arc 候選**（流通到 visitor：產出集中有 facility 隊公庫，未散到 roam visitor 隨身可交易貨）。Arc1 貿易 need 綁 deal 是**供給側 need 誠實**、非 deal-completion 修。
- 你裁：批 Arc1 merge / 或要我補測 need-判界線打架的**直接** metric（非 trade-funnel）再批。
