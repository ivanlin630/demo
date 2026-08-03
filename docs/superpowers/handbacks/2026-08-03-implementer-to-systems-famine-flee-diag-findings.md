---
from: implementer
to: systems
status: consumed
topic: "[饑荒-flee 診斷真值·measure-first 別下結論·root≠(a)決策 pin:resident 給可達已知糧源即 relocate(遷移找糧→移向糧格)、與 mobile 同、無結構 pin] feat/famine-flee-diag 32827479。同饑荒世界對照:resident(擁 outpost)+mobile 皆 rank_survival winner=遷移找糧、皆 move target=(7,5)food-rich、皆離開貧瘠格。blueprint(a)『resident pin、mobile 逃它不逃』REFUTED。→narrows (b)/visibility:真 §5 餓死居民大概率 food_seek_target=-1(視野無 wild_game 可達+無親聞 food 賣單)→遷移找糧 not-applicable→無 food option 餓死。★converge jia root:food_seek_target 源②親聞 food 賣單=team_known propagation(co-location-only:79)→settled 居民不共位→從不親聞→源②恆空=學不到哪有糧。measurement docs/measurements/2026-08-03-famine-flee-diagnostic.json。交 measurer tap 真 §5 食 food_seek_target 值定 (b)vs 執行 pin。"
branch: feat/famine-flee-diag
commit: 32827479
base: main d9e8304f
measurements: docs/measurements/2026-08-03-famine-flee-diagnostic.json
---

# 饑荒-flee sanity 診斷真值（measure-first、別下結論、只交 (a)/(b) 判別）

**問**：§5 居民 food=0 runway=0 餓死、覓食有 fire 卻救不了——(a) resident 結構 pin vs (b) 全域糧缺？

bed `famine_flee_diag_bed.gd`（純觀測、零 production 改）：同一饑荒世界（貧瘠主格+鄰格 + 遠格(7,5)food-rich wild_game 可達視野內）**resident vs mobile 對照**。

## 真值
| | resident（PRODUCE 擁 outpost） | mobile（無 outpost） |
|---|---|---|
| food_seek_target | **(7,5)** | (7,5) |
| has_forage_tile | false（鄰格無 wild_game） | false |
| rank_survival | **["遷移找糧"]** | ["遷移找糧","紮營"] |
| winner | 遷移找糧 → FORAGE target **(7,5)** | 遷移找糧 → FORAGE target (7,5) |
| **移動離開貧瘠格** | **true** | true |

## 判別結果
- ★**root ≠ (a) 決策 pin**：blueprint「resident 結構 pin：只採 local barren、從不 relocate、mobile 會逃它不會」**決策層 REFUTED**。resident 與 mobile **皆選 遷移找糧、皆 move target 同一 food-rich 格、皆離開貧瘠格**。resident 給**可達已知糧源**就 relocate（與 mobile 無異）。差異僅 mobile 多 紮營（無 outpost 才能 found），winner 皆 遷移找糧。
- **→ narrows (b)/visibility**：真 §5 餓死居民大概率 **food_seek_target=-1**（視野內無 wild_game 可達 + 無親聞 food 賣單）→ 遷移找糧 not-applicable + 覓食 not-applicable + 買糧 not-applicable → **無 food-yielding survival option → 餓死**。= 居民**學不到哪有糧**（visibility），非決策不逃。

## ★convergence（與 jia distribute root 同一機制）
`food_seek_target` 兩源（`_find_food_seek_target`）：① 視野 wild_game ② **親聞 food 賣單**（`received_sell_orders` = team_known）。② 與 jia distribute/deliver root **同 propagation 機制**：訊息傳播 **co-location-only**（`propagate_on_arrival:79` 要同 tile）→ settled 居民不與賣糧方共位 → **從不親聞 food 賣單** → 源② 恆空。若 ① 也空（local 無 wild_game）→ food_seek_target=-1 → 困死。**同一 team_known 傳播/visibility root 貫穿 distribute=0 與 famine 餓死**。

## 交 measurer / 待你
- ★**別下修結論、我 HOLD**（spec：先確認餓死非既有求生機制 bug、再談求援信使決策）。
- **measurer tap 真 §5 餓死居民 runway→0 全程**：`food_seek_target` 值——恆 -1 → **(b)/visibility 坐實**（非決策 pin）；曾 !=-1 卻沒移動 → 執行層 pin（手不聽腦、另查）。本 bed 已證：**給可達已知糧源、居民決策層會 relocate**。
- bed-only 零 production 改 → headless/constitution/determinism 不受影響。
