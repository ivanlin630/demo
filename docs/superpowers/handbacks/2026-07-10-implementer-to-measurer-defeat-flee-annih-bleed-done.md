---
from: implementer
to: measurer
status: consumed
topic: de-patch 傷亡累積器 done+驗 → 定向床+organic 數字：bleed 活了但 annih 仍=0（結構，非 sample）→ 判稀度定案
---

# de-patch §D4 done（commit a6b90e2 @feat/defeat-flee）+ 數字給你定案

## 做了什麼（照 §D4，含 1 處刻意 deviation）
- `_resolve_combat_round` 傷亡改 real-valued + flanking 套 real 上 + `_accum_casualty` floor 累積器（跨 round carry 餘量）。
- **★deviation（技術修，非違工單意圖）**：累積器餘量存**專屬生產 dict `_cas_carry`**，非工單寫的 `_combat_track.cas_carry`。因 `_combat_track` 只在 `if Probe.enabled` 內 init/erase（純探針、Probe off 時全空）→ piggyback 會使 de-patch **僅測量時流血、生產仍截斷不流血**（假修）。`_cas_carry` 開場無條件歸零、零 randf → 生產真流血 + determinism 保。
- 閘：`--import`/multi-sanity(coin_eq/inv=0)/constitution **綠**。determinism：seed 1337 兩跑 `[bed] probe` **byte-identical PASS**。

## 定向床（你那把 defeat_flee_annih_exercise_bed.gd，我跑了確認 bleed）
| courage | n | annihilation | mortal_flee | other(rout) |
|---|---|---|---|---|
| high | 240 | **0** | 185 | 55 |
| mid | 240 | **0** | 212 | 28 |
| low | 240 | **0** | 231 | 9 |

Probe: `mortal_flee.n=628`（n_high=**87**/mid=354/low=187）、`end_rout=92`、`retreat_captured=148`、`combat.end_annihilation=0`、`str_ratio/pop_ratio_annih=N/A(n=0)`。床自印 `n_high>0 達成=YES`。

## organic 3 seed（1337/42/7, 3mo）
- rout **now appears**（1337 rout=2、42 rout=3；de-patch 前=0）、capture 2/3、mortal_flee 主端、`end_annihilation=0` 全 seed。

## 判讀（★需你定案 + 可能回 systems/blueprint）
- **de-patch 生效**：bleed 真發生（rout/capture/n_high 由 0→非 0）。de-patch 前 mortal zone 零流血是真病、已解。
- **但 annih 仍=0，且是結構非 sample**：定向床強逼 n_high=87（勇者小隊大量進戰）annih 照樣 0。根因（我讀 code:270-295）：annih 端（`eff≤1`, :286/291）要**雙方都不逃**才到得了；但 (a) 被 outnumber 的勇者 outnumber 項 saturate pressure→逃；(b) 沒被 outnumber 時對手（床固定 mid, flee_thr 0.8）自己先逃。∴ **flee 兩路 pre-empt annih**，de-patch=必要非充分。
- **定向床 enemy 寫死 mid → 對手恆逃 → annih 被床設計排除**。要真測 annih 端需 **brave×brave 對稱格**（雙方都 hold 才 bleed 到殲滅）——你的床 SELF_EFF×ENEMY_EFF 有覆蓋但 enemy courage 固定 mid，建議加 enemy=high 對稱格複跑。

## 待你 → blueprint
數字齊。**殲滅=0（flee/rout 全吃）是可接受的「稀」，還是 under 意圖需 mechanism 調整**（annih 需一條逃不掉的路，或 brave-vs-brave 才殲滅）？= 稀度定案。若你補 enemy=high 格量到 annih>0 → 證機制只是 organic 罕見；若仍 0 → 結構性，標 systems（flee 公式 pre-empt annih 過強）。
