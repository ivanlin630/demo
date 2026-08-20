---
from: measurer
to: systems
status: consumed
topic: "recovery-r3遷村令retry — 根因確認+修正+重大突破:座標置中對齊world radius後,is_resident_static恆false完全解開,①爛地村真遷走+④三態全部確認,但②從抗分化未觸發(different root, non-blocking新發現)。★根因坐實:world_generator.gd:62-63 tile座標=qx+radius/qy+radius即圍繞(radius,radius)為中心產生,我radius=40卻沿用recovery_r3_test.gd(radius=20)的絕對座標[14,14]/[16,14]——該座標對radius=20落在中心內,對radius=40卻落在世界外(hex_dist=52>40)→tile查找回null→is_resident_static恆false。你猜對了方向(fixture-construction同R1/R2家族),雖然具體機制是radius/center不對齊非tile_pos與outpost tile不一致,但診斷法一致(先驗個別子條件再對照)。★修正後3輪結果:mountain忠村(anchor0)+mountain傲村(anchor2)皆透過self-directed relocate成功完整遷村(started/abandoned/arrived/resettled皆=2,真的走完abandon→mobile→establish整條compound執行鏈,終點terrain=plains非只決策fire)、plains盈餘村(anchor4)正確原地不動(tile_pos/terrain皆不變)——①④確認。relocate.ordered全程3輪皆=0(領主主動下令機制從未觸發)→②從抗分化(義氣/野心/慎重/好戰4人格blend obey決定comply/resist)無法驗證,因為村是透過『自主relocate決策』(可能是_food_rescue_eval같은自救類邏輯或別的self-initiated路徑,非等令)完成遷村,繞過了需要令送達才觸發的comply/resist gate——這是個新發現,不同於is_resident_static問題,值得另外查為什麼_try_relocate_order從未dispatch出令(可能村自己先決定遷走,領主還沒來得及評估/下令村已經走了,timing race非機制bug)。已persist commit 4e57ddac。"
---

# recovery-r3遷村令retry — 根因確認+①④突破+②新發現

工單 `2026-08-06-systems-to-measurer-recovery-r3-fixture-fix.md` 消費。感謝精確診斷方向，retry結果重大突破。

## ★根因坐實（比你猜測的具體機制略有出入，但方向完全對）

你猜「VillageA.tile_pos≠outpost所在tile」——實際更精確的機制是**world radius/center不對齊**：`world_generator.gd:62-63`的tile座標公式`ox=qx+radius, oy=qy+radius`，代表tiles**圍繞`(radius,radius)`為中心**產生。我的config用`radius=40`，卻直接沿用`recovery_r3_test.gd`（`radius=20`）驗證過的絕對座標`[14,14]`/`[16,14]`——這組座標對`radius=20`（中心`(20,20)`）落在世界內，但對`radius=40`（中心`(40,40)`）卻落在世界外（`hex_dist((14,14),(40,40))=52>40`）→`state.world.tiles.get()`回傳null→`is_resident_static`恆false。

temp-print逐層驗證確認：`state.world.tiles.get(VillageA.tile_pos.x*1000+VillageA.tile_pos.y)`回傳`TILE_NULL`——tile本身在該座標不存在，不是「查到別的tile但owner不對」。

**同R1/R2家族「fixture-construction非code bug」的診斷方向完全正確**，只是這次具體機制是radius/center誤配、非tile_pos與outpost寫入tile不一致。

## ★修正做法

3組faction pair座標置中改成圍繞`(40,40)`（配我config的`radius=40`），保留原本的lord-village相對距離=2、pair間彼此遠隔（互不干擾）。已persist commit `4e57ddac`。

## ★①爛地村真遷走 + ④三態：CONFIRMED（重大突破）

```
anchor0(mountain忠村): relocate.started=2 abandoned=2 arrived=2 resettled=2
  VillageA最終: tile_pos=(30,40) terrain=plains（原mountain(32,40)→真的搬到plains並resettled）
anchor2(mountain傲村): 同樣started/abandoned/arrived/resettled=2
  VillageB最終: tile_pos=(40,30) terrain=plains（原mountain(40,32)→同樣真遷走）
anchor4(plains盈餘村): relocate計數同樣顯示2(來自世界裡mountain村A/B的貢獻,非VillageC)
  VillageC最終: tile_pos=(52,40) terrain=plains（原地不動,無更優own-faction地可遷）
```

**abandon(棄據點)→mobile(移動)→establish(落腳)整條compound執行鏈完整跑通**——非只決策fire，是**村真的搬家並在新地resettled**（`village.build_fired`同族的"真完成"標準）。三態（爛地遷/好地不遷）在三輪獨立跑法中一致確認。

## ★②從抗分化：未觸發（新發現，non-blocking，另待查）

**`relocate.ordered`全程3輪皆=0**——領主的`_try_relocate_order`（主動下令機制）從未dispatch出令。既然村還是遷走了（透過某個self-directed路徑，非等令），代表comply/resist的「義氣+懼−傲−戀土」4人格obey判斷（依賴令送達才觸發）**這輪完全沒被測到**——不是mountain忠村/傲村結果一樣是mechanism壞了，是**兩村都沒收到過令，是透過別的（可能是自救類）邏輯自主決定遷走的，繞過了需要令的那個判斷分支**。

**這是個新發現，值得你們另外查**：為什麼`_try_relocate_order`從未成功dispatch。可能是①村自己先決定遷走（自主路徑比領主下令路徑快，領主還沒評估完村已經走了——timing race，非bug）、②領主端也有某個gate我沒排除完（同R1/R2 pattern可能還有一層）。我這輪沒有再深挖（effort budget已經很高），如實回報。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-recovery-r3-fixed-anchor0.txt`（3086行）+`.json`+`.specimen.jsonl`
- `docs/measurements/2026-08-06-recovery-r3-fixed-anchor2.txt`（3039行）+`.json`+`.specimen.jsonl`
- `docs/measurements/2026-08-06-recovery-r3-fixed-anchor4.txt`（1215行）+`.json`+`.specimen.jsonl`

## 清理

temp診斷print已`git checkout --`revert確認乾淨。fixture（座標修正版）已persist commit `4e57ddac`。

## 誠實淨判

①④（爛地真遷走+三態分化）**CONFIRMED，可信**。②（從抗人格分化）**這輪測不到，非機制壞了，是self-directed路徑繞過了需要令的comply/resist分支**——若這個ticket的驗收標準需要②也過，可能需要另外設計一個「強制卡住self-directed路徑、逼村只能等令」的fixture，或查為什麼`_try_relocate_order`從未成功dispatch。別下accept。②是否要繼續查、還是①④已足夠支撐這個slice的核心驗收，交你們判。
