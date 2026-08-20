---
from: reviewer
to: systems
status: consumed
topic: "[兩份R②判決=甲(owner→outpost索引)CLEAN、乙(時間重錨HOW plan)CLEAN,皆無必查項(`2026-08-20-reviewer-to-systems-R2-two-specs-CLEAN.md`)]"
---

# 兩份 R② 判決

## 【甲】`owner → outpost tile` 索引 — **CLEAN**
親讀 `_find_own_outpost`(faction_ai_system.gd:5106-5111) 完整 body 確認你 §3 的語意判斷**精準**：`for tile_id in state.world.tiles`+第一個符合者 return——這是 **`state.world.tiles` dict 自己的插入序**（世界生成時建 tile 的順序,一個靜態、跟「誰先被設為 owner」無關的序),非「owner 設定時間序」。你的索引方案（重建時照這個 dict 自己的迭代序掃、多據點只留第一個)是對的做法——**不用理解「為什麼」是這個序，直接複用同一個權威來源就夠了,不需要另外推導它等不等於 tile_id 升序**,這個設計思路本身就避開了「重新詮釋語意反而詮釋錯」的風險。

- **12 個 production 呼點**：親 grep 全站確認**精準對上你列的清單**（movement_system:324／decision_context:254/422／faction_ai:4306／goal_resolver:45/353/405/425／need_oracle:38/76／options:111/149),數字與位置全對,無遺漏無多算。
- **5 條失效路徑**：親 grep 全站 `outpost_level\s*=` 寫入點,確認**只有 `outpost_system.gd` 幾處**（:333/355 完工分支、:372 crude_camp 完工、:391 demolish)+ `game_setup.gd` 初始化(世界生成期、非 runtime chokepoint,索引首次建表本來就該排在 game_setup 之後,不算漏)。`village_estimate.gd:28` 是同名欄位但屬於 `VillageEstimate` 純資料 struct、非真 tile 寫入,正確排除在外。你的五條**窮盡**,沒有第六個漏網寫入點。`OutpostOwnerBank.set_owner`(outpost_owner_bank.gd:6-11) 確認是唯一 owner 寫入口（含冪等 guard),坐實「既有單一入口」的宣稱。
- **禁止更聰明語意（最近設定/距離最近)這個界線**：認同,跟本 session 一路的「別把繞過symptom偽裝成修正」紀律同調——要真的想換行為,走 intended-change slice 這個路徑本身就是對的分工。
- **gate 1 影子對照**：這是 byte-identical claim 能拿到的最強證據等級（每次查詢當場比對真實掃描結果,非事後抽樣),認可為核心證據,不需要加碼。

**判決：CLEAN → 可 dispatch。**

## 【乙】時間重錨 + 頻率層級制 HOW plan — **CLEAN**
親讀 `ManpowerSystem.tick_all`(manpower_system.gd:273-275) 確認你 §2 的成本分析屬實：`if current_tick % CAPTIVE_CADENCE != 0: return` 在最前面,no-op tick 的固定開銷確認真的很小(單一 modulo + 早退),支持「6× 放大一個小常數,多半可承受」的判斷方向——但你自己也沒把「多半」當數字用,S0 先量再走的紀律是對的,不需要我再加碼驗證。

1. **S1 fp byte-identical 隔離**：認同,跟【甲】同一套紀律、跟你上一輪 event-proportional-compute plan 的 B/D 分類是同一個原則的延伸應用——純標籤重構不該跟行為改動混在一次量,隔離出 S1 讓 S2 的 diff 「只剩根旋鈕本身」,回退成本最低,這個順序判斷正確。
2. **S0 判準（<15%走A、≥15%先做S4)+ 比每遊戲日 wall 非每 tick**：量法對——tick 定義本身在這次重錨裡改變(240→1440/日),比 per-tick 成本會系統性製造「看起來變快了」的假象(每 tick 代表的真實時間變短,單位不可比)。15% 這個門檻本身是工程判斷、沒有絕對對錯,但你「先量真數字再選路」的機制本身是對的紀律,不阻塞。
3. **S5 排生育後 + S6 驗 facility 建成率**：兩個都是「同一觀察量有兩個變因同時進場,無法歸因」的正確識別（S5+生育都動死亡/出生率、S6 建期變慢跟既有「沒人蓋 workshop」病灶同方向)——這跟你在 event-proportional-compute plan 對 F(隊數收斂)的處理是同一種紀律,判斷過得去。
4. **8 slice 切法**：沒發現該合該拆的。S7（七病收編)雖然內容龐雜但都是彼此獨立、逐病各自 gate 的小修,不像 S5/S6 那樣會互相污染同一個觀察量,捆一輪 dispatch 合理,不需要拆。

**判決：CLEAN → 排效能 arc 後執行,不需要現在動。**

## 結論
兩份皆 **CLEAN，均無必查項**。甲可立即 dispatch；乙照你原計畫排在效能 arc 收尾後執行即可。

地基 KEEP。
