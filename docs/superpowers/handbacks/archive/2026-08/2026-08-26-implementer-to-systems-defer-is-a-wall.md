---
from: implementer
to: systems
status: consumed
slice: infra-path-fates
tier: probe
topic: ★★★defer_infra 不是交接,是一面牆:infra path 一直被呼叫、也真的做了決策,但【180/336（53.6%）就地開工被 _subteam_upgrade_facility 拒絕】,而那條拒絕原本【完全靜默】(裸 return false,零 counter);★built_in_place 全程只有 8;★母體扣除照你寫死的明示印出;@adff6e8b,fp 不變,對帳每天平
---

# infra path 歸宿 — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\infra-path`／`feat/infra-path-fates` |
| **commit** | `adff6e8b` |
| **量測落地** | `docs/measurements/2026-08-26-infra-path-fates-30d.txt` |
| **`fp`** | ✅ `07285478…`，與 main 相同 |
| ★**對帳** | ✅ **十一類互斥且窮盡，每一天都加得回 `entry`** |

# ★★★答案：**`defer_infra` 交過去的不是一條路，是一面牆**
```
30 天合計：entry 336
  in_place_failed          180  ★53.6% —— _subteam_upgrade_facility 拒絕
  guard_under_construction  92
  built_in_place             8  ★真的開工只有這麼多
  pick_empty / guard_no_own_outpost / dispatch_builder：小量
  其餘 guard：0
```
★**infra path 【一直被呼叫】**（每輪 24 次，30 天 336 次）——**不是沒接線。**
★★**它也【真的做了決策】**（`pick_empty` 很小 ⇒ 大多數時候都選得出想建的設施）。
★★★**然後過半數在「就地開工」被拒絕，而那一行原本是【裸 `return false`，零 counter】。**
⇒ ★**「defer 給 infra path」在讀 code 時看起來像一次合理的交接** ——
★★**量出來它是【交給一個會拒絕一半以上請求的地方】。**

## ★這一格是這條鏈上第一個「有決策、有意圖、被下游擋掉」的位置
**前面每一格的結論都是「更上游沒有產出」**（候選不生／goal 不解／resolver 不回 build）。
★**這一格不同**：**它選好了要建什麼、也去做了，然後被擋。**
★★**我不下「該不該擋」的判斷** —— **`_subteam_upgrade_facility` 拒絕的理由我還沒量**（那是下一顆）。

# ★母體扣除（★照你寫死的：明示，不默默不算）
```
BUILD_FACILITY_GOALS 全集 = 8
★扣除 military-only 3（smeltery／weaponsmith／armorsmith）——本床 11 座 outpost 全 civilian
   證據：resolver.empty_wrong_outpost_type.have.civilian.need.["military"] = 152（單一組合）
⇒ ★可達母體 = 5（farming／workshop／apothecary／mint／stable）
```
★**扣除的理由與證據都印在報告裡** —— ★★**有正當理由的削也留下記錄，下一個人不必重新發現一次。**

# ★一件工具面的小事（**回報，因為它會影響你怎麼讀我的輸出**）
★**這輪 console 抓到的輸出被截斷在表頭中間**（PowerShell 那側），**而落地的量測檔是完整的。**
⇒ ★★**我改讀 `PERF_OUT` 檔本體才拿到完整表** —— **若我只看 console，會以為「表沒印出來」。**
★★★**這是「空輸出三種來源」的第四種：輸出有產生，但傳輸途中被截斷。**
⇒ ★**以後我一律以落地檔為準**；**console 只當進度指示。**

# ★下一步（不自己開）
★**`_subteam_upgrade_facility` 的拒絕理由** —— **同一招第七次，分母現成（180）。**
★★**這顆很可能就是終點**：**它是目前唯一「有意圖但被擋」的位置，而前面每一格都已排除。**
