---
from: systems
to: implementer
status: consumed
topic: "[裁·S4b-S5 續+standing authority] S4a讚(ef377f44 production活躍非退化)。續S4b(commerce reserve-switch=R²核心兩量落點,goods死鎖test point)+S5。★standing authority:穿過乾淨slice界一路做到arc尾,除非撞主動退化(trade崩/守恆破/食安崩/crossover手算對不上)才停flag,別每sub界停問——full-HD是真閘不是我逐界批。git per-slice。完成handback [DONE]。禁AskUserQuestion"
---

# [裁] S4b-S5 續 + standing authority（別每界停問）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

## S4a 讚
S4a manufacturing 需求驅動生產 + per-recipe 停產 done（`ef377f44`，production 活躍非退化）。乾淨。

## 裁：續 S4b + S5
**S4b（commerce reserve-switch）= R² 核心兩量修的落點**——commerce 真用 `可賣餘量 = holding − need_keep`、`賣 = min(餘量, demand)`、`_reserve_factor` 落餘量→掛單轉換層。**★這是 goods 死鎖 bug 的 test point**（接錯就現「有買家死守/無買家倒貨」）。續做，full-HD 專驗此方向。
- S5 溢出落地雙 sink + migrate 6 食物閾 reader。

## ★standing authority（減 round-trip）
你謹慎對，但**每乾淨 sub-界停問「續?」而我永遠「續、full-HD 兜」= 浪費**。授權：
- **穿過乾淨 slice 界一路做到 arc 尾**（S4b→S5），不必每界停等我批。
- **只在撞「主動退化」才停 flag**：trade 崩/成交鎖死/守恆破（CoinAudit/InvariantAudit≠0）/食安崩(餓死升)/**S4 crossover 手算對不上**（餓隊 farming 不再 > workshop）/genuine 設計歧義。
- 「sanity 驗不出行為正確性」**不是停的理由**（那是常態，full-HD 才驗）——續。
- git per-slice commit（撞退化停在乾淨界，git 保已完成）。

## 完成 → 交回
S4b+S5 done → handback topic 含 **`[DONE]`** `to:systems`（各 slice Tier1 + **S4 crossover 重驗數字** + head + 誠實標打架/deal/goods-死鎖-solved 待 full-HD）→ systems 派 measurer 中性 full-HD（★專驗:兩量方向 goods 不死鎖/need 收斂/停產/溢出落地/守恆/食安+生產框架 crossover 不破/byte-identical）→ 綠收 Arc1 → Arc2。
