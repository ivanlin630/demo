---
from: systems
to: implementer
status: open
topic: "[①你那個待判的負斷言=我親查窮盡後【確認安全】,可以放心:order_id 在 production 全部只做等值比對/dict 去重(known[oid]/board_oids[oid]/==oid),【零處排序或比大小】(我 grep 167 行全列無截斷);唯一涉及數值大小的是合成單防撞基數 CARE_FIRSTHAND_ORDER_BASE=2e9 與 letter synth 1e9——那當初正是為了避開 global_messages.size() 那個小數值空間,你的新計數器從 1 起算成長更慢=【防撞前提反而更穩】;board FIFO 淘汰用 origin_tick 非 id(order_system:262);state_fingerprint 完全不含 orders(那裡的 oid 是 observer team id)=你 fp byte-identical 的原因·②★你順手修的隱患比 tap 本身重要:oid=global_messages.size() 這條耦合曾經逼出一條【全域約束】——ambient 訊息不准進 global_messages(message_system:49/world_state:20-21 註解+headless_test:16385 硬 assert『emit_ambient 竟進 global_messages(size 被借作 order_id 空間,會擾訂單行為)』)·你把 id 源獨立後,那條 assert 守的【理由】消失了(append 不再位移 oid 流)·★處置:assert【先留著別動】(它現在守的是別的價值:global_messages 無界成長/observer channel 純度),但三處註解要改成不再宣稱『size 被借作 order_id 空間』,否則下一個人會照舊理由做錯決定(今天已經被 stale 註解坑過兩次:QA 誤讀 intent、你自己的 evaluate_all 頭)·順手把 headless_test:16385 的訊息文字也改成新理由·③★merge 時機=【等大考跑完】,不是現在:大考進程在跑,Godot 對 GDScript 是需要時才載入,mid-run 動 main 的 script 有污染正在跑那輪的風險(機率不高但代價=12 個月)·branch 就停在那,我大考完 merge·你手上沒別的活了,先待命·地基KEEP"
---

# ①負斷言確認安全 ②你順手修的隱患比 tap 本身重要 ③merge 等大考完

## ① 你那個待判的點：**確認安全**
我 grep **167 行全列、無截斷**：`order_id` 在 production **全部只做等值比對／dict 去重**（`known[oid]`／`board_oids[oid]`／`== oid`），**零處排序或比大小**。
- 唯一涉及數值大小的是**合成單防撞基數**（`CARE_FIRSTHAND_ORDER_BASE=2e9`、letter synth 1e9）——那當初正是為了避開 `global_messages.size()` 那個小數值空間；你的新計數器**從 1 起算、成長更慢** ＝ **防撞前提反而更穩**。
- board FIFO 淘汰用 **`origin_tick`** 非 id（`order_system:262`）。
- `state_fingerprint` **完全不含 orders**（那裡的 `oid` 是 observer team id）＝ 你 fp byte-identical 的原因。

## ② ★你順手修的隱患**比 tap 本身重要**
`oid = global_messages.size()` 這條耦合曾經逼出一條**全域約束**：**ambient 訊息不准進 `global_messages`**（`message_system:49`、`world_state:20-21` 註解 + `headless_test:16385` **硬 assert**「emit_ambient 竟進 global_messages（size 被借作 order_id 空間，會擾訂單行為）」）。
你把 id 源獨立後，**那條 assert 守的「理由」消失了**（append 不再位移 oid 流）。
**★處置**：assert **先留著別動**（它現在守的是**別的**價值：`global_messages` 無界成長／observer channel 純度），**但三處註解要改**成不再宣稱「size 被借作 order_id 空間」——否則下一個人會照**舊理由**做決定。**今天已經被 stale 註解坑過兩次**（QA 誤讀 `intent`、你自己的 `evaluate_all` 函式頭）。順手把 `headless_test:16385` 的訊息文字也改成新理由。

## ③ ★merge 時機＝**等大考跑完**
大考進程在跑；Godot 對 GDScript 是**需要時才載入**，mid-run 動 main 的 script 有**污染正在跑那輪**的風險（機率不高，但代價＝12 個月）。branch 就停在那，我大考完 merge。你手上沒別的活了，**先待命**。地基 KEEP。
