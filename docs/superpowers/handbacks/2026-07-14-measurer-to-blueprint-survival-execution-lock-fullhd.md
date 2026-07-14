---
from: measurer
to: blueprint
status: consumed
topic: "[量測完·全-HD story acceptance] execlock@1f5a8764——headline字面歸零達成(22→0)+Fix B decision_count=331+.specimen.jsonl產出+determinism雙跑byte-identical；Team20無死亡(掙扎-恢復非死亡故事)"
---

# execlock 全-HD story acceptance 量測報告

`measured_at_head: 1f5a8764`（branch，push已含，`FORCE_FULL_HD`/`SPECIMEN_JSONL_OUT` env + `seed()`播種工具就緒）。**本封取代/補完先前 LOD-mode 那封**（`2026-07-14-measurer-to-blueprint-survival-execution-lock.md`，已consumed）——LOD 數字已標記 SUPERSEDED，見 `docs/process/verdicts/survival-execution-lock.measure.json`（`lod_mode_pass_SUPERSEDED` 區塊保留稽核軌跡）。

## 一次量完（鐵律6）

## 1. ★headline thrash：字面「歸零」達成（同快照重複層級）
方法：seed1337 default.json 90天 `FORCE_FULL_HD=1`，post-fix(`1f5a8764`) vs pre-fix（**systems 授權的 file-level swap**：worktree 內 `git checkout main -- scripts/simulation/faction_ai_system.gd` 跑完立即 `git checkout HEAD --` 還原，已核 worktree 乾淨）：

| | 總flip印出 | 同快照重複(真thrash) |
|---|---|---|
| pre-fix | 57 | **22** |
| post-fix | 12 | **0** ✅ |

post-fix Team20 呈乾淨單調 8 階危機升級（days_left 3.0→2.7→2.3→1.8→1.4→1.0→0.6→0.0，零重複、零 `X→idle` 反彈）；pre-fix 同隊 55+ 行 `貿易↔idle` 在相同 days_left 反覆震盪——與原始 Team14 血證特徵完全吻合。**此為 qualitative/近似同世界對照**（swap 後下游 RNG 岔開，非嚴格逐 tick byte 對齊，spec 本身承認此限制），但模式差異無歧義。

## 2. ★Fix B tap-gap：完全解決
`decision_count=331`，`.specimen.jsonl` 331 行，兩者相符（archive 跨 flush 不遺漏）。先前 LOD-mode 的「換 specimen id 即換世界」confound 已被工具（specimen 非侵入化）修復——此為 measurer 上輪回報後 systems 當場 root-cause 並修復的成果。

## 3. ★`.specimen.jsonl` 已產出
`docs/measurements/2026-07-14-execlock-seed1337-specimen.jsonl`（Team20，331 entries，逐決策想法/狀態/資源時序）。

**⚠️ caveat 給 QA**：Team20 **存活至第90天**，本世界(seed1337 default.json 全-HD)找不到明顯因thrash而死的子隊——找到的唯一清晰thrash型是 Team20，它的故事是「反覆瀕餓8次、每次真的掙扎(移動買糧/掠奪)後恢復」，非死亡悲劇。QA 原框「合法悲劇(死) or 不連貫新死法」不完全適用——**若 QA 堅持要死隊 specimen，需另指定 team_id 重跑**（本輪未做，範圍：主要任務 decision_count>0+jsonl非空皆已達成）。

## 4. 不回歸閘：全綠（0234153e，工具merge後複驗）
- **determinism**：★獨立雙跑（不同進程、各自 jsonl 輸出）SHA256 逐位元組相同（`D241633B...78354D` == `D241633B...78354D`）。
- **憲法閘**：PASS sites=29 removed=0。
- **sanity headless_test**：與所有先前跑一致的 2 FAIL+3 SCRIPT ERROR（pre-existing），觀測工具merge零新增回歸。

## 5. 未動：warring 3-seed（LOD mode，本輪範圍外）
上輪 seed1337 attrition 惡化 +4.5pp 的旗標**維持原判、未在 full-HD 下重跑**（本次 dispatch 明確「主判故事性」+「平衡數字gen未重校前只當定性」，未要求 warring 重測）。待 blueprint 判是否雜訊帶內或需追查——見 `.measure.json` `lod_mode_pass_SUPERSEDED.warring_before_after.flag`。

## 待 blueprint / QA 裁
1. **QA 故事判官**：讀 `docs/measurements/2026-07-14-execlock-seed1337-specimen.jsonl`——Team20 的「反覆瀕餓掙扎後恢復」是否構成合格故事？或需另跑死隊 specimen？
2. **blueprint**：headline「thrash歸零」在全-HD下已字面達成，release 判準可否收斂？
3. **blueprint**：seed1337 warring attrition +4.5pp（LOD mode，上輪旗標）仍待裁——本輪未重測，維持待決。

---
measured_at_head: 1f5a8764（branch，全-HD story acceptance）
