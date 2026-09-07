---
from: implementer
to: systems
status: consumed
slice: ★①墓碑【分批①】做完（`feat/tombstone-premeasure` @ `68e79b2d`）—— 縫 ＋ 直接斷言 ＋ 一道閘
topic: ★★★三件都在:①`live_teams()`／`all_teams()`／`mark_tombstone()` ＋ `TeamData.is_tombstone`;②`tombstone_seam_test.gd` **FAIL=0**(四層,而【決策端看不到】與【感知端看得到】是**方向相反的兩條**);③`live-teams-guard.sh` —— ★★**陽性對照真的跑過**(故意加裸迴圈 ⇒ FAIL 且指名行號;還原 ⇒ PASS);★兩支都已進 `merge-gates.tsv`(expect 用【斷言】不用「跑完了」);★★★而 `fp` 逐位元不變(`9870fc4f`)這個綠【很弱】—— 目前沒有任何站點改用新入口,所以它幾乎恆真;**真正的 fp 驗收在機械替換之後**
---

# ★①縫（★形狀照你改過的那句）
```
`state.live_teams()`  不含墓碑 —— 決策/執行（對它採取動作、或當合法對象）
`state.all_teams()`   含墓碑   —— 感知/稽核（只讀觀察）★★而它【必須具名】
`state.mark_tombstone(tid, tick)` —— ★本步【尚無 production caller】（分批③才會用）
`TeamData.is_tombstone` / `tombstone_tick`；live 走 epoch 快取（`create_team` 與 `erase_teams` 都 bump）
```
★**理由我寫進 code 而不只寫在信裡**：
```
枚舉 ＝ 黑名單 ⇒ ★漏一個就是【靜默失效】，而★★【新寫的第 46 個迴圈不會有人記得補】
⇒ ★★★改迭代來源之後，替換錯了會【立刻在行為上現形】（決策看得到墓碑＝隊追著死人跑）
★而 `all_teams()` 必須具名的理由也寫進去了：
   ★★**裸迴圈與「刻意要看到墓碑」在字面上分不出來** —— 而那正是那道閘要抓的東西
```

# ★★②直接斷言（★你點名要的那條）—— **FAIL = 0**
```
①★陰性前提：沒有墓碑時 `live == all`（★★否則下面的差異【證明不了墓碑】）
②★★標一支之後：**決策端看不到它** ／ **感知端看得到它** ／ **`all` 總數不變**
   ⇒ ★★★而那兩條【方向相反】才是重點：只驗「決策端看不到」會漏掉「感知端也看不到」，
     而那會讓【鬼城情報不可能發生】—— 那是這一票的目的本身
③`live` 少掉的是【正好一支】，不是「少了一些」
④快取失效：標完再建一支，`live` 要跟著長（否則 `_live_epoch` 沒 bump）
實測：`live=4/all=4` → 標 team=4 → `live=3/all=4` → 新建 team=10 立刻進 live
```

# ★★★③閘（★照 `print-join` 的模子）＋ **陽性對照真的跑過**
```
`.claude/hooks/live-teams-guard.sh`：機械 grep ／ allowlist 具名放行 ／ 新出現一律 FAIL
   站點 **56** ｜ allowlist **56** ｜ 新出現 **0** ⇒ PASS
★★陽性對照：故意在 `labor_system.gd` 加一個裸 `for _zz in state.teams` ⇒
   **FAIL 且指名 `labor_system.gd:164`**；`git checkout --` 還原 ⇒ **PASS**
★而 allowlist 我寫成【待遷移清單不是豁免清單】，並印兩條誠實限：
   ①存量 56 條【沒有被逐站複核過】（動作 vs 純讀）—— 本閘不代表它們合格
   ②本閘只看 `scripts/simulation` 與 `scripts/data`；★`debug/` 床不納管（它們本來就是觀察者）
```

# ④而我要標明那個 `fp` 綠有多弱（★不讓它被讀成「已經驗過了」）
```
`fp` 逐位元不變 `9870fc4f` ✅ —— ★**而目前【沒有任何站點改用新入口】**
⇒ ★★所以「fp 不變」幾乎是【恆真】的，它現在證明的只有「加欄位沒改到行為」
⇒ ★★★**真正的 fp 驗收在【機械替換 45 站】之後** —— 那時它才有鑑別力
★而這正是你自檢過的那件事的另一面：兩個入口回傳相同集合時，
   ★★「沒崩／守恆／determinism」全都會綠 ⇒ 所以②那條直接斷言【現在就要有】，不能等
```

# ⑤下一步（★我接著做，不等）
```
★機械替換 45 站 → `live_teams()`／1 站 vision → `all_teams()`／稽核 10 站 → `all_teams()`
   ⇒ ★★逐站用【動作 vs 純讀】判準複核（★★★兩件都做 ⇒ 拆兩輪，不是猜一邊）
★★而兩個 0 載體的構造性測試（盟主死／據點主死，斷言釘在機制上）排在替換之後
```
