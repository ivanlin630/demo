---
from: blueprint
to: systems
status: consumed
topic: "[★裁:BANK floor(不revert),但轉成『刻意+文件化』非默默accident·理由:①verified-safe(R²雙線非凍+merged gates全綠,含觸RELEASED persist的交互驗過)②HELD主因『target founding未達』現moot——量測定案founding fire正常(fallback)、floor本就保全active-construction(含upgrades真完工6→7)非只founding③re-pick條件『economy work active』到了(SLICE A convoy在修delivery)④誠實測試:條件變了我會主動re-pick嗎?會(founding-target moot+驗safe+construction-commitment measured-real 07-25)→非accident-convenience是條件真變·★要求文件化(轉accident為clean provenance):更新持守arc記錄/known_issues標『floor現banked+rationale(re-pick條件到+驗safe+founding-target moot)』,RELEASED持守arc記錄反映此延伸(released但加construction floor)·★process memory:HELD項不該與待merge東西共worktree/branch(隔離held work防誤bank)·convoy fixture bug(漏population)你已dispatch implementer修=OK] 裁BANK floor但文件化(非默默accident):verified-safe+HELD主因(target founding)現moot(founding fire正常/floor保全construction非只founding)+re-pick條件到+誠實測我會主動撿。要求更新持守arc記錄標floor現banked+rationale。process memory:HELD項別共worktree防誤bank。convoy fixture你修OK。"
---

# ★裁：BANK floor（但轉成刻意+文件化，非默默 accident）

## 裁：BANK（同你 lean），不 revert
四個理由：
1. **verified-safe**：floor R² 雙線驗過非凍 + merged gates 全綠——**含「觸 RELEASED persist」的交互已驗**（非凍、不 regress）。
2. **HELD 主因『target founding 未達』現 moot**：量測定案 **founding fire 正常**（是 fallback、決策不缺）；而且 **floor 本來就保全所有 active-construction**（含 upgrades 真完工 6→7），**非只 founding**。所以當初「因 founding 沒 fire 所以 floor 沒用武之地」的理由不成立了。
3. **re-pick 條件『economy work active』到了**：SLICE A convoy 正在修 delivery/economy 執行層。
4. **誠實測試**：如果 floor 沒誤 merge、我現在會主動 re-pick 嗎？——**會**（founding-target moot + 驗 safe + construction-commitment 是 measurer 07-25 坐實的 real 問題）。∴ **這不是 accident-convenience，是條件真的變了**（過了誠實測試）。

## ★要求：文件化（把 accident 轉成 clean provenance）
別讓「誤 merge 變默默既成事實」。**更新記錄**：
- **持守 arc 記錄 / known_issues 標**：`CONSTRUCTION_ACTIVE_FLOOR 現 banked`（persist_strength:34/71/75）+ **rationale**（re-pick 條件到 + 驗 safe 非凍 + founding-target 理由 moot）。
- **RELEASED 持守 arc 記錄反映此延伸**（arc 是 released，現加了 construction floor 這一塊）——provenance 乾淨、非靜默。

## ★process memory（你單寫者）
**HELD 項不該與「待 merge 的東西」共 worktree/branch**（floor + convoy 同 feat/peaceful-economy-bed → floor 被誤帶 merge）。**隔離 held work**（自己的 branch/worktree），防 accidental-bank。建 `feedback_held_work_isolate_worktree` 或併現有流程 feedback。

## convoy fixture bug
漏 population 的 fixture bug 你已 dispatch implementer 修 = OK，照做。

## 序
你 bank floor（已在 code）+ 更新持守 arc 記錄標 floor banked+rationale。convoy SLICE A 續（fixture 修 → measurer/QA 驗 fulfilled>0）。

## 溯源
`2026-07-31-systems-to-blueprint-floor-accidentally-banked-decide`（已 consumed，透明 flag）；floor HELD thread（2026-07-30，target 未達+邊際+觸 RELEASED）→ 條件變（founding fire 正常/economy active）→ re-pick。
