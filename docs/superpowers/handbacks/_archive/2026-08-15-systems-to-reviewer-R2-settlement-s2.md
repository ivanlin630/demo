---
from: systems
to: reviewer
status: consumed
topic: "[R² settlement S2(L0營地階梯+L1工期)HOW審·spec=2026-08-15-settlement-S2-L0-camp-ladder-HOW.md·R①免(前提全file:line坐實)·審點:①★前提fact-check負斷言『outpost_level==0全樹=無據點空tile哨兵~10處(need_oracle:42/80/faction_ai:492/505/3293/4010/4119/4178/4213/5022)→L0必用獨立camp_level非level=0』窮盡否漏site否?+『camp_level窮盡零存在』確認否?②★設計:L0=camp_level獨立flag(outpost_level保持0語意正確L0非真據點)——是延伸統一or框架內冗餘(camp_level跟outpost_type/level重疊做重疊事?)③機制意圖對照:mechanism-intents『紮營vs建點』row(露宿免費/L0臨時無倉無居民/L1工期)+『蓋新點戰略三動機非亂蓋』——S2符否?④感知鐵律:L0選址採集讀腳下live(proximate合法同establish_crude_camp:4708)⑤補丁閘:工期中斷用既有busy-preemptible非新gate、establish_crude_camp拆非疊·此slice待R²CLEAN→S2a plan→dispatch(base post-crash main f9bb8283)·地基KEEP"
---

# R² settlement S2（L0 營地階梯 + L1 工期）HOW 審

spec=`docs/superpowers/specs/2026-08-15-settlement-S2-L0-camp-ladder-HOW.md`。R① 免（前提全 file:line 坐實）。

## 審點
1. **★前提 fact-check（負斷言、你的活）**：我斷言「`outpost_level==0` 全樹=**無據點/空 tile 哨兵** ~10 處（need_oracle:42/80、faction_ai:492/505/3293/4010/4119/4178/4213/5022）→ L0 必用獨立 `camp_level` 非 level=0（否則所有 guard 誤判 L0 為空）」+「`camp_level` 窮盡零存在」。**窮盡否？漏 site 否？**（若漏 site=L0 collision 面更大或更小）。
2. **★設計 sound**：L0=`camp_level` 獨立 flag（outpost_level 保持 0=語意正確 L0 非真據點）。是**延伸統一** or **框架內冗餘**（camp_level 跟 outpost_type/outpost_level 重疊做重疊事？能否既有欄達成？）。
3. **★機制意圖對照（新品質閘）**：`mechanism-intents.md`「紮營 vs 建點」row（露宿免費/L0 臨時無倉無居民身分/L1 工期）+「蓋新點=戰略三動機非亂蓋」——S2 設計符否？drift 否？
4. **感知鐵律**：L0 選址/採集讀腳下 live（proximate 合法、同 establish_crude_camp:4708 讀 team.tile_pos）。
5. **補丁閘**：工期中斷用既有 busy-preemptible(:415) 非新 gate、establish_crude_camp 拆（非疊補丁）。

## 時序
待 R² CLEAN → S2a plan → dispatch implementer（base post-crash main `f9bb8283`）。地基 KEEP。
