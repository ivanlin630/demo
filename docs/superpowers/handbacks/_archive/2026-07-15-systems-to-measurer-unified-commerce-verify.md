---
from: systems
to: measurer
status: consumed
topic: "[量測·整條經濟climax] 統一商業框架@ac18721d——★市場終於revive?deal大幅升(市場即地方,免賣方在場解65%漫遊)+統一無殘+守恆CoinAudit=0+coin單向泵長窗觀測(deals不得單調衰減0)+觀測on/off byte-identical"
---

# 量測：統一商業框架（整條經濟調查 climax — 市場 revive?）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/unified-commerce` @ **`ac18721d`**（base 最新 main）。systems 驗 diff PASS：M2 `_resolve_market_at_outpost`（owner-mediated 雙側 coin 雙向）+ order_id 權威直沖履約 + effective_holding/spend_holding 6 縫 + 去 absorb/spill + de-patch kill-list + invariants 公開地標豁免。TDD 12 綠+CoinAudit=0(4 scenario)+byte-identical+盲點閘+sites=29。

## 這是整條經濟調查的 climax（6+ 刀 inert 後統一框架一次做）
用戶裁：棄 hole-by-hole（打地鼠+互 confound）→ 整個商業框架一次做好+補釘融入+人格化+再量測。**乾淨模型，驗市場首次 revive。**

## 要驗（★中性 full-HD，before[main]/after[branch]）
1. **★市場 revive（headline）**：`deal`（按 ARCHETYPE_TRADE 分流的 deal probe）從 ~0 **大幅升**（市場即地方、買方到 outpost 買/賣 stock、免賣方在場→解 65% 漫遊撲空）；`order_fulfilled` 回升。**這是整條調查要看的一數。**
2. **★coin 單向泵長窗觀測（R² 異質審抓的風險）**：**長窗 deals 不得單調衰減到 0**（若 deals 暴增→coin 抽乾→歸零＝脈衝非穩態，那 coin 循環 backlog 要提前）+ **coin 分佈逐月記錄**（team/person/treasury/tile）。owner-mediated 雙側該讓 coin 雙向（買方→owner + owner→賣方）——驗真雙向非泵乾。
3. **統一無殘**：雙 resolver→單、target 三 fallback→單、accessor 6 縫→一個、掛單死常數→人格化、absorb/spill 拆。稽核無殘補釘。
4. **★守恆**：CoinAudit=0、InvariantAudit=0、無幽靈貨（履約 order_id 直沖不掛幽靈單）。
5. **觀測**：新路徑 specimen tap + 盲點閘綠 + **on/off byte-identical**（觀測非侵入）。
6. **不誤傷**：活命糧不甩（SURVIVAL 無單不賣）、既有飢荒/戰鬥/trade 鏈綠、resident 巧遇次路保。
7. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites 稽核、headless 零新增。

## 判定
- **deal 大幅升 + coin 雙向不泵乾 + 統一無殘 + 守恆 + 觀測非侵入** → **市場首次 revive、經濟維接通** → handback `to:blueprint`（deal 前後 + coin 分佈長窗 + 無殘稽核 + 守恆）→ QA → blueprint 批 merge。**經濟 arc 首個 non-inert 交付。**
- deal 仍~0（統一框架沒接對 or 更深）→ halt `to:systems`（貼數字，大框寧可多轉）。
- coin 泵乾（deals 衰減 0）→ 回報，coin 循環 backlog 提前。
- 守恆破/活命糧甩 → 硬 halt。

## 下游
數字一封信 `to:blueprint`（★deal 前後 headline + coin 長窗 + 守恆 + 無殘 + 觀測）。**後磨**（流動摩擦 tune / coin 循環 / threat 韌性 / accessor 殘）＝revive 後乾淨模型另刀。溯源 raw + measured_at_head `ac18721d`。log/jsonl UTF-8。
