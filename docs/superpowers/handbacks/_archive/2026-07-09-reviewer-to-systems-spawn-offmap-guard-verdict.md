---
from: reviewer
to: systems
status: consumed
topic: spawn-offmap-guard spec 審畢——CLEAN，1 補充修正你對 RNG 影響的過度悲觀估計
---

# spawn-offmap-guard spec 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-spawn-offmap-guard.md`

## 查項 1：root cause——CLEAN

`game_setup.gd` grep 確認：`_random_near` 呼叫點只有 :148/:261 兩處，與 spec 一致，無漏。`_random_empty_tile`(:316-326) 從 `state.world.tiles.keys()` 挑，鍵本身就是既有 in-map tile → 天生安全，非猜測。`_random_near`(:309-314) 現行 `origin+dir` 確無邊界檢查，唯一越界源成立。

## 查項 2：fallback 語意——CLEAN（合理）

先 6 方向掃描保「近 origin」意圖，只在**全鄰格越界/被佔**才退全圖隨機空格——非「退 origin 本格」也說得通：`origin` 是既有 outpost/leader tile_pos，非空格判準用 `_is_tile_occupied`（查 team 位置,:304-307），origin 本格通常不算「被佔」（該函式只查 team.tile_pos 重疊，非查 tile 本身)，但 spec 選「退全圖隨機」而非「退 origin」是**更安全**的選擇（避免多隊疊在同一格的觀感問題），合理裁決,非缺陷。

## 查項 3：★RNG 影響——你的評估過度悲觀，實際影響比你想的窄

你問「有無辦法保 RNG 流不變（只在越界時才多抽）」——**答案是：spec 給的實作已經做到了，只是 spec 文字沒講清楚**：

- 舊碼：`_random_near` 每次呼叫消耗 **2 抽**（origin 挑 1 抽 + dir 挑 1 抽,:311/314）。
- 新碼：`start := rng.randi() % dirs.size()`（1 抽,取代舊 dir 抽）+ **for 迴圈掃描本身不呼叫 rng**（純用 `start+i` 位移試候選,:26-30）→ **只要第一個候選（`start+0`）就合格（絕大多數非邊緣 origin 皆如此），消耗仍是 origin 1 抽 + start 1 抽 = 2 抽，跟舊碼完全同量**。
- **只有** `origin` 真的鄰近地圖邊緣、且掃描 6 方向全部越界/被佔時，才會落入 `_random_empty_tile` fallback（內含自己的 `while` rng 迴圈,:320-325）→ 這才是額外消耗的唯一觸發點。

**結論**：RNG 消耗不是「必然全域改變」，而是**條件性**——只在該次生成的 origin 恰好靠邊緣時才觸發。若某 seed 剛好沒任何 outpost/leader 落在邊緣附近，該 seed 的 RNG 軌跡**位元級不變**（消耗量同舊碼）。你 spec 內「RNG 消耗改變 → 全下游 seeded 軌跡岔開」的敘述**成立但範圍被你講寬了**——一旦真觸發（哪怕只一次），下游確實全岔（單一 seeded RNG stream 特性，這點你判斷對），但**觸發與否是 data-dependent，非必然每個 seed 都中**。

**建議**：spec 的 measurer 交代那段加一句「若某 seed 的 baseline 全隊 tile_pos 掃描結果 0 越界（原本就沒踩過 bug），RNG 應 byte-identical；只有原本有越界隊的 seed 才會位移」——讓量測員知道可以先跑掃描判斷該 seed 屬不屬於「必位移」類，省一輪誤判「怎麼有些 seed 沒位移」的疑惑。非阻塞，敘述補充。

## 查項 4：簽名改——CLEAN

兩 caller（:148、:261）所在函式皆已有 `state` 參數在 scope 內（旁有 `_random_empty_tile(state, rng)` 同段呼叫可證），加 `state` 到 `_random_near` 呼叫零阻礙，無漏 caller。

## 裁決

**CLEAN，可鎖 spec，無阻塞修正**。查項 3 的補充是說明性修正（讓 measurer 判讀更準），非邏輯缺陷，systems 自行判斷是否採納進 spec 文字。
