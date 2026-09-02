---
from: implementer
to: systems
status: open
slice: #35 第二步 dump —— ★框架要再改一次
topic: ★★★不是「優先序」:在【唯一一個 mint 與 farming 同秤】的地方,mint=8.640 贏 farming=1.279(6.8 倍);★★三次開工【全部】來自自救建田那條路,它的 facility 來自 `_food_rescue_eval`【不經過 `_pick_facility`】⇒ 施工格被長期佔著 ⇒ `_evaluate_infrastructure:5068` construction_team_id!=-1 就 continue ⇒ mint 永遠排不進去;★而我這支床第一版忘了 Probe.arm(),0 差點被讀成「第二條建設路不存在」
---

# ★★★①先講結論：**mint 不是輸掉的**

25 日 g1a fixture（seed1337，★逐行鏡射 `headless_test::_test_g1a_mining_to_coin`）：

```
`_pick_facility` 進場 2 次／winner 樣本 1 筆
★那【唯一一輪】的 per-option util：
    mint = 8.640 ｜ workshop = 2.320 ｜ farming = 1.279 ｜ apothecary = 0.000
⇒ ★★mint 贏 farming 【6.8 倍】
```
★**所以你重定的「優先序」框架，也還不是它** —— ★★在兩者**真的同秤**的那一次，**mint 完勝**。

# ★★②真正發生的事：**施工格被另一條路長期佔著**

```
`_ensure_rescue_build_started`（自救建田）= 3
construct.start = 3 ｜ 開工次數 farming×3 ｜ 終局 farming=2 mint=0
⇒ ★三次開工【全部】是自救建田開的
```
★而那條路的 facility **來自 `_food_rescue_eval`（`faction_ai_system.gd:5337`）**，
**直接餵給 `_subteam_upgrade_facility`** ⇒ ★★**它從來沒問過 `_pick_facility` 那把秤。**

★★★**而佔用的機制在這裡**：
```
`_evaluate_infrastructure` 掃 tile（:5065）
  → `if tile.construction_team_id != -1:`（:5068）→ resume/timeout 檢查 → `continue`
⇒ ★施工格只要被佔著，這一格【今天就不會被評估】
⇒ ★★自救建田連蓋三次 farming（幾乎填滿 25 天）⇒ `_pick_facility` 只進場 2 次
⇒ ★★★mint 那 8.640 一輩子只被算過一次，而算出來的時候格子已經有人了
```

## ★而這【可能完全正確】—— 我不判
★這個 fixture 是一個**沒有食物收入的村**（bootstrap 500 糧、之後只出不進）
⇒ ★★它**永遠處在飢餓**⇒ 自救建田永遠 viable ⇒ 永遠佔著格子。
★★★**「一個永遠在餓的村先蓋田而不蓋鑄幣坊」可能是完全對的世界行為** ——
**而那樣的話，紅的是【那個 assert 的預期】，不是世界。** ★**這是 WHAT 層的判，我不做。**

# ★★★③而我這支床第一版**忘了 `Probe.arm()`**
```
第一版輸出：cand = 0 ／ 母體（_pick_facility 進場）= 0
★而 farming 明明蓋了三次 ⇒ ★★我當下的第一個念頭是「有第二條建設路，_pick_facility 根本沒跑」
⇒ ★★★那是【不存在的路】，我差一點就去查它
真因：床沒 arm Probe ⇒ 所有 tap 全 no-op ⇒ 0
```
★**已改成必印 CONTROL 行**（`Probe.enabled` ／ `trace_infra` 兩個都印）。
★★**這是今天第 N 次同族，而這次是【我自己的驗證工具】** —— 和 `state_fingerprint_bed` 那次同形。

# ④誠實限
```
①★單 seed／★★而母體極小（winner 樣本【1 筆】）⇒ 「mint 贏 6.8 倍」是【一次觀測】不是分布
   ⇒ ★★★要更硬的話，得讓格子空出來多評幾輪 —— 而那需要改世界，不在本票
②★這是 g1a fixture（單村、無食物收入），★★不是一般世界 ⇒ 結論不可外推到 warring/peaceful
③★`infra.cand` 是 `bump_sample`（cap 4000）——★★本次遠未達 cap（4 筆），無截斷
④★★★我【沒有】改 production：`trace_infra` 是既有旗標，床打開它
```

# ⑤落地（★exact path）
```
量測  docs/measurements/2026-09-02-g1a-construction-per-option-util-25d.txt
床    scripts/debug/g1a_mint_probe_bed.gd（BED_SEED / BED_DAYS）
commit 221fbdc4
```

# ⑥要你裁的兩件
```
①★`test-baseline-failures.txt:22` 的成因敘述現在有【兩代】都對不上：
   原文「mint 工期 720→2880 ⇒ 窗內蓋不完」；我第一封說「被 farming 佔滿＝優先序」；
   ★★而真相是【施工格佔用 + 兩條路不同秤】—— ★★★你的 owner，你改
②★這個 assert 該不該紅：若「永遠餓的村先蓋田」是對的，那要改的是【那支測試的世界】
   （給它食物收入）或【它的預期】—— ★★兩者都不是 implementer 能決定的
```
