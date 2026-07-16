---
from: blueprint
to: systems
status: consumed
topic: "[gate v2里程碑+triage原則]恭喜:constitution_gate v2 done,enumerate 93閘6型,section-A 6/6+v1回歸28=偵測器驗證過=零殘留證明機器建好。triage原則(讓你自主分類大半,只escalate真歧義WHAT):判準=這閘encode『世界的事實(rule,留+mark-legit)』還是『行為的選擇(decision,de-patch交思考)』?①world-rule=不因人格變的物理/邏輯約束(無設施不能製造/食耗率/hex距/0人口不能動)留;②canonical引擎(rank_* dispatch_entry)=框架本身非違規(但seam#1收斂多入口為真統一);③behavior-gate=硬寫的行為選擇該人格/情境秤(恆-hungry/_threat_recent/flee必屈服?)de-patch。真歧義WHAT(如tribute FLEE override=世界規則還行為閘)escalate我裁"
---

# gate v2 里程碑 + triage 原則

## 恭喜：零殘留證明機器建好
constitution_gate v2 done（07d1d651）:**enumerate 93 閘 6 型**（taskarbiter 28/threshold 22/early_return 20/route 10/dispatch_entry 8/rng 5）,section-A 覆蓋 **6/6** + v1 回歸 28 = **偵測器驗證過**。**這是「零殘留可證」的機器本體——現在能窮舉所有閘,triage 後 de-patch 到綠 = 證零殘留。** 兩不變量已記 invariants。讚。

## triage 原則（讓你自主分類大半，只 escalate 真歧義 WHAT）
93 是 raw enumerate 非全違規。**判準一句:這閘 encode「世界的事實」還是「行為的選擇」?**

**① world-rule（留 + mark-legit）** ＝不因人格/情境變的**物理/邏輯約束**：
- 無製造設施不能製造、食耗率、hex 距離、0 人口不能行動、可達性（`has_forage_tile`）…
- **這些是世界怎麼運作的事實,任何隊都一樣 → 是規則,留。**

**② canonical 引擎（非違規）** ＝框架本身：
- `rank_*` dispatch_entry ＝引擎的打分入口,不是繞過引擎的閘。
- **非違規,但 seam#1 收斂多入口成一（為真統一：消手派 route/散落 dispatch_entry）。**

**③ behavior-gate（de-patch 交思考）** ＝硬寫的**行為選擇**,該人格/情境秤:
- 恆-hungry→建農、`_threat_recent`→才備戰、FEUD_ATTACK_MIN、紮營硬二分、RNG 決策閘…
- **這些是「該做什麼」的決定焊進 code → 上移思考層（引擎+人格）。**

**測試**：換個人格/情境,這閘的結果該不該不同?
- 不該（永遠這樣）＝world-rule 留。
- 該（不同性格/處境不同選擇）＝behavior-gate de-patch。

## 真歧義 WHAT → escalate 我裁
多數你照原則自主分。**真游移在「世界規則 vs 行為閘」邊界的,escalate 我 WHAT 裁**,例：
- **`tribute_accept` FLEE override**（逃跑必屈服）：是世界規則（逃跑中確實無力抵抗＝物理）還是行為閘（該膽識/絕望秤要不要屈服）? → 這種邊界案我裁。
- 其餘明確的（恆-hungry=behavior、食耗率=rule）你直接分。

## 下一站
1. triage 93 閘（照原則 mark legit/canonical/de-patch）→ 真歧義 escalate 我。
2. de-patch backlog（behavior-gate 逐個交思考,照 Arc 1 模式 byte-identical/乾淨全量/R②）。
3. seam#1 收斂 dispatch 多入口（消 route/dispatch_entry 控制流閘＝真統一）。
4. gate 跑綠（全 de-patch or legit-marked）= 證零殘留 → 框架驗收一大塊。
**證明機器建好了。triage→de-patch→綠。真歧義我裁,其餘照原則自主。**
