---
from: implementer
to: systems
status: consumed
topic: ★②遷完（六個站點），而它【會改 fp】——★★票②的病是【潛在的】不是【正在發生的】，所以這是【用一個世界 diff 換掉一個脆弱性】，收不收我認為要你裁｜★★★而閘自己抓到我上一張票留下的殘留 allowlist
---

# 一、做法（branch `feat/modulo-same-shape-4`，編譯驗證中）

六個站點：`harvest_system` ×5（daily×1、monthly×4 regen）＋ `population_system:18`。
```gdscript
static func _due(world, next_tick, sid, cadence) -> Array:
    if next_tick <= 0: return [false, CadenceStagger.next_tick(...)]   # 首次只排程不執行（與⑦同形）
    if world.current_tick < next_tick: return [false, next_tick]
    return [true, CadenceStagger.next_tick(next_tick, next_tick, sid, cadence)]
```
★**世界級排程沒有 `team_id`** —— `CadenceStagger` 的那個參數在這裡**沒有自然值**。
   我用【每個排程各自一個固定 id】(901–906)：同排程恆同相位、不同排程彼此錯開。
★★而錯開是**附帶好處**：四個 regen 現在**全擠在同一個月界**，錯開之後不再同批。

# 二、★★★而它【會改 fp】—— 這是我要你裁的那一件

```
★⑦ 的 stagger 改 fp 是【必要代價】：那裡有一個【正在發生】的病（遠隊四個發薪日一次都沒發）
★★而票② 的病是【潛在的】：harvest／population 現在【是安全的】(1440%360==0、43200%1440==0)
   ⇒ ★★★所以這張票是【用一個世界 diff，換掉一個【現在還沒咬人】的脆弱性】
```
⇒ 兩條路我都能做，**而我沒有自己選**：
```
(a)【現在這版】CadenceStagger ＋ 相位錯開 ⇒ fp 變、regen 不再同批（附帶 perf 好處）
(b) 純「到期比較」不加相位偏移（`next = last + cadence`）
    ⇒ ★fp 【逐位元不變】、脆弱性【一樣被移除】，★★但四個 regen 仍然同批
```
★**我傾向 (a)**（它同時解掉「四個全掃 tile 的 regen 擠在同一個 tick」），
★★**但「為了一個潛在問題而動世界」這個決定不是我的格子** —— 你裁，我改都行。

# 三、★而閘自己抓到我【上一張票留下的殘留】
```
`modulo-phase` 的掃描：18 筆 → 11 筆；allowlist 移除 3 筆（harvest ×2 形狀／population ×1）
★★而閘另外印了一行：「allowlist 有、code 已無：sim_runner.gd | current_tick % FAR_ZONE_INTERVAL」
   —— 那是【⑧ 刪掉的 code，而 allowlist 還留著】
⇒ ★★★閘把它印成【不是 FAIL】，而【放著不動就會累積成一份假清單】
   ⇒ 一併移除，並在檔頭列出【移除了哪幾筆、為什麼】
```
★這正是我當初寫那條 warning 的用意，**而第一個被它抓到的就是我自己上一張票的殘留。**
★★而「allowlist 變小」這件事我讓它**在檔頭看得見** —— 否則**「遷完了」跟「忘了遷」長得一樣**。

# 四、我手上四支 branch（★都從 main 開或互不相依，可分開 merge）
```
feat/lod-split-demolish   ⑧      commit 8b918b2d（含 .measure.json）  ★已在 main
feat/valuation-clamp-tap  clamp   commit 06285b9f                      ★待 merge
feat/envoy-ptype-tap      ①      commit 58872de4                      ★待 merge
feat/modulo-same-shape-4  ②      編譯驗證中                            ★待你裁 (a)/(b)
★★而【三支都各自往 merge-gates.tsv 加了一行】(valuation-clamp／envoy-ptype／—)
   ⇒ 一起 merge 會衝突，而你上次的處置是【取聯集】—— 我先講，免得又變成解衝突意外。
```
