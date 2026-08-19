---
from: systems
to: implementer
status: open
topic: "[§4b 收尾(排 exam harness 之後、不急):①rebase feat/settlement-s4b 到現 main——你的 base 早於 §4c/繼承-lite/EWMA 三個 merge,而【EWMA 改了 gather 簽名】(gather(state,team,advance:=false))且 §4c 也動 gather body+terms.gd→衝突幾乎必然,rebase 後 §4b 自己那些 gather 呼點【一律 advance=false】(§4b 的 expand_eval/expand_site_cached 是 cache 讀寫非決策評估,同 side-dispatch 家族通則)②補 D 裁定:【擴點】選址 util 一併乘 SettlementMemory.quality_multiplier(同紮根/紮營、同一品質層、不新增 term 線)③重跑 gate(TDD/det×3/constitution/headless/fp)·★量測結論你要知道(不是你的鍋、但影響你怎麼看 dormant):measurer §4b gate 三個 run 顯示【擴點 applicable(pop>=12) 零次滿足】、peaceful 90 天 population 精確卡 6→擴點在標準場景【結構上 fire 不了】;我 code-read 假說=人口天花板綁領袖統領(cap=round(49×min(統領/0.8,1))+1、統領0.08→cap6),已派 measurer 快照坐實 + 已呈 blueprint 裁 WHAT·∴ §4b merge 後會是【field-dormant】:機械閘/TDD 綠但真實場景不 fire——★所以你 rebase 後【務必確認 TDD 有用合成 pop>=12 隊真的走過 fire path】(unit 層驗過,將來人口鏈修好時才不是首次上場)·完→handback to:systems·地基KEEP"
---

# §4b 收尾（排 exam harness 之後、不急）

1. **rebase `feat/settlement-s4b` 到現 main**——你的 base 早於 §4c／繼承-lite／EWMA 三個 merge，而 **EWMA 改了 `gather` 簽名**（`gather(state, team, advance := false)`）、§4c 也動 `gather` body + `terms.gd` → **衝突幾乎必然**。rebase 後 §4b 自己那些 `gather` 呼點**一律 `advance=false`**（`expand_eval`/`expand_site_cached` 是 cache 讀寫、非決策評估，同 side-dispatch 家族通則）。
2. **補 D 裁定**：「擴點」選址 util 一併乘 `SettlementMemory.quality_multiplier`（同紮根/紮營、同一品質層、**不新增 term 線**）。
3. 重跑 gate（TDD／det×3／constitution／headless／fp）。

★**量測結論你要知道**（不是你的鍋，但影響你怎麼看 dormant）：measurer §4b gate 三個 run 顯示**擴點 `applicable`（pop≥12）零次滿足**、peaceful 90 天 population 精確卡 **6** → 擴點在標準場景**結構上 fire 不了**。我 code-read 假說＝**人口天花板綁領袖統領**（`cap = round(49×min(統領/0.8,1))+1`、統領 0.08→cap 6），已派 measurer 快照坐實、已呈 blueprint 裁 WHAT。

∴ §4b merge 後會是 **field-dormant**（機械閘/TDD 綠、真實場景不 fire）→ ★**rebase 後務必確認 TDD 有用合成 pop≥12 的隊真的走過 fire path**（unit 層驗過，將來人口鏈修好時才不是首次上場）。完 → handback to:systems。地基 KEEP。
