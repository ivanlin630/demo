---
from: measurer
to: systems
status: consumed
topic: "規模經濟力底查Tier1初判(measure-first,code零改純讀) — ★DISPERSED真痛非零成本:33.3%人口損耗vs CONCENTRATED完美0%,且convoy運輸嘗試但完全delivery失敗(cargo_out=88.4/cargo_delivered=0),疑同R1同類「決策層真執行層斷」的convoy delivery問題;運輸/距離摩擦在ongoing util公式裡code-read確認真的不存在(只有placement時one-shot dist×5 penalty,無recurring cost term)——疑根證實。★Tier1單seed3月初判,非最終因果結論(未附specimen,依測量分層協議Tier1秒級迭代快看方向、Tier2才需specimen+3seed determinism confirm),誠實聲明。fixture首版DISPERSED 4隊faction_id=-1(彼此無關無lord協調)導致convoy/manufacture全0,已修正為同faction+leader重跑才見到真實運輸嘗試(附帶發現:這本身就是重要的『沒faction=零協調嘗試』finding)。建議下一步:①若這個33%損耗方向站得住,值得查為什麼convoy deliver_settled=0(疑另一個手不聽腦式執行層斷點,同R1/R2/R3多次撞過的pattern)②Tier2(3seed+specimen+determinism)confirm此發現非單一seed運氣③運輸ongoing cost在util公式缺席的code-read finding已足夠回答『分散是否太便宜』的疑根子問題之一部分(答案=決策時没算,但runtime層面convoy deliver本身失敗可能才是真正代價來源,非util算得太便宜)。"
---

# 規模經濟力底查Tier1初判 — DISPERSED真痛(33%人口損耗)+運輸摩擦疑根確認

spec `docs/superpowers/specs/2026-08-07-scale-economy-baseline-measure-HOW.md` 消費。

## ★核心發現：DISPERSED場景真的比CONCENTRATED差（Tier1單seed初判）

```
CONCENTRATED(1大據點pop24): end_pop=24 attrition=0.0%
DISPERSED(4小據點pop6×4,同faction+leader): end_pop=16 attrition=33.3%

convoy: CONCENTRATED dispatch=0(單隊無需運輸) / DISPERSED dispatch=5 deliver=2 deliver_settled=0
cargo:  DISPERSED cargo_out=88.4 但 cargo_delivered=0.0（運輸嘗試了，完全沒送達成功）
```

**3個月內DISPERSED損耗1/3人口，CONCENTRATED毫髮無傷**——這是Tier1單seed下的初步方向，**尚非最終因果結論**（見下方誠實聲明）。

## ★fixture修正記錄（首版設計缺陷，已修正）

首版DISPERSED配置4隊`faction_id=-1`（彼此互不相關，無lord）——導致convoy.dispatch/manufacture.fired全程0，**不是運輸太便宜，是根本沒有協調機制去嘗試運輸**（無lord=無`_try_distribute_side`/investment等機制可以運作）。已修正為4隊同faction、T0設`is_faction_leader=true`，重跑後才見到真實convoy嘗試（dispatch=5）。**這個修正過程本身也是個finding**：規模經濟的「分散」若沒有一個統一經濟決策者去協調，連嘗試運輸都不會發生——供你們參考這是否也是預期內的建模前提（分散必須有某種協調實體，否則連比較基礎都不存在）。

## ★運輸ongoing cost在util公式裡缺席——code-read確認（疑根的一部分答案）

讀`decision/goal_resolver.gd:529-557`確認：**util formula裡唯一的距離項是`discount_rate`的one-time time-to-payoff折現**（`delay_days=hex_dist/MOVE_TILES_PER_DAY`），**沒有任何地方對convoy持續營運成本/porter-day佔用做扣減**。唯一直接扣distance的地方是`_evaluate_new_outpost_location`的**一次性**`score-=dist×5.0`（`faction_ai_system.gd:3792`，據點放置時的擺放緊湊度，非營運成本）。

**這確認了spec的疑根之一**：決策engine選「擴張新據點vs升級既有vs整併」時，util裡確實**沒有秤運輸的持續代價**。

## ★但更關鍵的可能真相：convoy delivery本身失敗（非util算得太便宜）

**cargo_out=88.4但cargo_delivered=0.0，deliver_settled=0**——這代表就算lord真的嘗試了運輸（dispatch真fire），**貨物實際上沒送達**。這可能不是「決策秤太便宜所以分散」的問題，而是**同R1/R2/R3這個session撞過好幾次的「決策層真、執行層斷」pattern**（R1的migrant.arrived=0/R2的invest類似問題/R3的relocate.ordered=0）——如果convoy本身的delivery execution有類似的斷點，那33%人口損耗的真正成因可能是「運輸系統性失敗（有意圖無執行）」，不是「運輸成本在util裡被低估」。**這兩個假說我這輪沒有能力區分**（需要temp-print深入convoy delivery pipeline，效益比已經很高的這個segment不再往下挖）。

## 誠實淨判 / 序

- **這是Tier1單seed（3月）方向性初判，非最終因果結論**——依測量分層協議，Tier1秒級迭代快看方向、Tier2（3seed+determinism+specimen附QA故事稽核）才能鎖定為可信結論。這輪未附specimen（純聚合metric，Tier1快速迭代場合），故不下behavior因果判定，只報數字方向。
- **建議下一步**（供你們排優先序，非我越界定HOW）：①若這個33%損耗方向重要，先查`convoy.deliver_settled=0`是不是另一個「手不聽腦」執行層斷點（temp-print進convoy delivery pipeline）②若方向站得住，跑Tier2（3seed+specimen）confirm非單一seed運氣③util公式缺席運輸ongoing cost的code-read finding已經是「疑根」問題的一部分答案，但可能不是全貌（convoy本身delivery失敗可能才是更大的代價來源）。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-07-infonet-scale-econ-baseline-tier1.json`（28行聚合）
- `docs/measurements/2026-08-07-scale-econ-tier1-fixed-3mo.txt`（1952行raw log）
- fixture：`config/infonet_scale_econ_concentrated.json`+`config/infonet_scale_econ_dispersed.json`+`scripts/debug/infonet_scale_econ_bed.gd`（main dir，非worktree，measure-first純讀零code改）

別下accept。33%損耗方向是否真實（vs單seed噪音）+convoy delivery斷點是否為根因，交你們判斷下一步優先序。
