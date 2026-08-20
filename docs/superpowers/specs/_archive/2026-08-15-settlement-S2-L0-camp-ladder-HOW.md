# settlement S2：L0 營地階梯 + L1 工期（HOW / systems）

status: DRAFT→R²（2026-08-15）
owner: systems（HOW）← design `2026-08-14-settlement-lifecycle-agriculture-design.md` §2 + HOW spec §2
溯源：12mo 期末考深根（碎裂→non-viable 小團→崩塌）→ S1 merged（鬼城釋放）→ crash merged（12mo 解封、深根 pop-87.4% 乾淨可測）→ blueprint 裁 S2 next（viability 層直攻餓）。

## §0 命門（HOW 守、整檔驗證後）
- **★L0 用獨立 flag `tile.camp_level`、非 `outpost_level=0`**（**驗證 blocker**）：`outpost_level==0/<=0` 全樹 = **「無據點/空 tile」哨兵**（★**真窮盡 grep no-head、47 站跨 14 檔**：faction_ai 18/outpost_system 7/order_system 5/player_command 3/resource_system 2/observer_query 2/harvest 2/need_oracle 2/state_fingerprint 1/player_query 1/manufacturing 1/interaction 1/game_setup 1/food_flow 1。**★R² 訂正**：初稿「~10 處」是我 grep 誤用 `head` 截斷成 faction_ai 單檔子集=第 8 次負斷言 head-undercount、reviewer 親 grep 抓；方向不變**更強**）。L0 若設 outpost_level=0 → 全 47 guard 把 L0 當空 tile（採集/認領/facility/升級鏈全誤判）。∴ **L0 = `outpost_level` 保持 0（語意正確：L0 非真據點、無設施/倉/領土）+ 新 `tile.camp_level: int`（0=無、1=L0 營地）標 transient shelter**。既有 47 guard 全不動（L0 對它們＝正確地「還不是據點」）、camp 專屬邏輯讀 camp_level。
- **★★state_fingerprint:119 determinism 要害（R² 必查項）**：現 fp 於 `t.outpost_level<=0 and construction_team_id==-1` 條件下**跳過該 tile**（:119-122）→ L0（outpost_level 保持 0、無 construction）當前**不入 fingerprint** → camp_level 狀態變化對 determinism **不可見**（盲點 + determinism gap）。∴ **S2a 必顯式把 `camp_level` 納入 state_fingerprint**（:119 條件擴充或 :122 欄位加），否則 fp intended-change 驗證抓不到 L0 變化。
- **禁 crank / 禁死常數 pop 曲線**（design §0）：viability 由工期+地形物理湧現、L0 採集低倍率**單旋鈕**。
- **感知鐵律**：L0 選址/採集讀腳下 live（proximate 自站處合法、同既有 :4708 establish_crude_camp 讀 team.tile_pos）；跨距目標選擇走 belief（S1b 既有）。
- **守恆**：L0 採集走既有 harvest chokepoint（不新開生成路）。

## §1 現況（窮盡驗證、負斷言附證）
- `establish_crude_camp`(faction_ai:4707)：**現直建 L1 免費瞬間**——`outpost_level=1`(:4718)、無工期無建材、type by leader 好戰/野心(:4716)、`OutpostOwnerBank.set_owner(...,"camp")`(:4721)、抬 food cap CRUDE_CAMP_FOOD_SEED(:4724 不送即時糧、2026-06-16 A/B 量測即時糧非 load-bearing)、tag 躍遷(:4726)。
- `camp_level`：**窮盡搜零存在**（grep camp_level scripts/ 非 test = 0 命中）→ 新欄、無撞。
- busy-preemptible(:402-416)：`_busy_preemptible = current_task in PREEMPTIBLE_TASKS`、忙且不可 preempt→原行為(:405)、壓境「能傷你」威脅才打斷(:415)。**存在、S2b 工期中斷複用不新發明**。

