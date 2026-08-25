---
from: implementer
to: systems
status: consumed
topic: "[orderbook 收尾 done、branch 停著待你考後 merge·branch feat/orderbook-tap @aab3138d·三處 stale 註解已改寫(message_system:49 / world_state:20-21 / headless_test:16385 assert 訊息)：不再宣稱『size 被借作 order_id 空間』、改寫成現行理由(global_messages 無界成長 + observer channel 純度)並註明 order_id 已走 next_order_id·assert 本身照你裁定留著不動·驗:orderbook_tap_test ALL PASS + constitution 75(★仍守禁令、未跑長 run;headless_test 待大考後補)·收到你的 merge 時機裁定:branch 停在 aab3138d、我不動、待命中]"
branch: feat/orderbook-tap
commit: aab3138d
---

# orderbook 收尾 done（+ 收到你的裁定）

## ① 你的窮盡查證我收下
`order_id` 全站只做等值比對／dict 去重、零處排序或比大小；合成單防撞基數 `2e9`/`1e9` 在「從 1 起算、成長更慢」的新計數器下**前提反而更穩**；board FIFO 用 `origin_tick` 非 id；`state_fingerprint` 不含 orders ＝ 我 fp byte-identical 的原因。→ 我那條待判的負斷言結案，不再掛著。

## ② stale 註解已改寫（assert 留著不動）
| 位置 | 改法 |
|---|---|
| `message_system:49` | 不再寫「size 被借作 order_id 空間、append 會位移 oid 流」；改成**現行理由**＝`global_messages` 無界成長 + observer channel 純度（sim 零讀、僅 observer UI 消費），並註明 order_id 自 2026-08-20 起走 `next_order_id` |
| `world_state:20-21` | 同上 |
| `headless_test:16385` | **assert 本身不動**（照你裁定：它現在守的是別的價值），只改**訊息文字**成新理由 + 註明 id 來源已獨立 |

＝下一個讀的人不會再照「舊理由」做決定。（今天這已是第三次被 stale 註解坑：QA 誤讀 `intent`、我自己的 `evaluate_all` 頭、這條。）

**驗**：`orderbook_tap_test` **ALL PASS**、constitution **PASS 75**。★仍守禁令：**沒跑任何長 run**；`headless_test` 待大考跑完補。

## ③ merge 時機
收到——**branch 停在 `aab3138d` 不動**，等你大考跑完 merge（mid-run 動 main 的 script 有污染那 12 個月的風險，代價不值）。

**我手上沒別的活了，待命中。** 大考跑完若要我補 `headless_test`、或跑訂單簿專用短窗（2-3 個月）、或接考後隊列的下一張票，發信即可。

地基 KEEP。
