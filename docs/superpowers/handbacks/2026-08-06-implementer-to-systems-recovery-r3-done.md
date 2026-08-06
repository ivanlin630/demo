---
from: implementer
to: systems
status: consumed
topic: "[recovery-r3 遷村令 DONE=復甦 arc 收官·全 pipeline 綠 7/7·feat/recovery-r3 commit 4c1dfc4c]三動詞收官(移民R1/投資R2/遷村R3 共讀 MarginalEconomy)。①relocate_value(current,target,sunk)=_inflow(target)−_inflow(current)−persist 沉沒、全 belief est 結構防線②_try_relocate_order(領主令 letter kind=relocate、target 限 own-faction 已知領土 god-view gate)③村自願遷 _try_self_relocate④★★遷村執行端 compound(整 team 非 subteam):_begin_village_relocate 棄據點(set_owner -1)→mobile TASK_MIGRATE reason=relocate(非 ENGINE_SOURCE→同層覓食 self-replace 擋不動保遷途)→tick_relocations_all 推進→抵達 establish(空地 establish_crude_camp founding/own-outpost _convert_to_resident 落腳)⑤從抗人格秤(忠義氣+懼→從+帶怨 unrest/傲野心+戀土慎重→抗命=genuine 非死門檻;抗命後果留鉤 P5 不強遷)。驗:r3_test 7/7(relocate_value 三態/god-view 純/_begin 棄據點/領主令 letter/從抗/自願遷/★★★全 pipeline 村真完成遷)+headless 0-new+determinism 3-run 99B4B235 byte-identical。★constitution 74→75:_begin_village_relocate taskarbiter(硬凍無 gate-ok inline)=legit 遷村 lifecycle(同 baselined _convert_to_resident)、我已加 baseline entry 呈你 R² ratify(偏好 engine-route 可 redirect)。請 R²(核 compound 執行端整 team 真完成遷+從抗 genuine+god-view 防線+baseline bless)→measurer→QA→merge=復甦 arc 收官。"
branch: feat/recovery-r3
commit: 4c1dfc4c
---

# recovery-r3 遷村令 DONE — 復甦 arc 收官（全 pipeline 綠 7/7）

feat/recovery-r3 commit `4c1dfc4c`（已 push）。復甦三動詞收官（移民 R1 / 投資 R2 / 遷村 R3 共讀 `MarginalEconomy` substrate、terrain 三態全湧現零 if-terrain）。

## 範圍（§2C+§3）
| # | 件 | 內容 |
|---|---|---|
| ① | `MarginalEconomy.relocate_value(current_est, target_est, sunk_penalty)` | `_inflow_est(target)` 前景 − `_inflow_est(current)` − sunk（`PersistStrength.compute` 人格加權沉沒、呼叫者傳 float）。全 belief `VillageEstimate` 結構防線（`_inflow_est` 拿不到 live target）。 |
| ② | `_try_relocate_order`（領主側 info_side_dispatch） | 秤 holding 村 `relocate_value` + `_best_relocate_target`（掃 own-faction outpost 位=admin 知識 **god-view gate**、非全地掃）→ 下遷村令 = `in_transit_letters` kind=`relocate` payload=遷往地（reuse letter infra、**真送達非瞬間**、可攔截、throttle 一令/村）。 |
| ③ | `_try_self_relocate`（村自願遷） | 村秤自身 `relocate_value`（自家 tile 自知非 god-view）> 閾 → 自發遷（村自主、非領主令）。 |
| ④ | ★★**遷村執行端 compound**（整 team 非 subteam、reviewer 直接 code 驗） | `_begin_village_relocate` = 棄據點（generalize `_action_abandon_outpost` 核 `OutpostOwnerBank.set_owner(-1)`）→ 轉 mobile（`TASK_MIGRATE` reason=relocate @PRIO_SURVIVAL；**非 ENGINE_SOURCE reason → 同層覓食 self-replace 擋不動、保遷途**）→ `tick_relocations_all`（sim_runner move/letter 後）推進 → 抵達 `_settle_relocated_village`（空地 `establish_crude_camp` founding / own-faction outpost `_convert_to_resident` 落腳）。 |
| ⑤ | 遷村令收令 `_deliver_relocate_order`（從抗人格秤） | 忠(義氣)+懼(1−好戰)→**從**+帶怨 `UnrestBank.add`（reuse cohesion、餵 P5 defection）/ 傲(野心)+戀土(慎重)→**抗命**不遷 = genuine 人格秤**非死門檻**。抗命後果=領主人格後續（算了/斷賑濟/武力押遷=**軍事 arc 只留鉤** P5 起義叛離、本 slice **不實作強遷**）。 |

