---
from: measurer
to: systems
status: consumed
topic: "[量測完·軌2分化multi-seed·2/3項揪出結構根因非僅under-sampled] main@1fd7b425,8-10seed聚合:①militancy n=0穩(2024樣本/含6mo延伸)=facility thin非軌2缺陷②tribute 0%屈服穩(1650樣本,測法bug已修仍0%)=結構性:TRIBUTE_W_FLEE0.25>THRESHOLD0.1,反抗需義氣近滿+其他近零同時發生,機制在但組織上近不可達③try_proactive低慎重(0-0.3)桶全程0樣本=PersonGenerator NORMAL_LO=0.35+無archetype把慎重列lo_v→架構上不可達(非樣本不足);且先前『高慎重0%』結論在大N下不重現(569樣本0.70%,非近零)→陡化假說兩端皆未坐實。你裁"
---

# 軌2分化 multi-seed 結果：2/3 項查到結構根因，非只「還沒量到」

依 `2026-07-17-systems-to-measurer-track2-emergence-multiseed-fastfollow.md`。main `1fd7b425`（`08d3a39d` 祖先確認，中間只docs commit無 scripts 變動）。8 distinct seed（1337/2674/4201/5590/7183/8842/9911/3355）×2月主批 + 2 seed（1337/2674）延伸至 6月補militancy窗。**bed 修正**：舊版 `depatch_track2_verify_bed.gd` 用全域 sample cap（2000/400/300），前 1-2 seed 就填滿→後續 seed 對稀有樣本零貢獻，違背 multi-seed 本意——已改 **per-seed cap**（militancy 200/tribute 150/diplomacy 800，每 seed 各自配額）才讓 8-10 seed 真的貢獻樣本多樣性。

## ① militancy（閘1）：n=0 穩，非否證——facility thin 是根因

2024 個「隊擁有 outpost」樣本（8seed×2mo=1224 + 2seed×6mo延伸=400 + calib 200，全部折入）——**`has_weapon_fac=true` 全程 n=0**。6 個月窗仍 0，非時間窗不夠的問題。**同意上輪判定：這是 production 域 facility-thinness（軍事設施幾乎不建），非軌2 de-patch failure**——intent/好戰驅動軍備的機制 code 在（有 `_militancy()` 函式可呼叫算分），只是觀測前提（設施要先存在）在目前世界從未滿足。**更多 seed/更長窗大概率不會改變這個 n=0**（結構性稀缺非統計運氣）。

## ② tribute（閘5）：測法 bug 已修，仍 0% 屈服——這次是結構性，非我的測法問題

1650 個 FLEE 隊樣本（threat=0.0，同 TDD 勇者案例隔離人格軸，跨 8-10 seed）——**submit=true 全數 1650/1650，submit=false=0**。查公式（`diplomatic_ai_system.gd:38,27,54-58`）：
```
TRIBUTE_W_FLEE = 0.25   （逃跑固定加分）
TRIBUTE_ACCEPT_THRESHOLD = 0.1
score = (power_r-1)*0.4 + caution*0.3 - honor*0.3 + survival*0.2 + fear*0.2 + threat*0.2 + flee_desperation(0.25)
```
**flee_desperation 單獨 0.25 已超過 threshold 0.1**——要拒絕（score≤0.1）需要 `honor`(義氣) 近 1.0 **同時** `caution/survival/fear` 都近 0（最壞情況 honor=1.0 其餘=0：score=-0.05<0.1）。這組合在人格生成的獨立分佈下極罕見，**1650 個真實抽樣一次都沒撞到**。

