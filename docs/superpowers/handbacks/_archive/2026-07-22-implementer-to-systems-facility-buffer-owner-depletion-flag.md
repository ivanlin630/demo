---
from: implementer
to: systems
status: consumed
topic: "[卡點·裁決·facility-buffer owner-depletion 具現] const 1.5→1.1 fix 做完+TDD 5/5(RED 驗)但 headless 1 new:G1a 礦村→鑄幣鏈斷。★坐實 buffer-level 依賴 owner-depletion(1.4→headless 3 過/1.1→4 失敗)=spec 明列的 owner-depletion 在 headless 具現(非只 organic measurer)。權衡:1.1 解 weaponsmith choke 但觸 depletion/1.4 不 depletion 但 choke-relief 弱。請裁 const 值/depletion guard/G1a 處理。"
---
# Hand Back（卡點裁決）: facility dispatch buffer — owner-depletion 在 headless 具現

facility-dispatch-afford-buffer fix 主體做完（const FACILITY_DISPATCH_AFFORD_MULT=1.1，連改姊妹站 2637+2780，2551 不碰），TDD 綠，**但 headless 揭 1 new = 你 spec 明列的 owner-depletion 具現**，需裁 const 值（TEST VALUE）。

## fix 已完（worktree feat/facility-buffer 保留）
- 新 const `FACILITY_DISPATCH_AFFORD_MULT=1.1`（TEST VALUE），**兩姊妹 dispatch 站同用**：`_dispatch_facility_builder`（`* 1.5`→`* const`）+ `_dispatch_upgrader`（同）。`2551` 新據點 strict-private **不碰**（grep 驗）。
- **TDD** `facility_buffer_test` **5/5 PASS**（RED→GREEN；★還原 1.5→builder/upgrader avail×1.2 case FAIL[1.5 擋]，證 load-bearing）。①builder ×1.2 過 ②×1.05 擋 ③④姊妹站 _dispatch_upgrader 同 const 同行為。
- gate PASS sites=75 removed=0；determinism byte-identical。

## ★卡點：headless 1 new（G1a 礦村→鑄幣鏈斷）= owner-depletion 具現
- **`_test_mining_to_coin`（G1a T3）** 6000-tick 礦村該建 mint→coin，**現 mint_level=0 coin_delta=0**（vault_ore=46 有礦沒鑄）。
- **★坐實 buffer-level 依賴**（我實驗）：**const=1.4 → headless 3（baseline，mint 過）；const=1.1 → 4（mint 失敗）**。∴ 非我 code bug，是**降 buffer 到 1.1 觸發 owner-depletion**。
- **機制**（診斷，你 verify）：礦村常駐該**就地建 mint**（`faction_ai:2993` on-site→`_subteam_upgrade_facility` in-place exact cost）。但 **faction 級 `_evaluate_infrastructure`（`:3056` `_dispatch_facility_builder`）降 buffer 後 dispatch 一支 builder 撥走 material（`_fund_subteam_cost`）→ owner material 降到 mint 就地建不起**。= **你 spec §measure 明列的「owner-depletion→thrash」**，只是在 headless 整合測就咬到（非只 organic）。

## 請裁（const=TEST VALUE，你 owner；measure-sensitive）
- **A（tune const 高）**：1.1→1.3/1.4 避 depletion。但 weaponsmith cost 80×1.4=112，roaming mil hold 54-80 **仍卡**（choke 沒解=fix 目的失）。1.1 才解 choke。→ tune 是拉鋸（解 choke vs 避 depletion）。
- **B（depletion guard）**：dispatch afford 加「撥料後 owner 留 ≥ 自身近期 need（如 mint/survival reserve）」= 不撥到自己建不起。**較治本**（buffer 低仍不 over-dispatch），但 +邏輯（你 HOW 定）。
- **C（G1a 容忍）**：接受 1.1 的 depletion，G1a 測改「給礦村更多 material」或放寬斷言。**但這掩蓋真 owner-depletion**（違「別盲設掩蓋 gap」精神）——不推薦。
- **我傾向 B**（治本：低 buffer + 不 over-dispatch depletion），但涉 dispatch 邏輯設計=你 HOW。或你判 A 的 tune 值可接受（choke 部分解即可）。

## 現況
worktree feat/facility-buffer 保留（const 1.1 + TDD 5/5 + 姊妹站改）。status blocked，hold warm 等你裁 A/B/C（+const 值）。裁完我落地 + headless 0new + handback measurer（含 owner-depletion 稽核已在 headless 部分坐實）。
