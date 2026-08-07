---
from: systems
to: reviewer
status: consumed
topic: "[R² 結構審:F3 subteam-messenger 3 utils→SubteamSystem(spec docs/superpowers/specs/2026-08-07-framework-F3-subteam-messenger-HOW.md)·②結構 F3、byte-identical·spec 自檢:envoy 域揭 _recall_envoy/_equip_envoy_mounts/_founding_timeout 被 envoy+scout+herald 共享(subteam-messenger 基礎設施非 envoy-only)、proper 家=SubteamSystem(已有 _pick_subteam_leader/dispatch_anon_messenger)·body 亲验零反向耦合(_recall_envoy=TaskArbiter+state.detach/remove_tag 零 faction_ai helper[早 grep _letters_all/_subteam/_tag=下個函式 tick_letters_all 註解 sed 跨界誤讀、已訂正]/_equip=ResourceBank/_founding_timeout=純算術 MovementSystem const)·caller 全 faction_ai 內(~18 site、零 debug/test 外部)·切法=3 函式+FOUNDING_TIMEOUT const 逐字移 static、caller 改 SubteamSystem.·★R² 結構審重點:①body 零反向耦合確認(移 SubteamSystem 後 SubteamSystem 不呼 faction_ai)?②caller exhaustive 無漏(~18 site + 任何 debug/test、F2 headless:8521 教訓)?③純 code-move 零 logic 改?④taskarbiter site(_recall_envoy 的 TaskArbiter.release)隨移=constitution baseline 路徑更新 faction_ai→SubteamSystem 非新增 site?·序:CLEAN→build(fp byte-identical 對 ce201650 27/27)→QA→merge=F3 收·地基 KEEP"
---

# R² 結構審：F3 subteam-messenger utils→SubteamSystem（②結構、byte-identical）

spec：`2026-08-07-framework-F3-subteam-messenger-HOW.md`。

## spec 自檢
envoy 域揭 `_recall_envoy`/`_equip_envoy_mounts`/`_founding_timeout` 被 envoy+scout+herald **共享**（subteam-messenger 基礎設施）→ proper 家 **SubteamSystem**。body **亲验零反向耦合**（_recall_envoy=TaskArbiter+state 方法、零 faction_ai helper；早 grep _letters_all/_subteam/_tag=下個函式註解 sed 跨界誤讀已訂正）。caller 全 faction_ai（~18 site、零 debug/test 外部）。切法=3 函式+FOUNDING_TIMEOUT const 逐字移 static、caller 改 `SubteamSystem.`。

## ★R² 結構審重點
1. **body 零反向耦合確認**（移 SubteamSystem 後 SubteamSystem 不呼 faction_ai）？
2. **caller exhaustive 無漏**（~18 site + 任何 debug/test、F2 headless:8521 教訓）？
3. **純 code-move 零 logic 改**？
4. **taskarbiter site**（_recall_envoy 的 TaskArbiter.release）隨移=constitution baseline 路徑更新 faction_ai→SubteamSystem 非新增 site？

## 序
CLEAN → build（fp byte-identical 對 ce201650 27/27）→ QA → merge = F3 收。地基 KEEP。
