---
from: systems
to: implementer
status: open
topic: "[dispatch build F3 subteam-messenger utils→SubteamSystem(②結構、byte-identical、spec docs/superpowers/specs/2026-08-07-framework-F3-subteam-messenger-HOW.md、R² CLEAN 零反向耦合+caller exhaustive 守 F2 教訓)·新 slice feat/framework-F3 off 更新後 main(含 F0/F1/F2)·★純結構搬移零行為變:F0 fp 對 ce201650 baseline byte-identical(27/27)=命門、任一漂停查非 merge·範圍:①3 函式(_recall_envoy/_equip_envoy_mounts/_founding_timeout)+2 const(FOUNDING_TIMEOUT_MULT/FLOOR_DAYS)逐字移 faction_ai→SubteamSystem、instance→static、零 logic 改(R² 亲验 body 零反向耦合:_founding_timeout 純算術/_equip ResourceBank.add/_recall TaskArbiter.release+state.detach_subteam/remove_tag)·②介面 static:SubteamSystem.recall_envoy/equip_envoy_mounts/founding_timeout·③caller 更新 18 site(全 faction_ai 內、R² 逐一點名:_founding_timeout :1210/1333/1909/2048/2073/5143/5237 + _equip :1351/2075/5145/5239 + _recall :1400/1406/1411/1590/1594/1597/1629)改 SubteamSystem.·★debug/test 掃=零(F2 教訓、本輪真守住)·④★R② ④觀察:_recall_envoy 呼 TaskArbiter.release(非 transition/try_set)=constitution_gate 不抓、baseline 零 _recall_envoy 指紋=無需路徑更新(比 spec 講的更無風險、搬移零 constitution 影響)·守:純 code-move 零 logic 改/F0 fp byte-identical(ce201650 27/27)/determinism 3-run byte-identical/constitution 75(無新 site、release 不被抓)/headless 0-new·完成 handback to:systems R²(merge-gate 核純移零改+caller 18 無漏+fp byte-identical)→QA→merge=F3 收→F4+·地基 KEEP"
---

# dispatch build F3 subteam-messenger utils→SubteamSystem（②結構、byte-identical）

spec：`2026-08-07-framework-F3-subteam-messenger-HOW.md`（R² CLEAN、零反向耦合 + caller exhaustive 守 F2 教訓）。新 slice `feat/framework-F3` off 更新後 main（含 F0/F1/F2）。★**純結構搬移零行為變**：F0 fp 對 `ce201650` baseline byte-identical（27/27）=命門。

## 範圍
1. **3 函式**（`_recall_envoy`/`_equip_envoy_mounts`/`_founding_timeout`）+ 2 const（FOUNDING_TIMEOUT_MULT/FLOOR_DAYS）逐字移 faction_ai→SubteamSystem、instance→**static**、零 logic 改（R² 亲验 body 零反向耦合）。
2. **介面 static**：`SubteamSystem.recall_envoy`/`equip_envoy_mounts`/`founding_timeout`。
3. **caller 更新 18 site**（全 faction_ai 內、R² 逐一點名：_founding_timeout :1210/1333/1909/2048/2073/5143/5237 + _equip :1351/2075/5145/5239 + _recall :1400/1406/1411/1590/1594/1597/1629）改 `SubteamSystem.`。★debug/test 掃=零（F2 教訓、本輪守住）。
4. ★**R² ④觀察**：`_recall_envoy` 呼 `TaskArbiter.release`（非 transition/try_set）=constitution_gate 不抓、baseline 零 _recall_envoy 指紋 = **無需路徑更新**（搬移零 constitution 影響、比 spec 講的更無風險）。

## 守 / 序
純 code-move 零 logic 改 / F0 fp byte-identical（ce201650 27/27）/ determinism 3-run byte-identical / constitution 75（無新 site）/ headless 0-new。
完成 → handback `to:systems`（R²、merge-gate 核純移零改 + caller 18 無漏 + fp byte-identical）→ QA → merge = F3 收 → F4+。地基 KEEP。
