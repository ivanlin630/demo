---
from: systems
to: reviewer
status: consumed
topic: "[R² 審設計:recovery-path Slice R3 遷村令(復甦 arc 收官 slice、spec §2C+§3)·blueprint R3 GO(用戶定兩層對抗)·R3=領主遷村令(P4 letter)+村從抗人格秤+村自願遷·★R² 重點審:①★村遷村執行端(驗執行端命門、無既有整村 relocate 機制、同 R1 arrived/R2 build 血證家族):整村 relocate=接既有件 compound(generalize _action_abandon_outpost player_command:525→AI 棄據點→村轉 mobile population 隨隊→TASK_SETTLE target→_convert_to_resident faction_ai:2142 落腳)——此 compound reuse 正確否?驗執行端硬標:測試跑真全 advance_tick pipeline 驗村真完成遷(棄據點→抵 target→settle→resident 於新 tile)非只決策 fire②★relocate 目標選擇 god-view gate(無 explored-tiles terrain belief store):領主令 target=領主已知領土(own-faction 行政知、同 §1.0 VillageEstimate 結構欄來源)、村自願遷 target 限 vision-explored/reachable(鏡射遷移找糧 options.gd:288)、禁 god-view 全地掃最佳 tile——防線齊否?③relocate_value=MarginalEconomy 第3 marginal(_inflow_est(target)前景−_inflow_est(current)−sunk_penalty persist)、全 belief VillageEstimate(同 R1/R2 結構防線)④從抗人格秤 genuine(忠懼→從帶怨 unrest 累積/傲戀土→抗命=人格秤非死常數門檻)+unrest reuse cohesion⑤令=reuse in_transit_letters kind=relocate 真送達非瞬間(感知鐵律跨距)⑥抗命後果=領主人格(算了/斷賑濟/武力押遷=軍事 arc 只留鉤 P5 起義出口承接暴君逼反)·序:CLEAN→systems dispatch implementer build(feat/recovery-r3)→量(令送達+從抗分化+怨→叛/起義劇情鏈)→QA→merge=復甦 arc 收官→轉框架收尾·地基 KEEP"
---

# R² 審設計：recovery-path Slice R3 遷村令（復甦 arc 收官 slice）

spec §2C+§3。blueprint R3 GO（用戶定兩層對抗）。R3 = 領主遷村令（P4 letter）+ 村從抗人格秤 + 村自願遷。

## ★R² 審查重點
1. ★**村遷村執行端**（驗執行端命門、**無既有整村 relocate 機制**、同 R1 arrived/R2 build 血證家族）：整村 relocate = **接既有件 compound**（generalize `_action_abandon_outpost` player_command:525→AI 棄據點 → 村轉 mobile population 隨隊 → `TASK_SETTLE` target → `_convert_to_resident` faction_ai:2142 落腳）——**此 compound reuse 正確否**？驗執行端硬標：測試跑**真全 advance_tick pipeline** 驗村真完成遷（棄據點→抵 target→settle→resident 於新 tile）非只決策 fire。
2. ★**relocate 目標選擇 god-view gate**（無 explored-tiles terrain belief store）：領主令 target=**領主已知領土**（own-faction 行政知、同 §1.0 VillageEstimate 結構欄來源）；村自願遷 target 限 **vision-explored/reachable**（鏡射遷移找糧 options.gd:288）；**禁 god-view 全地掃最佳 tile**——防線齊否？
3. **relocate_value** = MarginalEconomy 第 3 marginal（`_inflow_est(target)` 前景 − `_inflow_est(current)` − `sunk_penalty` persist）、全 belief VillageEstimate（同 R1/R2 結構防線）。
4. **從抗人格秤** genuine（忠懼→從帶怨 unrest 累積 / 傲戀土→抗命 = 人格秤非死常數門檻）+ unrest reuse cohesion。
5. **令** = reuse `in_transit_letters` kind=`relocate` 真送達非瞬間（感知鐵律跨距）。
6. **抗命後果** = 領主人格（算了/斷賑濟/武力押遷=軍事 arc 只留鉤、P5 起義出口承接暴君逼反）。

## 序
CLEAN → systems dispatch implementer build（`feat/recovery-r3`）→ 量（令送達 + 從抗分化 + 怨→叛/起義劇情鏈）→ QA → merge = **復甦 arc 收官 → 轉框架收尾**。若需異質框外審請 flag。地基 KEEP。
