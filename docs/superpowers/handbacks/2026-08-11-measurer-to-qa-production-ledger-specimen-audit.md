---
from: measurer
to: qa
status: consumed
topic: "[re-measure scale v2生產淨值帳specimen故事稽核請求(長跑+specimen硬規則)——★主稽核標的=為何manufacture.fired全程=0(4個月零產出)+labor_pool從month1到month2為何急遽崩潰(concentrated9→2,dispersed5→1)且從未回補]聚合層讀到:兩scenario在4個月內完全零manufacturing產出,labor_pool都在month1後急遽崩潰。★需你逐tick讀specimen驗證:①team0(lord)逐月的候選集裡有沒有評估過生產/建設相關選項,還是被別的優先序(威脅回應/求援/叛離)完全佔據②labor_pool驟降是否對應某個具體事件(anon池被population-overflow spinoff搬空/團隊tag變化/團隊實際離開該tile)③manufacture noop卡在哪個原因(no_outpost/no_worker/no_facility/no_material)。"
---

# re-measure scale v2 生產淨值帳 specimen 故事稽核請求

依 §長跑必附 specimen 規則，已回 systems 聚合結論（`2026-08-11-measurer-to-systems-production-ledger-verdict.md`），這裡單獨請你稽核 specimen 故事，因果結論待你驗證才鎖。

## 我的聚合層判讀（非故事驗證，供你對照）

seed8181，concentrated_fair 跟 dispersed 兩個 scenario，4 個月內 `manufacture.fired` 全程 0（完全零產出），`LaborSystem.pool_of`（team0 所在 tile 的勞力池）都在 month1 後急遽崩潰：concentrated 9→2、dispersed 5→1，且此後 4 個月從未回補。

## ★待你稽核

1. **team0（lord）逐月的候選集裡有沒有評估過生產/建設相關選項**，還是被別的優先序（威脅回應/求援/叛離，我這個 arc 前幾輪反覆撞到的模式）完全佔據，manufacturing 根本沒進入決策視野？
2. **labor_pool 驟降**（month1→2）**是否對應某個具體可辨識的事件**——是 anon 池被 population-overflow spin-off 搬空（同前幾輪找到的機制）、還是團隊 tag 變化（例如失去 `生產` tag）、還是團隊成員實際離開了那個 tile？
3. `manufacture.noop_no_outpost`/`no_worker`/`no_facility`/`no_material` 這幾個既有 tap，哪個在 fire——卡在哪一關？

## 落地檔案（已 git commit `f287cc71`）

- `docs/measurements/2026-08-11-scale-econ-production-ledger-seed8181-CONCENTRATED_fair.specimen.jsonl`（2218 entries）
- `docs/measurements/2026-08-11-scale-econ-production-ledger-seed8181-DISPERSED.specimen.jsonl`（2396 entries）

## 序

你讀完給故事稽核 verdict 後，我會把 verdict ref 併入回 systems 的報告，別搶你的因果判定。
