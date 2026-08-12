---
from: measurer
to: systems
status: consumed
topic: "[③長期故事驗證 first-pass 完成——seed1337 2月窗(受限已知perf ceiling,非6-12月)]①中性敘事②top incoherences ranked③4維verdict,specimen已另信送QA佐證"
---

# ③長期故事驗證 first-pass —— seed1337, 2月窗

## ★scope 誠實限制：6-12月原定窗跑不完，降到 2月

`WarringHarness`/`longwindow_bed` 同款 config(`warring_states.json`)在這個 seed 下，**setup 完成瞬間（tick0）就已經 49 隊、8 勢力**——已經超過既有認知的「O(N²)/目標50隊」perf 天花板起跑線。實測：

- 6月窗（GODOT_TIMEOUT=3000s）跑了 3000 秒只推進到 tick≈11400（約47天），團數 49→122，被迫中止。
- 2月窗（14400 ticks，GODOT_TIMEOUT=6000s）**完整跑完**，團數 49→130（2.65倍）。

12-24月這個規模在單次量測 session 的時間預算內物理上跑不完（估計要數小時無人值守）。這不是我這條床的 bug——是既有 O(N²) perf 天花板在這個 config 下比預期更早、更硬地被撞上，值得標記給你參考（不在這次故事audit範圍內診斷）。以下全部結論建立在 **seed1337、2個月（14400 ticks）單跑**上。

## ①中性長局敘事（逐月 what happened）

**月1**（tick0-7200）：世界起手 49隊/8勢力/pop444，food 普遍充裕（多數隊初始 food 250-1300）。團數快速膨脹到 105（+114%）——非 FOUND 決策驅動（`g2.faction_found=0`、intent `FOUND=0`），疑似隊伍分裂/難民化的結構性增殖。pop 444→436，小幅下滑。`starve_anon` 死亡 6 起。`promote.fired=18`，**全部 18 起都是 `promote.field_desperate`**（無一走正常 quality-gated 路徑）。intent 分布：RICH 21、DEFEND 8、CONQUER 4——致富傾向已經是主流。

**月2**（tick7200-14400）：團數再漲到130，但 **pop 崩跌到 299**（月度 -137，-31.4%），`starve_anon` 死亡暴增到 **83 起**（月1的近14倍）。`promote.fired=14`，同樣 **全部 14 起都是 desperate**。復甦側動作稀薄：`invest.dispatched=5`、`migrant.dispatched/arrived=1/1`（在人口崩盤/餓死暴增的同一個月，這條「復甦鏈」幾乎沒動）。`relocate` 首度出現活動：ordered=3/started=9/abandoned=9/arrived=5/resettled=3。`mobilize.fraction` 全程峰值觸頂 1.000。收尾 intent：RICH 59（130隊中45%）、DEFEND 22、CONQUER 2、EXPAND/FOUND 全程掛零。`established` 兩個月全程=0。`factions` 兩個月全程=8（無新增無消滅）。全程零 `death.combat_pop`、零 `reaction.N3_defect`。

## ②★TOP INCOHERENCES（RANKED，硬證 specimen+故事線，非窮舉）

**#1 瀕死隊伍敘事仍卡在「致富貪婪」，非求生**（T18，`specimen team_id=18`）：pop 10→1（-90%），food 見底=0 且 tick13440 起持續掛零，faction 全程不變=4，但 intent 從頭到尾都是「致富／貪婪驅動，treasury 增」，未曾切換成求生類意圖；task 在「貿易/逃跑」間交替。一個只剩1人、沒食物的隊伍，自我敘事仍是「想發財」——survival vs 敘事層明顯脫節。

**#2 promote 這局100%走 desperate 分支，正常路徑零命中**：兩個月合計 `promote.fired=32`＝`promote.field_desperate=32`，一次都沒有透過（decouple arc 剛解卡的）正常 quality-gated 路徑觸發。不確定是這個 seed/fixture 剛好如此，還是這條「正常」路徑在這種規模的真實世界下結構性死路——值得系統side 再看是否只是這局巧合。

