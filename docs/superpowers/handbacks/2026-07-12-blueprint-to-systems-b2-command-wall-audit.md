---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] B2統領技能門100%結構性硬牆(24311=24311全卡)——查ESTABLISH_COMMAND門檻vs統領技能成長機制,是門檻脫real還是技能練不起來
---

# established B2(統領技能)門100%卡死——真根查（更硬於A門人口）

## 背景
measurer 兩階段gate funnel定位完成（`2026-07-12-measurer-to-blueprint-establishment-gate-funnel-result.md`）：
- **A門**主卡 gate_fail_pop（82.7%，人口太小，呼應經濟長程月1-3急性危機吃掉~45%人口）——非我原懷疑的A5可達盟友（僅6.6%）。
- **B門更硬**：`gate_fail_b2_command`（領袖統領技能不足）與 `gate_b1_ok`（≥2成員分母）**完全相等 24311=24311**——即使faction真的組成（A門全過、真結盟成功），**領袖統領技能門檻一次都沒被任何leader達到過**。B3(野心)也89.2%卡，B4(readiness)因B2全擋從未真正被測試到（readiness門檻本身可能沒問題，只是輪不到顯現）。

**B2是比A門更決定性的斷點**——就算A門(人口)全解，established依然100%卡死在B2。

## 待查（零跑，file:line，patch-gate-first邏輯：先查是否死常數/成長機制斷裂，非猜tuning）
1. `ESTABLISH_COMMAND` 門檻常數值 + 位置（`faction_ai:977`附近，`0.4 −(野心−0.5)×0.2`那條，查ambition範圍下實際門檻區間）。
2. **統領技能（command skill）的成長機制**——leader的統領技能怎麼漲？時間積累/事件觸發/tick cadence？查其成長速率常數、觸發條件、是否有上限/衰減。
3. **對照真實可達值**——12個月窗內，一般leader的統領技能實際能長到多少（若有既有probe/log可查其分布，或請measurer量測leader.command_skill的實際數值分布）。
4. 判斷：**門檻脫離現實**（設得太高，正常遊戲時長內無人能達到）vs **成長機制本身斷裂**（例如某個觸發條件永不fire，類似先前faction-only補丁閘教訓）。兩者修法完全不同——一個是調常數，一個是de-patch/修機制。

## 為何優先這個
B2是唯一「100%結構性硬牆」（非機率性瓶頸），且擋在A門之後——A門解了也沒用。這比繼續查A門(人口)更決定性。世界要能立國，B2必須先有路可通。

## 序
零跑出常數+成長機制file:line → to:blueprint → 我判讀(常數調整 vs 機制de-patch，方向不同) → 若需用戶裁(改變統領技能設計語意) → brainstorm → 對抗 → spec。
