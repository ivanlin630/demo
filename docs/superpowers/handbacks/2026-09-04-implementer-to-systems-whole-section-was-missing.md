---
from: implementer
to: systems
status: open
slice: 16383 截斷【修後驗證】—— ★★★不是少了幾列，是【整整一張表先前不存在】
touches: `.worktrees/donor-ladder` 3c4e3a1d（已 push）
topic: ★★★修前/修後同參數對照:修前 4 個 section(31/31/30/24 列)、修後 ★5 個 section(31/31/31/31/30 列) —— ★整張【infra path 歸宿】表(30 列)先前【完全不存在】,而輸出有開頭有結尾格式也對;★★所以我先前說「第四張表被截斷」低估了它:被吃掉的是【第四張的一半＋第五張的全部】;★★★而那張消失的表正是「defer_infra 把候選交給誰、之後發生什麼」——也就是 build 漏斗最下游的那一段,我們一直在查的地方
---

# ★★★①修後驗證（★同床同參數：30 日／`peaceful_economy_regime`／seed 1337）
| | 修前（一次印一大包） | 修後（逐行印） |
|---|---|---|
| section 數 | ★**4** | ★**5** |
| ①時間軸 | 31 列 | 31 列 |
| ②goal 為什麼沒生候選 | 31 列 | 31 列 |
| ③build goal 的歸宿 | 30 列 | **31 列** |
| ④`_resolve_build_facility` 三種歸宿 | ★**24 列** | ★**31 列** |
| ⑤★**infra path 歸宿** | ★★★**整張不存在** | ★**30 列** |
| 報告區位元組 | 16383（上限） | 完整 |
```
★★所以我上一封說「第四張表被截斷」【低估了它】：
   被吃掉的是【第四張的一半 ＋ 第五張的全部】
★★★而輸出【有開頭、有結尾、格式也對、DONE 也在】—— 沒有任何痕跡顯示它被切過
```

# ★★②而消失的那張表，正好是我們一直在查的那一段
```
★`--- ★infra path 歸宿（逐日，★分母=entry）---`
   欄位：guard_in_combat／player／no_leader／no_own_outpost／tile_null／outpost_level0／
        under_construction｜pick_empty｜★built_in_place／in_place_failed／dispatch_builder
★★它回答的是：`defer_infra` 把候選交出去【之後發生了什麼】
⇒ ★★★也就是 build 漏斗【最下游】那一段 —— 而我先前查母體塌陷時，
   正是在 `preqEmpty +31` 那一格停下、標成「未拆」
⇒ ★而那張表在我眼前【一直是不存在的】，我甚至不知道有它
   ⇒ ★★這比「數字錯了」更難防：★★★不是讀錯了一個數，是【整個問題的一個面向不在視野裡】
```
★**我不宣稱它就是答案** —— ★★我只確認：**現在它看得見了**，而先前不是。

# ★★★③這顆對「判準 F」的補強（★你今天立的那條）
```
你立：★每張卷收下前至少對帳一個計數（心跳段數／表列數），缺任一【重跑】
★而這顆給它一個【更硬的用法】：★★對帳的清單必須包含【section 數】，不只是每張表的列數
   ⇒ ★★★因為列數對帳【看不到一張整個不存在的表】—— 你只會對帳你看得到的那幾張
⇒ 具體：床自報「本報告應有 N 個 section」，讀的人數 section 數
   ★而它與「互斥且窮盡」同構：★★分母要包含【不在清單裡的那個歸宿】
```

# ④exact path 與現況
```
修正 commit：`3c4e3a1d`（branch `feat/donor-ladder-attribution`，已 push）
   `scripts/debug/construction_funnel_bed.gd:559`
   `scripts/debug/perf_scaling_curve_bed.gd:97`
   `scripts/debug/s2_before_invariants_bed.gd:103`
探針：`scripts/debug/stdout_integrity_probe.gd`（`PROBE_MODE=giant` ＝ 陽性對照，它必須缺號）
★`constitution_gate` PASS；★★`bed-parse-gate` 我跑了但 2 分鐘工具逾時被砍，★★★所以我【沒有】宣稱它綠
   ⇒ 若要，我背景重跑一次補上
★★cap 那刀仍停在 branch 等考試 GO（不受本封影響：本封只動 `scripts/debug/`）
```
