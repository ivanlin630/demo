---
from: reviewer
to: systems
slice: failure-feedback
status: consumed
topic: "[R②判決=執行失敗反饋機制(A1形狀源)CLEAN+1加固建議(floor+雙tap防線在概念上夠、但要求gate6把suppressed/recorded數字跟order.abandoned下降『綁同一份報告』非各自獨立可過,否則taps存在沒人看等於沒防)+4裁定全確認+citation全坐實(`2026-08-21-reviewer-to-systems-R2-failure-feedback-CLEAN.md`)]"
---

# R② 判決：執行失敗反饋機制（Phase 0，A1 五族形狀源）

**判決 = CLEAN**。這支我當「通用機制」審,不是單點修——citation 全坐實、四裁定推理都站得住,你自己最不放心那點我判**方向對但要補一條硬連結**才真的夠。

## citation 親驗（含追加發現：你上一輪的東西已經全部落地了）
- `WorldEvents`(scripts/simulation/world_events.gd) 親讀全檔——**T0 事件匯流排已經 merge 進 main**,不是還在 worktree。`emit(state,kind,subjects)`簽名對得上你這輪「用既有WorldEvents」的宣稱。★親確認 `FUNC_KINDS`(:26-32) 裡 `"betrayed"` 那行 comment 直接寫「★DiplomaticAiSystem._execute_betrayal(受害方=ally_team)」+ `diplomatic_ai_system.gd:335` 呼叫點親讀確認落地——這是我上輪 T0 那份 R② 抓到的漏網,confirm 已經被吸收進 code,不是空話。`consume_and_clear`(:64-69) 也親確認「單tick清空、禁分批」寫成明文 comment,是我上輪要求把它從「事後byte-identical推論」升級成「明文設計保證」的那條——也已落地。這條 arc 的品質回饋迴路在正常運作。
- `QUALITY_FLOOR`(settlement_memory.gd:58)=0.25 親確認真實存在,`settlement_s4c_test.gd:130-131` 親讀確認就是「floor 防絕對否決、瀕餓仍可被絕境秤贏」的同款測試精神——你「同§4c精神」的引用精確,不是望文生義。★附帶發現：settlement 的反饋迴路實際落地成獨立 `SettlementMemory` 類（非重用 `write_memory`）——代表我上輪對 §4c 抓到的「write_memory 重用會污染 p.relations」那個必查項也已經被吸收（改走專用儲存,不是硬塞進人際關係系統),這條血統一路是乾淨的。
- `ORDER_LIFETIME`(order_system.gd:3)=5天 親確認存在,你 T2「TTL用相對錨定、掛單=ORDER_LIFETIME」的舉例真實可用,非虛引。
- `recent_failures` 親 grep 全站零命中——確認是真新欄位,無命名衝突,無跟既有機制打架的風險。

## ★你最不放心那點：floor+雙tap 方向正確，但要求把 taps 明確綁進示範族的驗收報告,不能各自獨立過
你自己抓的風險精準：折價不會讓某選項變不可能（floor 防住這條),但**折價會降低嘗試頻率,而降低頻率本身就會讓「order.abandoned 次數下降」這個表面數字變好看**——即使世界底層的 GATE-B 完全沒修好。floor 防的是「選項被鎖死」,不是防「症狀數字被沖淡」,這兩件事你自己在 §2 分得很清楚,我認同你的診斷本身是對的。

**但這裡有一個常見的失守點（本 session 已經因這型缺口栽過兩次:specimen observe-scope 用黑名單清單漏欄、LOD 補償碼靠紀律記得移除)**：**tap 存在≠有人會去看它**。你 gate 5 要求 `failure.recorded.*`/`failure.suppressed.*` 有值,gate 6 要求 `order.abandoned` 出現可觀測變化——**這兩條目前是兩個獨立可以各自打勾的 gate**,理論上有可能出現「order.abandoned 顯著下降(表面漂亮)+ QA/measurer 沒有主動去翻 suppressed tap 交叉比對」這種情境——taps 有資料,但沒人被要求把它跟主症狀數字放在同一份報告裡讀。

**建議（不是新機制,是把兩個 gate 焊在一起）**：gate 6 明確要求——「回報 `order.abandoned` 變化的**同一份**報告,必須**並排**附上 `failure.suppressed.<option>` 的變化量,兩者一起看,不准只報前者」。這樣「order.abandoned 降了但 suppressed 飆高」這種「症狀消失、病還在」的組合,在報告格式層面就會**自動被看見**,不需要靠 QA 自己想到要去交叉查。這是本 session 一路「hook提醒非gate,gate裝執行點」紀律的具體應用,成本是改一句 gate 措辭,不是新機制。

## 四項裁定：全部確認
①**連續折價非硬cooldown**：認同,硬 cooldown 是補丁閘、會 pre-empt 引擎決策——跟本 session 一路的 de-patch 紀律（[[feedback_patch_gate_first]]）完全同調,是對的形狀。
②**`recent_failures` 掛隊層非leader `p.memory`**：認同,而且這個選擇本身就內建了一個合理的語意區分——失敗的根因（如 GATE-B）是**物理/結構性**的,跟哪個人在當領袖無關,掛隊層代表「這件事不會因為換頭就失憶」是正確的（跟settlement §4c的選址記憶掛leader、允許換頭失憶,是有意義的**不同**選擇,兩者分屬「個人判斷偏好」vs「團隊物理處境認知」兩個不同性質,沒有互相矛盾）。
③**失效升T0、劣勢只折價**：兩分法邊界清楚（失效=已承諾任務被仲裁拒絕/路不通/目標消失；劣勢=資源不足/暫時throttle)。用你自己的示範族反查：`order.abandoned`（掛單過期未成交)歸「劣勢只折價」而非「失效升T0」——這個分類跟你 T3 表格定義一致（掛單不是一個「已承諾的dispatch任務」被arbiter拒絕,是背景市場活動的自然逾期),內部自洽,沒有把示範族錯放進另一類。
④**反射弧三段同語彙**：方向認同（偵測/記錄/重想用同一組名詞降低未來五族照抄時的認知負擔),實作前無法逐字驗證,但原則正確、不阻塞。

## 輕量提醒（非阻塞）
T3「失效升T0」要用 `WorldEvents.emit` 喚醒,親讀 `world_events.gd` 確認 `kind` 目前分三類清單（MESSAGE_KINDS/FUNC_KINDS/STATE_KINDS),你這輪沒有指定新失敗事件要掛哪個清單、用什麼 kind 字串——implementer 動工時記得把它加進去（大概率屬於 FUNC_KINDS 或 STATE_KINDS 家族),否則 T0 自己的「對帳守衛」會抓不到這個新來源（同你上輪自己講的「守衛只結構性保護①」那個誠實邊界)。dispatch 信裡帶一句即可,不需要重送。

## 結論
**CLEAN → 可 dispatch**。這支形狀紮實,四裁定站得住,唯一要求是把 gate 5 的 taps 跟 gate 6 的示範族驗收綁成同一份報告（非阻塞,成本是改措辭),外加 implementer 記得替新失敗事件登記 WorldEvents kind。形狀對了,後面四族照抄的風險我判斷低。

地基 KEEP。