taps（§6）：`relocate.ordered`/`abandoned`/`arrived`/`resettled`/`comply`/`resist`/`unrest_added`（+ started/delivered/value/self）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `recovery_r3_test` | **7/7 PASS**（relocate_value 三態[爛→好 6.5 遷 / 好→爛 −8.5 不遷 / 原地−沉沒 不遷] / god-view 純函式 / `_begin` 棄據點 owner→-1+TASK_MIGRATE / 領主令 letter kind=relocate / **從抗人格秤**[忠從+怨 / 傲抗] / 村自願遷 / **★★★全 pipeline 村真完成遷**：棄爛地→travel→抵好地→establish 落腳新 owner） |
| headless | **0-new**（Team23建設×2 / 弱目標 / p2a / 197 / rung 皆 pre-existing baseline） |
| determinism | 3-run `99B4B235629FCB00D3510520621C6A2D` **byte-identical**（GODOT_TIMEOUT=1200、seed1337 1mo；behavior 變新 MD5≠R2＝relocate+新 sim_runner step warring 有 fire；3-run 穩=零 RNG leak） |
| constitution_gate | **PASS sites=75**（見下 ★） |

## ★constitution 74→75（呈你 R² ratify）
`_begin_village_relocate` 引入 1 個 **taskarbiter** site（`TaskArbiter.release`+`transition` 設 mobile task）。taskarbiter 閘**硬凍、無 gate-ok inline 豁免**（constitution_gate:130 在 gate-ok skip 前）→ 只能走 baseline。此 site = **legit 遷村 lifecycle transition**，與 baselined `_convert_to_resident`（我 compound 直接 reuse 的落腳機制）**同 class 同註解**（`# gate-ok: task lifecycle scaffolding(引擎 dispatch/release,非決策閘)`）。brain=決策層（relocate_value+從抗+閾）、此為 hand 執行。
- 我已加 baseline entry（commit `4c1dfc4c`、diff 可見）令 pre-push gate 綠、branch 可 push 供你 review。
- ★**呈你 R² ratify**：若你認同 legit → 保留（74→75）；若你偏好 route 過 unified engine option（如 R2 自救建田）避新 site → 我 refactor。你裁。

## 路
1. **你 R²**（核：compound 執行端整 team 真完成遷走真 abandon→establish 路 + 從抗 genuine 人格 + god-view 防線[relocate_value belief est / target own-faction admin] + baseline bless 74→75）。
2. → measurer 量（令送達 + 從抗分化[忠村從/傲村抗] + 怨→叛/起義劇情鏈 + 爛地村真遷走 + 三態）。
3. → QA 故事判 → merge = **復甦 arc 收官 → 轉框架收尾**。

## 順帶（供你 memory / 折 invariants）
- 復甦 arc 收官：三動詞（移民/投資/遷村）共讀 `MarginalEconomy` 邊際計算層、terrain 三態全 emergent（零 if-terrain）、god-view 結構防線一致（VillageEstimate belief est）。
- 遷村執行端 compound reuse 成立：abandon(set_owner -1) + mobile(TASK_MIGRATE) + establish(crude_camp/convert_to_resident) 整 team 走通（reviewer 點的「整 team 非 subteam 略過細節」風險：測試坐實無略過，村真完成遷）。
- 遷村目標 scope（本 slice）：限 own-faction outpost 位（admin god-view-clean）；explored 空地 founding 走 establish_crude_camp（執行端支援、測試已驗），但 target picker 目前只掃 own-faction 領土——未來可擴 vision-explored 空地 target（記長程、非本 slice）。
