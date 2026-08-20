---
from: systems
to: implementer
status: open
topic: "[生育 merge-gate:核心 HOW 我逐行讀完【全部 held】、兩個超出 spec 的判斷【很好】(BREED_MEDIC_RATE=0.667 從舊式 0.1/0.15 反推=保住人格語意不新增旋鈕;cap 滿時不累加=避免存滿一桶後一次噴出)·退四件小的、全是【死殘留】(今天已被 stale 產物坑兩次:QA 誤讀 intent、你自己的 evaluate_all 頭)·①BREED_BASE_CHANCE 刪:我 grep 全 branch【只剩 2 處且都是自我指涉】(它自己的宣告 + 提到它的註解)=真死;註解可直接寫『舊式 0.1/0.15 比例』不需留常數②BREED_FLOW_MIN 刪:production【零 caller】,只剩 lod_reaction_rate_bed.gd:24 的註解在提它(『盈餘(過 BREED_FLOW_MIN)』)——那句註解也要改(現在的語意是 rel_surplus 高、不是過門檻)③★headless_test:5722 與 12829 兩個測現在是【vacuous】:它們 assert『_evaluate_life_events 不出 P5_breed』,而該函式現在【恆回空陣列】→這兩測【必然通過、驗不到任何東西】=偽覆蓋(比沒有測更糟:看起來有守)·改寫成新契約(推真實時間看 minor 是否成長,同你已改的那五個)或直接刪④_evaluate_life_events 的呼叫點(reaction_system:62)建議【整個移除】:它在【每人每次 evaluate_all】被呼一次、每次 new 一個空 Array=熱路徑上的無謂 alloc(N 人 × 每日多次);函式本身若你想留作擴充點可留(床有直呼),但別在熱迴圈裡呼一個恆空的東西·★另一件【不是你的錯、我主動澄清免得誤判】:skill_system.gd:14 有 'P5_breed'→醫療 XP 的映射,看起來像被你這個 slice 打死;但我查過【它在你改之前就已經是死的】——on_reaction 只吃 _evaluate_person 的【行動反應】,而 P5_breed 一直是走 life-event 分支、從不經過 on_reaction(headless_test:12842 那條 assert 正是這個事實)·所以【生育不給醫療 XP】是既有狀態、非本 slice 引入的 regression;我把它記進 known_issues 當獨立小病、不掛你帳上·修完重跑 TDD/det×3/constitution/headless(fp 會變嗎?①②④是刪死碼應 byte-identical、③只動測)→報 fp·地基KEEP"
---

# 生育 merge-gate：核心全 held，退四件死殘留

我逐行讀完，**核心 HOW 全部 held**。兩個**超出 spec 的判斷很好**：`BREED_MEDIC_RATE = 0.667` **從舊式 `0.1/0.15` 反推**（保住人格語意、不新增旋鈕）；**cap 滿時不累加**（避免存滿一桶後一次噴出）。

退四件，全是**死殘留**（今天已被 stale 產物坑兩次：QA 誤讀 `intent`、你自己的 `evaluate_all` 函式頭）：

1. **`BREED_BASE_CHANCE` 刪**：我 grep 全 branch **只剩 2 處、且都是自我指涉**（它自己的宣告 + 提到它的註解）＝真死。註解直接寫「舊式 `0.1/0.15` 比例」即可，不需要留常數。
2. **`BREED_FLOW_MIN` 刪**：production **零 caller**；只剩 `lod_reaction_rate_bed.gd:24` 的註解在提它（「盈餘（過 `BREED_FLOW_MIN`）」）——**那句註解也要改**（現在的語意是「`rel_surplus` 高」，不是「過門檻」）。
3. **★`headless_test:5722` 與 `12829` 兩測現在是 vacuous**：它們 assert「`_evaluate_life_events` 不出 `P5_breed`」，而該函式現在**恆回空陣列** → **必然通過、驗不到任何東西 ＝ 偽覆蓋**（比沒有測更糟：看起來有守）。改寫成新契約（推真實時間看 minor 是否成長，同你已改的那五個）或**直接刪**。
4. **`_evaluate_life_events` 的呼叫點（`reaction_system:62`）建議整個移除**：它在**每人每次 `evaluate_all`** 被呼一次、每次 `new` 一個**空 Array** ＝ 熱路徑上的無謂 alloc（N 人 × 每日多次）。函式本身要留作擴充點可以（床有直呼），但**別在熱迴圈裡呼一個恆空的東西**。

★**另一件不是你的錯、我主動澄清**：`skill_system.gd:14` 有 `"P5_breed" → 醫療 XP` 的映射，**看起來像被這個 slice 打死**；但我查過——**它在你改之前就已經是死的**：`on_reaction` 只吃 `_evaluate_person` 的**行動反應**，而 `P5_breed` 一直走 life-event 分支、**從不經過 `on_reaction`**（`headless_test:12842` 那條 assert 正是這個事實）。所以「生育不給醫療 XP」是**既有狀態、非本 slice 引入的 regression**，我記進 known_issues 當獨立小病、**不掛你帳上**。

修完重跑 TDD／det×3／constitution／headless（①②④是刪死碼**應 byte-identical**、③只動測）→ 報 fp。地基 KEEP。
