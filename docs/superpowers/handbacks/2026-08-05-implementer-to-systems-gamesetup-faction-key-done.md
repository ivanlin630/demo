---
from: implementer
to: systems
status: consumed
topic: "[GameSetup faction-key robust DONE·T3 根治·feat/info-network-whole commit 20a7d8ef]cfg_to_actual(config faction_id→actual sequential id)map、leader 接 create_faction 回傳存 map、非 leader 用 cfg_to_actual[fid2] 查 actual id。★faction map 修正確認(T0/T1=fac0、T2/T3=fac1=config 意圖)。驗:lord_bed 9/9+infonet 全綠+headless 0-new+gate PASS 74+determinism 9290F462 byte-identical(warring inert=驗不破他 bed 實證、只 infonet_whole 非 conforming 受影響)。★★誠實 flag:faction 結構修好但 T3 仍死 day41=非 faction(已修)而是 faction2 relief 鏈不 engage(T2 聞 0、T3 distress 無人聞):T3(proud 求生0.2)不 broadcast+T2(neglectful)不 scout→收不到。疑 intended 人格 emergent 對比 or 另一 gap→待 blueprint 判 arc-done(悲劇 T3)vs 進一步機制。未達 spec 驗收 T3 救活。請 R²→measurer re-measure(T1 confirm+T3 死歸因)+warring 2seed→QA/blueprint。"
branch: feat/info-network-whole
commit: 20a7d8ef
---

# GameSetup faction-key robust — DONE（T3 診斷根治、路 systems R²）

照 spec `2026-08-05-gamesetup-faction-key-robust-HOW.md`（R² CLEAN、blueprint 裁 (a)）build 完。

## 做了什麼（test-infra、只 `game_setup.gd`）
- 第二段 create factions：leader `var actual_fid = state.create_faction(int(t_cfg["id"]))`（接回傳的**實際 sequential id**）→ `cfg_to_actual[fid] = actual_fid`（config faction_id → actual map）。
- 第三段 非 leader：`if cfg_to_actual.has(fid2) and state.teams.has(tid): set_team_faction(state.teams[tid], cfg_to_actual[fid2])`（用 **actual id** 入正確 faction；查不到＝沿舊靜默不指派 factionless、非新失敗模式）。
- 掃全檔 config faction_id 用點（澄清①遵守）：`:603/612` god-view seed＝**config-only 自比較**（`fa==tb config faction_id`、不碰 `state.factions`/`team.faction_id`、同 config→同 actual 保證下正確）＝**安全不動**（硬改可能查未建 actual id 引新 bug）。`:298`（procedural 模式）/`:394`（player join）本已用 actual id、不動。
- **scope 硬守**：不碰 `world_state.create_faction`（engine）/ decision / faction_ai；constitution/感知鐵律不涉（faction 結構 setup 非決策讀值）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| ★faction map 修正 | **T0/T1=fac0、T2/T3=fac1**（tap 確認＝config 意圖；前 T1→T2 亂配 / T3 orphan 已治） |
| `lord_distribution_bed` | 9/9 |
| infonet 全 bed | letter 17 / sideaction 6（+ 前批綠） |
| headless | **0-new** |
| constitution_gate | **PASS sites=74 removed=0** |
| ★驗不破他 bed（條件①） | warring/default（無 explicit faction_id＝procedural 路）+ peaceful（全 -1）＝**change inert byte-neutral**；只 `infonet_whole`（非 conforming faction_id=1,2）受修正。**determinism 3-run MD5 `9290F462…` = 前批同值 = warring 實證 inert**（條件②） |

## ★★誠實 flag（別 overclaim、未達 spec 驗收「T3 也救活」）
faction-key **結構修好**（T2/T3 現真同 faction），**但 T3 仍死 day41**——**非 faction（已修）**，而是 **faction2 relief 鏈根本不 engage**：
- `diag.dist_heard`：**只 T0 聞買單（84×）、T2 聞 0、T3 distress 無人聞**。
- 因：**T3（proud、求生欲0.2、義氣0.3）疑不 broadcast distress**（求援 side mini-util 用 求生欲/義氣＝低→不派 herald）＋ **T2（neglectful、義氣0.4、統領0.2、野心0.8）不 scout 子民**（scout mini-util 用 統領/野心＝低統領+高野心 neglect→不主動探）→ **T2 收不到 T3 need → 不賑濟**。
- 對照：T0（responsible 義氣0.6）救 T1（pragmatic 求生欲0.9＝會求援）＝relief 全鏈通。
- ★**歸因待 blueprint 判**：這**極可能是 config 刻意設計的人格 emergent 對比**（config 名 `T_LORD2_neglectful`+`T_RESIDENT2_proud`＝就是要測「疏忽領主+傲氣子民→悲劇死」vs「責任領主+務實子民→獲救」）＝**arc-done with 悲劇 T3（好戲）**；**或** blueprint 認為機制該更主動（如 neglectful lord 仍該被動聞到、或 proud resident 絕境仍該求援）＝**進一步機制 follow-up**。**此為 WHAT 判斷、非我 implementer 定**。

## 路（下一站）
1. **你 R²**（審 config→actual map / 驗不破他 bed / determinism / scope=test-infra / 無殘留直用）。
2. CLEAN → **measurer re-measure 症1 端到端 on persist bed**：T1 救活 confirm（distribute/deliver/food_delivered 保持）+ **T3 死歸因**（tap T3 有無派 herald / T2 有無 scout / dist_heard T2=0 復現）。+ warring 2seed（faction 結構不變）。
3. → **blueprint 判**：T3 悲劇死＝intended 人格對比（arc-done）**vs** 需 proud-resident-絕境求援 / neglectful-lord-被動聞 follow-up。

★measure-first、只交真值（[[feedback_verify_execution_end]]＝驗執行真效果、T3 未真獲救誠實報；[[feedback_genuine_value_not_crank]]＝不為達「T3 救活」硬 crank 求援/scout util）。**HOLD-warm 待你 R² + blueprint T3 歸因裁定。**
