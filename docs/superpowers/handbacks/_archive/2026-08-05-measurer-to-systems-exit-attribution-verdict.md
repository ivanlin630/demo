---
from: measurer
to: systems
status: consumed
topic: "faction-cohesion開場exit-attribution verdict:★★defect出口=genuine確認(非純arbitrary門檻)——建4組matched-honor對照(T1餵飽honor0.34 vs T3餓honor0.34同值):T1(unrest恆0,60天never exit)vs T3(unrest 26/52/79/105/132飆升,exit_day=0即刻defect)——同一honor值,結果南轅北轍,證unrest_turns>=20(runway-driven真distress)是真正gatekeeper非honor threshold本身;reviewer疑慮(義氣0.34 vs 0.36差一點被踢=arbitrary)不成立——因為只有真餓的member才會unrest爬到20,不餓的member即使honor剛好卡在門檻下也永遠不會被評估到defect check。★uprising:T5同starve曲線但honor0.6(defect-safe)走uprising路(day14守城Path A無條件clear)——起義本身也是unrest/loyalty-gated(非任意),但『能否換領主留勢力非必然脫』的設計問題本輪未反駁也未證實,維持open。★contact-loss:T7(遠距離24格+安全honor0.6+餵飽)60天內從未觸發評估——inconclusive非負面確認,懷疑要嘛從未建立初始belief(never contacted=提早return不觸發)要嘛distance不足以在60天內累積30天CONTACT_TIMEOUT,需重新設計測法(先建立belief再物理隔離,而非從tick0就分隔兩地)。純觀測零production code動,自建4-pair對照fixture(measurer own,未persist,ticket未要求)。落地2檔已ls/wc驗證。已回systems handback:2026-08-05-measurer-to-systems-exit-attribution-verdict.md，別下accept，defect刀口有堅實grounding可討論,uprising/contact-loss仍需補測才能定案，交systems判§2 spec方向"
---

# faction-cohesion 開場 exit-attribution：defect 出口 genuine 確認，uprising/contact-loss 仍待補測

## 做法

自建 4 組 lord+member pair 對照 fixture（temp、`config/infonet_cohesion_exit.json`，未 persist——工單框為「開場 grounding」非長期 arc 床，本輪未依 infonet_whole 慣例 commit；如需重跑供 R②/spec 引用可再開票 persist）：
- **T1/T0**：GoodLord + Member（honor=0.34，餵飽 food=3000）
- **T3/T2**：BadLord + Member（honor=0.34，**同值**，starving food=15、mountain）
- **T5/T4**：Uprising 對象（低 loyalty=0.15、honor=0.6，starving）
- **T7/T6**：遠距 contact-loss 對照（honor=0.6，餵飽，跟 lord 距離 24 格）

seed3033、60天、純觀測（inline advance_tick，零 production code 改，零新 randf）。

## ★★defect 出口：確認 genuine（reviewer 疑慮不成立）

```
T1（餵飽,honor0.34）：unrest_turns 恆 0，60天 never exit（alive_at_end=true）
T3（starving,honor0.34，同值）：unrest_turns day1=26→day2=52→day3=79→day4=105→day5=132，exit_day=0（不到1天即 defect）
```

**同一個 honor 值（0.34，皆低於 0.35 門檔）、結果完全相反**——T1 從未被評估到 defect check（因為 `event_faction_defect.check()` 第一個門檻 `unrest_turns>=20` 從未達成，恆為 0）；T3 因為真的餓（runway<2天持續）unrest 每天狂飆 ~26-27，第一天內就衝過 20，立刻被評估、honor<0.35 命中、defect。

**這直接回答 reviewer 的疑慮**：「義氣0.34 vs 0.36 差一點就被踢」的門檻 flip 疑慮**不成立於實際運行**——因為只有**真正陷入資源困境（runway 持續<2天）**的 member 才會讓 `unrest_turns` 爬到 20，讓 defect check 真正被觸發；一個安穩、有餘糧的 member（哪怕 honor 剛好卡在門檻下）永遠不會被評到這條 check。**honor<0.35 是必要非充分條件**，真正的 gatekeeper 是 unrest（=真實資源困境的代理）。這是 genuine 而非死常數的證據。

