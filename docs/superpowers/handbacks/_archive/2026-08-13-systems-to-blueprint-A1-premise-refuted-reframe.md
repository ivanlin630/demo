---
from: systems
to: blueprint
status: consumed
topic: "[★A1 gate:面1 anti-crank 綠但面2 arc-目標紅——premise 被 measure refuted、arc direction 需你(+可能用戶)reframe·measurer 兩獨立測 branch=baseline 無差異:build_outpost baseline=10 branch=10(★非我ticket假設camp.fire=0)、佔據率6.60%→6.38%持平略降·root-cause=camp_drive 不是 bottleneck(舊flat1.0在有farmable靶時本就贏argmax、A1只改精確度/防crank非改會不會被選)·真bottleneck=①has_farmable_tile geography(多數團找不到鄰近可耕空地=_find_unowned_farmable_tile只掃鄰7格、無靶就false)②desperation門檻③argmax競爭·★誠實premise訂正:③audit『camp.fire=0』是指紮營-argmax-option、但outpost其實經establish_crude_camp(faction_ai求生founding action、非argmax option)形成→我把『camp_drive量級』當WHY紮營不夠=診斷gap(同資不抵債家族、measure又refute一premise)·★A1本身=correctness淨勝(面1極乾淨:富流浪100%不濫紮/瀕餓平原100%紮/低產地100%不crank/CAP精確bound、感知鐵律proximate、determinism byte-identical、零regression build10=10佔6.6→6.38持平)但arc-goal-neutral·★我建議(交你裁WHAT direction):(a)merge A1當correctness/anti-crank groundwork(無downside、camp valuation防crank本就該要、未來若camp路徑load-bearing則備好)(b)★arc reframe:占據率bottleneck在geography(找不到可耕靶)+founding-path(establish_crude_camp非argmax)+desperation門檻→A2/A3該redirect打真bottleneck非camp_drive·★問你:A1 merge當correctness OK嗎? A2/A3 target 要不要跟著 measurer root-cause 重定(可能要用戶知道arc premise partial-refute)?·evidence-only、我沒單裁·地基KEEP"
---

# ★A1 gate：面1 綠、面2 紅 — premise 被 measure refuted、arc reframe 交你

measurer 判：**面1（anti-crank 四象限）★★★綠**、**面2（arc 目標=紮營 fire/佔據率升）★★★紅**。這是 premise 被實測 refuted、arc direction 需你（+可能用戶）reframe。

## ★面2 紅的硬證據（branch=baseline 無差異）
- 大 realistic 世界：`build_outpost` **baseline=10 branch=10**（★**非我 ticket 假設的 camp.fire=0**）；佔據率 **6.60%→6.38%**（持平略降）。
- 零 faction/戰鬥 confound 的 6 隊 vagrant 專測床：`build_outpost` baseline=1 branch=1（同團同 day19 onset、逐位元一致）。

## ★root-cause（camp_drive 不是 bottleneck）
- 舊 flat 1.0 在**有 farmable 靶時本就贏 argmax** → A1 只改善「選中時的精確度/防 crank」、**非「會不會被選中」**。
- 真 bottleneck：①**has_farmable_tile geography**（多數團找不到鄰近可耕空地、`_find_unowned_farmable_tile` 只掃鄰 7 格、無靶=false）②desperation 門檻 ③argmax 競爭。**都不是 camp_drive 量級。**

## ★誠實 premise 訂正
③ audit 說「`camp.fire=0`」是指**紮營-argmax-option**、但 outpost 其實經 **`establish_crude_camp`**（faction_ai 求生 founding action、非 argmax option）形成 → 我把「camp_drive 量級」當 WHY 紮營不夠 = **診斷 gap**（同資不抵債家族、measure 又 refute 一 premise、守 measure-first）。

## ★A1 本身 = correctness 淨勝（但 arc-goal-neutral）
面1 極乾淨：富流浪 100% 不濫紮 / 瀕餓平原 100% 紮 / 低產地 100% 不 crank / CAP 精確 bound；感知鐵律 proximate；determinism byte-identical；**零 regression**（build 10=10、佔 6.6→6.38 持平）。= 防 crank groundwork done、但不提升佔據率。

## ★我建議（交你裁 WHAT direction、我沒單裁）
- **(a) merge A1 當 correctness/anti-crank groundwork**：無 downside（camp valuation 防 crank 本就該要、未來 camp 路徑若 load-bearing 則備好）。
- **(b) ★arc reframe**：佔據率 bottleneck 在 **geography（找不到可耕靶）+ founding-path（`establish_crude_camp` 非 argmax option）+ desperation 門檻** → **A2/A3 該 redirect 打真 bottleneck**、非 camp_drive。

## ★問你
1. A1 merge 當 correctness OK 嗎？
2. A2/A3 target 要不要跟 measurer root-cause 重定（可能要**讓用戶知道 arc premise partial-refute**、他核可的 arc 方向有調整）？

evidence-only、我沒單裁 merge/reject。地基 KEEP。
