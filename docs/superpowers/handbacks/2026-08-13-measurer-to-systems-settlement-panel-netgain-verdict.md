---
from: measurer
to: systems
status: consumed
topic: "[安家福祉面板+netgain真值CLOSE]★granary餘額全月=0.0(9居民全數、含team47,非取整/是精確浮點0——安家未提供任何糧倉緩衝,故事全在team_food私產層);residency-onset全在day23-30(月後1/3才有resident,前22天確認0);月底food-security-days:僅team47(3.3天)、team45(1.69天,僅1天樣本)有緩衝,其餘7團全≤0.75天/6團=精確0;真值harvest_vault+hunt逐團sum(非回推)證team30/58/70/83/109/111六團真實採集量遠低於飯量=genuine慢性餓(famine_days正累積,非net_gain公式回音假象);team45非missing——它income全走hunt非harvest_vault(Σ38.21/3事件);對照組wanderer 444→400人(-9.9%)、僅day30出現1筆starve_delta、food_days雖降仍達16.1(遠高於多數resident的0)——安家=餓不死目前僅team47證實,其餘8團證據指向仍precarious甚至比流浪更差"
---

# 安家福祉面板 + netgain 真值驗證 —— 兩票合併回報

兩張票（settlement-treatment-panel + netgain-artifact）用同一輪 fixture 一次答完（seed1337、1月窗、`GODOT_TIMEOUT=6000`、官方 `SpecimenDumpHelper`，未手動改 `specimen_team_ids`）。先講最重要的一個意外發現，兩票的答案都繞著它轉。

## ★★★ 意外發現：9 居民「自家糧倉」全月餘額 = 0.0（精確值，非取整）

`resident_detail.granary_food`（讀 `ResourceSystem.own_granary_tile(state,t).public_storage.food`，`_granary!=null` 才進 resident_detail 且此欄非 -1.0 sentinel）——**逐團逐日檢查 raw JSON（非文字報表四捨五入），9 個居民團、全部 30 天窗內出現的所有 team-day，granary_food 精確等於 `0.0`，一筆例外都沒有，連唯一「thriving」的 team47 也不例外。**

同時 `income.harvest_vault` 真值 tap（`resource_system.gd:295`，deposit 進的正是 `dst_tile = team.tile_pos` 對應 tile，deposit 只在 `dst_tile.outpost_level>0` 時走這條路，且該路徑跟 `own_granary_tile()` 用的是同一個 `outpost_owner==team.team_id` 判斷式邏輯上該是同一塊地）**確實記到真實正數 deposit**（team47 10 筆 Σ40.99、team30 21 筆 Σ5.65…）。換句話說：**糧倉有真實進帳，但每天普查時點餘額永遠是 0**——糧倉在這個月的運作更像「流水帳過路口」而非「儲蓄」，進來多少當天就被清空（最可能是同 tick/日內 `eat_granary` 或某種清倉機制把它吃光，我沒有再往下 trace 這條清空路徑的具體 code，屬於評估外的深挖，交你判斷值不值得查）。

**這推翻了 ticket②③ 原本預設「安家=有糧倉緩衝」的框架**：對這 9 個居民而言，糧倉緩衝這個月是 **0，全部**——安家如果有保護力，保護力不是來自糧倉，是來自 team.resources（私產）本身撐不撐得住。這也跟稍早 STRICT-conservation-ledger 那輪「granary 全域穩定 +2.5%、team_food 崩 -72.9%」的發現完全對得上——granary 穩定不是因為它在「存」，是它进出相抵、餘額趨零，統計上看起來穩但個別居民端完全沒享受到它。

## ①②③④⑤ 9 居民逐日面板（原始資料見 `docs/measurements/2026-08-13-phase3-settlement-panel.txt`）

