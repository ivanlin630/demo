"""git-handback bus — 節點間唯一傳遞面（07 increment 2）。

兩種 artifact，全在 git（= durable state，crash 撿得回）：
  handback = markdown + frontmatter（人讀 audit trail；格式沿用 00_roles §跨角色 handback）。
  verdict  = JSON（機器 gate 信號；conditional edge 讀它決定走向）。

純函式，零 claude 呼叫 → 單元測試確定性、不碰 auto-mode 分類器。
"""
from __future__ import annotations
import os, re, json, glob, datetime
from dataclasses import dataclass, asdict
from typing import Optional

MAIN_REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
HANDBACK_DIR = "docs/superpowers/handbacks"
VERDICT_DIR = "docs/process/verdicts"       # 機器 gate 信號（JSON）
METRICS_PATH = "docs/process/metrics.jsonl"  # 流程自量表

ROLES = {"blueprint", "systems", "implementer", "qa", "reviewer"}
_FM_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n?(.*)$", re.DOTALL)


@dataclass
class Handback:
    path: str
    frm: str
    to: str
    status: str
    topic: str
    body: str


def _slug(topic: str) -> str:
    s = re.sub(r"[^\w一-鿿-]+", "-", topic.strip())
    return re.sub(r"-+", "-", s).strip("-")[:60] or "untitled"


def _parse_frontmatter(text: str) -> tuple[dict, str]:
    m = _FM_RE.match(text)
    if not m:
        return {}, text
    fm: dict = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            k, _, v = line.partition(":")
            fm[k.strip()] = v.strip()
    return fm, m.group(2)


# ── handback（人讀 audit trail）──
def write_handback(frm: str, to: str, topic: str, body: str,
                   date: Optional[str] = None, status: str = "open",
                   repo: str = MAIN_REPO) -> str:
    assert frm in ROLES and to in ROLES, f"bad role {frm}->{to}"
    date = date or datetime.date.today().isoformat()
    fname = f"{date}-{frm}-to-{to}-{_slug(topic)}.md"
    path = os.path.join(repo, HANDBACK_DIR, fname)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    content = (f"---\nfrom: {frm}\nto: {to}\nstatus: {status}\ntopic: {topic}\n---\n\n{body}\n")
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return path


def read_open(to_role: str, repo: str = MAIN_REPO) -> list[Handback]:
    """掃 handbacks/，回 to:to_role status:open 的（義務收件匣，鏡射 hook 邏輯）。"""
    out: list[Handback] = []
    for p in sorted(glob.glob(os.path.join(repo, HANDBACK_DIR, "*.md"))):
        try:
            fm, body = _parse_frontmatter(open(p, encoding="utf-8").read())
        except OSError:
            continue
        if fm.get("to") == to_role and fm.get("status") == "open":
            out.append(Handback(p, fm.get("from", ""), fm.get("to", ""),
                                fm.get("status", ""), fm.get("topic", ""), body))
    return out


def consume(path: str) -> None:
    """status: open → consumed（不刪檔，留軌跡）。"""
    text = open(path, encoding="utf-8").read()
    text2 = re.sub(r"(?m)^status:\s*open\s*$", "status: consumed", text, count=1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text2)


# ── verdict（機器 gate 信號）──
def write_verdict(slice_id: str, node: str, obj: dict, repo: str = MAIN_REPO) -> str:
    path = os.path.join(repo, VERDICT_DIR, f"{slice_id}.{node}.json")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    return path


def read_verdict(slice_id: str, node: str, repo: str = MAIN_REPO) -> Optional[dict]:
    path = os.path.join(repo, VERDICT_DIR, f"{slice_id}.{node}.json")
    if not os.path.exists(path):
        return None
    try:
        return json.load(open(path, encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


# ── 流程自量表（每節點一行）──
def log_metric(row: dict, repo: str = MAIN_REPO) -> None:
    path = os.path.join(repo, METRICS_PATH)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")
