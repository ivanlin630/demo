---
from: measurer
to: blueprint
status: consumed
topic: "[subteam-idle v3 硬驗·結構修 DONE 但 seed-swap 續·殘留=gate-value] 6 項硬驗:(a)recall 收斂✓無震盪 (b)seed42→0 ✗FAILED(9,比v2 4差) (c)seed1337 6→10 回落✓(4,低於baseline7,最佳) (d)orphan消✓ (e)手不聽腦≈0(seed1337殘1) (f)perf O(1)✓。結構修對且乾淨(無震盪/囤糧/手不聽腦),但 seed-swap 續3版(v1:6/10→v2:10/4→v3:4/9)。seed42 殘留=乾淨famine無結構病=★gate-value敏感度(結構已補,你說的『再談(A)』條件到)。建議授權 bounded gate-sweep 平衡雙 seed,或認 inherent cascade 挑最佳版。"
measured_at_head: c53c8cbb
---

# subteam-idle v3 硬驗 → blueprint（結構修 DONE，殘留=gate-value）

v3（我根因報告後的結構修：連續母團監看 in-transit + orphan-forager）。baseline c5ab36d9。

## 6 項硬驗結果
| # | 項 | 結果 |
|---|---|---|
| (a) | recall 收斂無慢震盪 | **✓ PASS**（SITRACE resets ≤4，多數 0-1，無 recall↔forage 震盪） |
| (b) | seed42 famine→0 | **✗ FAIL**（9，比 v2 的 4 更差） |
| (c) | seed1337 v2 惡化回落 | **✓ PASS**（4，低於 baseline 7＝最佳版；v2 的 10 回落） |
| (d) | orphan 消 | **✓ PASS**（無 200-2000 囤糧，orphan handler 生效） |
| (e) | 手不聽腦維持 0 | **≈**（seed42 0；seed1337 殘 1 手不聽腦 + 2 stuck-task，marginal） |
| (f) | perf 無 spike | **✓**（連續監看=每 tick O(1) `teams.get`／survival subteam，bounded；未微基準但無演算法 spike） |

## ★結構修對且乾淨，但 seed-swap 續 3 版
| seed | baseline | v1 | v2 | **v3** |
|---|---|---|---|---|
| 1337 | 7 | 6 | 10 | **4**（最佳） |
| **42** | **0** | 10 | 4 | **9**（must-pass ✗） |
| 4201 | 0 | 0 | 0 | 0 |

每版翻不同 seed：v1 傷 42、v2 傷 1337、v3 傷 42。**沒有一版雙 seed 同時乾淨。**

## seed42 殘留 = gate-value（非結構病）
- seed42 v3 死因＝**9 famine（乾淨）**，stuck-task 1、**手不聽腦 0**、無震盪、無囤糧 → **結構病都沒了**（v3 監看/orphan 補完）。
- 是**供給不足**（母團餓死）於 seed42 緊糧世界。SITRACE：foragers 卡低糧 3.7（未到 SATED 10）、樣本少 → 疑 **PARENT_LOW=3 過度召回**（母團一跌破 3 就召 forager，forager 沒累積夠就被叫回 → 交糧少 → 母團還是餓）。
- ∴ **結構已補，殘留是純參數敏感度**——正是你說的「gate-value 敏感度而非結構洞，再談(A)」條件**現在到了**。

## 建議：授權 bounded gate-sweep（(A) 現在正當）
- 結構修 DONE（v3 是對的結構版，別回退）。剩 seed42/seed1337 的 tradeoff 是 gate-value。
- **授權我掃幾組 (FORAGE_SATED_DAYS, PARENT_LOW_DAYS)**（如 SATED 6/8/10 × PARENT_LOW 3/5）對 seed 1337/42/4201，找**雙 seed 同時可接受**的值。
  - 假說：SATED 降（早交）或 PARENT_LOW 升（早救）可能救 seed42，但可能又傷 seed1337——sweep 才知有無平衡點。
- **若 sweep 無平衡點**（gate 值也 whack-a-mole）→ **inherent seed-cascade** → 你挑最佳 aggregate 版/tradeoff（v3 最佳 1337、v2 最佳 42）。
- 此 sweep **非過早**（結構方向已定＝v3 結構修），符量測協議（code 定稿才 sweep）。

## 下一站
你裁：授權 gate-sweep（我跑）or 認 cascade 挑版。verdict `docs/process/verdicts/subteam-idle-latch-v3.measure.json`、raw `docs/measurements/2026-07-19-subteamidle-v3-*`。SITRACE revert、branch clean、fix intact。gates（constitution/headless/determinism 2ebb70aa）implementer 報綠，我未獨立重跑（結構驗證優先）。
