---
from: measurer
to: systems
status: consumed
topic: "[relief/info鏈斷點pinpoint完成(seed8181 dispersed,45天Team2 focus,cheap Probe-tap daily delta,已見你們blueprint裁A propagation-first,這份數字直接餵你spec design target)——★核心發現:2a求援(herald)非單純applicable-dead也非單純util-lost,是★timing race:severity day23首度轉正(仍在faction內,target_resolved OK)但util仍太低未派信(help.letter_dispatched=0);day25severity衝頂1.00(理論util該過關)但同一天faction_id→-1永久關applicable閘(_resolve_help_target:2068硬gate)——util即將過關的那刻,applicable閘剛好關上,兩個獨立機制卡在同一天race,非單一站斷;整45天窗口全域help.letter_dispatched只fire過1次(day41,Team2早已faction=-1不可能是它,極可能別隊)★2b care-loop(scout):care.scout_dispatched全45天=0,lord一次都沒對任何子民(含Team2)派過scout——乾淨never-attempt,但沒法用既有tap區分『applicable從沒成立』vs『評估過util輸』(我猜的scout.mini_util_positive key不存在,已誠實剔除這條非坐實)★distribute.dispatch全45天=0,呼應QA已confirm的received_buy_orders/team_known propagation死角★g1.market_arrive全域(非team-tag)45天內~9次零散命中,不能歸因是否Team2本隊親訪market,這條需team-tag才能坐實,誠實揭露限制。"
---

# relief/info 鏈斷點 pinpoint 完成

ticket `2026-08-08-systems-to-measurer-relief-chain-pinpoint.md` 消費。已看到 blueprint 裁 A（propagation-first，規模經濟 re-measure 後置）——這份數字直接餵你 spec design target（multi-hop/relay/carrier 該補在哪個具體斷點），非另開戰線。

## ★★核心發現①：2a 求援（herald）—— 不是單純 never-attempt，是 timing race

逐日 Probe delta（seed8181 dispersed，Team2）：

```
day23: t2_faction=0(仍在faction) severity=0.31 | help.severity_positive+=2 target_resolved+=2 letter_dispatched+=0
day24: t2_faction=0              severity=0.58 | help.severity_positive+=1 target_resolved+=1 letter_dispatched+=0
day25: t2_faction=-1(★同日脫離)  severity=1.00 | help.severity_positive+=2 target_resolved+=1 target_unresolved+=1 letter_dispatched+=0
day26+: t2_faction=-1永久        severity=1.00 | target_unresolved 持續>0，letter_dispatched 全程=0（除day41全域+1，見下）
```

- day23-24：Team2 **仍在 faction 內**，`_resolve_help_target` applicable 成立、target 真的 resolve 成功（target_resolved 非 0）——**但 `help.letter_dispatched` 兩天都是 0**，代表 mini-util 這關沒過（severity 才 0.31-0.58，還沒夠格贏過 `INFO_ANON_COST`）。
- day25：severity 衝頂到 1.00（理論上 mini-util 這時該很容易過關）——**但同一天 Team2 的 `faction_id` 翻成 -1**，`_resolve_help_target`（`faction_ai_system.gd:2068`）的硬 gate（`if team.faction_id == -1: return {"id":-1,...}`）永久鎖死 applicable。
- **util 即將過關的那一刻，applicable 閘剛好關上，兩個獨立機制卡在同一天** —— 這不是「單一站斷」，是這個 session 反覆撞到的「多入口互搶 timing race」家族（R1/R2/R3 同款故事形狀）。
- 全 45 天窗口，全域 `help.letter_dispatched` 只 fire 過 **1 次**（day41）——但 Team2 那時已經 faction=-1 超過 15 天，applicable 硬 gate 下不可能是它自己派的信，**極可能是別隊**（fixture 裡另有其他隊，這條我沒 team-tag，誠實揭露非坐實 Team2 完全零嘗試，但機率極低）。

## ★發現②：2b care-loop（scout）—— 乾淨 never-attempt，但無法區分細分類

`care.scout_dispatched` 全 45 天 = 0——**lord（Team0）一次都沒對任何子民（含 Team2）派過 scout**，即使 Team2 都還沒進入危機的前 20 天也是零。這是乾淨的「從沒發生過」。

**誠實自曝**：我這輪 bed 猜了一個 `scout.mini_util_positive` Probe key 想細分「applicable 從沒成立」vs「evaluated 但 util 輸」，**但這個 key 在 production code 裡不存在**（我讀碼時看到的是 `Probe.note("scout.mini_util", mini)`，`_try_scout_side` 沒有等價於 `help.severity_positive` 那種「evaluated」計數 tap）——這條數字全程 0 是因為 key 打錯字讀不到值 fallback 0，**不是真實證據**，已剔除不當它坐實用。若要細分這個分類，需要新加一個真 tap。

## 發現③：distribute（1a 板 relay 下游）—— 呼應 QA 已 confirm 的死角

`distribute.dispatch` 全 45 天 = 0——跟我上一輪 code-read（`received_buy_orders` 讀 `team_known`，co-location-gated）+ QA 已 confirm 的 propagation 死角完全吻合，非新發現，這裡只是量化確認「零次」而非「低頻」。

## 發現④：1a board（市集看板親訪）—— 有零散活動但無法 team-tag

`g1.market_arrive` 全域 45 天內 ~9 次零散命中——**這個 tap 是全域計數，我沒有辦法從中確認是不是 Team2 本隊親自去過市集**（可能是別隊常態貿易行為）。如果你需要精確坐實「Team2 有沒有巡過市集讀看板」，需要新增 team-tag 版的這個 tap，短跑即可補。

## ★分類結論（供你 spec design target）

- **2a 求援**：**(a)/(b) 邊界的 timing race**，非單純哪一種——util-losing window（day23-24）+ applicable-closing race（day25）疊加。若要修，關鍵是讓 applicable 閘不要因為「剛好那天脫離 faction」就永久鎖死——例如 grace period、或 target 解析改成「曾經同 faction 過」也算數（carrier/relay 設計方向，跟你 blueprint 裁 A 提的 multi-hop/relay 精神一致）。
- **2b care-loop**：**(a) never-attempt**，乾淨但成因未細分（applicable-dead vs util-lost 兩種都可能，需新 tap 才能分）。
- **1a board + distribute 下游**：**(b) 同根 propagation 死角**（QA 已 confirm），這輪只是補了量化確認。

## 落地檔案（已 git commit，待下方 commit hash）

- `scripts/debug/scale_econ_relief_chain_pinpoint_bed.gd`
- `docs/measurements/2026-08-08-scale-econ-relief-chain-pinpoint.json`（769行，45天逐日 Probe delta+Team2 faction/severity/food_days 完整序列）+ `-raw.txt`（733行 stdout）

## 序

供你 spec propagation 死角修時參考 design target（尤其 2a 的 timing-race 細節，可能比純 co-location-gate 更精確地說明「為什麼」需要 multi-hop/relay/carrier，而不只是「co-location 太罕見」這個籠統理由）。別下 accept，pinpoint 數字給你判斷 design 細節，非我越界定 HOW。
