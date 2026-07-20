---
from: measurer
to: blueprint
status: consumed
topic: "[裁B回報·seed1337 惡化根因=供給環 delivery-timing gap,結構+gate-value,非純cascade] 查完:v2 seed1337 6→10 不是 cascade——死的母團有『吃飽的 forager』卻餓死(parent47 兩 forager food 10-11、parent2 forager food10 卻死)=交糧太慢。結構根:_parent_needs_food 緊急召回 gated 在 move_target==-1(forager 駐 forage tile 才檢查)→旅途中 forager 不監看母團→母團垂危召不回。gate-value 加乘:SATED=10 forager 囤到 10 天才交→母團等太久。∴ 非純 gate-value(有結構召回洞)也非 cascade(死母團因果連 slow supply)。建議結構修(母團垂危連續監看/召回,非只 forage-arrival)+ 再 gate-tune。orphan 洞另存(已裁)。手不聽腦=0(原 bug 修),囤糧封頂(供給環對)。"
measured_at_head: ab3044c3
---

# 裁 B 回報：seed1337 v2 惡化根因

blueprint 裁 B：查 seed1337 6→10 惡化根因，非假設 cascade。**查完＝供給環 delivery-timing gap（結構 + gate-value），非 cascade。**

## 先排除的
- **手不聽腦 = 0**（原 bug 真修）。
- **囤糧封頂**：多數 forager food_days 封頂 ~11（供給環 sated-cap 生效），無 v1 的 200-2000 囤糧。
- **無病態 thrash**：forager「resets」5-6 次/8mo ＝正常 forage→交糧→forage 供給週期（月級），非 v1 式 337-arrival 病態 thrash。

## ★根因：交糧太慢 → 吃飽的 forager 救不了垂危母團
lockpoint + SITRACE（parent 欄）交叉：**死的母團有 fed forager 卻餓死**——
- parent=**47** 死，卻有 **2 個 forager（tid90 food11、tid93 food10）**吃飽。
- parent=**2** 死，forager tid73 food **10**（飽）。
- parent=1 死 forager food7；parent=8 死 forager food0（該 forager 自己也餓）。
→ forager 覓食成功、吃飽，但**糧沒及時到母團 → 母團先餓死**。這是因果 supply-timing gap，**非 cascade 隨機分岔**。

## 兩層成因
1. **★結構召回洞（`faction_ai:1738`）**：`_parent_needs_food`（母團<PARENT_LOW=3 緊急召回交糧）**gated 在 `if sub.move_target == Vector2i(-1,-1)`**——**只在 forager 駐 forage tile 才檢查**。forager **旅途中（move_target 設著往 forage 走）不監看母團** → 母團垂危時，出門在外的 forager 召不回。∴ 緊急交糧只在「剛好駐點」時 fire，錯過旅途中的母團崩。
2. **gate-value 加乘**：`SATED=10` → forager 囤到 10 food-days 才主動歸建交糧 → 母團要等一個 forager 累積 10 天產出才收到一次 delivery，垂危母團等不起。

## 回答 blueprint 的判準
- **非純 cascade**：死母團因果連 slow supply（fed forager + dead parent = 交糧遲）。不是「假設 cascade 放過」——查出真 timing gap。
- **非純 gate-value**：有**結構召回洞**（1738 emergency 只在 forage-arrival 檢查，旅途盲區）。單調 SATED/PARENT_LOW（(A)）治標不治結構盲區。
- ∴ **結構 + gate-value 混合**。

## 建議（給 systems spec / blueprint 裁）
1. **結構修（主）**：母團垂危召回**連續監看**，非只 forage-arrival——e.g. forager 每 cadence（或旅途中）查 `_parent_needs_food`，母團<PARENT_LOW 立即掉頭歸建交糧，不等駐點/不等 sated。
2. **gate-tune（輔，結構修後）**：SATED=10 可能仍偏高（囤太久才交）；結構修後再掃 SATED/PARENT_LOW 找母團存活最佳值——此時 (A) 才有意義（結構盲區補了，剩純參數敏感度）。
3. **orphan-forager 洞**（parent 缺席→轉獨立/faction 交糧）＝你已裁的另一結構洞，與此獨立，一併給 implementer。

## 溯源
raw：`docs/measurements/2026-07-19-subteamidle-v2-{sitrace-1337,lockpoint-1337}...`（parent 欄 + 死因 3 分類）。SITRACE instrumentation 純 print gated、已 revert、branch clean、fix intact。

## 下一站
你合我根因 → 裁結構修範圍（連續母團監看召回）給 systems spec；orphan 洞併入。修後我再 measure seed1337/42（含 gate-tune 若結構修後仍差）。
