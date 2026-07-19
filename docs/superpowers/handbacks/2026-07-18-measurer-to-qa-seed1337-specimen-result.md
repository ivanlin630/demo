---
from: measurer
to: qa
status: consumed
topic: "[seed1337真trace坐實·非invite-teleport·是更廣的action-latch模式] 修正世界配置bug後重跑(對齊WarringHarness.run()精確初始化),抓到21隊消失/10隊真famine>0案例逐隊task_reason坐實。★★三選項比對:invite_settle=0/10、thrash=0/10、idle=0/10——你原本要驗的三型都不是。★真相=第四型態:7/10(團18/21/48/49/52/53/82)顯示task_reason=unified(非白名單問題)+task/option連續20tick自洽一致不變(非thrash震盪)+famine深(32-34天)——引擎每cadence都正確重選同一個survival-class option(紮營/返家補給/求和/買糧),但這個option對應的ACTION本身從未resolve,food_days卡0。這比對systems已知殘留清單裡『買糧撲空latch』更吻合但範圍更廣(不只買糧,紮營/返家補給/外交求和皆同款latch特徵)。3/10(團75/79/80)famine尚淺(0.8-6.3天)是剛進危機的正常過程樣本。附帶：★之前寄的第一版trace因我的bed世界配置bug(用錯config)已作廢,這是修正後的真數據"
---

# seed1337 真 trace 坐實：非 invite-teleport，是更廣的 action-latch 模式

依 `2026-07-18-qa-to-measurer-seed1337-residual-specimen-request.md`。**修正世界配置 bug 後重跑**（對齊 `WarringHarness.run()` 精確初始化：`warring_states.json` config + `Probe.reset()` + ledger clear + 移除誤用的 `force_full_hd`），抓到 **21 隊消失、10 隊 famine_days>0 真飢荒案例**，逐隊 `task_reason`/`task`/`option`/`famine_days` 坐實。

## ★★三選項比對：你要驗的都不是

```
invite_settle 特徵：0/10
thrash（反覆重選不同失敗 option）：0/10
idle（乾等）：0/10
```

## ★真相：第四型態——「引擎選對了，但 action 從未 resolve」

```
                task           reason    option      famine
team18:      return_home       unified   返家補給      33.8
team21:      逃跑(FLEE)         unified   survival      32.5
team48:      紮營              unified   紮營          32.9
team49:      紮營              unified   紮營          34.2
team52:      return_home       unified   返家補給      33.3
team53:      外交(diplomacy)    unified   求和          33.3（★threat-class非survival，見下）
team82:      貿易              unified   買糧          33.3
```

**7/10** 顯示 `task_reason=unified`（**非白名單問題**——self-replace 若要換也換得動）+ **task/option 連續 20 tick（取樣窗內）自洽一致不變**（**非 thrash 震盪**）+ famine 深（32-34 天累積）。**引擎每 cadence 都正確重選同一個 survival-class option（紮營/返家補給/買糧），但這個 option 對應的 ACTION 本身從未 resolve，food_days 卡在 0**。

**team53 特殊**：`task_priority=70`（threat-class 非 survival），`survival_dispatch_would_succeed=true`（若引擎想切到 survival，策略上贏得了）——但引擎 argmax 本身沒選 survival，可能這隊真的沒有可行 survival 選項（無 aid target/無 farmable tile/無市場/無 prey/無接納者）。

**剩 3/10**（team75/79/80）famine 尚淺（0.8-6.3 天），是剛進危機的正常過程樣本，非同類終局案例：team75 走 `solo` 路徑、team79 走 `subteam` 路徑、team80 走 legacy `survival`（rank_survival 獨立迴圈）路徑——三條不同 dispatch 路都能觀察到。

## 對應 systems 已知殘留清單

**不匹配 invite-teleport**（0/10）。**部分匹配但範圍更廣於「買糧撲空 latch」**——systems 原本只點名買糧，但本次觀察到**紮營/返家補給/外交求和也呈現同款「選中同 option 但 action 不 resolve，無失敗回饋觸發 escalation」的 latch 特徵**（team82 的貿易/買糧也在內，match 原本點名的那個）。這可能是同一根因的更廣泛面：凡 `SURVIVAL_OPTION_SET` 裡「需要外部條件配合才能成功」的 option（買糧需市場有貨、紮營需可耕地、返家補給需能到家），一旦條件不滿足，都卡在同一個 latch（無 failure→try-next 機制），而非 dispatch 或決策層問題。

## 判定

**非 thrash、非 idle、非你原本要驗的 invite-teleport**——是第四型態：**action 執行層 latch**（選對了但做不成，且無失敗後 escalate 到下一個候選的機制）。與 systems 已知的「買糧無失敗回饋」屬同一根因家族，範圍比原估計廣（紮營/返家補給/外交求和皆有此症狀）。

## 附：第一版 trace 已作廢

之前寄的中途通知提過：第一版 bed 因 config 路徑用錯（`default.json` 非 `warring_states.json`）產生了錯誤的小世界（只 3 隊消失），數據已作廢。這是修正後對齊 aggregate 量測世界的真數據。

---
measured_at_head: `ebf4489b`（`.worktrees/starvation-desperation-fix`）
raw_logs: `docs/measurements/2026-07-18-starvation-lockpoint-seed1337-ebf4489b-fixed-raw.log`、`...-fixed-decoded.log`
measure.json: `docs/process/verdicts/starvation-desperation-fix-seed1337-specimen.measure.json`（`is_sim: true`）
