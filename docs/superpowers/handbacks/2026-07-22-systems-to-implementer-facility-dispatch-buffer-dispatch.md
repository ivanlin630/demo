---
from: systems
to: implementer
status: consumed
topic: "[dispatch·facility dispatch afford buffer 降·Gate B cheap·R² 2修正已納·★off LOCAL main 0f0a5eca·★連姊妹站2637+2780] spec=2026-07-22-facility-dispatch-afford-buffer.md。reviewer R² 訂正2點已納:①×1.5非anomaly是3站dispatch convention(資助移動subteam),但是choke(作者98a0a8f7認),降解mil weaponsmith卡建②須連姊妹站2637+2780同const(只改2780自拆一致)。修:新const FACILITY_DISPATCH_AFFORD_MULT=1.1(TEST VALUE),兩站同用:①_dispatch_facility_builder:2780 `cost[k]*1.5`→`*FACILITY_DISPATCH_AFFORD_MULT`②★_dispatch_upgrader:2637 同(vault+private ×1.5→同const)。★2551(新據點strict-private)別碰(另案)。TDD 4型(avail 90/80/88邊界+姊妹站同行為)。gate/headless 0new/determinism 2跑byte-identical 無RNG。★measure=facility-build-by-type(weaponsmith/upgrade dispatch成功率)+★owner-depletion稽核(降buffer後owner撥料是否depletion→thrash,reviewer要驗)+doom-delta,帶§④b樣本(長跑→QA新規則)。★仍trade-primary次要(mil仍需有material靠買=material貿易流measure主線,別誤當主fix)。task=systems+reviewer。做完→to:measurer。"
---

# dispatch：facility dispatch afford buffer 降（Gate B cheap，R² 2 修正已納）

spec：`docs/superpowers/specs/2026-07-22-facility-dispatch-afford-buffer.md`。reviewer R² 2 訂正**已納入 spec**（framing + 姊妹站）。blueprint 授權（cheap）。

## ★★ branch base
- **off LOCAL main `0f0a5eca`**（禁 origin）。pre-push hook 已裝。

## 修（★兩站同 const）
新 const（`faction_ai_system.gd`，兩 dispatch 站同用保 convention 一致）：
```gdscript
const FACILITY_DISPATCH_AFFORD_MULT: float = 1.1   # TEST VALUE — dispatch afford buffer(資助移動subteam;原1.5是choke,降解mil weaponsmith卡建;1.1留小fund-transfer buffer防途損/owner-depletion,measurer tune)
```
1. **`_dispatch_facility_builder:2780`**：`cost[k] * 1.5` → `cost[k] * FACILITY_DISPATCH_AFFORD_MULT`。
2. **★`_dispatch_upgrader:2637`**（姊妹站，同 vault+private ×1.5）：**同改** → 同 const。**別漏**（reviewer：只改 2780=自拆一致化）。
3. **★`2551`（新據點 strict-private）別碰**（另案，不同語意）。

## 驗收
- **TDD 4 型**：①avail=90 cost=80 → ×1.1(88) pass（原 120 fail）②avail=80 → fail ③avail=88 → pass ④**姊妹站 `_dispatch_upgrader` 同 const 同行為**。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★measure（→measurer，帶 §④b 樣本；長跑→QA 新規則）**：facility-build-by-type（weaponsmith/upgrade dispatch 成功率↑?）+ **★owner-depletion 稽核**（降 buffer 後 owner 撥料是否 depletion→thrash/餓，reviewer 要驗）+ doom-delta（seed1337/42）+ 無回歸。

## ★仍 trade-primary 次要
只降 dispatch 門檻，mil 仍需**有** material（54-80 靠買才夠）→ **material 貿易流 measure（另軌，在飛）才是主**。別誤當主 fix。

## 完成判定 = systems + reviewer。做完 → to:measurer。
