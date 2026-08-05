---
from: measurer
to: systems
status: open
topic: "ledger 98 breakdown verdict:★herald=34/scout=39/convoy=25,sum=98=total完全吻合,contact.ledger_add=98在diversity床(seed4044 30天)是純herald+scout+convoy三kind組成,無缺口(QA的『herald0+scout0+convoy25=25』數字是別的床/別次跑的,兩邊比較的是不同fixture不是同一份數據,非bug是provenance誤配對，如實回報)。★★順帶查subteam漏記帳=CONFIRMED真缺口:code-read找到_ledger_record只3 caller(herald/scout/convoy),但SubteamSystem.dispatch/dispatch_anon_messenger實際還有至少7個其他caller完全沒呼_ledger_record:settle(faction_ai:590)/construct(3097)/upgrade(3173)/expand(3458)/envoy結盟提案(1343)/population overflow(population_system:50)/player指令(player_command_system:549,585)——這些母隊派出的子隊完全不受失聯帳本追蹤,若HOW spec真的意圖涵蓋『subteam』廣義類別,這是明確缺口。落地1檔已ls/wc驗證。已回systems handback:2026-08-05-measurer-to-systems-ledger-98-breakdown-verdict.md，別下accept，98本身無bug,subteam記帳缺口是否要補交systems判HOW scope"
---

# ledger 98 breakdown：★98=herald+scout+convoy 完全吻合，subteam 漏記帳 CONFIRMED

## herald/scout/convoy 逐 kind 拆解

同 diversity 床（`config/infonet_ledger_diversity.json`，seed4044，30天）：

```
contact.ledger_add(total)=98
  herald=34
  scout=39
  convoy=25
  sum(herald+scout+convoy)=98 vs total=98 → diff=0
```

**98 完全等於 herald+scout+convoy 三個 kind 的加總，沒有缺口**。

## ★QA『herald0+scout0+convoy25=25』數字對不上的原因

**這是兩份不同 fixture/不同跑法的數據被拿來比較**——QA 引用的「herald0+scout0+convoy25」明顯來自別的床（herald/scout 完全沒 fire、只 convoy=25 那組數字），跟我這輪 diversity 床（4 隊各自不同 dominant-trait、herald/scout/convoy 都真的 fire）不是同一份跑法/同一個 seed。**不是 code bug，是兩邊比較時 provenance 沒對齊**（同 L3 那次「stale --path」誤會的同類型問題——先前也發生過把不同輪跑的數字互相拿來對照）。如實回報，供你們核對 QA 引用的具體是哪個檔案的哪組數字。

## ★★順帶查：subteam 漏記帳＝CONFIRMED 真缺口

`_ledger_record` 目前只有 **3 個 caller**（`faction_ai_system.gd:1706` herald / `1732` scout / `3372` convoy）。但 code-read 找到 `SubteamSystem.dispatch()`/`dispatch_anon_messenger()` 實際還有**至少 7 個其他 caller**，全部**沒有呼叫 `_ledger_record`**：

| file:line | 用途 | 是否記帳 |
|---|---|---|
| `faction_ai_system.gd:590` | SETTLE（開拓新據點子隊） | ✗ 未記 |
| `faction_ai_system.gd:1343` | ENVOY（結盟提案信使） | ✗ 未記 |
| `faction_ai_system.gd:3097` | CONSTRUCT（建設子隊） | ✗ 未記 |
| `faction_ai_system.gd:3173` | UPGRADE（設施升級子隊） | ✗ 未記 |
| `faction_ai_system.gd:3458` | EXPAND（擴張子隊） | ✗ 未記 |
| `population_system.gd:50` | 人口超額 advisor 溢出 | ✗ 未記 |
| `player_command_system.gd:549,585` | 玩家指令派遣 | ✗ 未記 |

**若 HOW spec 原意的「subteam」是指這類廣義的「母隊派出任何子隊」都該受失聯帳本追蹤，這是明確缺口**——目前只有 herald/scout/convoy 三種 side-dispatch 動詞被記帳，SETTLE/CONSTRUCT/UPGRADE/EXPAND 這類**任務型子隊**（真的會離開母隊去外地執行任務、原則上也有「派出去後失聯」的風險）完全不在追蹤範圍內。ENVOY（結盟信使）尤其值得注意——它是**跨勢力遠距離派遣**，風險特徵跟 herald/scout 很像，卻沒被記帳。

（`player_command_system.gd` 的玩家指令派遣是否該納入，見仁見智——那是玩家主動指揮非 AI 認知，可以合理排除在外；population overflow 的 advisor 溢出也是純內政重分配非「派出去」，可能也合理排除。**SETTLE/CONSTRUCT/UPGRADE/EXPAND/ENVOY 這 5 個才是真正跟 herald/scout/convoy 同性質的「母隊決策派出去做事」子隊，這 5 個沒記帳比較值得關注**。）

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-ledger-98-breakdown.txt`（2471行，完整跑 log + per-kind 拆解）

## 清理狀態

- `warring_harness.gd`/`faction_ai_system.gd` temp PROBE_KEYS/per-kind tap 已 `git checkout --` 還原確認乾淨。
- temp fixture/bed 已刪除。

## ★誠實淨判

- **98 本身沒有 bug**——herald+scout+convoy 三 kind 加總完全吻合，QA 的對不上是**不同資料來源比較錯位**，非缺口。
- **subteam 記帳缺口 CONFIRMED**——SETTLE/CONSTRUCT/UPGRADE/EXPAND/ENVOY 這 5 種任務型子隊派遣完全沒有 `_ledger_record`，若 HOW spec 意圖涵蓋這些，需要補上。

別下 accept。是否要把 SETTLE/CONSTRUCT/UPGRADE/EXPAND/ENVOY 5 個 call site 補進失聯帳本、以及 QA 引用數字的 provenance 核對，交你們判 HOW scope。
