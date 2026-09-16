---
from: reviewer
to: systems
status: consumed
slice: 尾部人格在常態會搶
topic: ★①②③三問都判過,無阻擋；★★★但查§2 retaliation_risk時撞到一件事：「目標belief戰力/我方戰力」**已經是一支既有函式**（`ThreatAssessment._power_ratio(state,team,other)`——泛型,吃任意TeamData,就是上一張票defer的那個「對target另算一次」要的東西），建議直接呼叫它,別另起一份新公式(否則會重演它自己文檔裡記過的skill不對稱舊bug)；★★另查§4的「同軸」前提**不成立**——`person`(`terms.gd:272`)實際是`maxf(好戰,貪婪)`不是`max(好戰,殘忍)`,「兇性容忍與person同軸」這句站不住,不影響設計本身但理由要換
---

# §0 現況 file:line：核過一致

`terms.gd:266-272` 現行 `_odds`/`_person` 讀過，跟你 §0 引的形狀一致
（`util=(W_loot×take+W_need×need)×odds×person`，目前確實沒有成本項）。
實測基準數字（0.0669 vs 0.1984）讀 code 驗不了，當既有測量接受。

# ①「§2 新增成本項」——不是繞路加成

`subjective_cost` 是**乘數壓低**（`×(1-subjective_cost)`），且 `retaliation_risk` 的來源
（見下方 ★★★ 那段）是真世界量非手填——跟 §1 `w_wealth` 同一種「人格 MODULATE 真值」
形狀，不是先造一個假成本再用人格去圓它。結構上我判：**不是 crank，不擋**。

# ②「w_wealth 讓 <0.5 貪婪的人 util 變低」——判：預期，正確

對稱調製（0.5→×1.0 中性，>0.5 放大，<0.5 縮小）是這個磚（`flow_weight`）原本就有的形狀，
不是這張票發明的新行為，之前 coin 的討論裡也核過這個磚的合法性。**預期行為，不擋**。

# ★★★③query 之外，查 retaliation_risk 時撞到一個更值得處理的東西

你寫「`retaliation_risk`＝目標的 belief 戰力／我方戰力」——這句話描述的東西
**已經有一支現成、獨立、已經修過至少一次 bug 的函式**：

```gdscript
# threat_assessment.gd:84
static func _power_ratio(state: WorldState, self_team: TeamData, other: TeamData) -> float
```

讀了它的內部（:84-107）——泛型（`other` 是任意 `TeamData`，不綁定「威脅來源」這個語意，
跟上一張票我們發現 `perceived_power_ratio` **綁死**在威脅來源不同）、belief-based
（`BeliefSystem.best_estimate` + population_est self-fallback）、★★而且它的註解
（:95-106）記著一個**已經修過的真 bug**：舊版技能維讀「自己真實技能 vs 對方手填 0.3」，
兩邊不同尺 ⇒ 全世界平均算出 ratio≈3（систем's own 2026-09-02 R②抓的）；修法是技能維
**一律用自身當先驗**（跟 population 維同一招）。

⇒ **這正是上一張票 defer 的 `odds-must-read-the-target` 要的那個「對 attack/raid 目標
另算一次 `_power_ratio`」**——現在你在這張票裡又需要同一個量，只是換個名字
（`retaliation_risk`≈`1/_power_ratio` 或某個單調變換）跟目的（成本而非贏率）。

⇒ **建議**：`retaliation_risk` 直接呼叫 `ThreatAssessment._power_ratio(state, team, prey_team)`
取倒數/單調變換，**別另起一份「belief 戰力比」新公式**——理由：
①省工，這支函式已經存在且已驗證；②更重要：**避免重蹈它自己文檔裡記過的技能不對稱 bug**
（若新公式自己土法煉鋼算「belief戰力」，很可能重新掉進「自己真技能 vs 對方手填/粗估」
這個已知坑，因為那個坑不是明顯的，是量出來才發現的）。

★這也連帶回答你上一張票沒問的一件事：`odds-must-read-the-target` 那張 defer 票
跟這張的 `retaliation_risk`，**最後可能是同一次呼叫、餵兩個不同的下游用法**
（一個算 odds、一個算 cost）——如果兩邊各自獨立實作，會產生你今天已經抓過三次的
「同一件事兩個名字」病的第四個實例。建議兩張票在 implementer 排的時候互相看一眼，
不必合併成一張，但呼叫點最好共用。

# 另查：§4「兇性容忍與 person 同軸」——這句前提不成立

去讀了 `person` 的真正組成（`terms.gd:266-272`）：

```gdscript
var _mart: float = float(ctx.leader_values.get("好戰", 0.5))
var _greed2: float = float(ctx.leader_values.get("貪婪", 0.5))
var _person: float = clampf(0.5 + (maxf(_mart, _greed2) - 0.5) - ..., 0.0, 1.5)
```

`person` 用的是 `maxf(好戰,貪婪)`——**不是**你 §4 寫的 `max(好戰,殘忍)`。
兩者只有「好戰」共用，第二軸不同（`person` 是貪婪，你 §2 提的兇性容忍是殘忍）。

⇒ 這代表 §2「兇性容忍 與 person 同軸（見§4待判）」這句話**事實上不成立**——
它們是兩個不同的軸組合，不是同一形狀的兩個實例。這不代表用 `max(好戰,殘忍)`
本身是錯的（殘忍/好戰放大「不在意反咬」的直覺我認為合理，可以在自己的道理上站得住），
只是**不能拿「跟 person 同軸」當理由**，因為那個理由查出來是假的。

⇒ 建議把 §4 那句改成：`兇性容忍` 的軸選擇是**獨立的設計判斷**（好戰/殘忍都合理地
降低對報復的顧慮），不是沿用 `person` 的既有形狀——這樣即使 §4 那個「`person` 裡
較小那軸會不會被完全蓋掉」的待判日後有結論，也不會反過來波及這裡（因為這裡本來
就不是同一組軸，不會被那個結論牽動）。

# 小結

| 項 | 判 |
|---|---|
| §0 現況 | ✅ file:line 核過一致，實測數字讀 code 驗不了 |
| ① 新增成本項是否繞路加成 | ✅ 不是，乘數壓低+真世界量，同「人格調製真值」既有形狀 |
| ② w_wealth 讓低貪婪變低 | ✅ 預期，對稱調製本來就會這樣 |
| ③ `retaliation_risk` 來源 | ⛔ 建議直接呼叫既有 `ThreatAssessment._power_ratio`，別另造公式，跟 defer 票 `odds-must-read-the-target` 共用呼叫點，防第四個「同事兩名」 |
| §4「同軸」前提 | ⛔ 不成立：`person`=好戰+貪婪，`兇性容忍`提案=好戰+殘忍，第二軸不同；建議改成獨立設計判斷的措辭 |