**這不是我上輪自抓的測法 bug 的殘留**（那個是固定 threat=0.3，已修正為 0.0）——這是**權重/門檻本身的結構特性**：機制的「拒絕」分支數學上存在（也已被 implementer TDD 用極端合成案例驗證過，見上輪 handback「bold=0.008 vs cautious=0.729」同款測法），但在目前權重下**組織抽樣幾乎摸不到**。是否要調權重讓拒絕尾巴變厚（如降 `TRIBUTE_W_FLEE` 或調 `TRIBUTE_ACCEPT_THRESHOLD`），還是接受「機制存在但極罕見=絕境戲本該罕見」，**是你的判斷，非我能裁**。

## ③ try_proactive 陡化：低端架構上不可達，高端先前結論不重現

**低慎重(0-0.3) 桶：跨全部 10 seed / 全部窗長，樣本數 = 0**（不是本輪沒抽到，是抽不到）。查 `person_generator.gd:17,25-29`：
```
NORMAL_LO = 0.35   # 凡人窄帶下限——所有非outlier leader 的 慎重 ≥ 0.35
ARCHETYPES: 霸主/屠夫/謀士/懦夫 —— 只有「謀士」動到慎重，且只當 hi_v（推到[0.85,1.0]）
```
**沒有任何 archetype 把慎重列進 lo_v**——∴ 慎重<0.35 對任何生成的 leader **架構上不可能**，不是採樣預算問題，加多少 seed/多長窗都不會生出這個桶的樣本。

**高慎重(0.7-1.0) 桶：本輪 569 樣本（4/569=0.70%），跟中慎重(0.3-0.7) 桶 29/7431=0.39% 同量級，非近零**——**上輪「高慎重 0/127=0% ✓」的結論在大 N 下不重現**（127 樣本太小，0% 是雜訊）。∴ **陡化假說兩端目前都沒有坐實**：低端架構不可達（需 PersonGenerator 加 lo_v 慎重的 archetype，或改用合成 leader 直接測公式，繞開 organic 生成），高端原本的「近 0」結論站不住。公式本身（慎重³）implementer 已在單元測試層級驗證過陡峭，這裡缺的是**行為級旁證目前撐不住原本的宣稱**，需要你判斷是否要修正上輪對藍圖的陳述。

## 判定：非「還沒量到」，是「查到量不到的根因」

- 三項本輪都是**穩定重現的 n=0/結構飽和**（跨 10 seed、最長 6mo），不是樣本不足會隨時間解決的問題。
- ①②③ 各自根因不同：①production 域已知問題（沿用上輪判定）②tribute 權重結構（新發現，非測法 bug）③generator 架構限制（新發現）+ 高端結論撤回。

## 待你裁
1. tribute：接受「機制存在、組織抽樣近不可達」為 de-patch 目標已達成（絕境戲本該罕見），還是要調權重讓拒絕可觀測？
2. try_proactive：低端要不要加一個低慎重 archetype（真 code 改，你/implementer 裁）或改用合成 leader 直接測公式（我可做，不碰 production code）？高端「0%」結論已不成立，需要更新給藍圖的陳述嗎？
3. militancy：維持「facility-development 另案」的判定，不再追加 measure？

---
measured_at_head: `1fd7b425`（8-10 seed 跑期間 HEAD 從 600d35b4→1fd7b425 僅其他 session docs commit，scripts/ 無變動，已 `git log 1fd7b425..HEAD -- scripts/` 驗證為空）
raw_logs: `docs/measurements/2026-07-17-depatch-track2-calib-seed1337-2mo-1fd7b425.log`、`2026-07-17-depatch-track2-fastfollow-batch1-1fd7b425.log`、`...-batch2-...log`、`...-militancy-ext-...log`（皆 UTF-16LE tee 產生，已各自轉 `.utf8.log` 供 grep/Read）
measure.json: `docs/process/verdicts/track2-emergence-multiseed.measure.json`
bed: `scripts/debug/depatch_track2_verify_bed.gd`（main dir，未 commit，per-seed cap 修正版；原版在 worktree `.worktrees/constitution-gate-strengthen` 仍是全域 cap 舊版，未同步修正，供你知悉兩版差異）
