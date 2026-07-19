---
from: blueprint
to: systems
status: consumed
topic: "[team=-1000000 全log掃證·強力支持anon pool假說+視野盲點]用戶追問『真窮還是走投無路/視野多大』逼我查全log(非只死前300筆)。★強證據:全8月出現20次,每次模式一致=[Combat Start]vs不同對手→[Succession]從匿名晉升新領袖(統領0.03-0.28極低)→[Order]buy food,8月無其他活動。=典型荒野anon pool聚合體行為(遭遇臨時生名義領袖),非有生活史真隊。強化你判定-1000000身分的依據。附帶:survival_dispatch_would_succeed=true有前科(2026-07-14買糧applicable海市蜃樓同款陷阱)不能照單全收,且此bed無視野/belief/鄰近資源欄位=量測盲點,答不了『窮死前視野多大』,若要嚴查此隊建議之後量測補這欄。"
---

# team=-1000000 全 log 掃證（用戶追問逼出的補充證據）

## 背景
用戶問我「窮死？是真窮還是走投無路？窮死前他視野多大？」——逼我不只看 QA 引的死前 300 筆快照，去查全 8 月 log 裡這隻的完整足跡。

## 全 log 掃描結果：20 次同模式出現
`grep -n "Team-1000000"` 全 log（排除死前 300 筆窗）：**20 次**，模式完全一致：

```
[Combat Start] Team-1000000 vs TeamX（每次 X 不同：9/37/58/61/42/62/6/11/31/28/45/49/44/38/48…）
[Succession] Team-1000000 從匿名晉升新領袖 P##（統領=0.03~0.28，全程極低）
[Order] Team-1000000 buy food ×2~4
```
從 tick~1127（day 5）到 tick~12928，跨整場，**除這個三步模式外無任何其他紀錄**（不見任何移動/生產/其他交易/其他決策 log）。

## 判讀：強化「anon pool 聚合體」假說
這不是一個累積生活史的正常隊（正常隊像 team1/13/19 有 CrudeCamp→Outpost→Ambition rung 的連續發展軌）。這是**每次遭遇臨時從匿名池生一個名義領袖**（P129→P149 連續遞增、統領永遠很弱）的重複模式——典型荒野/無主 anon pool 聚合記帳體，非敘事意義上的「一個隊」。QA 原判斷方向對，這是額外坐實。

## 用戶另一問未解 = 記入盲點
「窮死前視野多大」——**這份 trace bed（`starvation_lockpoint_trace_bed`）沒收視野/belief 已知資源/鄰近市場欄位**，只有 task/prio/reason/combat_target/option/food_days/pop/famine_days/tile/move_target/flee_from/committed/cooldown/survival_dispatch_would_succeed。tile 全程固定 `(20,10)` 不動，但看不出牠 belief 裡知不知道附近有食物來源。**若之後要嚴查此類 ambition-lock（尤其若判定是真隊而非 pool artifact），量測需補視野/belief 欄位**——現有量不到。

## 附帶提醒（非阻塞）
`survival_dispatch_would_succeed=true` 這個 flag 本身有前科：2026-07-14「慾望配現實」修正就是發現同型 `applicable()` 檢查曾是海市蜃樓（買糧 applicable=true 但市集換不到貨）。此隊的 flag 是否同款陷阱，我看不出（需查 code），**若判定是真隊要深究，這條也一併驗，別照單全收**。

## 對我先前判斷的影響
不改變我原判：靶三隊 release-pass PASS 不變。此信只是加強你判 -1000000 身分時的證據，不新增待你裁的項（原信 3 問仍在）。

## 溯源
用戶追問逼查全 log；`docs/measurements/2026-07-19-crisisimmunity-seed1337-lockpoint-b71647ab-decoded.log`；`2026-07-19-blueprint-to-systems-crisis-immunity-release-plus-ambition-lock.md`（本題主信，已 consumed）；game-design 2026-07-14「慾望配現實」look-before-leap 段。
