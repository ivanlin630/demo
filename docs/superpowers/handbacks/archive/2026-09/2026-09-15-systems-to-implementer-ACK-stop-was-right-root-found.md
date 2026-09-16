---
from: systems
to: implementer
status: consumed
slice: `coin` ｜ **你停對了；原票撤銷；root 找到了**
topic: ★**`BASE_PRICE["coin"] = 1.0` 撤銷**（型別錯不是數值錯——補表 ⇒ coin 變成可買賣商品）｜★★**`maintain_coin` dormant 的 root 是 `need_keep(coin) ≡ 0.0`**：`TARGET_PER_POP` 也缺 coin ⇒ `_self_use` 0、coin 非任何配方 `in` ⇒ `_supply_chain` 0、建造成本明文無 coin ⇒ 第三項 0 —— **與你的實跑 0 次互為獨立證據**｜★★★**現在在 reviewer 手上（R²），你先別動手**
---

# ① 你那兩件事都收下了

- **停止條件觸發 ⇒ 你停了** —— ★**而值錢的不是「擋住壞修法」，是你停下來後往旁邊看了一眼**，
  撞到 `trade_valuation.gd:173-175` 的既有特判。**沒有那一眼，我會讓你去做一個型別錯的修改。**
- **38 處、六分類、對帳＝母體、沒有「其他」** —— ★這就是我要的形狀。
  ★★而你**特地去查** `:175` 而不是推測它「應該不受影響」⇒ 記一筆。

# ② root（★我靜態證的，你不必再跑）

```
goal_resolver.gd:44  status = effective_holding(coin) < need_keep(coin) ? active : satisfied
need_oracle.gd:82    need_keep = _self_use + _supply_chain + _construction_facility_need
  _self_use :236-249 coin 落末行 pop × TARGET_PER_POP.get(res, 0.0)
                     ★ trade_valuation.gd:30-51 【也沒有 coin 鍵】⇒ 0
  _supply_chain      coin 不是任何配方的 `in`（manufacturing_system.gd 零筆 "coin"）⇒ 0
  _construction_...  outpost_system.gd:9 / :94 明文「無 coin、無有限資源」⇒ 0
⇒ need_keep(coin) ≡ 0.0 ⇒ holding ≥ 0 ⇒ 恆 satisfied ⇒ 永不進 frontier ⇒ derived_payoff 0 次
```

★★★**所以真正的病是同一個形狀落在兩張表上**：
**per-resource 表的預設 `0`，在語意上是「不存在」而不是「零」** ——
而 `local_value():173` 的特判**就是補丁閘**：有人撞過這個洞，
修法是在一個函式裡特判、不是修表 ⇒ **洞在其餘 37 處照樣開著，而且從此沒人會再撞到它。**

# ③ 下一步（★別動手，等 R²）

spec v2 已覆蓋 v1：`docs/superpowers/specs/2026-09-15-coin-is-the-unit-HOW.md`

- **票甲 取價單一真相**：先驗＝量「A 類 9 處 `.get(res, ...)` 裡 `res == "coin"` 的次數」。
  全 0 ⇒ 潛伏不是現行 ⇒ 降級成機械收斂、零行為變；非 0 ⇒ 逐處判。
  ★驗收要一顆 tap 證**新路徑真的被走到**（`local_value():180-190` 有同型可抄）——
  **fp 不變只證等價，不證被走到。**
- **票乙 coin 的需求是衍生的**：★**禁止**往 `TARGET_PER_POP` 塞 `"coin": N`（手抄物理）。
  接線＝`Σ max(need_keep(res) − holding(res), 0) × 取價(res)`，coin 必須是 DAG 的葉。
  **票乙等票甲**（它要用取價函式，而取價現在有兩份真相）。

# ④ 你側報的那個，我另立

`maintain_material` **85% payoff ＝ 0** ⇒ **另立一條**，不併本票。
★**你報數字沒有順手解釋，這是對的** —— 我來決定要不要開。
