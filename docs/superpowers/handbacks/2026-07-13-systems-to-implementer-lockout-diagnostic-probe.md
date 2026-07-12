---
from: systems
to: implementer
status: open
topic: [診斷probe·裁A] per-option applicable-but-not-chosen 三類分流探針(coeff/主層urg/util gap)→交measurer分類
---

# 診斷 probe：9-zero option 三類分流（裁 A，先分類再定藥）

藍圖裁 A：不動 S3，先加診斷 probe 分類 9-zero（真 coeff-lockout / base-util 競爭 / applicable 稀有），measurer 跑分類後對症。**純觀測、零行為變、不 tune**。

## 加什麼（`decision_engine.gd` rank_scored_ctx，`Probe.enabled` gate）
rank_scored_ctx 排序後，對**每個 applicable 但非 rank[0]（沒選中）的 option**，記 4 訊號（key 後綴用 option 中文名，比照現有 opt_dist）：
```gdscript
# 診斷(裁A):zero-option 三類分流。排序後、回傳前。
if Probe.enabled and ctx.need_urgency.size() == NeedHierarchy.N_LAYERS and scored.size() > 0:
    var winner: Dictionary = scored[0]
    for e in scored:
        if e["opt"] == winner["opt"]: continue
        var opt: String = e["opt"]
        var cf: float = NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
        var ml: int = NeedHierarchy.main_layer_of(opt)   # 見下,加 helper
        Probe.bump("diag.%s.appl_n" % opt)                                  # 分母:applicable-but-lost 次數
        Probe.add_amount("diag.%s.coeff_sum" % opt, cf)                     # 平均 coeff
        if cf < 0.5: Probe.bump("diag.%s.coeff_pressed" % opt)             # coeff-lockout 候選
        Probe.add_amount("diag.%s.mainurg_sum" % opt, ctx.need_urgency[ml] if ml >= 0 else 0.0)  # 主層 urgency
        Probe.add_amount("diag.%s.ownutil_sum" % opt, float(e["u"]))       # 自己 util(post-coeff)
        Probe.add_amount("diag.%s.winutil_sum" % opt, float(winner["u"]))  # winner util
```

加 helper（`need_hierarchy.gd`，純觀測；S3 亦會用，先放無妨）：
```gdscript
# option 主 affinity 層(argmax)。空/未知→-1。純 lookup。
static func main_layer_of(opt: String) -> int:
    if opt == "": return -1
    var aff: Array = affinity_of(opt)
    var best: int = 0
    for i in range(1, N_LAYERS):
        if float(aff[i]) > float(aff[best]): best = i
    return best
```

## 硬約束
- **純觀測零行為變**：不改 scored/rank，只讀。determinism 不動。
- `Probe.enabled` gate（perf）。中文 key 後綴 OK（比照 opt_dist）。
- **不 tune affinity/coeff**（藍圖明令先分類）。
- 只加此診斷；S3 不做（排程不動）。

## 回報 → measurer
probe 加完 + headless 無新 error → handback to:measurer，請 full_probe 跑（比照上批 per-option 的 seed/時長），dump `diag.*`，**按三類分流**（每 zero-option）：
- **applicable 稀有**：`diag.<opt>.appl_n` 相對總 cadence 極低 → gate 稀有(可能合理,非缺陷)。
- **真 coeff-lockout**：`coeff_sum/appl_n` 平均 <0.5 **且** `mainurg_sum/appl_n` 平均 >0.6（主層高急迫卻被壓）→ 鬆綁(S3)對症。
- **base-util 競爭**：`coeff_sum/appl_n` 高(~>0.7) **且** `winutil_sum/appl_n` ≫ `ownutil_sum/appl_n`（coeff 沒壓、純輸 base util）→ affinity/base 權重待 tune。
- 順帶：TC7 貿易獨大歸哪類（base-util vs coeff）。

分類結果 → to:blueprint（裁下一步：稀有=記錄 / base-util=帶數據 tune / lockout=排 S3）。守：純觀測、不 pre-tune、不問 user。
