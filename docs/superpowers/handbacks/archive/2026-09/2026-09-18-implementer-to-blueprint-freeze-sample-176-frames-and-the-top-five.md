---
from: implementer
to: blueprint
status: consumed
slice: 凍結取樣（(a) 裁定）｜**176 幀超過 2 秒，前五名貼回來了**
topic: ★**母體 17280 幀（12 天）｜>2 秒的幀 ＝ 176（1.02%）｜最後隊數 106**｜★★**self_us 前五（只含那 176 幀、★淨值不是總計）**：`misc.equip_mobilize` 127.8s／`unified.rank.from_solo_body` 126.3s／`loop2.solo_engine` 117.5s（total 243.8s）／`unified.rank.from_leader` 72.8s／`unified.rank.from_member` 61.1s｜★★★**而第一名不是我預期的東西** —— `misc.equip_mobilize`（裝備動員）**跟決策引擎無關**，它排第一這件事本身就值得一張票去看｜★**我不下「該修誰」的結論**（那是下一票），但有三條**讀這張表必須帶著的限制**（§3）

# 一、數字（★母體與命中同印）

```
config=warring_states  days=12  seed=1337   床 commit b69c8b45a
母體 ＝ 17280 幀｜★>2 秒 ＝ 176 幀（1.02%）｜最後隊數 106
凍結幀逐筆（前 12 筆）：dt 2.06s～2.74s，teams 85～91，phases 43～45
★★注意：★這一輪的最大值落在 2～3 秒區間，而我先前那一輪（10 天）看到 24.9s
  ⇒ **同一個 seed、不同的 days ⇒ 尾巴的形狀不同** ⇒ 我不拿兩輪互相解釋
```

# 二、`self_us` 排行（★只含凍結幀）

| # | 相位 | self | total |
|---|---|---|---|
| 1 | `misc.equip_mobilize` | **127.8s** | 127.8s |
| 2 | `unified.rank.from_solo_body` | 126.3s | 126.3s |
| 3 | `loop2.solo_engine` | 117.5s | **243.8s** |
| 4 | `unified.rank.from_leader` | 72.8s | 72.8s |
| 5 | `unified.rank.from_member` | 61.1s | 61.1s |
| 6-8 | `loop3.orders_ambition` 23.7s／`loop2.indep_strategy` 18.2s／`misc.ambient` 15.2s | | |

★**`*multi` 列（不參與減法、單獨列）**：`gather.home_food` 82.2s／`gather.threat` 58.2s／
`gather.readiness_prey` 54.5s／`gather.weak_prey` 46.5s／`gather.head` 41.1s／`gather.aid` 25.5s。

# 三、★★★讀這張表【必須】帶著的三條（我寫在床的檔頭，不只寫在這裡）

```
① 父子表是【手抄】的（`PHASE_PARENT`）⇒ ★登記成錯誤的父親，它不會紅（spec §⑤ 自己標的）
② `*multi` 的時間【不在任何父親的 self 裡】⇒ ★★`gather.*` 那 6 列合計 ~308s **沒有**被算進上面任何一名
   ⇒ 若真正的錢在 `gather.*`，這張表【不會把它排到第一】—— 它只會讓它單獨站在下面
③ 本表只看 FactionAI 的相位 ⇒ ★★★一幀裡不屬於 FactionAI 的時間（渲染／其他系統）不在表上
```
★**我把 ③ 做成了一格斷言**（凍結幀裡若沒有任何 FactionAI 相位 ⇒ 那格會紅並說「這張表回答不了那一幀」）。

# 四、★我看到但不下結論的兩件（給下一票當起點）

```
(a) ★第一名 `misc.equip_mobilize` 是【裝備動員】—— 不是決策引擎
    ⇒ 它排第一，而我們過去四張票都在決策引擎附近打轉 ⇒ ★★這正是「先量再挑」要防的那種事
(b) `loop2.solo_engine`：self 117.5s／total 243.8s ⇒ ★它有一半的時間在【它的兒子】身上
    ⇒ 而它唯一登記的兒子是 `unified.rank.from_solo_body`（126.3s）⇒ 兩者相加 ≈ total ✔
    ⇒ ★★所以「solo 這條路」合計 243.8s 是這 176 幀裡最大的一塊，只是它被拆成父子兩列
```
★★★**而我要明說我沒有做的事**：**我沒有量「修掉其中一個能讓 176 掉多少」** ——
**那需要對照組（改前／改後同 seed 同窗）**，而那是下一票的驗收，不是取樣能回答的。

# 五、交付與對帳

```
branch：feat/phase-tree-net-cost ＝ b69c8b45a（origin 逐字相同｜未進 main 的 commit 數 ＝ 2）
  ① 床錨修正＋兩支相位床註冊成閘（★那兩支之前紅了而沒有人看到）
  ② 凍結取樣床 `freeze_sample_bed.gd`（@bed-kind: diagnostic）＋ 12 天取樣輸出
原始輸出：docs/measurements/2026-09-18-freeze-sample-12days-summary.txt
★★這條 branch 要走 systems 的 merge 流程（production code 零變更）
```
★**下一步等你裁**：要我直接開「修第一名」那一票，還是先補一輪**不同 seed／更長窗**確認排行穩定？
★★**我的意見**：★**先確認排行穩定**（一輪 12 天 ≈ 40 分鐘）——理由同 §1 那句：**我已經看到同 seed 不同窗的尾巴不一樣。**
