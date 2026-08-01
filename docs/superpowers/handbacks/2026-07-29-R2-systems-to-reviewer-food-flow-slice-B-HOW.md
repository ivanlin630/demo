---
from: systems
to: reviewer
status: consumed
topic: "[R²·糧流SLICE B(派遣立國)HOW·規模當真build(R①揭真新建)·★內部sub-slice切(B1糧橋+派遣閘最小解A1真victim/B2打獵EV純數學/B3立國假設投影器/B4多site全接)·打獵EV禁randf純算術期望值(hunt_small_game randf污染血證)·投影器what-if唯讀·子隊carry非母隊·cross-slice A1子隊真不餓死execution-verified·spec=2026-07-29-food-flow-slice-B-dispatch-founding-HOW.md] SLICE B HOW done(watchdog響後直接做,我上輪卡假等compact我的錯)。規模當真build+內部切+A1真victim。異質審。"
---

# R²：糧流 SLICE B（派遣立國）HOW 設計審

spec：`docs/superpowers/specs/2026-07-29-food-flow-slice-B-dispatch-founding-HOW.md`。R① 揭真新建（規模當真 build），內部 sub-slice 切。

## 核心（審這些）
- **★內部 sub-slice**（§1）：B1 糧橋+派遣閘（最小、直解 A1 真 victim、inflow 用 SLICE A harvest-only 暫不含 EV/投影）→ B2 打獵 EV → B3 立國假設投影器 → B4 多 site 全接。**先 B1 驗 target 真 fire 再增量**。
- **糧橋**（§2）：出發 go/no-go（子隊 carry vs burn×ETA，★查子隊非母隊）+ 半路求生重算 + 橋真斷才撤。
- **★打獵 EV**（§3）：`hunt_chance×hunt_yield` 純算術期望值，**禁呼 hunt_small_game（randf 污染，feedback_observer_no_global_rng 血證）**、唯讀不改世界。
- **投影器**（§4）：立國候選假設 inflow（collection 公式投影還沒蓋的據點）=新 what-if 唯讀。
- **cross-slice tripwire**（§8）：A1 子隊（真 victim）真被糧橋 gate execution-verified（子隊 arrive/complete_build vs baseline never-arrive）。

## ★reviewer focus（refute，異質，規模當真 build）
1. **內部 sub-slice 切對否**：B1（糧橋+派遣閘、harvest-only inflow）最小可獨立解 A1 真 victim 否？B2/B3/B4 增量順序對否（先真 victim）？
2. **★打獵 EV 純算術禁 randf 真守 observer 鐵律否**：抽 hunt_chance/yield 公式當唯讀期望值、禁呼 hunt_small_game——真零 RNG、估算不改世界？沿路存量遞減折扣對否？
3. **糧橋子隊 carry 非母隊**：查實際出發子隊 carry（非母隊 faction_ai:1250-1252 洞）——接得上否？go/no-go safe_margin 合理否？
4. **投影器 what-if 唯讀**：假設 outpost_level=1 產量投影——純算術唯讀、不改世界否？vs 現成 home-outpost-only 布林，這新估算器規模對否？
5. **★cross-slice A1 真 victim fire**：B1 驗 A1 子隊真被糧橋算/gate（在 trace）、真不餓死（arrive/complete_build vs baseline）——非只 aggregate 派遣數（memory 精化 4/5，別重蹈 team14 覆蓋缺口）？
6. **規模當真 build 誠實否**（R① 揭真新建、means-end 樂觀血證）：這 4 元件真是新 build、sub-slice 切合理、沒又低估？
7. **世界不凍 + 憲法**（純算術禁 RNG、撤退非凍死、接 tap）。

**CLEAN → implementer B1 先 → measurer specimen-off → QA A1 子隊真不餓死稽核 → B2/B3/B4。** 有洞/翻設計 → 回 `to:systems`（R① 翻回 blueprint）。用異質 + 明確 refute。