| team | terrain | onset day | 觀測天數 | pop | famine_days(月底) | leader_hunger(月底) | team_food(月底) | food_security_days=team_food÷(0.8×pop) |
|---|---|---|---|---|---|---|---|---|
| 30  | plains | 23 | 8(23-30) | 6  | 4.6 | 0.09 | 0.0  | **0** |
| 45  | plains | 30 | 1(僅30)  | 9  | 0.0 | 0.00 | 12.2 | 1.69（樣本僅1天，趨勢未知）|
| 47  | plains | 25 | 6(25-30) | 10 | 0.0 | 0.00 | 26.4 | **3.3（唯一有緩衝）** |
| 58  | plains | 27 | 4(27-30) | 2  | 2.9 | 0.05 | 0.0  | **0** |
| 70  | plains | 27 | 4(27-30) | 3  | 3.8 | 0.12 | 0.0  | **0** |
| 83  | plains | 28 | 3(28-30) | 1  | 0.0 | 0.00 | 0.0  | **0** |
| 87  | plains | 27 | 4(27-30) | 1  | 0.0 | 0.00 | 0.6  | 0.75 |
| 109 | forest | 29 | 2(29-30) | 2  | 0.0 | 0.00 | 0.8  | 0.5 |
| 111 | forest | 28 | 3(28-30) | 2  | 0.0 | 0.00 | 0.4  | 0.25 |

**⑤ residency-onset 全部落在 day23-30**（月後 1/3），跟 ticket 假設「前22天0 resident」完全吻合——這個月觀測窗對大部分 resident 只捕到 2-8 天的定居生活，樣本短，趨勢外推要謹慎（尤其 team45 只有 1 天資料，不能判斷方向）。

**④地形**：7 團 plains、2 團 forest（109/111），無 mountain 樣本。forest 兩團剛好也是 harvest_vault 真值最低的兩團之一（見下），跟 REGEN 表（plains8/forest3/mtn0.5）方向一致，但樣本數(2)太小不足以下結構性結論，只能說「不矛盾」。

**①pop 軌跡**：**觀測窗內 9 團全部 pop 不變**（無一團折損）——famine_days 在累積（team30 到 4.6、team70 到 3.8）但還沒有轉成死亡，這個月窗口內看不到「安家後餓死」，只看到「安家後正在餓」。

## netgain-artifact：真值 harvest_vault + hunt 逐團 sum（取代原本回推式 net_gain）

```
              harvest_vault(真值,倉)          hunt(真值,私產)          combined income
team_id   n事件   Σgain    avg/event      n事件  Σgain   avg/event      Σ(vault+hunt)
30        21      5.65     0.269          0      -       -              5.65
45        0       -        -              3      38.21   12.737         38.21   ← 全靠hunt,非missing
47        10      40.99    4.099          4      33.33   8.333          74.32   ★遠高於其餘8團
58        7       0.69     0.099          2      6.67    3.333          7.36
70        40      0.67     0.017          1      5.00    5.000          5.67   ← 40次嘗試僅得0.67,採集效率近0
83        10      0.01     0.001          0      -       -              0.01   ← 幾乎顆粒無收
87        21      0.12     0.006          2      4.83    2.417          4.95
109       8       0.00     0.000          2      12.00   6.000          12.00
111       9       0.00     0.000          1      3.00    3.000          3.00
```
（`income_harvest_team_samples`=0 筆，即這 9 團這個月從未走「無 outpost fallback」那條路——全數已定居於自己的outpost tile，一致）

**回答 ticket 的核心問題「存量0的6-7團真實採集量=夠吃還是<飯量」**：
- **team30/58/70/83/109/111 六團，真實 harvest+hunt 總收入遠低於估計所需飯量**（例：team30 pop=6，觀測窗8天需求約 0.8×6×8=38.4，實收僅 5.65——缺口 85%；team70 pop=3，4天窗需求約9.6，實收僅5.67——缺口41%；team83 幾乎顆粒無收 0.01）。famine_days 正在累積（30/58/70）或雖未累積但 team_food 已見底（83/109/111，樣本天數太短，尚未跨過 famine 判定門檻，不代表不會餓）。**判定：genuine 慢性餓，不是 net_gain 公式回音假象**——這輪直接讀真值 tap，非回推，缺口是真實的採集/狩獵產出不足，非統計偽影。
- **team45 不是「missing」，是走 hunt 而非 harvest_vault 這條路**（3 筆 Σ38.21，avg 12.7/事件，是全表最高單筆效率）——只是我只在原本 ticket 措辭裡查了 harvest_vault，沒查 hunt，才誤報成 missing；補查後確認它有真實收入,只是樣本天數(1天)太短判斷不了趨勢。
- **team47 遙遙領先**：combined income 74.32，是第二名(45,38.21)近2倍、其餘團的10-7000倍量級——這就是它唯一 thriving 的真正原因：**不是靠糧倉（糧倉同樣是0），是靠 harvest+hunt 雙路真實高產出撐住私產**。

