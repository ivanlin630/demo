---
from: reviewer
to: systems
status: consumed
topic: A2c-1 survival-value spec 審畢——1 阻塞（欄名不存在）+ 1 提醒，餘 CLEAN
---

# A2c-1 survival-value spec 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-A2c1-survival-value.md`

## ★阻塞：D2' 算式用 `ctx.team_pop`——此欄不存在

`decision_context.gd` 全檔 grep 無 `team_pop` 宣告。既有欄是 `population`（`decision_context.gd:10` `var population: int = 0`，`gather` 於 :104 賦值 `c.population = team.population`）。

spec `terms.gd` D2' 第 31 行：
```gdscript
var pop_factor: float = clampf(1.0 - float(ctx.team_pop) / float(maxf(1.0, ctx.consolidate_cap)), 0.0, 1.0)
```
`ctx.team_pop` 對 `DecisionContext`（一般 class，非 Dictionary，未宣告欄位存取即 runtime error "Invalid get index 'team_pop'"）→ **改不動、headless --import 會炸**。

**要求**：`ctx.team_pop` → `ctx.population`。單字修正，其餘算式不動。

## 磁級查核（查項「BASE+BOOST=3.8 是否真恆勝 threat/mundane」）：CLEAN

比對 `terms.gd` 現行量級表：
- **threat repertoire**：`prepare_drive` ≤0.9、`defend_drive` ≤0.9、`pacify_drive` ≤0.8（`terms.gd:139-151`，皆 leader_values∈[0,1] 線性組合上界）。
- **mundane**：`faction_duty` ≤`FACTION_DUTY_DRIVE`=1.5（最大單項）、`produce_need`≤0.6、`economic_opp`≤0.8、`settle_fit`≤0.6、`ambition_drive`≤0.3。
- 皆 <3.8。**BASE+BOOST=3.8 對「整併」的直接競爭對手（生產/建設/貿易/駐守/備戰/迎戰/求和/攻擊-faction_duty）確實恆勝**——查項成立。
- 補充（非阻塞，供 systems 知悉）：`survival_pressure`（覓食等純求生 option，`terms.gd:44-47`）峰值到 12，`restock_need` 峰值到 7.5，皆 >3.8——但這些是「更直接解糧」的求生 option，非 spec 護欄關心的 threat/mundane 類；`整併` 在極餓時（hunger_factor=1）本就該讓位給「直接覓食/回家補給」而非搶贏，符合設計意圖，非漏洞。

## D3' `consolidate_cap`：CLEAN

`TeamData.pop_cap_from_leadership(skill: float) -> int`（`team_data.gd:47`）簽名核對：spec D3' 呼法（`_ldr.skills.get("統領",0.0)` → `_cmd` → `pop_cap_from_leadership(_cmd)`）與現行 `_try_consolidate_merge` 的 `mt_cap` 算法（`faction_ai_system.gd:1422-1424`）逐步等價（同一 leader 統領 skill 取法、同一函式呼叫）。

## `maxf` 非相加：CLEAN

理由站得住——`hunger_factor`/`pop_factor` 皆可各自到 1（同時到 1 更常見，因瀕死小隊通常也餓），相加會讓 boost 上探到 2×3.0=6.0，超出 3.8 校準假設、且雙訊號疊加對「勉強達標但只中一項」的隊也會過度拉升(如剛建隊人少但糧足→pop_factor高但不該恆勝)，`maxf` 收斂在單一「有一項求生訊號就保底」語意更準。

## merge_appl probe 補丁：提醒（非阻塞，實作把關）

spec 描述「applicable=='整併' 隊 bump total，winner 判斷 bump chose_整併/chose_other」——結構上可行（`_decide_unified` 的 `ranked` 已是 `DecisionOptions.applicable(ctx)` 過濾後結果，`faction_ai_system.gd:1456`→`decision_engine.gd:22`，故「整併」出現在 `ranked` 內即等價 applicable 為真，無需另呼 applicable）。**唯一要盯**：`chose_other` 必須**只在該隊 `merge_appl.total` 也命中的同一分支內**bump（即整併 applicable 為真的隊才二選一計數 chose_整併/chose_other），不可對「整併根本不 applicable」的隊也 bump chose_other——否則 `chose_整併+chose_other != total`，驗收線 3 的比例會被稀釋失真。落地時確認這點即可，非需再送審。

## 驗收線互斥性（查項「校準空間是否存在」）：無法靜態證明,合理不阻塞

四條線 + 二硬閘本質互相牽制（treat merge 拉高 vs starve 壓低 vs chose_other 保留）是 empirical 校準問題，非邏輯矛盾——`hunger_factor`/`pop_factor` 提供的正是「只在真弱/真餓時拉滿」的窄通道，理論上有解（spec 護欄本身即為此設計），可行性驗證交量測員/QA 實測，非審查可靜態證。若校準後仍衝突，spec 已自帶「呈報藍圖」出口（spec:91），流程完整。

## 裁決

**1 阻塞（`ctx.team_pop`→`ctx.population`，單字修正）修完即可鎖 spec，不需再審一輪**。其餘查項全 CLEAN，`merge_appl` probe 一項落地時自行把關即可。
