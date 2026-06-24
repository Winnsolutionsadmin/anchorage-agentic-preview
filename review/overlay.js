/* Anchorage deck — self-hosted REVIEW overlay.
   Internal team feedback tool. No external deps, no backend, no SaaS.
   Click any element in Review mode -> leave a per-item comment.
   Each comment can be filed as a GitHub issue (prefilled) into the private
   feedback repo, OR exported as a JSON/Markdown batch (no GitHub login needed).
   Comments persist in localStorage so refresh/scroll never loses them. */
(function () {
  'use strict';
  var REPO = 'Winnsolutionsadmin/anchorage-deck-feedback';
  var VERSION = window.__REVIEW_DECK_VERSION__ || 'deck';
  var LSKEY = 'anchorage-review::' + location.pathname;
  var comments = loadLS();
  var reviewing = false, hi = null, pop = null;

  function loadLS() { try { return JSON.parse(localStorage.getItem(LSKEY) || '[]'); } catch (e) { return []; } }
  function persist() { localStorage.setItem(LSKEY, JSON.stringify(comments)); renderPanel(); }
  function esc(s) { return (s || '').replace(/[<>&]/g, function (c) { return { '<': '&lt;', '>': '&gt;', '&': '&amp;' }[c]; }); }

  /* ---------- styles ---------- */
  var css = ''
    + '.rvw-ui,.rvw-ui *{box-sizing:border-box;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}'
    + '.rvw-fab{position:fixed;right:18px;bottom:18px;z-index:2147483600;background:#08111f;color:#cda349;'
    + 'border:1px solid #cda349;border-radius:30px;padding:11px 18px;font-size:13px;font-weight:600;cursor:pointer;'
    + 'box-shadow:0 6px 24px rgba(0,0,0,.35);letter-spacing:.02em}'
    + '.rvw-fab.on{background:#cda349;color:#08111f}'
    + 'body.rvw-on{cursor:crosshair}'
    + '.rvw-hl{outline:2px solid #cda349 !important;outline-offset:1px;background:rgba(205,163,73,.10) !important}'
    + '.rvw-pin{position:absolute;z-index:2147483500;width:22px;height:22px;margin:-11px 0 0 -11px;border-radius:50%;'
    + 'background:#cda349;color:#08111f;border:2px solid #08111f;font-size:11px;font-weight:700;display:flex;'
    + 'align-items:center;justify-content:center;cursor:pointer;box-shadow:0 2px 8px rgba(0,0,0,.4)}'
    + '.rvw-pop{position:absolute;z-index:2147483601;width:320px;background:#0d1825;border:1px solid #cda349;'
    + 'border-radius:10px;padding:13px;box-shadow:0 14px 40px rgba(0,0,0,.5);color:#e8eef5}'
    + '.rvw-pop .t{font-size:11px;color:#9fb0c2;margin-bottom:6px;max-height:48px;overflow:auto;line-height:1.35}'
    + '.rvw-pop textarea{width:100%;height:74px;background:#08111f;border:1px solid #2b3b4f;border-radius:6px;'
    + 'color:#e8eef5;padding:8px;font-size:13px;resize:vertical}'
    + '.rvw-pop .row{display:flex;gap:8px;margin-top:9px}'
    + '.rvw-btn{flex:1;padding:8px;border-radius:6px;border:1px solid #cda349;background:#cda349;color:#08111f;'
    + 'font-weight:600;font-size:12px;cursor:pointer}'
    + '.rvw-btn.sec{background:transparent;color:#9fb0c2;border-color:#2b3b4f}'
    + '.rvw-panel{position:fixed;top:0;right:0;height:100vh;width:330px;z-index:2147483550;background:#0a131f;'
    + 'border-left:1px solid #cda349;transform:translateX(100%);transition:transform .22s;overflow:auto;color:#e8eef5}'
    + '.rvw-panel.open{transform:none}'
    + '.rvw-panel h3{font-size:14px;margin:0;padding:14px;border-bottom:1px solid #1d2a3a;color:#cda349}'
    + '.rvw-panel .hd{display:flex;gap:6px;padding:10px 12px;border-bottom:1px solid #1d2a3a;flex-wrap:wrap}'
    + '.rvw-panel .hd .rvw-btn{flex:1 1 auto;font-size:11px;padding:6px 8px}'
    + '.rvw-item{padding:11px 12px;border-bottom:1px solid #14202e;font-size:12px}'
    + '.rvw-item .sec{color:#cda349;font-size:10px;text-transform:uppercase;letter-spacing:.05em}'
    + '.rvw-item .tgt{color:#7e90a4;margin:3px 0;max-height:34px;overflow:hidden}'
    + '.rvw-item .cm{color:#e8eef5;margin:5px 0;white-space:pre-wrap}'
    + '.rvw-item .acts{display:flex;gap:6px;margin-top:6px}'
    + '.rvw-item .acts a,.rvw-item .acts button{flex:1;text-align:center;font-size:11px;padding:5px;border-radius:5px;'
    + 'text-decoration:none;border:1px solid #2b3b4f;background:#0d1825;color:#9fb0c2;cursor:pointer}'
    + '.rvw-item .acts a.gh{border-color:#cda349;color:#cda349}'
    + '.rvw-empty{padding:20px 14px;color:#5d6e82;font-size:12px;line-height:1.5}';
  var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);

  /* ---------- target context ---------- */
  function isUI(el) { return !el || (el.closest && el.closest('.rvw-ui')); }
  function cssPath(el) {
    var p = [], depth = 0;
    while (el && el.nodeType === 1 && el !== document.body && depth < 6) {
      var s = el.tagName.toLowerCase();
      if (el.id) { p.unshift(s + '#' + el.id); break; }
      var par = el.parentNode, idx = 1, sib = el;
      while ((sib = sib.previousElementSibling)) { if (sib.tagName === el.tagName) idx++; }
      p.unshift(s + ':nth-of-type(' + idx + ')'); el = par; depth++;
    }
    return p.join(' > ');
  }
  function sectionOf(el) {
    var s = el.closest && el.closest('[id]');
    if (s && s.id) return s.id;
    var n = el;
    while (n) {
      var h = n.querySelector ? null : null;
      var prev = n;
      while ((prev = prev.previousElementSibling)) {
        if (/^H[1-4]$/.test(prev.tagName)) return (prev.innerText || '').trim().slice(0, 40);
      }
      n = n.parentElement;
    }
    return '(top)';
  }
  function targetText(el) { return ((el.innerText || el.textContent || '').trim().replace(/\s+/g, ' ')).slice(0, 160); }

  /* ---------- highlight + click capture ---------- */
  document.addEventListener('mousemove', function (e) {
    if (!reviewing) return;
    if (hi) { hi.classList.remove('rvw-hl'); hi = null; }
    if (isUI(e.target)) return;
    hi = e.target; hi.classList.add('rvw-hl');
  }, true);

  document.addEventListener('click', function (e) {
    if (!reviewing || isUI(e.target)) return;
    e.preventDefault(); e.stopPropagation();
    openPop(e.target, e.pageX, e.pageY);
  }, true);

  function openPop(el, x, y) {
    closePop();
    var tgt = targetText(el), sec = sectionOf(el), sel = cssPath(el);
    pop = document.createElement('div'); pop.className = 'rvw-pop rvw-ui';
    pop.style.left = Math.min(x, window.innerWidth - 340) + 'px';
    pop.style.top = (y + 12) + 'px';
    pop.innerHTML = '<div class="t"><b style="color:#cda349">' + esc(sec) + '</b> &middot; ' + esc(tgt.slice(0, 90)) + '</div>'
      + '<textarea placeholder="What should change here?"></textarea>'
      + '<div class="row"><button class="rvw-btn save">Save comment</button>'
      + '<button class="rvw-btn sec cancel">Cancel</button></div>';
    document.body.appendChild(pop);
    var ta = pop.querySelector('textarea'); ta.focus();
    pop.querySelector('.save').onclick = function () {
      var v = ta.value.trim(); if (!v) { ta.focus(); return; }
      comments.push({ id: Date.now(), section: sec, target: tgt, selector: sel, comment: v });
      persist(); closePop(); openPanel();
    };
    pop.querySelector('.cancel').onclick = closePop;
  }
  function closePop() { if (pop) { pop.remove(); pop = null; } }

  /* ---------- issue URL ---------- */
  function issueUrl(c) {
    var title = '[deck] ' + c.section + ' — ' + c.comment.slice(0, 60);
    var body = '**Target:** ' + c.target + '\n\n**Section:** `' + c.section + '`\n**Selector:** `' + c.selector
      + '`\n**Deck version:** ' + VERSION + '\n\n**Requested change:**\n' + c.comment
      + '\n\n---\n_Filed from the deck review overlay. Triage: add `accepted` or `denied`._';
    return 'https://github.com/' + REPO + '/issues/new?labels=feedback&title='
      + encodeURIComponent(title) + '&body=' + encodeURIComponent(body);
  }

  /* ---------- panel ---------- */
  var panel = document.createElement('div'); panel.className = 'rvw-panel rvw-ui';
  document.body.appendChild(panel);
  function openPanel() { panel.classList.add('open'); renderPanel(); }
  function renderPanel() {
    var items = comments.map(function (c) {
      return '<div class="rvw-item"><div class="sec">' + esc(c.section) + '</div>'
        + '<div class="tgt">' + esc(c.target.slice(0, 110)) + '</div>'
        + '<div class="cm">' + esc(c.comment) + '</div>'
        + '<div class="acts"><a class="gh" target="_blank" href="' + issueUrl(c) + '">File issue ↗</a>'
        + '<button data-del="' + c.id + '">Delete</button></div></div>';
    }).join('');
    panel.innerHTML = '<h3>Deck feedback &middot; ' + comments.length + '</h3>'
      + '<div class="hd"><button class="rvw-btn exp">Export JSON</button>'
      + '<button class="rvw-btn md">Copy Markdown</button>'
      + '<button class="rvw-btn sec clr">Clear all</button>'
      + '<button class="rvw-btn sec cls">Close</button></div>'
      + (items || '<div class="rvw-empty">No comments yet. Turn on Review mode and click any part of the deck to leave one. Each can be filed as a GitHub issue, or export them all as a file to send Jarred.</div>');
    panel.querySelectorAll('[data-del]').forEach(function (b) {
      b.onclick = function () { comments = comments.filter(function (c) { return c.id != b.getAttribute('data-del'); }); persist(); };
    });
    panel.querySelector('.exp').onclick = exportJSON;
    panel.querySelector('.md').onclick = copyMD;
    panel.querySelector('.clr').onclick = function () { if (confirm('Clear all ' + comments.length + ' comments?')) { comments = []; persist(); } };
    panel.querySelector('.cls').onclick = function () { panel.classList.remove('open'); };
  }
  function exportJSON() {
    var blob = new Blob([JSON.stringify({ deck: VERSION, when: new Date().toISOString(), comments: comments }, null, 2)], { type: 'application/json' });
    var a = document.createElement('a'); a.href = URL.createObjectURL(blob);
    a.download = 'deck-feedback-' + VERSION + '.json'; a.click();
  }
  function copyMD() {
    var md = '# Deck feedback (' + VERSION + ')\n\n' + comments.map(function (c, i) {
      return (i + 1) + '. **' + c.section + '** — ' + c.comment + '\n   _target:_ ' + c.target.slice(0, 100);
    }).join('\n\n');
    navigator.clipboard.writeText(md).then(function () { alert('Copied ' + comments.length + ' comments as Markdown.'); });
  }

  /* ---------- toggle ---------- */
  var fab = document.createElement('button'); fab.className = 'rvw-fab rvw-ui'; fab.textContent = '✎ Review';
  document.body.appendChild(fab);
  fab.onclick = function () {
    reviewing = !reviewing;
    document.body.classList.toggle('rvw-on', reviewing);
    fab.classList.toggle('on', reviewing);
    fab.textContent = reviewing ? '✎ Reviewing — click items' : '✎ Review';
    if (reviewing) openPanel(); else if (hi) { hi.classList.remove('rvw-hl'); hi = null; }
  };
  renderPanel();
  console.log('[deck-review] overlay ready. Repo:', REPO, 'version:', VERSION, 'saved:', comments.length);
})();
