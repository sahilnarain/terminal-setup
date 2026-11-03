#!/usr/bin/env python3
"""Mutt $send_multipart_alternative_filter.

Reads the composed text/plain body on stdin and writes a text/html
alternative to stdout (mime type line, blank line, content), the way
Mutt expects.

- "> " quoted lines become nested <blockquote type="cite" class="gmail_quote">, with
  the "On ... wrote:" line as a gmail_attr header, so Gmail/Outlook show
  a normal collapsible trail instead of a wall of ">" characters.
- --signature FILE inserts an HTML signature after your own text and
  before the quoted trail (Gmail style), or at the end if you bottom-post.
- Light formatting: blank-line paragraphs, "- " / "1. " lists,
  **bold**, `code`, and auto-linked URLs / email addresses.
"""
import argparse
import html
import json
import os
import re
import sys
import time

ATTRIB_RE = re.compile(r"^On .+ wrote:\s*$")
QUOTE_RE = re.compile(r"^((?:>[ \t]?)+)(.*)$")
UL_RE = re.compile(r"^\s*[-*]\s+(.*)$")
OL_RE = re.compile(r"^\s*\d+[.)]\s+(.*)$")
LINK_RE = re.compile(
    r"(?P<url>\b(?:https?://|www\.)[^\s<>\"']+[^\s<>\"'.,;:!?)\]])"
    r"|(?P<mail>\b[\w.+-]+@[\w-]+(?:\.[\w-]+)+\b)"
)

QUOTE_STYLE = "margin:0 0 0 6px;border-left:1px solid #cccccc;padding-left:8px"


def inline(text):
    out, pos = [], 0
    for m in LINK_RE.finditer(text):
        out.append(fmt(text[pos:m.start()]))
        if m.group("url"):
            url = m.group("url")
            href = url if "://" in url else "http://" + url
            out.append('<a href="%s">%s</a>' % (html.escape(href), html.escape(url)))
        else:
            mail = m.group("mail")
            out.append('<a href="mailto:%s">%s</a>' % (html.escape(mail), html.escape(mail)))
        pos = m.end()
    out.append(fmt(text[pos:]))
    return "".join(out)


def fmt(text):
    text = html.escape(text, quote=False)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*(?=\S)(.+?)(?<=\S)\*\*", r"<b>\1</b>", text)
    # keep runs of spaces (indentation, aligned text from plain-text quotes)
    text = re.sub(r"(?<= ) ", "&nbsp;", text)
    return text


def render_text(lines):
    """Render unquoted lines of one level: paragraphs, lists, line breaks."""
    out, i = [], 0
    while i < len(lines):
        line = lines[i]
        if not line.strip():
            out.append("<div><br></div>")
            i += 1
            continue
        for rx, tag in ((UL_RE, "ul"), (OL_RE, "ol")):
            if rx.match(line):
                items = []
                while i < len(lines) and rx.match(lines[i]):
                    items.append("<li>%s</li>" % inline(rx.match(lines[i]).group(1)))
                    i += 1
                out.append("<%s>%s</%s>" % (tag, "".join(items), tag))
                break
        else:
            out.append("<div>%s</div>" % inline(line))
            i += 1
    return "".join(out)


def parse(line):
    m = QUOTE_RE.match(line)
    if not m:
        return 0, line
    return m.group(1).count(">"), m.group(2)


def render(items, depth=0):
    """items: list of (depth, text). Renders nested blockquotes."""
    out, i = [], 0
    while i < len(items):
        d, text = items[i]
        if d > depth:
            j = i
            while j < len(items) and items[j][0] > depth:
                j += 1
            out.append('<blockquote type="cite" class="gmail_quote" style="%s">%s</blockquote>'
                       % (QUOTE_STYLE, render(items[i:j], depth + 1)))
            i = j
            continue
        j = i
        while j < len(items) and items[j][0] == depth:
            j += 1
        block = [t for _, t in items[i:j]]
        # Attribution line directly before a deeper quote -> gmail_attr, placed
        # inside the blockquote so the whole trail (attribution + text) is quoted
        if j < len(items) and block and ATTRIB_RE.match(block[-1]):
            out.append(render_text(block[:-1]))
            k = j
            while k < len(items) and items[k][0] > depth:
                k += 1
            out.append('<blockquote type="cite" class="gmail_quote" style="%s">'
                       '<div dir="ltr" class="gmail_attr">%s<br></div>%s</blockquote>'
                       % (QUOTE_STYLE, inline(block[-1]),
                          render([(d - 1, t) for d, t in items[j:k]], depth)))
            j = k
        else:
            out.append(render_text(block))
        i = j
    return "".join(out)


def split_trail(lines):
    """Index where the quoted trail starts (attribution + quotes to the end), or None."""
    for i, line in enumerate(lines):
        if parse(line)[0] == 0 and ATTRIB_RE.match(line):
            rest = [l for l in lines[i + 1:] if l.strip()]
            if rest and all(parse(l)[0] > 0 for l in rest):
                return i
    return None


ORIGINAL = os.path.expanduser("~/.mutt/tmp/reply-original.json")
ORIGINAL_MAX_AGE = 6 * 3600


def original_trail(trail):
    """Gmail-style trail built from the original message's HTML, or None.

    Used only when save-original.py stored an HTML original recently and the
    sender address in our "On ... wrote:" line matches it (guards against a
    stale file from an earlier reply)."""
    try:
        with open(ORIGINAL, encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, ValueError):
        return None
    if time.time() - data.get("saved_at", 0) > ORIGINAL_MAX_AGE:
        return None
    attrib = trail[0]
    addr = data.get("from_addr", "")
    if not addr or addr not in attrib.lower() or not data.get("html"):
        return None
    # Gmail's own reply layout: attribution just above the quote bar, both in
    # one gmail_quote container so Gmail folds them together behind "..."
    return ('<div dir="ltr" class="gmail_attr">%s<br></div>'
            '<blockquote type="cite" class="gmail_quote" style="%s">%s</blockquote>'
            % (inline(attrib), QUOTE_STYLE, data["html"]))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--signature", help="HTML signature file to insert")
    args = ap.parse_args()

    body = sys.stdin.buffer.read().decode("utf-8", errors="replace")
    lines = body.replace("\r\n", "\n").split("\n")
    while lines and not lines[-1].strip():
        lines.pop()

    cut = split_trail(lines)
    own, trail = (lines, []) if cut is None else (lines[:cut], lines[cut:])
    while own and not own[-1].strip():
        own.pop()
    while own and not own[0].strip():
        own.pop(0)

    parts = ['<div dir="ltr">', render([parse(l) for l in own]), "</div>"]
    if args.signature:
        with open(args.signature, encoding="utf-8") as f:
            sig = f.read().strip()
        parts.append('<br><div dir="ltr" class="gmail_signature">%s</div>' % sig)
    if trail:
        quoted = original_trail(trail) or render([parse(l) for l in trail])
        parts.append('<br><div class="gmail_quote gmail_quote_container">%s</div>' % quoted)

    sys.stdout.write("text/html\n\n")
    sys.stdout.write('<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"></head>'
                     '<body>%s</body></html>\n' % "".join(parts))


if __name__ == "__main__":
    main()
