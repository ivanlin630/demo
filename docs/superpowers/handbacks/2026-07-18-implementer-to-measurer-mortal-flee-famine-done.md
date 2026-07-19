---
from: implementer
to: measurer
status: consumed
topic: "[mortal_flee 認飢餓 交付·cause2 de-patch·B 前置] _mortal_flee_check 擴認飢餓:eff>3 絕對閘只對不餓 pre-empt+famine_pressure 餵 mortal_pressure。FAMINE_W=1.2(food→0 頂過最勇 flee_thr 1.1)。branch feat/mortal-flee-famine HEAD d0e3bae0 off origin/main@31f9833c。char 5/5+gate 64 removed=0+headless 3-baseline。★measure 必含硬 seed1337 multi-seed(claim 前,你驗):no_forage 傻站死歸零+seed1337 pop 不 bleed。"
---
# Hand Back：mortal_flee 認飢餓（cause2 de-patch，B 前置）

**branch** `feat/mortal-flee-famine`（已 push）**HEAD `d0e3bae0`**，off origin/main `31f9833c`（survival PRIO merged）。

## 修（de-patch：eff≤3 絕對門檻 pre-empt 膽量秤 for 飢餓=補丁閘）
`npc_combat_system.gd _mortal_flee_check`：
- **食物公式對齊絕境判**：`food_days = effective_food / maxf(pop×FOOD_PER_PERSON_PER_DAY, ε)`；`starving = food_days < FAMINE_FLEE_FLOOR(3.0)`。
- **(1) 閘改**：`if eff > MORTAL_EFF_POP and not starving: return false`（健康**且不餓**才續戰；飢餓隊即使 eff>3 進絕境逃判）。
- **(2) famine_pressure**：`clampf((FLOOR − food_days)/FLOOR, 0, 1) if starving else 0` → `mortal_pressure = clampf(criticality + outnumber×0.5 + famine_pressure×FAMINE_W, 0, 1.5)`。膽量秤 flee_thr 不變。
- **★FAMINE_W=1.2（邊界校）**：food_days→0 時 famine_pressure×W = 1.2 **> 最勇 flee_thr 1.1**(`MORTAL_FLEE_BASE 0.5 + 1.0×MORTAL_COURAGE_SPREAD 0.6`)→ **連最勇餓極也 break-off**（絕境階梯保證，同 survival boost 破頂精神）。clamp 1.5 > 1.1 足夠。
- **+observability**：`mortal_flee.famine` probe（measurer 分 famine vs combat flee）。

## 自驗（char bed 5/5 綠）
- **健康(eff=6)+不餓(food_days=10)→ 續戰**（return false，non-starving 不亂逃）。
- **健康勇者+不餓+被 outnumber → 仍續戰**（眾寡由既有 readiness-abandon/殲滅三端管，非 mortal_flee）。
- **★最勇者(courage=1)+健康(eff=6)+極端斷糧(food_days=0)→ mortal_flee fire**（FAMINE_W 夠，餓極必逃非傻站死）。
- **膽量秤**：餓+怯(courage=0,flee_thr=0.5)→**早逃**；餓+勇(courage=1,flee_thr=1.1)+中度餓(food_days=1.5)→**撐**（照妖鏡#1 courage 桶）。
- **constitution_gate PASS 64 removed=0**（npc_combat_system 非 decision-file → 零 fingerprint 變）。
- **full headless** `=== DONE ===` + 3 pre-existing baseline（無新增；combat 不崩）。

## ★下一站 measure（★含硬 seed1337，claim 前非事後——blueprint process 鐵律，3 度過早宣勝教訓）
**我不宣普適勝——需你 organic multi-seed 中性複核**：
1. **multi-seed 含 seed1337 + 42 + 4201（8mo）**：`_on_team_extinct` **no_forage 傻站死普適歸零**（餓死回 survival-action/mortal_flee 自限）——**★seed1337 必驗**（上輪就是它壞）。
2. combat 三端保 + world sustain（**seed1337 pop 不 bleed**）。
3. `mortal_flee.famine` 觸發率健康（餓隊逃有數，非全隊亂逃）。
- 綠（含 seed1337）→ to:systems 判 merge。此為 **B(絕境經濟) 前置**（敗北出路：餓極逃=自限 starvation，膽量秤鏈乾淨）。

## 溯源
dispatch `2026-07-18-systems-to-implementer-mortal-flee-famine-fix.md`（R² CLEAN）；`npc_combat_system.gd:152-177`；[[project_desperation_economy]]；[[feedback_patch_gate_first]]（eff≤3 絕對閘=補丁閘 de-patch）；[[reference_measurement_protocol]] multi-seed-before-claim。
