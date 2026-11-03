MUTT SETUP: WHAT CHANGED AND WHY
================================
Written 2026-11-03. A walk-through of every changed or new file, block by
block, for maintaining the setup yourself.


0. OVERVIEW
-----------
Files you maintain:
  ~/.muttrc                      main config (changed)
  ~/.mutt/xane.conf              Xane account (changed)
  ~/.mutt/gmail.conf             Gmail account (changed)
  ~/.mutt/html-alternative.py    new: plain text -> HTML, signature, trail
  ~/.mutt/save-original.py       new: saves the original's HTML on reply

Written automatically (you don't edit it):
  ~/.mutt/tmp/reply-original.json   the original from your last reply

Backups (safe to delete once you're happy):
  ~/.muttrc.bak-20261103
  ~/.mutt/xane.conf.bak-20261103
  ~/.mutt/gmail.conf.bak-20261103
  ~/.mutt/html-alternative.py.bak-compat   (converter before the CSS fixes)
  ~/.mailcap.bak-20261103                  (~/.mailcap is back to its original)

How it works now:
  - You always write plain text in vim.
  - Every email goes out as plain text + HTML. You never pick a content type.
  - In compose:  y = send without signature,  S = send with signature.
  - r / g / L replies quote the original's own HTML (formatting, signature,
    earlier thread intact). Replies to plain-text emails get a text quote,
    converted to HTML.
  - aa archives without prompts. sg / sx switch accounts.

To see what changed in a config file:
  diff -u ~/.muttrc.bak-20261103 ~/.muttrc


1. ~/.muttrc
------------

1.1 Account sourcing (comment only)
  # Accounts: the last one sourced is the one mutt starts in (currently Xane)

  The old comment said "Default account", which suggested Gmail. Mutt applies
  files in order and Xane is sourced second, so mutt starts in Xane.
  To change the starting account, swap the two `source` lines.

1.2 General behaviour (new block)
  set ssl_force_tls = yes
  set send_charset = "utf-8"
  set copy = no
  set confirmappend = no
  set delete = yes

  ssl_force_tls   Refuse to connect without encryption, so a network problem
                  can't silently downgrade your login to plaintext.
  send_charset    Always send UTF-8. The default tries old encodings like
                  iso-8859-1 first, which some clients show wrongly.
  copy = no       Stop saving mutt's own copy of each sent email to ~/sent.
                  Gmail's SMTP already files sent mail in [Gmail]/Sent Mail.
                  GOTCHA: if you ever send through a non-Gmail SMTP server,
                  set this back to yes and point `record` at a sent folder,
                  or sent mail won't be saved anywhere.
  confirmappend   Removes the "Append to All Mail?" prompt.
  delete = yes    Removes the "Purge deleted messages?" prompt.
                  These two prompts were why aa kept asking for confirmation.
                  The aa macro also sets them itself (1.7).

1.3 Reading and quoting
  set attribution = "\n\nOn %{%a, %b %-d, %Y at %-I:%M %p} %n <%a> wrote:"

  Was: "On %d, %n wrote:". %d used mutt's long default date format, which
  looked odd next to Gmail's.
  Now: "On Tue, Nov 3, 2026 at 9:12 AM Name <addr> wrote:", matching Gmail.
    %{...}       the date in the sender's timezone, using strftime codes
    %-d, %-I     day and hour without a leading zero
    %n, %a       sender's name and address
    \n\n         two empty lines first: you type on line 1, and line 2 is
                 the gap before "On ..."

  GOTCHA (important): html-alternative.py finds the trail by matching lines
  against ^On .+ wrote:$ (ATTRIB_RE). If you change this format, update that
  pattern too, or the signature lands at the bottom and the HTML quote
  styling breaks. Keep <%a>: the converter uses it to match the saved
  original to the right sender.

  Other quoting lines (include, indent_string, auto_view, alternative_order
  etc.) are unchanged. Only the dead comment "# unset implicit_autoview" was
  removed.

1.4 Forwarding (moved and changed)
  set mime_forward = no
  set forward_decode = yes
  set forward_attachments = yes
  set forward_format = "Fwd: %s"
  set forward_attribution_intro = "---------- Forwarded message ---------"
  set forward_attribution_trailer = ""

  Was: mime_forward=yes, which attached the forwarded email as an .eml file
  that Gmail and Outlook users have to open separately.
  Now:
    mime_forward, forward_decode   the forwarded email goes inline (Gmail
                                   style), headers shown as readable text
    forward_attachments            the original's attachments still come along
    format / intro / trailer       "Fwd:" and Gmail's separator line
  These lines used to sit at the bottom of the file; they're grouped here now.

1.5 Sending (new block; the core of the setup)
  set send_multipart_alternative = yes
  send-hook . 'set send_multipart_alternative_filter=$my_filter_nosig'

  send_multipart_alternative = yes
    Every email carries your plain text plus an HTML version. Mutt makes the
    HTML by piping your text through the program in
    send_multipart_alternative_filter, which is html-alternative.py.

  The send-hook
    Runs at the start of every compose and resets the converter to the
    no-signature version. That's why S never carries over to the next email.
    GOTCHA: the single quotes stop mutt reading $my_filter_nosig when it
    loads the file; it's read each time the hook runs instead, so it follows
    whichever account sg/sx loaded last. With double quotes, the value would
    be fixed to Xane's at startup.

  macro index,pager r "<enter-command>set pipe_decode=no wait_key=no<enter>
      <pipe-message>~/.mutt/save-original.py<enter>
      <enter-command>set pipe_decode=yes wait_key=yes<enter><reply>" "Reply"
  (the same for g -> <group-reply> and L -> <list-reply>; one line each in
  the file)

    r, g and L used to be mutt's built-in reply keys. Each one now first
    pipes the raw message to save-original.py, which saves its HTML for the
    converter, and then runs the normal reply.
      pipe_decode=no   send the raw MIME message, HTML part intact, instead
                       of decoded text (you normally have pipe_decode=yes)
      wait_key=no      skip the "Press any key..." prompt after the script
      Both are set back to yes afterwards.
    GOTCHA: if you change the global value of pipe_decode or wait_key,
    change the restore step in these three macros to match.
    GOTCHA: replying any other way (e.g. from the attachment menu) skips the
    save. Still safe: you just get the text quote, not the original's HTML.

  macro compose S '<enter-command>set send_multipart_alternative_filter=
      $my_filter_sig<enter><send-message>' "Send with signature"

    In compose, S switches the converter to the with-signature version and
    sends. y is unchanged: it sends with whatever the send-hook set, which
    is no signature. Single quotes again, so on Gmail S uses Gmail's
    settings. This replaces the old S macro in xane.conf (section 2).

1.6 Sidebar bindings (comments only)
  The comments said "Ctrl-Shift-P" etc., but \CP is plain Ctrl-P. Only the
  comments were fixed.

1.7 Archive macros
  macro index,pager aa "<enter-command>set confirmappend=no delete=yes<enter>
      <save-message>=[Gmail]/All Mail<enter><sync-mailbox>" ...
  macro index A   (the same)

  Was:
    - aa was <save-message>=[Gmail]/All Mail<enter><enter><sync-mailbox>.
      The second <enter> answered the "Append?" prompt, but the sync then
      asked "Purge?". And if "Append?" didn't appear, that extra <enter>
      would open a message instead.
    - A turned confirmappend back ON at the end, which brought the prompt
      back for the next aa.
  Now:
    - Both macros set the two prompt settings off themselves, so they work
      whatever any other setting says.
    - How archiving works in Gmail: copy to All Mail, mark deleted in the
      inbox, sync. Gmail then just removes the Inbox label, which is what
      archiving is.
    - aa also works while reading a message (pager). That makes plain `a`
      in the pager a prefix key, so the built-in pager `a` (create-alias) is
      gone. It was already gone in the message list.

1.8 Account switching (unchanged)
  sg and sx are untouched. They work better now because delete=yes removes
  the "Purge?" prompt that <sync-mailbox> could raise mid-macro.


2. ~/.mutt/xane.conf
--------------------

2.1 Removed
  macro compose S "<attach-file>~/.mutt/xane/xane-signature.html<enter>
      <toggle-disposition><edit-type>text/html; charset=utf-8<enter>n" ...

  Why:
    - Signature in the wrong place: it was attached as a separate HTML part
      after the whole message, so it appeared below the quoted trail. A big
      part of the "weird trail".
    - Body still plain text: Gmail users saw raw ">" lines.
    - Leaked into Gmail: it lived in xane.conf and nothing removed it when
      you switched with sg, so Gmail emails got the Xane signature.

2.2 Added: converter settings
  set my_filter_nosig = "~/.mutt/html-alternative.py"
  set my_filter_sig   = "~/.mutt/html-alternative.py --signature
                         ~/.mutt/xane/xane-signature.html"   (one line)
  set send_multipart_alternative_filter = $my_filter_nosig

  The two variables are the "without signature" and "with signature"
  commands that the send-hook and S pick between. Settings starting with
  my_ are your own variables, which mutt stores but otherwise ignores.
  Because they're defined per account, sx and sg switch the signature
  automatically. The third line sets a sensible starting value.
  To change your signature: edit ~/.mutt/xane/xane-signature.html. Nothing
  else needs to change.

2.3 Added: hostname
  set hostname = "xane.ai"

  Mutt builds each email's Message-ID from hostname. Without this,
  Message-IDs contained this server's internal Oracle hostname
  (sahil-access-terminal.subnet...oraclevcn.com), visible to recipients in
  the headers. Threading wasn't affected.

2.4 Permissions
  chmod 600 (was 644). The file holds your IMAP/SMTP passwords in plain text
  and was readable by any user on the machine.


3. ~/.mutt/gmail.conf
---------------------
The same additions as Xane's:
  - my_filter_nosig and my_filter_sig are BOTH the no-signature command,
    because you have no Gmail signature, so S behaves like y there.
    To add a Gmail signature: create an HTML file and add
    --signature <path> to my_filter_sig.
  - hostname = "gmail.com", for the same Message-ID reason.
  - chmod 600, for the same reason.


4. ~/.mutt/html-alternative.py  (the HTML converter)
-----------------------------------------------------
When it runs: every time you send, and when you press v / Esc-v in compose
to preview. Mutt pipes your plain-text body in. The script writes
"text/html", a blank line, then the HTML: the output format mutt requires
from send_multipart_alternative_filter.

Lines 1-15: header and description
  MAINTENANCE NOTE: lines 8-10 are slightly out of date. They say Outlook
  folds the trail (not guaranteed) and describe the attribution as a header.
  The two layouts actually used are explained under lines 91-123 and
  140-161. Worth updating that text if you edit the file.

Lines 24-31: patterns
  ATTRIB_RE   "On ... wrote:" lines. MUST match your attribution in
              .muttrc; change both together.
  QUOTE_RE    leading ">", "> >" or ">>"; the number of ">" is the depth
  UL_RE       "- item" / "* item"     -> bulleted list
  OL_RE       "1. item" / "1) item"   -> numbered list
  LINK_RE     URLs (http(s)://, www.) and email addresses -> clickable
              links; trailing punctuation like "." or ")" is left out

Line 33: QUOTE_STYLE
  The grey bar: margin:0 0 0 6px;border-left:1px solid #cccccc;
  padding-left:8px. Pixels and a hex colour because Outlook desktop's
  Word-based renderer supports those reliably.
  This is the one line to edit to restyle quotes.

Lines 36-58: inline() and fmt(), formatting within a line
  inline()  finds links, turns them into <a href> tags, passes the text in
            between to fmt(). www. links get http:// added.
  fmt()
    - Escaping: escapes <, > and &, so typing <v2> shows as text.
    - Formatting: `x` -> <code>, **x** -> bold.
    - Spaces: keeps runs of spaces (as &nbsp;) so aligned text, such as
      table columns in quoted HTML emails, stays aligned.
    - No single *: deliberately not treated as italic; too many false
      matches in normal text.

Lines 61-81: render_text(), block structure for one quote level
  - Blank line         -> empty <div><br></div> (Gmail's spacing)
  - List lines in a row -> one <ul> or <ol>
  - Any other line     -> its own <div>, so your line breaks are kept
    exactly. Lines are not joined into paragraphs, because vim doesn't
    hard-wrap your text and quoted lines must keep their breaks.

Lines 84-88: parse()
  Turns a line into (depth, text): "> > hi" -> (2, "hi"); an unquoted line
  has depth 0.

Lines 91-123: render(), the text trail with nesting
  Used when the trail can't come from the original's HTML, typically when
  replying to a genuinely plain-text email. Recursive:
    - Deeper lines (96-103): a run deeper than the current level is wrapped
      in a <blockquote> with the grey bar and rendered one level down.
    - Attribution (108-119): if the last line before a deeper run matches
      ATTRIB_RE, the attribution and the quoted lines go INSIDE the same
      bar, attribution on top. This is the layout you asked for and kept
      when we reverted.
    - Everything else: render_text().

Lines 126-133: split_trail(), where your text ends and the trail begins
  Finds the first unquoted "On ... wrote:" line where EVERY non-blank line
  after it is quoted. If none fits, there's no trail.
    - Top-posting (you write above the quote): this finds the attribution,
      and the signature goes between your text and the trail.
    - Bottom-posting (you write below the quote): it doesn't qualify as a
      trail. Everything counts as your text, and the signature goes at the
      very end.

Lines 136-161: original_trail(), the trail from the original's HTML
  Reads ~/.mutt/tmp/reply-original.json (written by save-original.py) and
  uses it only if ALL of these hold:
    1. Readable: the file exists and is valid JSON.
    2. Recent: saved less than 6 hours ago (ORIGINAL_MAX_AGE).
    3. Same sender: the saved sender address appears in your attribution
       line (this is why the attribution must keep <%a>).
    4. Has content: the saved HTML isn't empty.
  If any check fails it returns None and the text trail from render() is
  used. This guards against a leftover file from an earlier reply ending
  up in the wrong email.
  When it passes, it outputs Gmail's own reply layout: the attribution JUST
  ABOVE the bar, the original's HTML inside it. You approved this in T3.
  When Gmail folds the trail, the attribution is hidden along with it.
  So the two trail types use different layouts on purpose; don't make them
  the same without retesting folding.

Lines 164-192: main(), putting it together
  1. Arguments (165-167): reads --signature FILE if given (my_filter_sig
     passes it; my_filter_nosig doesn't).
  2. Input (169-172): reads your body as UTF-8, drops trailing blank lines.
  3. Split (174-179): your text vs the trail; trims blank lines at both
     ends of your text (removes the empty lines \n\n in attribution makes).
  4. Your text (181): rendered inside <div dir="ltr">.
  5. Signature (182-185): inserted as-is, wrapped in gmail_signature. Gmail
     uses that class to recognise signatures; other clients ignore it.
  6. Trail (186-188): the original's HTML if available, otherwise the text
     trail, wrapped in "gmail_quote gmail_quote_container". That wrapper
     lets Gmail fold the trail behind "..."; other clients ignore it.
  7. Output (190-192): "text/html", a blank line, then a full HTML document
     that declares UTF-8.

To test it by hand:
  ~/.mutt/html-alternative.py --signature ~/.mutt/xane/xane-signature.html \
      < some-body.txt
In compose, press v to see the rendered HTML, or Esc-v for the source.


5. ~/.mutt/save-original.py  (saves the original's HTML)
---------------------------------------------------------
When it runs: when you press r, g or L. The macro pipes the RAW message in
(pipe_decode=no) just before the reply starts.

Lines 1-17: header, imports, output path
  Output file: ~/.mutt/tmp/reply-original.json

Lines 20-31: html_part()
  Walks the message's MIME parts and returns the first text/html part that
  isn't marked as an attachment, decoded with its own charset. If decoding
  fails it falls back to a lenient decode, so one malformed email can't
  break your reply.
  EDGE CASE: the walk also looks inside attached emails. For a plain-text
  email with a forwarded HTML email attached INLINE, it could pick up the
  forwarded one's HTML. The sender check in original_trail() would usually
  reject it (different sender), giving you the text trail. Rare, harmless.

Lines 34-47: clean(), making the original safe to embed
  - Body only (36-38): keeps just what's inside <body>.
  - Removed (39-41): <script>, <head>, <title>, HTML comments, stray
    <html>/<body>/<meta>/<link> tags, and <style> blocks.
    The <style> removal is deliberate: a stylesheet applies to the whole
    email, so the original's CSS could restyle your own text and signature.
    Trade-off: emails relying on stylesheets (Outlook-written ones do,
    heavily) lose some styling in the trail. Content, tables, inline styles
    and remote images stay.
  - Inline images (43-46): images embedded in the original (cid:) aren't
    re-attached to your reply, so they'd show as broken. They're replaced
    with their alt text in brackets, e.g. [Acme logo], or [image].

Lines 50-69: main()
  1. Parse and look for HTML (51-53): finds the HTML part, creates
     ~/.mutt/tmp/ readable only by you.
  2. No HTML (54-57): DELETES any existing saved file and stops, so a
     plain-text reply can't pick up an old original.
  3. Save (58-64): sender address (lowercased), Message-ID, time, cleaned
     HTML. The Message-ID isn't currently used; it's stored for
     troubleshooting or a stricter check later.
  4. Write safely (65-69): writes a .tmp file first (mode 600, since it
     holds email content), then renames it into place. Mutt can't read a
     half-written file, and a crash can't leave a corrupt one.


6. HOW THE TWO SCRIPTS WORK TOGETHER
------------------------------------
  r / g / L --> save-original.py --> ~/.mutt/tmp/reply-original.json
                                           |
  vim (you write plain text)               |
                                           v
  y / S --> html-alternative.py -- (sender + age check) --> HTML version
               |- your text -> HTML
               |- signature (S only)
               '- trail: original's HTML if it passes, otherwise the text
                  quote


7. MAINTENANCE CHECKLIST
------------------------
  1. Attribution: if you change `attribution` in .muttrc, update ATTRIB_RE
     (html-alternative.py line 24), and keep <%a> so the sender check works.
  2. Use single quotes in hooks and macros that refer to $my_... variables.
  3. The r/g/L macros restore pipe_decode and wait_key to yes; keep them in
     step with your global values.
  4. Each account needs its own my_filter_nosig and my_filter_sig.
  5. copy = no relies on Gmail's SMTP saving sent mail.
  6. Restyle quotes only via QUOTE_STYLE (html-alternative.py line 33).
  7. Saved-original age limit: ORIGINAL_MAX_AGE (html-alternative.py
     line 137).
  8. If you move reply-original.json, change both ORIGINAL
     (html-alternative.py line 136) and OUT (save-original.py line 17).
  9. Both scripts use only Python's standard library (nothing to install),
     but need python3 on your PATH and must stay executable (chmod +x).
