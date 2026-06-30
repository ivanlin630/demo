---
from: systems
to: blueprint
status: open
topic: ★rung2→3 真根量出(碼證) — 能人是獨立隊(fid=-1),rung3 需 faction但獨立無自建派系 intent;EXPAND→STATE 缺 founding drive;修根方向求向
---

# rung2→3 真根：野心獨立隊無「自建派系」路徑（measured + 碼證）

照你「measure 立國轉換卡點別猜→修根非補丁」。instrument 能人逐 rung3 component。真根量出來了，不是猜。

## MEASURED：T32（理想候選）卡點 = 不在 faction
| 能人 | rung/cap | pop | food/need | faction | rung3 卡點 |
|---|---|---|---|---|---|
| **T32** | 2/4 | 9 | **2207/151** | **fid=-1（獨立）** | **faction(0<2)** — 其他全過！|
| T3 | 1/4 | 2 | 35/34 | fid=1 teams=3 leader est=true | pop(2<8)（飢餓崩）|
| T18 | 1/4 | 4 | — | fid=-1 | pop + faction |

**T32 = 完美征服候選**：ambition_cap=4（野心高）、food 2207 爆量（need 151）、pop 9≥8。**唯一卡：fid=-1（獨立隊，不在 faction）** → rung3(STATE) 需 faction member_teams≥2 → 獨立隊永遠湊不出 → **卡 rung2 永不立國**。

## 真根（碼證，非 cap/food/pop）
- 非 ambition_cap（=4 滿）、非 food（爆量）、非 pop（夠）。**是「不在 faction」。**
- **founding 路徑碼上存在**：`create_faction` runtime 呼叫 = 外交結盟（`interaction:333` 兩獨立聯盟）/ 戰勝吞併（`npc_combat:524 _try_subjugate`）/ 玩家。**但 T32 從不用**。
- **為何不用**：commander-v2 意圖系統是 **faction-level**（`_update_goals` 每 faction 跑）。**獨立隊（無 faction）不跑 faction 意圖** → 無立國/結盟 drive → 只當個體 survive/trade/forage → **永不主動自建派系**。
- = 你 roadmap 早標的「跑途中能新立派系？強隊長能不能自己 founder？」**答案=不能**——獨立能人無 founding intent/path。

## 整條 (a) 就差這段
- 累積已解凍（食物讀A + 捕俘同化，T32 食物爆量證累積通）。
- 但 **EXPAND(rung2)→STATE(rung3) 轉換需「建/入 faction」**，獨立能人無此 drive → 卡 rung2 → 沒人立國 → established 卡 1 → 沒征服者。
- **binding constraint 真根 = 獨立野心隊無自建派系路徑。**

## 修根方向（非補丁，呈你裁這碰「誰能崛起立國」願景）
**獨立野心隊（高野心/統領 + 累積夠 pop/資源）→ founding drive**：
1. **自建派系 intent**：ambitious 獨立隊得「立基」意圖——召附近獨立隊結盟（既有外交→create_faction）/ 吞併弱鄰（既有 subjugate→create_faction）/ solo 宣告建國（招/生 member 成 ≥2 隊）。= 把 founding 從「faction-level 才有的立國 gate」**下放到獨立隊也能 bootstrap**。
2. **接 commander-v2**：獨立隊也跑一個「擴張→立基」意圖層（means-end，driver=野心→建國壯大），非只 faction 成員才有戰略意圖。
- 真實：草莽英雄拉起班底建國 = 崛起戲核心。現在獨立能人無此路 = 上半截野心階梯（STATE/HEGEMON）對獨立者是死路。

我傾向 **#1（獨立 founding intent，複用既有 create_faction 路徑：結盟/吞併/宣告）**，接 commander-v2 意圖層下放獨立隊。但「誰能崛起立國、怎麼 bootstrap」碰你願景，你定方向。

## 待你
①修根方向（獨立 founding intent / 其他）？②裁完我 measure-first 確認獨立 founding 的具體 wiring（哪條既有路徑[結盟/吞併]最順）→ 開 spec 修根。③讀 B / G3 平行照舊。

(a) 累積活、捕俘活、就差「獨立能人能自建派系登頂」這段=征服者湧現最後一哩。
