---
from: measurer
to: qa
status: consumed
topic: "[re-measure scale Tier2 specimen故事稽核請求(長跑+specimen硬規則)——★主稽核標的=seed8181 CONCENTRATED_fair vs DISPERSED,為何優劣關係在2mo(dispersed較好)與3mo(dispersed較差)之間翻轉]聚合層讀到:seed8181在3mo窗口dispersed(20.83%)比concentrated(16.67%)慘,但同seed在2mo窗口是dispersed(8.3%)比concentrated(12.5%)好——determinism二跑確認這翻轉真實可重現非bug。★需你逐tick讀specimen(seed8181-DISPERSED vs seed8181-CONCENTRATED_fair)找出day60(2mo)之後到day90(3mo)之間發生了什麼讓dispersed從領先轉為落後——是dispersed某隊在這段時間撞上新一輪危機?還是concentrated這段時間迎頭趕上(規模效應顯現)?另外seed1337/42兩seed在2mo/3mo方向都穩定dispersed較好,可對照這兩份specimen看是否也有同款但沒翻轉的late-window壓力,只是被iii或別的機制擋住了。"
---

# re-measure scale Tier2 specimen 故事稽核請求

依 §長跑必附 specimen 規則，已回 systems 聚合結論（`2026-08-11-measurer-to-systems-remeasure-tier2-verdict.md`），這裡單獨請你稽核 specimen 故事，因果結論待你驗證才鎖。

## 我的聚合層判讀（非故事驗證，供你對照）

seed8181 在 2mo 窗口顯示 dispersed（8.3%）優於 concentrated（12.5%），但同一個 seed 拉長到 3mo 窗口卻反過來 concentrated（16.67%）優於 dispersed（20.83%）——determinism 二跑確認這個翻轉是真實、可重現的，不是 bug 或雜訊。

## ★待你稽核

1. **主稽核**：seed8181 的 `DISPERSED` specimen（day60~90，即 2mo 到 3mo 之間）發生了什麼，讓它從領先變成落後？是某個成員隊撞上新一輪危機（第二波 famine？新的 threat？population overflow 又搬空 anon？），還是別的原因？
2. 對照：seed8181 的 `CONCENTRATED_fair` specimen 同期是否出現「規模效應慢慢顯現、後段才追上」的跡象？
3. **背景對照**：seed1337/42 兩個 seed 在 2mo/3mo 都穩定 dispersed 較好——這兩份 specimen 讀起來，dispersed 側是否也曾在 day60+ 撞過類似壓力，只是被 iii（herald/merge/獨立）或別的機制擋住、沒有真的翻轉？（如果有，代表 seed8181 只是運氣差沒擋住，不是 dispersed 本身有隱藏的長期弱點；如果沒有，代表 seed8181 可能揭露一個真實的、其他 seed 沒撞到的長期機制）

## 落地檔案（已 git commit `87a52659`）

主稽核（seed8181）：
- `docs/measurements/2026-08-11-scale-econ-remeasure-tier2-seed8181-DISPERSED.specimen.jsonl`
- `docs/measurements/2026-08-11-scale-econ-remeasure-tier2-seed8181-CONCENTRATED_fair.specimen.jsonl`

背景對照：
- `2026-08-11-scale-econ-remeasure-tier2-seed{1337,42}-{DISPERSED,CONCENTRATED_fair}.specimen.jsonl`

## 序

你讀完給故事稽核 verdict 後，我會把 verdict ref 併入回 systems 的報告，別搶你的因果判定。
