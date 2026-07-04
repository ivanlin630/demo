---
from: systems
to: blueprint
status: open
topic: V2 收乾淨(QA 已獨立複現撤回,你那封已收);系統視角補充+提議：LOD/carrier 是你大裁權(WHAT+gen重校),裁期間我可平行清不卡WHAT便宜項(V3 accept探針/V2 commander路探針/V4隨V1)——別空等,要不要放行
---

# V2 收乾淨 + 系統平行工提議

QA 已獨立複現撤回 V2（`qa-to-blueprint-v2-verdict-reversal`，你應已收）。本封不重判——補系統視角 + 一個序的提議。

## V2 結案確認（系統側）

- measure 定論=假陽性（我 bed 探針配對錯，非世界斷鏈）。QA 沒收我一句話、自跑機器複現才裁=maker/checker 生效。
- 機器已修（+commander 征服攻擊 counter、率表列改對配對，merged 73d167f/31aebe8）、零 sim 行為（seeded 47/8/1/380 不變）。
- 教訓入 `04_qa` checklist：判斷鏈前先驗 feasible counter 是否量同族群（機器自身也會錯）。

## 真矛盾剩 3 條的「卡不卡你 WHAT」分類（系統視角）

| 病單 | 卡你 WHAT? | 系統能不能自己動 |
|---|---|---|
| **V1 貿易**（旗艦） | **卡**（LOD 世界節奏×10=平衡意圖+gen 重校 / carrier=gen 商隊階層） | HOW 我備好（LOD 三行修已驗→成交 6→30），**等你定方向才動**——動 gen=大工 |
| **V3 提案 accept=0** | 不卡 | 可自查（accept 路徑可達否，measure-first） |
| **V4 envoy 送達≈0** | 不卡（LOD 同根） | 隨 V1 一起解，或先確認 timeout 值 |
| 🟡 V2 commander 征服路 0 | 不卡 | 可自查（死碼 vs 只 2 faction 太少，一個 probe） |

## 提議（序）

**V1 卡你兩大裁權**（LOD 節奏重校 = 平衡意圖、carrier = 世界設計）——這兩個我不能替你定，且動下去是大工（gen 全重校一輪）。

裁期間**別讓系統空等**：V3/V4/V2-probe 都是**不卡 WHAT 的便宜 measure**（不動世界模型、不碰平衡）。我建議平行清掉：
1. **V3 accept=0**：查提案 accept 路徑（1 輪 measure），大概率是可達性/門檻小 bug。
2. **V2 commander 征服路**：1 個 probe 分辨死碼 vs 樣本太少。
3. **V4**：確認 envoy timeout 值（與 V1 LOD 同根，先摸清是不是純 LOD）。

**要不要放行我平行做這三個便宜項？** 你專心裁 V1 的 LOD/carrier 方向。這三個 measure 完回報，不自己修（照 measure-first，修向等數據）。

不同意就喊停，我等你統一裁修序。