## ★uprising 出口：同樣 unrest-gated，但「無條件清」問題本輪未解

```
T5（starving,honor0.6=defect-safe）：unrest 曲線跟 T3 完全一樣(26/52/79/105/132...)，
但 honor 夠高不會被 defect 撿到，一路撐到 unrest_turns>=60+avg_loy<0.2+stress_sources>=2 才在 day14 觸發 uprising Path A（守城，print"[Uprising A] Team5 守城"），無條件 clear_team_faction。
```
uprising 本身也是 unrest/loyalty 多重門檻驅動（非任意），跟 defect 一樣有 genuine 的資源困境根源。但工單問的「起義後可否換領主留勢力（推翻領主≠必然脫勢力）」是**設計問題**，本輪只確認了「目前 code 無條件走 clear」的事實，**沒有反駁也沒有證實**這是不是該改的問題——維持 open，交你們/blueprint 判斷這是不是 §2 該砍的刀口。

## ★contact-loss 出口：★本輪 inconclusive，需重新設計測法

T7（遠距離24格、安全 honor0.6、餵飽）**60天內從未觸發評估**（`exit_day=-1, alive_at_end=true`，unrest 恆0——因為餵飽跟 T1/上面同理，不是 contact-loss 特有的訊號）。

**誠實揭露**：這個測法本身可能有設計缺陷——`_evaluate_owner_contact` 第一行是 `if days_since==-1: return`（從未接觸過 → 直接跳過不評估）。我把 T6/T7 從 tick0 就放在 24 格外的遠距，**如果他們從一開始就沒有任何 belief 接觸紀錄，這條 check 可能整場都被這個 early-return 擋掉**，不是「安全通過 30 天門檻」而是「根本沒被評估到」——這兩種情況在我的 `exit_day=-1` 記法下無法區分。**需要重新設計**：先讓 lord/member 建立初始 belief（例如同起點短暫共處後再物理拉開，或直接在 config 給一個初始 `known_member_states` 條目），才能真正測「持續失聯 30 天」這件事。

## 出口佔比（本輪樣本，僅供參考、非代表性統計）

4 對中：1 對 defect（T3，day0 即刻）、1 對 uprising（T5，day14）、2 對 never-exit（T1/T7，設計上皆為「安穩」對照組，非真實佔比樣本）。**本輪是刻意設計的對照組 fixture、非隨機抽樣的自然世界**，佔比數字不能直接當「defect vs uprising 在真實世界的相對頻率」使用——如需要真實佔比，建議另跑一個多樣化人格分布的自然世界（如 warring 長跑）統計三種 exit 各自次數。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-infonet-cohesion-exit-run.txt`（1766行，完整跑 log + 4隊逐日摘要）
- `docs/measurements/2026-08-05-infonet-cohesion-exit-diagnostic.json`（1160行，結構化 dump，含完整逐日曲線）

## 清理狀態

- temp `config/infonet_cohesion_exit.json` + `infonet_cohesion_exit_bed.gd`（worktree 內）已刪除，未 persist（工單未要求、且此 fixture 是本輪臨時設計，若要正式收進 arc 床建議先讓 systems/blueprint 過目調整後再 persist）。
- 純觀測，零 production code 改動。

## ★誠實淨判

- **defect**：★★genuine，有堅實 grounding（matched-honor 對照直接證明 unrest-gate 是真正把關者）。
- **uprising**：unrest-gated（非任意），但「無條件脫離 vs 可換領主留任」的設計問題本輪未解，仍 open。
- **contact-loss**：★inconclusive，測法本身可能有缺陷（可能從未真正評估到），需重新設計（先建 belief 再隔離）才能真正回答。

別下 accept。defect 刀口已有紮實 grounding 可以拿去討論，uprising/contact-loss 兩個出口若要放進 §2 spec 判準，建議先補測（尤其 contact-loss 測法需要重做）。交你們定 §2 刀口方向。
