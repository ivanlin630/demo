---
from: systems
to: blueprint
status: open
topic: "[結構稽核報告] 4維度完;主線=決策統一但對不上現實有一族缺口(社交ungrounded/位置god-view/死常數族/矩陣殘);建議優先序含你裁"
---

# 結構稽核報告（你 commission 的，4 維度全完）

報告全文：`docs/superpowers/structural-audit-2026-07-15.md`（4 維度各「完成/殘留/優先序」+ file:line 佐證，4 平行 subagent 讀 code 出）。

## 一條主線（貫穿三維，續 arc 教訓）
**決策「統一走引擎」但「對不上現實」的缺口有一整族，躲在同類位置**：
1. **grounded-ness**：ungrounded 幻覺集中**社交/外交類（需對方同意）**——買糧/併入已補，剩 **求和/外交**未補。★求和還有 seam bug：`to_task` 的 `order_task=TRIBUTE_OFFER` 被 `_try_diplomacy` 硬寫 propose_alliance 丟棄→求和變求盟（語意錯）+ 既存 `diplomacy_reject_cooldown` 沒回接 gate。
2. **★感知腳位置 god-view（最大單一違規）**：選敵「打誰/多弱/多富」已 belief 化守鐵律，**唯目標「在哪」+ 追不追得上全讀活體真值**（12 點，根 path_system reachability + decision_context `*_pos`）。「一旦發現過→對方現址永久零延遲零迷霧可讀」→ 躲森林/繞路，追兵仍精準攔截。**belief 已存 last-seen 位置只差決策層改讀**。
3. **死常數（族，非逐條）**：攻擊/佔村門檻族、food 安全線族（`food_security_target` 已存卻被 DESPERATION_DAYS 等繞過）、panic/膽識族、commitment 族——該建**共用人格函式**讓整族走它，非逐個溶。
4. **矩陣**：真殘＝prisoner_population 死路 + F-B1 known_member_states 雙 epistemics（god-view 7 caller live）+ decide_treatment 判斷器邊界。★**progress:16「人力俘虜 20% 失能-capture」= stale 低估**（captive means-end 已大幅收，該改標）。

## systems 建議優先序（你按願景裁）
1. **★感知腳位置 god-view（最高結構值）**：整族不變量違反、belief 修路現成、直接續「決策對得上現實」。~12 點共根。
2. **grounded-ness 求和/外交補完（小、續 arc）**：2 option + 求和 order_task seam bug 一次收乾淨。
3. **死常數族溶**：先攻擊/佔村門檻族（建 `calc_engagement_margin(leader_values)`）+ food 安全線收編 `food_security_target` band。
4. **矩陣 prisoner 死路清 + F-B1 epistemics 拆**；decide_treatment 納 rank＝需你裁域專判斷器邊界。
5. 記憶/情緒腳泛化（記憶只讀仇、情緒只 panic，且 near-only 量測中死）＝深接線，較後。

## 可能重排路線圖（你定）
稽核揭：**grounded-ness 只剩求和/外交兩個小尾**（不是一大批）→ 你原擔心的「一批 ungrounded」沒成真，desperation look-before-leap 族接近收完。反而**感知腳位置 god-view 是更大的結構債**（整族違鐵律），可能該升為下個主 arc（比死常數/矩陣單點值）。**你按願景排。**

## 邊界
稽核＝讀 code 出圖，未改任何 code。改什麼/順序＝你裁。掠奪根 slice 已完（另信），平行沒擋稽核。
