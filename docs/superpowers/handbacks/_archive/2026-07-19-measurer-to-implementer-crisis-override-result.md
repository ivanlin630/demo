---
from: measurer
to: implementer
status: consumed
topic: "[crisis-override量完·HIGH·機制真fire但seed1337 starve不降反升·疑release-then-recommit] 快閘全過(char bed 7/7+gate 64+headless 6/6=baseline)。organic：crisis.override_release確認真fire(133/64/3跨3seed非死碼)，seed42/4201維持健康(0隊starve)，但★seed1337 extinct.starve不降反升(6→8,19.14%→20.05%attrition)。specimen層(seed1337 8mo lockpoint)給解釋：flee故事質量大幅改善(5/6候選coherent,對比修前team75『29天完全凍結』broken模式大幅進步)，但殘留2-3個案例(『等待新領主』defection狀態team1/19+task=逃跑的team13)全程零task transition仍餓死——懷疑release-then-instant-recommit(release後同cadence立刻被其他子系統重派回同task,bed逐tick取樣看不到中間瞬態IDLE)。54%逃跑真vs broken量化(小樣本n=6僅供方向)：83%coherent/17%broken。"
---

# crisis-override 量完（HIGH，機制真 fire 但 seed1337 starve 不降反升）

依 `2026-07-19-implementer-to-measurer-crisis-override-done.md`（branch `e77aa99b`，HIGH：先於 god-view D-後 doom-delta 讀）。

## 快閘：全過

char bed 7/7、gate PASS(64,removed=0)、headless comprehensive 6/6=baseline(0 new)。

## organic 3-seed×8mo vs d0ab7f91（pre-fix）

| seed | extinct.starve | attrition_pct | crisis.override_release |
|---|---|---|---|
| 1337 | **8**(was 6) | 20.05%(was 19.14%) | 133 |
| 42 | 0(was 0) | 5.09%(was 2.08%) | 64 |
| 4201 | 0(was 0) | 2.91%(was 2.62%) | 3 |

`crisis.override_release` **確認真 fire**（133/64/3，非死碼）。但 **seed1337 extinct.starve 不降反升（6→8）**——這跟「5 種 stuck-task 不再卡餓死」的預期不符，需要你查。

## ★specimen 層（seed1337 8mo lockpoint）：給部分解釋

跑擴充版 `starvation_lockpoint_trace_bed.gd`（含 task=逃跑 觸發 + stall_exclude fire 偵測），對 `e77aa99b` seed1337 全程追蹤。

**正面：flee 故事質量大幅改善**——6 隊 flee 候選裡 5 隊（team61/64/65/82/99）呈現 coherent 行為：持續移動、food_days 正常波動（因真實逃跑/覓食活動）、`flee_from` 持續刷新。跟修前（main-dir `a5495461`）team75 那種「29 天完全凍結不動、`flee_from` 全程 `(-1,-1)`、food 安然成長」的 broken 模式對比鮮明，明顯進步。

**疑慮：2-3 個殘留卡死案例，全程零 task transition**：

- **team1/team19**（`等待新領主`，defection 系統 path A）：famine 一路爬到 32.9-33.8 才死，**觀察窗內（300 筆快照）task 完全沒變過**。
- **team13**（`task=逃跑`，`reason=solo`）：`tile` 全程不動、`flee_from` 全程 `(-1,-1)`、`food_days=0.00` 全程，famine 爬到 33.3 死。

**假說（供你查證，非我定案）**：`crisis.override_release` 在 `_evaluate_threat` release 之後，若**同一 cadence 稍後**有其他子系統（defection 評估 / solo 決策路徑）判斷條件依舊成立，可能**立刻重新委派回同一個 task**——release→IDLE→（同 tick 內）重新 `等待新領主`/`逃跑`，我的 bed 逐 tick 取樣（每 tick 結束後才記一筆）**看不到中間那個瞬態 IDLE**，只看到「release 前後 task 一樣」的表象。若這個假說成立，可以解釋為何 extinct.starve 沒降——**crisis 確實在跑，但對這幾種 task 的 release 沒有真正生效（被立刻打回原狀）**。

## ★量化「54% 逃跑真vs broken」

樣本：seed1337 6 隊 `task=逃跑` 候選——**5/6（83%）coherent、1/6（17%）broken**（team13）。**樣本小（n=6，單 seed），非母體級精確統計，僅供方向參考**，跟修前對比 broken 比例明顯下降。

## 建議

如果 release-then-instant-recommit 假說成立，可能需要一個**短暫免疫窗**（release 後本 cadence/短時間內不可被同源子系統立刻重新委派回同一個 task），才能真正把這些殘留案例接住。

---
measured_at_head: `e77aa99b`（`.worktrees/crisis-override`）
raw_logs: `docs/measurements/2026-07-19-crisisoverride-*-e77aa99b.log`、`...-multiseed-e77aa99b.json`、`...-seed1337-lockpoint-e77aa99b-decoded.log`
measure.json: `docs/process/verdicts/crisis-override.measure.json`（`is_sim: true`）
