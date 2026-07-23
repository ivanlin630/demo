---
from: implementer
to: measurer
status: consumed
topic: GATE-A 認自家食物源 — measure（UN-HOLD resume，settled-left-home 主體 56-61%）
branch: feat/gateA-productive-home
commit: 7a2e22b0
spec: docs/superpowers/specs/2026-07-23-gateA-recognize-productive-home.md
---

# GATE-A 認自家食物源 — 做完（UN-HOLD resume），量測請收

## 改動（4 touch，同 home_food_productive 信號）
根：harvest positional → settled 隊離 food-rich home 買糧 → home regen 沒人採 → 餓死 surplus 平原；
返家補給 applicable + restock_need 綁 granary stock → 離家空 granary → 回不去 trap。
（systems UN-HOLD：end-state 分類 settled-left-home=**56%/61% 主體**，no-outpost 只 8-13%；GATE-A 原 scoping 對。）

- **① `decision_context` c.home_food_productive**：家 outpost tile `REGEN_RATE[terrain].food × harvest_factor ≥ burn(pop×FOOD_PER_PERSON_PER_DAY)`，僅 has_home_outpost 否則 false。★感知鐵律 clean（自家 outpost terrain）。
- **② `options 返家補給` applicable**：`+OR home_food_productive`（產糧家空 granary 也返，回去採飽）。
- **③ `terms restock_need`**：`maxf(clampf(home_food/RESTOCK_MIN,0,1), productive?1:0)`（產糧家 drive 滿）。
- **④ ★`options 買糧` applicable**：`+and not home_food_productive`（reviewer R² 必加，閉商隊 toss-up trap，結構偏好返家；forest 不誤鎖）。

## 自驗（皆綠）
- TDD `gateA_test` **10/10**（RED 確認 4 touch 各失效對應 FAIL）。
- headless 0-new（3 baseline）。gate PASS sites=75（無新閘）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `a6b736fb`（純算術無 RNG；≠produce-demand digest=GATE-A 在 warring 真改決策=行為變但 2 跑一致）。

## 量測請抓（原 dispatch §驗收 + UN-HOLD 薄利 caveat）
1. **end food_days<3 比例**（24-37%→?）：假飢餓消失多少。
2. **返家補給 chosen**（productive-home 隊）：食低→返家採飽脫餓。
3. **離家隊脫餓**（T28 型 plains at_market → 返家）。
4. **★forest 隊仍離家貿易無誤鎖**（home_food_productive=false → 買糧 applicable 不變）。
5. **buy-fill 漏斗壓力洩**（seek 降?）/ farming survival-crush fire 變化 / facility 建成數（食穩→脫 subsistence→specialize 起色?）。
6. **★薄利 caveat（UN-HOLD 揭）**：with-outpost collect **5.58-6.55/day < pop10 burn 8** → 返家的**大隊(pop>8)可能仍薄利慢餓**（harvest rate 另議）。GATE-A 先看**解多少**（measure 顯示返家大隊是否仍卡）。
7. 無新餓死。
8. §④b sample + specimen → QA。

床：`godot --path .worktrees/gateA` 對 branch 7a2e22b0 跑（★禁原地 checkout）。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:QA 判故事：
productive-home 食低→返家採飽脫餓；forest 仍正確離家；假飢餓消失、真缺（forest/薄利/no-outpost）留後續刀
（settled-productive 薄利 harvest 23-36% + no-outpost forage 8-13% = GATE-A measure 後定序）。
