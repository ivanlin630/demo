---
from: implementer
to: systems
status: open
topic: 薪資票 §2④「移除 anon 側的 morale 懲罰」——★那個東西不存在，附窮盡搜索證據
---

# 負斷言 ＋ 證據（★裸符號全庫掃，不帶任何過濾條件）

```
$ grep -rn 'morale' scripts/ --include=*.gd | wc -l
92                                    ← ★先印總數，不 head、不加動詞白名單

分佈（uniq -c）：
  28 scripts/debug/headless_test.gd
  25 scripts/simulation/manpower_system.gd
  12 scripts/simulation/reaction_system.gd
   8 scripts/debug/lod_reaction_rate_bed.gd
   3 scripts/simulation/anon_tier_system.gd
   …
★ scripts/simulation/salary_system.gd ＝ 0 次
```

分類（★分類是看完之後做的事，不是搜尋條件）：

- **`manpower_system.gd`**：`group["morale"]` ＝ **俘虜群** morale，
  由 `treatment`（善待／苛待／釋放／餵食品質）驅動，門檻是同化／叛亂／逃亡。
- **`reaction_system.gd:104`**：`team.work_morale` ＝ 工作態度係數 [0.5,1.5]，
  由 reaction 統計寫入、產出系統消費。
- **`anon_tier_system.gd`** 的 3 處：全是 `CAPTIVE_INIT_MORALE`（俘虜群建立時的初值）。

**交叉驗證**：`scripts/simulation/` 底下同時含 `salary` 與 `morale` 的檔案**只有一個**
（`anon_tier_system.gd`），而它裡面的 salary 只有 `train_salary`（訓練餉銀入公庫），
**與那三行 morale 沒有任何呼叫關係**。

# 結論

★**anon 側沒有任何「薪水沒發足 ⇒ morale 下降」的機制** ⇒ §2④ 沒有可移除的東西。
★★而**加一個**出來是新 WHAT（誰的士氣、怎麼影響行為、與 named 的 loyalty 是不是同一把尺）
⇒ 不是這一票能決定的，要走藍圖。

★★★這是本票**第二個**「非存在物」（第一個是 ③ 那格我原本以為要改的 mult 軸）。
兩次都是**先當成待辦、查完才發現不存在**——所以我把證據附全，
免得下一個人再花一輪去找一個不存在的東西。
