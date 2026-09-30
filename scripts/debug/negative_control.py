"""負對照驅動器的【判決】那一半：三態分類器 ＋ 它自己的對照（systems 裁 2026-09-30）。

★★★為什麼這支存在（血證，2026-09-30）：
  濫按煞車票的六道負對照第一輪【全部報 NOT-RED】，而六道都是真的紅 ——
  那一輪的每一次 Godot 都被 wrapper 的 deadline 砍掉（`.claude/hooks/.godot-runs.log`
  逐行寫 `timeout`，4 分鐘 × 6），而同一個 patch 直接跑是 3 秒、rc=1、9 處紅。
  ⇒ ★**沒有產生判決**被讀成【沒紅】，而那個方向是危險的那一邊：
    「這一格守不住」的下一步是去改守衛 —— 把真正在守的那一格拆掉。

★★裁定（systems 2026-09-30，逐字要點）：這條判準【升成常駐】但**不新增一支閘** ——
  它留在負對照驅動器裡，而「常駐」的意思是**它要有自己的對照**。
  ⇒ `--selfcheck` 的四格就是那個對照，而 `run_batch()` 在跑任何一道控制之前
    **先跑一次 selfcheck 並在失敗時中止** ⇒ ★它是【接上電】的，不靠任何人記得呼叫它。
    （「寫好」與「接上」是兩個獨立動作，而沒接電的閘其沉默跟一直綠的閘在卷面上一樣。）

★病因未定：為什麼那六次在那個 shell 裡會停住，我沒有查到底 ⇒ **不為了關掉症狀去改 timeout 值**。
  判準已經把「不可判」與「沒紅」分開，症狀可見即可；病因另登 defer。
"""
import os
import sys

# ★stdout 強制 UTF-8：Windows 的預設是 CP950，而本檔的輸出全是中文＋「⇒」
#   ⇒ 不設的話 selfcheck 會死在 UnicodeEncodeError（＝一支【印不出自己判決】的判決機器）。
try:
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
except AttributeError:   # 舊 python 沒有 reconfigure：讓它照舊，訊息可能花但判決不變
    pass

# 三態。★NO-VERDICT 不是一個顏色 —— 它與電池的 RC=2（不可判）是同一條紀律。
RED_OK = 'RED-OK'
NOT_RED = 'NOT-RED'
NO_VERDICT = 'NO-VERDICT'


# ★★★【病因找到了】(2026-09-30)：早先一輪六道負對照【每一次 Godot 都被 wrapper 的 deadline 砍掉】
#   而輸出裡零個 FAIL ⇒ 當時我只能把它登成 defer `godot-wrapper-batch-timeout-unexplained`。
#   真因在這裡：shell 已經 `export PSExecutionPolicyPreference=Bypass`，而驅動器又把
#   **同名但不同大小寫**的鍵塞進 env dict ⇒ PowerShell 的 `Start-Process` 直接丟：
#     「已經加入項目。字典中的索引鍵: 'PSExecutionPolicyPreference' 加入的索引鍵: 'PSEXECUTIONPOLICYPREFERENCE'」
#   ⇒ ★**Godot 一次都沒被啟動**，而 wrapper 仍然等到 deadline ⇒ 記成 timeout。
#   ⇒ Windows 的環境變數不分大小寫，而 python 的 dict 分 ⇒ 兩個拼法同時存在。
# ★處置：組 env 之前把【所有大小寫變體】清掉，再設一次。
#   ★★而這一段留在 code 裡不是為了紀念：下一支驅動器照抄 `child_env()` 就不會再踩。
def child_env(**extra):
    env = {k: v for k, v in os.environ.items()}
    for key in list(extra.keys()) + ['PSExecutionPolicyPreference']:
        for existing in [k for k in list(env.keys()) if k.lower() == key.lower()]:
            del env[existing]
    env['PSExecutionPolicyPreference'] = 'Bypass'
    env.update(extra)
    return env


def classify(out, expect, banner):
    """把一輪負對照的輸出分成三態。

    out    ：那一輪的 stdout+stderr
    expect ：這道控制【應該讓哪一句話紅】—— ★從【床自己的輸出】抄，不從 spec 抄
             （spec 的措辭與床印的句子不一樣時，真的紅會被讀成沒紅：2026-09-30 血證）
    banner ：床跑完會印的那一行（例：'spam_brake DONE ==='）
    回 (verdict, detail)
    """
    fails = [l.strip() for l in out.split('\n') if 'FAIL' in l]
    # ★★★順序是這支的命門：**橫幅先判**。
    #   反過來寫（先看 expect 命中）⇒ 一份被砍斷的輸出只要恰好含那句話就會被報成 RED-OK
    #   ⇒ 那比 NOT-RED 更糟：它會讓一個沒有判決的輪次看起來像通過。
    if banner not in out:
        return NO_VERDICT, '輸出 %d 字、FAIL %d 筆，而【沒有橫幅】⇒ 這一輪沒有產生判決' % (
            len(out), len(fails))
    hit = [l for l in fails if expect in l]
    if hit:
        return RED_OK, hit[0]
    return NOT_RED, ' / '.join(fails[:3])


