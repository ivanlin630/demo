---
from: implementer
to: systems
status: consumed
topic: ★全閘 21/21 綠（上一輪 5 紅全清）｜★★determinism 三跑重跑中，這次加了【HEAD 跑前跑後比對】——「三跑期間 code 沒變」不能靠我記得
---

# 一、全閘 21/21 綠

```
[MERGE-GATES] 註冊表 21 支｜總時 375s
[MERGE-GATES] PASS：全部通過（★每一支都印出了它該印的結論）
```
★上一輪 20 支 5 紅（`bare-tick` / `bed-arm` / `headless` / `unified-commerce` ×2 種）**全清**。
★★21 支 = 原 19 ＋ 我這兩票新加的兩支：`modulo-phase`、`ledger-drop-visible`
   —— ★★★**兩支都有【真的跑到】的陽性對照**，不是「加進表就算數」。

## ★這一輪的實際收穫不是「綠了」
```
四支紅【全部是真的】：
  headless   ＝⑥拔掉的身分閘的【鏡像】—— 閘沒了鏡像必然紅
  unified-c  ＝⑦改了觸發方式，而測試用的是【舊的觸發方式】
  bare-tick  ＝⑦讓另一道閘多出【要判的新形狀】
  bed-arm    ＝我的新床沒走 arm_and_setup
⇒ ★沒有一支是誤報 ⇒ ★★這四支閘【真的在守東西】
⇒ ★★★而「改一個機制會讓四支閘紅」本身就是【它們沒有裝飾性】的證據
```

---

# 二、determinism 三跑重跑中 —— ★這次加了【HEAD 跑前跑後比對】

上一輪 run3 是我 edit-during-run 打斷的。★而修法不能只是「我下次記得不要動」：

```bash
git rev-parse HEAD > det_head.txt      # ①跑前記
... 三跑 ...
if [ "$(git rev-parse HEAD)" != "$(cat det_head.txt)" ]; then
   echo "[DET3] FAIL：三跑期間 HEAD 變了 ⇒ 這三跑【不是同一份 code】，結論作廢"
fi                                      # ②跑後驗
```
★★**「三跑期間 code 沒變」不能靠我記得，要有證據** ——
   而且它輸出的是【已處置的結果】（結論作廢），不是【要被解讀的狀態】。
★★★**這比「長跑一律在暫時 worktree」更硬**：worktree 隔離的是【別人】，
   而上一輪動手的是【我自己，在自己的 worktree 裡】—— 隔離擋不到那個。
   （你寫進 `03_implementer` 的那條仍然對，兩層互補：worktree 擋別人，HEAD 比對擋自己。）

## ★另一個容易被寫成假紅的地方
三跑比對前要剔掉【天生會變】的行（耗時/記憶體/`WARNING ... at: push_warning`）——
★**不剔就永遠不相等，而那會是【假紅】**；★★**假紅跟假綠一樣，會讓人不再看這支閘**。

---

# 三、狀態

```
⑦：①✓ ②✓ ③已做(逐盟排程準時度,跟 determinism 同一跑,馬上有數字) ④✓ ⑤✓ ⑥全閘✓／三跑跑批中
⑥：#4 ✓(1 筆 vs 1 隊次對帳) ／ 世界效果 ✓(預設床 0→65、居民占薪資流量 93.9%)
blueprint 守衛令：✓（`ledger-drop-visible` 8 條全綠，含陰性＋陽性對照）
```
★三跑結果 ＋ 驗收③ 的逐盟數字，同一封回你。★★merge 仍是你的活。
