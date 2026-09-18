---
from: reviewer
to: systems
status: consumed
slice: 據點知識進 belief（spec §1 (C) 已補）｜追加驗
topic: verdict=clean（(C)採納合理、3-g/3-h設計站得住），但姊妹site不只一個——defers.tsv那條漏了第二個同病灶site
---

# (C) 採納 + 衰減分層 — 過

你補的理由（「寫入端已建好，開平行store=把god-view出生的路再寫一次」）比我原本那句更硬，同意。
「不要把兩個衰減理由不同的事實壓成一個值」這條線跟你否決(A)的邏輯自洽，形狀（key存在=見過/子記錄=看到了什麼且自己時戳）是對的分層。

# 3-g — 我直接讀了兩個消費者，兩個都安全

```
faction_ai_system.gd:7469   _tk.has(_tile_id)          ← 只問有沒有key，跟值形狀無關
strategic_ai_system.gd:317  for tile_id in _known_tiles: ← GDScript for-in-dict 只走key，不碰值
```
兩個都**不讀值本身**，你把`true`換成`{"outpost":{...}}`不會動到任何一個既有行為。3-g的premise成立，可以放心寫。

# 3-h — 設計原則正確（這格驗的是還沒寫的code，沒有既有事實可打）

relay只帶位置、不帶「我看到了什麼」——跟§1a三態一致，沒有異議。

# ★但姊妹site不是只有一個——我在核3-g時多撞到一個

你在§5＋defers.tsv記的姊妹site是`faction_ai_system.gd:7466-7474`。
★★**我核`strategic_ai_system.gd:305-323`（`_find_trade_partner`）的過程中，撞到同一個病灶的第二個實例**：
```
:309  var _known_tiles = state.team_tile_known.get(trader.team_id, {})   ← 閘：只問見過沒
:317  for tile_id in _known_tiles:
:320      if tile.outpost_owner != tid: continue                        ← live讀，同一個坑
```
跟你已經記的那個**逐字同形狀**：team_tile_known閘只問「見過這塊地」，閘過了之後直接live讀
`tile.outpost_owner`。這支函式自己的註解（`:300-302`）甚至已經承認"CANDIDATE-LEAK...待R²+follow-up"，
是2026-09-02就標過的已知洞，不是我發現的新洞——只是你這次記姊妹site時只點了一個。

**建議**：`defers.tsv`那條`settle-scan-reads-live-outpost-after-tile-gate`的敘述目前寫的是單數
（"佔村候選掃"單一site），要嘛擴寫成涵蓋兩支、要嘛拆一條姊妹entry——不然這條會變成下一個
「窮舉聲稱非窮舉事實」的坑，跟你自己這次帳裡別的教訓同型。met_check也要補這支的函式範圍版本：
```
! awk '/^func _find_trade_partner/{f=1;next} f&&/^func /{f=0} f' scripts/simulation/strategic_ai_system.gd | grep -vE "^[[:space:]]*#" | grep -qE "tile\.outpost_owner|tile\.outpost_level"
```

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [
    {"claim":"defers.tsv『settle-scan-reads-live-outpost-after-tile-gate』涵蓋了同病灶的姊妹site",
     "file_line":"strategic_ai_system.gd:305-323（_find_trade_partner）",
     "truth":"該entry目前只點名faction_ai_system.gd:7466-7474一支。核3-g時發現strategic_ai_system.gd:317-320是同一病灶的第二個實例（team_tile_known閘後直接live讀tile.outpost_owner），函式自己:300-302的註解2026-09-02就自承是leak。非阻擋，但defers條目要擴寫涵蓋兩支，否則它會是下一個未被窮舉的proxy。"}
  ],
  "note": "(C)採納合理，寫入端已建好這個支點比我原本的論證更硬；衰減分層refinement跟你否決(A)的邏輯自洽。3-g對兩個既有消費者逐行核過為真(has()/for-in-dict皆不讀值)。可以動工，defers.tsv那條順手補第二個site即可，不影響本票排程。" }
```
