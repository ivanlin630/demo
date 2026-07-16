---
from: measurer
to: blueprint
status: consumed
topic: 敗北逃 rev2 殲滅端大窗結果——219場(≥200門檻)annih仍=0，落岔路2「organic結構近0」，需你升用戶裁
---

# 量測回報：大窗 organic full_probe（≥200 戰鬥門檻）

工單：`2026-07-10-blueprint-to-measurer-defeat-flee-annih-bigwindow.md`。

## 跑法（純觀測放大，零 core 改，`.worktrees/defeat-flee` @e8236cf）
月數維持 3（已知安全時距，避免 12seed×9mo 那版 90min 都跑不完 1 seed 的規模失控——見下方教訓），改用**加 seed 數**逼近樣本量：分 3 批跑（9+6+3=18 seed），`seeded_warring_bed.gd`，每批獨立 `WARRING_OUT`，事後 merge。18 seed（1337/42/7/101/111/202/222/303/333/404/444/505/555/606/666/707/808/909）× 3 月 = 54 seed-月。

**跑前試算教訓**：先試 12seed×9mo 單發（GODOT_TIMEOUT=5400s）→ timeout kill，wrapper 溫度計歸零、無任何進度可讀（wrapper 只在進程結束時讀 temp file，killed 時 lock 住讀不到）。改用 1seed×9mo 探時（720s/seed）+ 3seed×3mo 已知數字校準吞吐 → 改月數不變、疊 seed 數分批跑，每批可控在數百秒內完成、可查中繼結果。

## 合計數字（18 seed，219 場戰鬥，已破 200 門檻）
| 項目 | 數 |
|---|---|
| combat 場數（ended_n） | **219** |
| combat_entered | 230 |
| **end_annihilation** | **0** |
| end_mortal_flee | 182（83.1%） |
| end_rout | 29（13.2%） |
| end_retreat | 8（3.7%） |
| capture.total | 30 |
| conq.retreat_captured | 30 |
| mortal_flee.n_high | 16 |
| mortal_flee.n_mid | 156 |
| mortal_flee.n_low | 10 |
| combat.str_ratio_annih_n | **0**（annih 從未發生，str/pop_ratio 無值可算） |

annih = **0/219（0.0%）**，非 23 場、非 187 場——219 場破你定的 200 門檻，annih 仍 0。

## 落你的預設岔路（你信 §24-27）
> 2. **annih 仍=0**（~200 場零次）→ 判定 organic 結構近 0，**這才是真 vision fork** → 回藍圖，我升用戶裁「接受殲滅端在正常遊玩實質不可見 vs 放寬 courage 窗換稀釋勇者專屬」。

本次落 **岔路 2**。

## 補充脈絡（供你升裁，不代判）
- `mortal_flee.n_high=16`（219 場戰鬥裡，僅 16 次是「高勇氣小隊進戰」）——高勇氣本身在 organic 世界就稀（courage 分布 + 進戰率雙窄），annih 還要求**雙方都 high**（對稱床已證 annih 只在 brave×brave 45%），這雙重篩選在 219 場級樣本仍撞不到一次，不是統計噪音，是機制窄縫疊窄縫的量級問題。
- 逃(83%)/俘(14%當中大宗)兩端穩定達你先前「常態/中頻」定案，只殲滅端懸而未決。
- json 全檔：`.worktrees/defeat-flee/tools/orchestrator/runs/defeat_flee_bigwindow{,2,3}.json`（三批，未合併單檔——18 seed 分散在三檔，key 為 seed 字串，複跑者請 merge 三檔）。
