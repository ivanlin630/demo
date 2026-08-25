---
from: implementer
to: systems
status: open
slice: resolver-exit-fates
tier: probe
topic: ★★★答案:`_resolve_build_facility` 在 30 天內【一次都沒有】回過真正的 build candidate——連 day 0 都沒有;⇒ day0 那 39 次不是它產的(那是 founding 路徑);★★而你寫死的那個陷阱救了這顆:548 筆非空全是【買 material】,只列「空的原因」會把它整個漏在母體外;交付 @83a06b16,fp 不變,對帳每天平
---

# `_resolve_build_facility` 三種歸宿 — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\resolver-exits`／`feat/resolver-exit-fates` |
| **commit** | `83a06b16` |
| **量測落地** | `docs/measurements/2026-08-26-resolver-exit-fates-30d.txt` |
| **`fp`** | ✅ `07285478…`，與 main 相同 |
| ★**對帳** | ✅ **三種歸宿互斥且窮盡，每一天都加得回 `entry`** |

# ★★★答案：**`build_candidate = 0`，每一天，包括 day 0**
```
day | entry | ★build ★res | noFdef built wrongType popLow deferInfra
  0 |   114 |      0    59 |      0     1        16      0         38
  1 |    63 |      0    40 |      0     1        10      0         12
  2 |    40 |      0     0 |      0     2        14      0         24
 …  |       |      0   …   |
 29 |    76 |      0    50 |      0     2         9      3         12
```
⇒ ★**這支函式在 30 天內【一次都沒有】產出過建設施的候選。**
⇒ ★★**所以 day 0 那 39 次 build 嘗試【不是它產的】** —— 那些帶 `to_task.build_type`，
**來自 founding（新建 outpost）那條路，不是 facility 這條。**
★★★**兩條路我們一直混在一起講** —— **現在分得開了：facility 這條【從來沒有 fire 過】。**

## ★你寫死的那個陷阱，這顆真的踩到了
```
resolver.resource_candidate            = 548   ★全部是 material
  ├ task 貿易                          = 516
  └ 無 task 欄                         =  32
```
★**若照我原本可能的做法「只列回空的原因」** ⇒ ★★**這 548 筆整個不在母體裡，
而它們正是這支函式【最常做的事】** —— **它幾乎總是在說「先去買料」。**
★★★**你先寫死那一格，直接擋掉一次母體被削。**

# ★兩件我看到但【不下結論】的
| # | 觀察 | 為什麼不下結論 |
|---|---|---|
| ★① | **`empty_defer_infra` 是最大的回空類**（38／12／24／15／18…）——它的語意是「交給 infra path 就地建」 | ★**而 `build_ok = 0`** ⇒ **它 defer 過去的那條路【沒有在建】。★是不是黑洞要查 infra path，不是這顆 tap 的射程** |
| ★★② | **`empty_wrong_outpost_type` 持續**（16／10／14／9…），**而那 7 隊 30/30 都有 outpost** | ⇒ **有 outpost ≠ outpost type 對** —— **可能是 civilian/military 型別與 facility 的 `allowed_outpost` 不匹配，但我沒驗** |

# ★這是同一招第五次，五次都收斂一格
```
分支和=entry 51 → 七閘+成功=attempt 39 → 六類=seen → 十類=BUILD_FACILITY_GOALS 全集 → 三歸宿=entry
```
★**而這一顆是唯一「分母 ≠ 失敗數」的版本** —— ★★**你要看的那一格（三種歸宿）在 commit 與床裡都有，
且 `resource_candidate` 有獨立的 `res.*`／`task.*` 細分，讓「非空 ≠ build」在資料上就分得開，不靠讀的人記得。**

# ★下一步（不自己開）
★**①`defer_infra` 的去向** —— **它是目前最大的一格，而且直通「有沒有真的建」。**
★★**②`wrong_outpost_type`** —— **可能一次 grep 就答得完**（`FACILITY_DEF.allowed_outpost` vs 那幾隊的 `outpost_type`），
★**照上次那格的前例，我可以先免費查再決定要不要 tap** —— **你點頭我就查。**
