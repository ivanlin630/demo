# F3 subteam-messenger utils→SubteamSystem HOW（systems、②結構 F3、byte-identical）

status: DRAFT（spec 自檢 → R² 結構審）
owner: systems（HOW）← F3+ standing GO、grounding 結構線
date: 2026-08-07
★純結構搬移（②、byte-identical）：F0 fp 對 ce201650 baseline 27/27 全同=證只搬位置零行為變。任一漂=停查非 merge。禁夾人格化。

## §1 選 subteam-messenger 3 utils（spec 自檢:clean、proper 家）
envoy 域自檢揭:`_recall_envoy`/`_equip_envoy_mounts`/`_founding_timeout` **被 envoy+scout+herald 共享**（非 envoy-only、subteam-messenger 基礎設施）。**proper 家=SubteamSystem**（已有 `_pick_subteam_leader`/`dispatch_anon_messenger`=subteam util 集散地）。移之=consolidate + unblock 未來 envoy/scout 域切。
- **body 亲验零反向耦合**：`_recall_envoy`=TaskArbiter.release+state.detach_subteam/remove_tag+envoy 欄位（零 faction_ai helper）；`_equip_envoy_mounts`=ResourceBank.add+mount；`_founding_timeout`=純算術(MovementSystem.BASE_MOVE_TICKS×const)。全呼下層模組/state、零 faction_ai-only。
- **caller 全 faction_ai 內**（exhaustive 掃:_recall_envoy 7/_equip 4/_founding_timeout 7=~18 site、零 debug/test 外部 caller）。

## §2 切法（byte-identical 純 code-move）
1. 3 函式 + const（`FOUNDING_TIMEOUT_MULT`/`FOUNDING_TIMEOUT_FLOOR_DAYS`）**逐字移** faction_ai→SubteamSystem、instance→**static**（無 instance state）、零 logic 改。
2. **介面**：`SubteamSystem.recall_envoy(state, envoy)` / `.equip_envoy_mounts(state, mother, envoy)` / `.founding_timeout(dist)`（static）。
3. **caller 更新（~18 faction_ai site）**：`_recall_envoy(...)`→`SubteamSystem.recall_envoy(...)` 等（faction_ai→SubteamSystem 下層依賴=正常非反向耦合）。★exhaustive 含任何 debug/test（本輪掃=零、F2 教訓仍守）。

## §3 守 / 驗（byte-identical 命門）
- ★純 code-move 零 logic 改（逐字、禁夾邏輯/人格化）。
- ★**F0 fp byte-identical**（state_fingerprint_bed 對 ce201650 27/27 全同）。
- determinism 3-run byte-identical + constitution 綠（taskarbiter site 隨 _recall_envoy 移=同語意、baseline 路徑 faction_ai→SubteamSystem 更新非新增）+ headless 0-new。
- ★§2.6 ratchet:faction_ai 行數再降（3 函式移出）。

## §4 序
spec 自檢→R²（結構審:邊界/介面/零反向耦合/caller 無漏/taskarbiter site 路徑更新）→build（fp byte-identical）→QA→merge=F3 收→F4+。地基 KEEP。
