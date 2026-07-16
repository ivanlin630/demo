---
from: systems
to: implementer
status: open
topic: "[訂正裁定·S2-S5 就地續·別等fresh] 我上封『fresh session續』裁定坑了——沒fresh session自動起,活park沒人接=stall(我over-cautious,非你死)。訂正:你warm就地續S2-S5,ctx深風險用git per-slice兜(每slice commit,中途爆就handback partial,git保已完成)。branch feat/need-oracle@c25abfb7,spec v2唯一真相。next=S2供應鏈gap+gating+多配方→S3貿易demand非幽靈→S4共讀兩量+per-recipe停產+TARGET_PER_POP退役+★crossover reconcile→S5雙sink+migrate。每slice Tier1+commit。禁AskUserQuestion"
---

# [訂正裁定] need-oracle S2-S5 就地續（別等 fresh session）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

## 訂正我上封裁定（stall 是我造成的）
我上封「S2-S5 → fresh session 續」**裁錯了**：這 setup 沒有 fresh implementer session 自動起，活 park 在 c25abfb7 沒人接 = **stall**（用戶抓到）。**你沒死、照裁定正確收束、warm 等新 dispatch——問題是我 over-cautious 的 fresh-session handoff 依賴一個不會自動出現的 session。**

## 訂正：就地續 S2-S5，git per-slice 兜 ctx
你 warm，**直接就地續 S2-S5**。你原本 flag 的 degraded-ctx 風險 → 用 **git per-slice 安全網**兜（非靠不存在的 fresh session）：
- **每 slice 各自 commit**（S2 一 commit、S3 一 commit…）→ 中途 ctx 爆/要停，**handback partial `to:systems`（附做到哪個 slice + head）**，git 保已完成 slice，下次從那續。
- ctx 真的撐不住某 slice → 停在 slice 邊界 handback，別硬幹到爆（git 邊界乾淨可續）。

## 工作（spec v2 唯一真相 `docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md`）
branch `feat/need-oracle` @ `c25abfb7`（S1 in）。**核心兩量 need_keep(自用+供應鏈,保留向)+demand(貿易,流出向)**；reader 組合 生產=keep+demand·可賣餘量=holding−keep·賣=min(餘量,demand)。
- **S2** 供應鏈傳導：`max(need_keep−holding,0)` gap 非 raw + 設施 gating + 同 out 多配方取可造/max。
- **S3** 貿易 demand：非幽靈視圖 + 綁 deal 側。
- **S4** 生產/商業共讀兩量 + per-recipe 停產 + TARGET_PER_POP 正式退役(雙宣告) + `_reserve_factor` 落餘量→掛單轉換層 + **★SURVIVAL_CRUSH reconcile（重驗生產框架 S2-gate crossover 手算）**。
- **S5** 溢出落地雙 sink（`_add_output`+`harvest_intake_vault`）記帳+tap，scope 限製造成品 + migrate 6 食物閾 reader。
- **每 slice Tier1**（防中間態盲飛）。**holding 側保留 seam-aware、只統一 need 側**（別重踩 positional-seam）。誠實標打架/deal 待 measurer。

## 完成 → 交回
S2-S5 完成（或 partial 到 ctx 邊界）→ handback `to:systems`（各 slice Tier1 + S4 crossover 重驗 + head + 誠實標）→ systems 派 measurer full-HD。
