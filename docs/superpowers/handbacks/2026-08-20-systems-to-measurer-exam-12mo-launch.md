---
from: systems
to: measurer
status: open
topic: "[★★12mo 大考啟動(等我 merge 綠即轉 open;若你先看到請等我改 status)·HALT 已解除條件:LOD 紅線修 merged(個體反應層不再綁玩家位置=世界不再靜止)·床=scripts/debug/exam_12mo_bed.gd(已在 main、純觀測 fp byte-identical)·★跑法:tools/godot-detach.ps1 型長跑、【必帶 --path 絕對路徑】(血證:省略=res:// 解析失敗整輪白跑)、增量落檔(被 reap 也留 partial)·env:PERF_SEED=1337 LW_CONFIG=<peaceful_economy 與 warring_states 各一輪> LW_MONTHS=12 WARRING_OUT=<jsonl 絕對路徑> WARRING_PROGRESS=<sidecar> SPECIMEN_SAMPLE_N=<夠 QA 讀故事的量、你判>·★這是【第一次在活著的世界】跑大考(修前 reactions 全期零執行=生育/士氣/暴動/叛/怠工全死)→所有數字都是【新基線】、不要跟舊輪比(舊基線量於零出生+零士氣變異的世界、已在 progress 註記)·★必看清單(床已內建欄位、你只要確認有值+在 verdict 點名):①phase_us 六階段 breakdown+n_teams 隨時間→【scaling 曲線=單一連續 run 內 N 自然成長=唯一能乾淨回答 O(N) vs O(N²) 的機會】②mint_level 分佈(監看項回鍋、鑄幣一直有在跑、0% 若持續=查設施鏈)③瞬時 daily_rate 的 zero/neg 隊數(零產出卡死病型)④site_memory.write vs applied(§4c 記憶被 MEMORY_MAX 擠掉多少)⑤need.ewma_advance vs budget(每隊每 tick<=1 在長窗仍守住否)⑥starve 明細(瞬時非 EMA)+這輪的 attrition=【新的真 accepted cost 紀錄】⑦政治家族計數(外交/結盟/背叛=政治質地)⑧統領分佈+effective_pop_cap 分佈(科目 A『世界是否領導荒』)⑨★人口曲線(修後第一次真的會有出生:村莊長不長得起來、擴點門檻 pop>=12 這次會不會被摸到)·★出 .measure.json + specimen dump 落地 path 明寫 → handback to:qa(故事稽核經濟四科目)副本 to:systems·★誠實優先於完整:跑不完/被 reap 就報跑到哪、partial 也有價值,禁湊數字·地基KEEP"
---

# ★★12mo 大考啟動（HALT 解除）

**解除條件已達**：LOD 紅線修 merged ＝ 個體反應層不再綁玩家位置、**世界不再靜止**。

- **床**：`scripts/debug/exam_12mo_bed.gd`（已在 main、純觀測、fp byte-identical）。
- **★跑法**：`tools/godot-detach.ps1` 型長跑、**必帶 `--path` 絕對路徑**（血證：省略＝`res://` 解析失敗、整輪白跑）、**增量落檔**（被 reap 也留 partial）。
- **env**：`PERF_SEED=1337`、`LW_CONFIG=`（`peaceful_economy` 與 `warring_states` **各一輪**）、`LW_MONTHS=12`、`WARRING_OUT=`（jsonl 絕對路徑）、`WARRING_PROGRESS=`（sidecar）、`SPECIMEN_SAMPLE_N=`（夠 QA 讀故事的量、你判）。

★**這是第一次在「活著的世界」跑大考**（修前 `reactions` 全期零執行＝生育/士氣/暴動/叛/怠工全死）→ **所有數字都是新基線**，**不要跟舊輪比**（舊基線量於「零出生 + 零士氣變異」的世界，已在 `progress` 註記）。

## ★必看清單（床已內建欄位，你只要確認有值 + 在 verdict 點名）
1. `phase_us` 六階段 breakdown + `n_teams` 隨時間 → ★**scaling 曲線**＝單一連續 run 內 N 自然成長＝**唯一能乾淨回答 O(N) vs O(N²) 的機會**。
2. `mint_level` 分佈（監看項回鍋；鑄幣一直有在跑，0% 若持續＝查設施鏈）。
3. 瞬時 `daily_rate` 的 zero/neg 隊數（**零產出卡死**病型）。
4. `site_memory.write` vs `applied`（§4c 記憶被 `MEMORY_MAX` 擠掉多少）。
5. `need.ewma_advance` vs budget（每隊每 tick ≤1 在長窗仍守住否）。
6. starve 明細（**瞬時、非 EMA**）+ 本輪 attrition ＝ **新的真 accepted cost 紀錄**。
7. 政治家族計數（外交/結盟/背叛＝政治質地）。
8. 統領分佈 + `effective_pop_cap` 分佈（科目 A「世界是否領導荒」）。
9. ★**人口曲線**（修後第一次真的會有出生：村莊長不長得起來、擴點門檻 pop≥12 這次會不會被摸到）。

**出** `.measure.json` + specimen dump **落地 path 明寫** → handback **to:qa**（故事稽核經濟四科目）、副本 to:systems。
★**誠實優先於完整**：跑不完/被 reap 就報跑到哪，partial 也有價值，**禁湊數字**。地基 KEEP。
