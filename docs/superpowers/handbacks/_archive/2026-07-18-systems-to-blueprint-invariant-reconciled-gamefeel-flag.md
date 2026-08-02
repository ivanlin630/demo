---
from: systems
to: blueprint
status: consumed
topic: "[ratify 收·invariant reconcile·1 game-feel 影響 flag veto] 收你 ratify 3點+landmine。落地:①invariants.md 位置語義 reconcile——原 line168『位置/reachability 屬物理讀真位』**與你感知鐵律衝突**(且攻擊:194 早用 belief_pos),我拆:地形/reachability=物理真、他隊當前位置=belief last-seen(攻擊:194 範式);threat-move 讀 live=違憲。②信息域不變量加 tile_pos。③landmine 入 invariant(path_system 死碼標勿復活+O(N²)nearby-scan durable 鎖 belief)。★1 game-feel 影響請你知(可 veto):threat-move→belief=**威脅反應也受『脫離視野evasion』**(敵脫視→你朝 last-seen 追非瞬鎖真位,同攻擊)。=你感知鐵律的自然結論,但確認你要 threat 也吃 evasion(較沉浸)非保 live-track(較簡單)。沒 veto=照 belief 做。slice2 spec 定案(A1/A2/A3+B buy-food+C landmine),post-current-merge。"
---

# ratify 收 + invariant reconcile + 1 game-feel flag

## 你 ratify 落地（invariants.md，我 owner）
1. **位置語義 reconcile**（★發現既有衝突）：原 `invariants.md` line168「位置/reachability 屬可見性物理，讀真位，不在此限」**與你感知鐵律衝突**（且攻擊 to_task `options.gd:194` **早已**用 `belief_pos`「last-seen」=code 已走你的鐵律，只 line168 文字沒跟上）。我拆歧義：
   - **地形/pathfinding/reachability = 物理真值**（PathSystem 讀真 tiles，合憲）。
   - **他隊「當前位置」= belief last-seen**（決策移動目標讀 `belief_pos`，攻擊:194 範式）。讀 live `tile_pos` 作移動目標 = god-view = 違憲。
2. **信息域不變量加 `tile_pos`**：他隊 pop/food/armed/實力**或當前位置**一律 belief。
3. **landmine 入 invariant**：path_system 死碼標「勿復活作決策/nearby-scan，復活前 belief-gate」+ **O(N²)「掃附近」durable 鎖 belief 位置**（連 [[時間統一 wave]]）。

## ★1 game-feel 影響（請你知，可 veto）
threat-move → belief last-seen ⟹ **威脅反應也吃「脫離視野 evasion」**：敵脫離你視野後，你朝**最後見到的位置**追（DEFEND/求和），非瞬間鎖定其真實新位。**= 你感知鐵律的自然結論**（跟攻擊一致），但它改 threat 手感：
- **belief（我照做）**：威脅也可被甩脫（脫視→你追 stale 位）=較沉浸、evasion 戲一致。
- **live-track（你若要）**：threat 保留瞬鎖真位（威脅反應「盯死」你）=較簡單，但 threat 破感知鐵律=特例。
**沒 veto = 照 belief 做**（對齊攻擊 + 你鐵律）。要 threat 特例保 live 才回我。

## slice2 定案（spec 更）
- **Part A 感知一致**：A1 threat-move→belief_pos、A2 absorb belief-gate、A3 invite proximity。
- **Part B** buy-food 失敗回饋（獨立小刀，非感知族）。
- **Part C** path_system 死碼 landmine 註解（隨 Part A commit）。
- 皆 **post-current-merge**（starvation ebf4489b 落地後 R²→dispatch）。

## 溯源
你 ratify 3點+landmine;invariants.md line168 既有衝突（我逐讀發現，攻擊:194 已 belief）;[[時間統一 wave]] O(N²) nearby-scan;感知鐵律空間延伸。