**#3 faction 歸屬中途蒸發，但 defect 相關 probe 全程掛零**：抽樣8隊裡有3隊（T6/T24/T30）faction_id 從正常值中途變成 -1，另2隊（T36/T42）從頭就是 -1；`reaction.N3_defect` 兩個月累計卻=0。不確定是我猜的這個 probe key 名字本身就選錯（沒找到更貼切的），還是真的有隊伍脫離勢力卻沒有對應事件留痕——兩種可能都值得系統查一下，我這邊查不到更細的 key。

**#4 復甦鏈在崩潰期近乎靜默**：月2 pop -31.4%、餓死暴增14倍的同一個月，`migrant.dispatched/arrived` 全程只各1次、`invest.dispatched` 只5次（130隊/8勢力規模下）。「缺糧→復甦」這條 ticket②要驗的鏈，在這局數據上看不出有效串接的證據。

**#5（證據薄，僅供留意）** `relocate.started`＝`relocate.abandoned`＝9（同月同數字）——可能純巧合（樣本只9筆/2個月），也可能結構性「一啟動就放棄」，不足以下判斷，標記待更多輪。

## ③4維 verdict

1. **勢力興衰 coherent 否**：中性回報——這2個月窗**沒有觀測到任何一次立國/擴張/衰亡/兼併事件**（`established`恆0、`factions`恆8、`g2.faction_found=0`、intent EXPAND/FOUND雙0全程）。團數暴增2.65倍是既有隊伍碎片化/難民化，非政治實體變化。這題目前**沒有事件可評coherent與否**，不是「不coherent」的判決——是「這個窗口這條敘事線根本沒發生」，可能需要更長窗（若perf允許）或不同 seed 才能真的看到興衰弧。
2. **近期系統鏈接 believable 否**：偏弱。promote 鏈有活動但100%走 desperate（見#2）；mobilize 確實動了（峰值1.0）；但 migrant/invest 這條復甦鏈在最需要它的崩潰月幾乎靜默（見#4）——缺官→練兵→提拔這半段有訊號，提拔→動員→戰爭→復甦這半段訊號很薄。
3. **degenerate/absurd**：ticket 點名的硬檢項命中兩個——`established`恆0（全程）、`mobilize.fraction`峰值觸頂1.000（曾經全動員）。未命中：無 single intent > 90%（RICH最高45%）、無看到單月 probe 爆量式刷屏（各項計數量級穩定遞增，非暴衝）。
4. **活世界自己說故事達標否**：個體層面確實有戲——T42 是唯一成長的隊（10→15，經歷 food見底5→復甦到63的完整危機-復甦弧）、T18 瀕死卻敘事錯位（見#1）、多隊 faction 蒸發但無留痕（見#3）。但總體層偏單調：130隊裡近半數（59隊/45%）收斂到同一個「致富」intent，EXPAND/FOUND 全程雙掛零——世界個體故事豐富，總體宏觀敘事略顯扁平。

## Determinism / 樣本

單 seed(1337) 單跑，2個月窗。8隊 specimen 抽樣（strided，team_id 0/6/12/18/24/30/36/42），4174 entries，涵蓋全程 tick10-14400（抽樣隊無一在窗內死絕）。若要交叉驗證非 seed-artifact，需再加 42/8181 跑——這輪先出 seed1337 一份first-pass，是否值得加碼交叉驗證，交你/blueprint 判斷 ROI（考量 perf 天花板下每輪 2月窗本身就要跑 ~1.5-2 小時背景時間）。

## 落地檔案（已 commit `868e7a8b`）
- `scripts/debug/phase3_longterm_story_audit_bed.gd`（可重跑，`LW_MONTHS`/`SPECIMEN_SAMPLE_N` env 控）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.json`（月度curve+近期系統delta+終態總結）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.specimen.jsonl`（8隊×4174 entries 原始 motive/action/outcome）
- `docs/measurements/2026-08-12-phase3-specimen-narrative.txt`（8隊逐隊時間軸摘要，人讀版）

specimen 已另開一封 handback 送 QA 佐證（同 topic）。

routing 依 ticket：你 consolidate top incoherence 清單 → blueprint 推用戶排 fix 優先序 → 逐個 fix arc。