## §2 Slice 拆分（TDD、每 task 跑 headless 驗）
### S2a：紮營=L0（establish_crude_camp 拆出 L0 階）
- **新 `HexTileData.camp_level: int = 0`**（0=無、1=L0；state_fingerprint 納入=determinism）。
- **拆 `establish_crude_camp` → 紮營建 L0**：改為設 `camp_level=1`（**不** set outpost_level、**不** set_owner=真領土宣稱）+ tag 躍遷（定居/流浪界線從 L1 起→**L0 tag 待議**：spec design §2「L0 無居民身分」→ L0 **不**清流亡/不升 PRODUCE tag（勞力池從 L1 起）；team 標 camping 狀態 via tile.camp_level + team.tile_pos 對位）。**拔營無沉沒**：離開/棄置 camp_level→0（無廢墟、地圖自清）。
- **L0 採集（最低、單旋鈕）**：L0 隊採集讀**腳下 tile 池現量**（既有 harvest 路）、低倍率 `L0_FORAGE_MULT`（單旋鈕 TEST VALUE、禁 pop-curve）；**遊牧循環湧現**=池吃乾→移（再生率只定久留線非產糧公式）。**無**倉/農田/設施/稅/領土。
- **L0 衰敗**：棄置 `L0_DECAY_DAYS`（TEST VALUE）自動 camp_level→0（物理、cadence tick 掃）。只 L1+ 留廢墟（=S1 可認領鬼城；L0 消失無痕）。
- **TDD**：①camp_level 欄存在+**顯式納 state_fingerprint**（:119 條件/欄位、L0 變化 fp 可見）②紮營設 camp_level=1 不設 outpost_level（既有 level==0 guard 不誤判）③L0 隊採集腳下池（低倍率、池竭移動）④棄置 L0_DECAY_DAYS 後 camp_level→0 無廢墟⑤L0 不清流亡不升居民 tag（勞力池不含 L0）⑥**★R² 必查項:回歸驗最要害 consumer 不被 L0 誤觸**——`outpost_system.gd` 升級鏈 7 站（446/469/511/638/658/681/745：L0 camp tile 不被當可升級/可建 outpost）+ `state_fingerprint:119`（L0 tile determinism 正確）+ 抽驗 order_system(5)/harvest(2)/need_oracle(2) 代表（L0 不被當市集/採集據點/oracle 據點）。非只驗 faction_ai 既有清單。

### S2b：建點=L0→L1（數天勞力工期=viability 過濾）
- **建點動作**：L0（camp_level=1）隊決策「紮根」→ 進 L1 建造工期（`outpost_level 0→1`、數天勞力）；期間 current_task=建設（既有 TASK 或新 camp→L1 transition state）、**不覓食=機會成本**。
- **工期中斷=既有 busy-preemptible**（:415、高門檻壓境威脅才打斷、不新發明）；中斷則工期作廢/暫停（TEST VALUE 決定 resume or restart）。
- **完成 L1**：outpost_level=1 + set_owner（真領土宣稱從 L1 起）+ 居民 tag 躍遷（勞力池納入）+ 既有 L1 語意（倉/設施/農田資格）。=現 establish_crude_camp 的 L1 部分**移到工期尾**（非瞬間）。
- **付不付得起工期=湧現過濾**（design §2）：瀕餓碎片工期中餓死/被 preempt→建不成（正確湧現、零硬門檻）；健康團付得起。
- **TDD**：①L0 隊選紮根→進 L1 工期（outpost_level 仍 0 期間）②工期數天勞力、期間不覓食③壓境威脅 busy-preempt 打斷工期④完成→outpost_level=1+set_owner+居民 tag（勞力池納）⑤瀕餓團工期中餓死→建不成（viability 過濾湧現、非崩）。

## §3 gate（measurer bounded、綠才 merge）
1. **L0/L1 界線真**：L0 隊無倉/設施/不入勞力池、L1 才有（勞力/居民/領土從 L1 起）。
2. **紮營廉價、建點有成本**：L0 快速無沉沒、L0→L1 數天勞力（付不付得起湧現過濾=瀕餓建不成、健康建得成）。
3. **不破既有**：level==0 guard 全不誤判 L0（camp_level 獨立）、S1 認領（既有 outpost）不受影響、determinism byte-identical（camp_level 純狀態）。
4. **L0 採集低倍率單旋鈕**：無 pop-curve、遊牧循環湧現（池竭移動）。
5. constitution 綠。fp intended-change（L0 階梯=行為變、紮營不再瞬間 L1）。

## §4 界外
- 農田產糧本體=§3 農業 slice（S2 後、L0 只採集不種田）。
- 軍事選址/植林/L0 生產能力=next arc（design §6）。
- B6 小團地板（勞力池<farming 門檻）：L0 吊命落位此 arc、B6 原題（地板機制）不動（design §2「B6 落位」）。

序：R² 審此 HOW → CLEAN → S2a plan → dispatch → gate → merge → S2b → 農業。地基 KEEP。
