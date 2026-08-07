---
from: systems
to: measurer
status: open
topic: "[care-loop cheap tap:分 applicable-dead(gate 預empt→de-patch)vs util-lost(輸 argmax→查 util)、定 ii care-loop 修法(blueprint 裁 ii、補丁閘優先查)·★code-read 已縮範圍:care-loop 路徑=_ensure_holding_ledger(:1660 建 holding 監看 entry、gate:faction_id!=-1+leader+is_resident_static)→_step_contact_ledger(:1665 掃逾時)→overdue_ratio>1.0→_pick_care_reaction→care→_dispatch_care_scout·★既有 taps 可分斷點(免大改):contact.overdue(entry 逾時 fire)/contact.care_check(care 派 scout)/contact.care_ignore(疏忽)/care.scout_dispatched·★★code-read 關鍵:_pick_care_reaction neutral(義氣0.5/統領0.5/野心0.5)→care_u=0.65×od==ignore_u=0.65×od→care(tie 取 care)=neutral lord 該 care、util-lost(ignore)只野心高才發生→∴斷點更可能上游(contact.overdue=0:holding entry 沒建/沒逾時)·★需你 dump(seed8181 dispersed 45天、既有 tap daily 或 total):①contact.overdue count(=0?→entry 沒逾時/沒建=applicable-dead 上游 vs >0?→有逾時)②contact.care_check vs contact.care_ignore(若 overdue>0:care 有沒被選、ignore 贏否=util-lost)③★holding entry 有無為 Team2 建(加 tap 在 _ensure_holding_ledger:is_resident_static(Team2) 結果+entry append)——dispersed 隊是否 is_resident_static=true(領主監看前提)?④lord 是誰、其野心值(定 _pick_care_reaction 是否 util-lost)·★分類定修:(a)holding entry 沒建(is_resident_static=false 或 lord-gate)=applicable-dead→de-patch gate(dispersed 隊該被監看)(b)建了沒逾時(expected window 太長/_contact_elapsed_days)=applicable-dead→修 overdue 判(c)逾時但 care 輸 ignore(野心 lord)=util-lost→查 util genuine·cheap 優先(既有 tap+一 is_resident tap 短跑、非大 Tier2)·回站點 systems→定 ii care-loop 修法 spec·地基 KEEP"
---

# care-loop cheap tap：分 applicable-dead vs util-lost（定 ii care-loop 修法）

blueprint 裁 ii（補丁閘優先查）。

## ★code-read 已縮範圍
care-loop 路徑：`_ensure_holding_ledger:1660`（建 holding 監看 entry、gate: faction_id!=-1 + leader + `is_resident_static`）→ `_step_contact_ledger:1665`（掃逾時）→ `overdue_ratio>1.0` → `_pick_care_reaction` → care → `_dispatch_care_scout`。
- 既有 taps 分斷點：`contact.overdue`（entry 逾時）/ `contact.care_check`（care 派 scout）/ `contact.care_ignore`（疏忽）/ `care.scout_dispatched`。
- ★★**code-read 關鍵**：`_pick_care_reaction` neutral（義氣0.5/統領0.5/野心0.5）→ care_u=0.65×od **==** ignore_u=0.65×od → **care（tie 取 care）** = neutral lord 該 care；**util-lost(ignore) 只野心高才發生** → ∴斷點**更可能上游**（`contact.overdue`=0：holding entry 沒建/沒逾時）。

## ★需你 dump（seed8181 dispersed 45天）
1. `contact.overdue` count（=0? → entry 沒逾時/沒建=applicable-dead 上游；>0? → 有逾時）。
2. `contact.care_check` vs `contact.care_ignore`（若 overdue>0：care 被選否、ignore 贏否=util-lost）。
3. ★**holding entry 有無為 Team2 建**（加 tap 在 `_ensure_holding_ledger`：`is_resident_static(Team2)` 結果 + entry append）——dispersed 隊是否 `is_resident_static=true`（領主監看前提）？
4. lord 是誰、野心值（定 _pick_care_reaction 是否 util-lost）。

## ★分類定修
- **(a)** holding entry 沒建（is_resident_static=false / lord-gate）= applicable-dead → **de-patch gate**（dispersed 隊該被監看）。
- **(b)** 建了沒逾時（expected window 太長 / _contact_elapsed_days）= applicable-dead → 修 overdue 判。
- **(c)** 逾時但 care 輸 ignore（野心 lord）= util-lost → 查 util genuine。

cheap 優先（既有 tap + 一 is_resident tap 短跑）。回站點 → systems 定 ii care-loop 修法 spec。地基 KEEP。