# ── selfcheck：四格，而每一格都寫出【它擋住什麼】────────────────────────────
#   ★前兩格是 systems 指定的；★★第三、第四格是我加的，理由寫在各自的 why：
#     沒有第三格，把兩個判斷寫反的版本會通過；
#     沒有第四格，一支【永遠回 NO-VERDICT】的分類器也會通過前三格
#     （＝「恆一個答案」那一族：對照組自己也會沒有鑑別力）。
BANNER = 'demo_bed DONE ==='
_GREEN = 'PASS: something\n=== demo_bed DONE === errors: 0\n'
_RED = 'ERROR: [FAIL] 好感【下降】（小事直接在好感做加減）\n=== demo_bed DONE === errors: 1\n'
_CUT = 'PASS: something\n[godot.ps1] child exit=1\n'          # 被砍斷：沒有橫幅
_CUT_WITH_TEXT = 'ERROR: [FAIL] 好感【下降】（被砍斷的那一輪剛好印到這一行）\n'

CELLS = [
    ('①有橫幅但沒紅 ⇒ NOT-RED', _GREEN, '好感【下降】', NOT_RED,
     'systems 指定：擾動沒有被接住時要說「沒紅」，而它必須跟「沒判決」分得開'),
    ('②沒有橫幅 ⇒ NO-VERDICT（不得報 NOT-RED）', _CUT, '好感【下降】', NO_VERDICT,
     'systems 指定：這一格就是 2026-09-30 那六道假 NOT-RED 的守衛'),
    ('★③沒有橫幅【而輸出剛好含 expect】⇒ 仍然 NO-VERDICT', _CUT_WITH_TEXT, '好感【下降】', NO_VERDICT,
     '守【判斷順序】：先看 expect 命中的版本會把一個沒判決的輪次報成 RED-OK'),
    ('★④有橫幅且真的紅 ⇒ RED-OK（陽性對照）', _RED, '好感【下降】', RED_OK,
     '沒有這一格，一支永遠回 NO-VERDICT 的分類器會通過①②③ —— 恆一個答案那一族'),
]


def selfcheck(verbose=True):
    """回 [] ＝ 四格全過；否則回失敗清單。"""
    bad = []
    for name, out, expect, want, why in CELLS:
        got, detail = classify(out, expect, BANNER)
        ok = got == want
        if verbose:
            print('  %s %s ⇒ 期望 %s／實得 %s' % ('PASS:' if ok else '[FAIL]', name, want, got))
            print('       它擋住什麼：%s' % why)
        if not ok:
            bad.append('%s：期望 %s 實得 %s（%s）' % (name, want, got, detail))
    return bad


def selfcheck_or_die():
    """★跑任何一道控制【之前】必呼這一支 —— 這就是「接上電」那一半。

    判決機器自己壞掉的時候，它壞掉的樣子是【所有控制都回同一個答案】，
    而那在卷面上跟「產品沒問題」長得一樣 ⇒ 先驗機器，再驗產品。
    """
    bad = selfcheck(verbose=False)
    if bad:
        print('[negative-control] ★★★selfcheck 紅 ⇒ **中止**（判決機器壞了，這一輪的紅綠都不算）')
        for b in bad:
            print('   ★ ' + b)
        sys.exit(2)
    print('[negative-control] selfcheck %d／%d ⇒ 分類器可用（NO-VERDICT 與 NOT-RED 分得開）'
          % (len(CELLS), len(CELLS)))


def run_batch(controls, run_fn, banner, patch_fn, restore_fn):
    """controls = [(name, expect, payload)]；run_fn(payload) 回 out 字串。

    ★本支刻意不知道怎麼改檔（patch_fn／restore_fn 由各票的驅動器給）：
      判決那一半要常駐，而【怎麼擾動】每張票都不一樣。
    """
    selfcheck_or_die()
    bad = 0
    for name, expect, payload in controls:
        if not patch_fn(payload):
            print('[%s] SETUP-FAIL（錨沒命中 ⇒ 這一道根本沒擾動到東西）' % name, flush=True)
            bad += 1
            continue
        try:
            verdict, detail = classify(run_fn(payload), expect, banner)
            print('[%s] %s  %s' % (name, verdict, detail[:180]), flush=True)
            if verdict != RED_OK:
                bad += 1
        finally:
            restore_fn(payload)
    print('passed %d/%d' % (len(controls) - bad, len(controls)))
    return bad


if __name__ == '__main__':
    if '--selfcheck' in sys.argv:
        print('=== negative_control --selfcheck ===')
        fails = selfcheck()
        print('=== negative_control SELFCHECK DONE === errors: %d｜到場點名 %d／%d'
              % (len(fails), len(CELLS), len(CELLS)))
        sys.exit(1 if fails else 0)
    print(__doc__)
    print('用法：python tools/controls/negative_control.py --selfcheck')
    sys.exit(0)
