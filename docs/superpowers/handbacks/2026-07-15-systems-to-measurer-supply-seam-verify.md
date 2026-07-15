---
from: systems
to: measurer
status: consumed
topic: "[量測·中性full-HD·經濟arc第一刀] 供給seam@4c2f85cb——★市場revive?order_fulfilled回升+arb_kill_nostock降+coin流+守恆+掛單噪音修前後對比(#7)"
---

# 量測：供給 seam 修（中性 full-HD，經濟維第一刀）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/supply-seam-effective-holding` @ **`4c2f85cb`**（base 最新 main）。systems 驗 diff PASS：`effective_holding`/`spend_holding` accessor + order_system 三讀點統一（賣/買短缺/food）+ `_execute_transfer` seller 走 spend_holding（守恆先扣糧倉）。TDD 9 綠 + CoinAudit delta=0、headless 3+3、sites=29。

## 這是經濟 arc 第一刀（seam 修=啟動經濟）
根＝framework seam（manufacture→public_storage，賣/買讀 team.resources=0）。修＝統一 accessor 讀糧倉貨。**驗市場 revive**。

## 要驗（★中性 full-HD force_full_hd）
1. **★供給活（headline）**：`order_fulfilled` 從 ~0（前 6月共1筆）**回升**（>0 顯著）、`arb_kill_nostock` 從數千/月**大降**（有貨可撮）。before(main 4c2f85cb 之前)/after(branch) 對比。
2. **市場流動**：定居隊製造 surplus 掛賣單（`trade.post_sell` 非糧 >0）、成交、**coin 流動**（買方付賣方收，私囊鎖是否鬆）。
3. **★掛單噪音修前後對比（驗收#7，blueprint+用戶抓）**：`order_placed`/`arb_call`/`arb_kill_nostock` 前後——**看噪音是供給下游自消 vs 獨立 churn**：
   - kill_nostock 大降 + order_placed 降（買短缺讀 effective→不亂買已有貨）→ 供給下游自消。
   - 殘留 order_placed 高（隊照掛成不了的單）→ 獨立 churn，回報數字供 blueprint 定掛單紀律 scope。
4. **★守恆**：CoinAudit delta=0、InvariantAudit=0、無幽靈貨（賣量=public_storage 實扣量）。
5. **不誤傷**：施工隊不賣建材、food 賣單照常（227 筆量級）、既有飢荒/貿易鏈綠。
6. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites=29、headless 零新增。

## 判定
- order_fulfilled 回升 + kill_nostock 降 + coin 流 + 守恆 → 市場 revive → handback `to:blueprint`（含噪音組成數字）→ QA/blueprint 批 merge → **觀察 revived 經濟定發展模型**。
- 市場仍死（fulfilled 仍~0）→ seam 沒接對 or 更深斷點 → halt `to:systems`（貼數字）。
- 守恆破（CoinAudit≠0/幽靈貨）→ 硬 halt。

## 下游
數字一封信 `to:blueprint`（order_fulfilled 前後 + kill_nostock 前後 + coin 流 + 守恆 + **掛單噪音組成：供給下游 vs 獨立 churn**）→ blueprint+用戶觀察 revived 經濟。溯源 raw + measured_at_head `4c2f85cb`。log/jsonl 存前 UTF-8。