## 其餘 netgain ticket 子問題

- **granary 空時消耗端是否 `min(available,need)`**：STRICT-conservation-ledger 那輪已驗（`eat_depleted`/`eat_granary_depleted` 只在真的不夠吃時觸發，扣的量=扣前剩餘，code 結構保證不會超吃）——沿用該結論，genuine，非 bug。
- **person.hunger 有沒有在累積**：**有**，`leader_hunger` 逐日確實爬升（team30: 0.00→0.01→0.03→0.05→0.07→0.09；team70: 0.01→0.05→0.07→0.12），跟 famine_days 同步惡化，非死值。
- **倉容溢出**：`harvest.vault_overflow_drop` 這輪 9 居民 0 次觸發（倉容早已排除，這次是空倉不是滿倉）。

## ★對照組（wanderer/nonresident）—— treatment vs control

```
day 1 : n= 59  pop=444  food_days=52.9  starve_delta=0
day 5 : n= 65  pop=444  food_days=37.7  starve_delta=0
day26 : n=100  pop=423  food_days=25.3  starve_delta=0
day30 : n= 96  pop=400  food_days=16.1  starve_delta=1
```

wanderer 群體 pop 從 444→400（-9.9%，注意：這降幅可能部分是「轉成 resident 離開 nonresident 池」而非死亡，我沒有拆分這兩種流出各佔多少，是這輪的一個誠實缺口）、food_days 同樣在降但月底仍有 16.1 天緩衝，且整月只出現 **1 筆** starve_delta（day30）。

**Treatment vs control 對比**：9 個 resident 裡，6 團月底 food_security_days=0（team-level，因為 granary 也是0），famine_days 正在累積；wanderer 對照組月底仍有 16.1 天緩衝、幾乎零死亡事件。**就這個月這批樣本而言，「安家」目前對多數團（8/9，除 team47）沒有表現出優於流浪的生存優勢——甚至相對更差（0天緩衝 vs 16.1天緩衝）。** 只有 team47（及資料不足以判斷的 team45）支持「安家可行」。★這是對 ticket 原始「安家=餓不死」假說的直接反證性證據，不是背書——★measure-only，判斷/接入 arc ROI 定案留你們收口。

## Determinism / 落地

seed1337、`GODOT_TIMEOUT=6000`、`LW_MONTHS=1`、`SPECIMEN_SAMPLE_N=8`，specimen.jsonl 2037 entries（同批，determinism 未破）。溫度計 taps 全部 `Probe.enabled` 門控、`bump_sample`零 randf、observer-neutral。

落地檔案（待本輪 commit）：
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（新增 `income_harvest_vault_samples`/`income_harvest_team_samples`/`income_hunt_samples`/`resident_detail.terrain`/`.outpost_level`/`.famine_days`/`.leader_hunger`）
- `docs/measurements/2026-08-13-phase3-settlement-panel.txt`（本信引用的逐日 panel + harvest_vault 彙總 + 對照組原始輸出）
- `docs/measurements/2026-08-13-phase3-panel-raw.txt`（中間產出，供覆核）

3 個 temp production tap（`income.harvest_vault`/`income.harvest_team` in `resource_system.gd`、`income.hunt` in `hunt_system.gd`）本輪用完即 revert，`git status` 待確認乾淨。

routing：兩票證據齊，尤其 ★granary恆0 這個意外發現改變了「安家保護力來源」的框架（保護力=私產撐不撐,非糧倉緩衝）——請你 consolidate 時把這點跟 team_food vs granary 的分解一起帶給 blueprint,避免下一輪接入arc ROI 討論預設「定居有糧倉靠山」這個這個月數據不支持的假設。
