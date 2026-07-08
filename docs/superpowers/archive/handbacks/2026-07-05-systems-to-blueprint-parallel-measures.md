---
from: systems
to: blueprint
status: consumed
topic: 三平行measure齊(夜班)——共根=far-zone移速稀釋(B)一修多解(V4 envoy+V1 trade+V3帶禮結盟);V3直解結盟0.55恆false=判準題;V2-cmd結構shadow(徵收支配攻擊elif)待2probe;④後勤×1>10格餓死真帳→你裁補給;修序建議B高優先
---

# 三平行 measure 回報（夜班，你睡時跑完）

V3/V4/V2-cmd + ④後勤帳全碼追完（詳入 known_issues 各條）。**最大發現：共根收斂到 far-zone 移速稀釋（B）**。

## ★共根：far-zone 10× 稀釋 = 一修多解（B slice 價值遠超預期）

`movement:76 (+=TICKS_PER_HOUR) × sim_runner:237 (far 每 100tick 才跑)` → 自然世界全隊 far → 移速稀釋 10×。**一個 debt 連坐三病**：
- **V1 trade** 旅程永不到場（旗艦病，你已知）。
- **V4 envoy 送達=0**：timeout floor 12 天很寬，但 budget 按 near 速校準、信使跑 far 速(10×慢)→走 1/10 距離就逾時。
- **V3 帶禮結盟脫 0**：唯一能把結盟 accept 抬過門檻的 `gift_term`(+0.4) **只隨信使走** → 信使送不到 → 帶禮結盟一次沒發生。

→ **B（far elapsed 積分）一修解三**。B 是錨、正交於 A/規模、你已裁「即修」——**measure 證它價值最高（解 V1+V4+V3-禮 + ②行軍降頻餵 A 減 O(N²)）。建議優先級拉最高**（slice A 骨架後緊接，同 movement_system，注意協調）。

## 各病斷點 + 待你裁

### V3 提案 accept=0（兩因）
- (a) **帶禮結盟**=連坐 V4，B 修好自通。
- (b) **直解結盟門檻 0.55 恆 false**：收方視角重算封頂 ~0.44（fresh-world power_gap=0/relation/rep 低）。**判準題**：陌生隊在關係建立前結盟 accept=0 是「合理的0」（無理由結盟）還是病？我傾向合理的0（帶禮/關係積累才該過），但你/QA 裁。若合理→V3 只剩 (a)，隨 B 解。

### V4 envoy 送達=0
- 純 far-zone 稀釋（非 timeout 短）。**隨 B 解。** 附帶：`AI_ETA_LIMIT`(1200 固定 tick)、founding budget 校準 = 裸/near-速常數，wave 收編時對齊新骨架。

### V2-cmd commander 征服路 0 = 結構 shadow（非死碼）
- `if "徵收"`(1476) **嚴格支配** `elif "攻擊"`(1486)：攻擊-eligible 成員是徵收-eligible 子集，征服 tick 多半 co-emit 徵收(war_chest+補力levy)→ 攻擊 elif 對這些成員恆死。窄可達窗存在。
- **待 2 runtime probe 坐實**（shadow 率/攻擊-eligible 成員普查）——我可順手插（輕，等 slice A 重 bed 完錯開跑）。
- **means-end 判準題（你的 WHAT）**：獨立 prosperity 路已達征服（攻擊2/捕俘3/同化2）；**faction member 直接執行征服攻擊是否必要**？若必要→拆 elif 序/tag 支配；若獨立路夠→這是「合理的近0」。你裁 means-end 意圖。

### ④ 後勤「走一格餓死」真帳（錨①×1 前置）
- ×1 下乾糧只夠 **10 格**（×5 下 50 格=從不餓死，遮蔽真相）。沿途補給弱（覓食僅 1.5 天地板、路過自家村才滿補）。
- **founding(12+格)、trade(全圖)>10 格 → 斷糧；>17 格真餓死。** ETA-gated 任務(catch-up/occupy)因 `AI_ETA_LIMIT` 自動縮 5 格=安全。
- **你裁補給機制**（measure-first 不預開藥，選項供參）：升 `PROVISION_DAYS`？沿途 raid/買糧主動化？糧耗率調？journey-length cap？→ 這決定 slice A(×1) 落地後世界會不會餓死潮 → 與 A/gen 重校綁。

## 建議修序（給你裁）
1. **slice A（TimeScale 骨架+×5→1）** 實作中（我夜班驗+merge）。
2. **★B（far elapsed 積分）拉最高優先** = 解 V1+V4+V3禮 一修多解 + 餵 A（②行軍降頻）。B spec 我可備（同 movement_system，接 slice A 後）。
3. **④ 補給機制** 你裁 → 配 slice A/gen 重校（否則 ×1 餓死潮）。
4. V3(b) 直解結盟 + V2-cmd member 征服 = 判準題（合理的0 vs 病），你裁 means-end。
5. cadence 語意化(③)/CI/gen = wave 後段。

## 夜班狀態
- slice A 實作中，handback 落我驗（headless/framework/coin_eq + seeded hash 前後量級不崩全滅）+ merge + docs 收編，留交接。
- 三 measure 已入 known_issues。measure 儀器（V2-cmd 2 probe）待你確認要不要坐實。
- 卡點（seeded 崩全滅/spec 抓錯/判準需你裁）→ 留 handback，不自作主張。
