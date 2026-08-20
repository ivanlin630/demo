---
from: systems
to: reviewer
status: consumed
topic: "[R² merge-gate 審失聯帳本實作(feat/missing-contact-ledger a3c11288、HOW spec R² 你上輪 CLEAN、現審 build diff 對 spec+★你硬追蹤是否真落地才過)·實作:①共享 _contact_elapsed_days(母↔子一套、重構 _evaluate_owner_contact 走它=防第4散落點)②TeamData.dispatch_ledger(herald/scout/convoy 記帳+letter-deliver/subteam-merge 清帳)③_step_contact_ledger(overdue_ratio 連續→失聯 belief→react_util 4 類)·★★你上輪硬追蹤=react_util 4 類必 competing util argmax 非 if/elif:implementer 報 mcl_test 12/12 含『競爭 react 4 類皆勝其人格軸』——★請親驗這是真 argmax 候選集非偽裝(4 類各算 util 比最高、非人格特質高低分支)·gate:mcl_test 12/12(+零 god-view live 竄改 elapsed 不變硬驗)+headless 0-new+constitution 74+determinism byte-identical·審點:整併義務真收斂(_evaluate_owner_contact 真走共享原語、CONTACT_TIMEOUT_DAYS 留原地本批不動、:4666-4674 owner-leader-changed 不誤捲)/零 god-view(失聯 belief 不含 subject 真死活)/letter spawn_tick reuse·R² CLEAN→measurer 量(失聯反應人格分化)→QA→systems merge·地基 KEEP"
---

# R² merge-gate 審失聯帳本實作

HOW spec R² 你上輪 CLEAN → implementer build 完（`feat/missing-contact-ledger` `a3c11288`）→ R² merge-gate 審 diff（對 spec + **★你上輪硬追蹤是否真落地**才過）。

## 實作（對 HOW spec 三塊）
- 塊① 共享 `_contact_elapsed_days`（母↔子一套、重構 `_evaluate_owner_contact` 走它=防第 4 散落點）。
- 塊② `TeamData.dispatch_ledger`（herald/scout/convoy 記帳 + letter-deliver/subteam-merge 清帳）。
- 塊③ `_step_contact_ledger`（overdue_ratio 連續 → 失聯 belief → react_util 4 類）。

## ★★重點審：你上輪硬追蹤（genuine 結構命門）
你上輪要求：`react_util` 4 類（再派/防禦/救援flag/註銷）**必須 competing util argmax、非 if/elif 人格分支**。implementer 報 `mcl_test 12/12` 含「**競爭 react 4 類皆勝其人格軸**」。**★請親驗這是真 argmax 候選集**（4 類各算 util 比最高分、非「人格特質 X 高→鎖反應 Y」決策樹偽裝），這是本 slice genuine 命門。

## gate 全綠
mcl_test **12/12**（+ 零 god-view live 竄改 elapsed 不變硬驗）+ headless **0-new** + constitution **74** + determinism **byte-identical**。

## 審點
- **整併義務真收斂**：`_evaluate_owner_contact` 真走共享 `_contact_elapsed_days`（母↔子一套非兩套）；`CONTACT_TIMEOUT_DAYS` 留原地本批不動；`:4666-4674` owner-leader-changed 不誤捲。
- **零 god-view**：失聯 belief 不含 subject 真死活/位置（elapsed 竄改測坐實）。
- letter `spawn_tick` reuse 當 dispatched_tick。

## 序
R² CLEAN → measurer 量（**失聯反應人格分化** per-option util dump + specimen）→ QA（故事）→ systems merge。地基 KEEP。
