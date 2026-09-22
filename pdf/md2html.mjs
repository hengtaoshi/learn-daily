// md2html.mjs — Markdown -> 适合打印的小字号 HTML
// 用法: node pdf/md2html.mjs <输入.md> <输出.html> [--css=路径] [--cols=1|2]
import fs from "node:fs";
import path from "node:path";

const BT = String.fromCharCode(96);           // 反引号
const FENCE = BT + BT + BT;
const isFence = s => s.startsWith(FENCE);
const args = process.argv.slice(2);
const inp = args[0], outp = args[1];
const cssArg = (args.find(a => a.startsWith("--css=")) || "--css=pdf/print.css").slice(6);
const cols = Number((args.find(a => a.startsWith("--cols=")) || "--cols=1").slice(7)) || 1;

const src = fs.readFileSync(inp, "utf8").replace(/\r\n?/g, "\n");
const esc = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

const inlineCodeRe = new RegExp(BT + "+([^" + BT + "]*?)" + BT + "+", "g");
function inline(s) {
  const codes = [];
  s = s.replace(inlineCodeRe, (_m, b) => { codes.push(b); return "\u0000" + (codes.length - 1) + "\u0000"; });
  s = esc(s);
  s = s.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  s = s.replace(/(【(?:★★★|★★|🔧|☆)】)/g, '<span class="mk">$1</span>');
  return s.replace(/\u0000(\d+)\u0000/g, (_m, i) => "<code>" + esc(codes[+i]) + "</code>");
}

const lines = src.split("\n");
const out = [];
let i = 0;
const isSep = l => /^\|[\s:|-]+\|$/.test(l.trim());
const splitRow = l => l.trim().replace(/^\||\|$/g, "").split(/(?<!\\)\|/).map(c => c.replace(/\\\|/g, "|").trim());
const isList = l => /^\s*(-\s+\[[ xX]\]\s+|[-*]\s+|\d+\.\s+)/.test(l);

while (i < lines.length) {
  const l = lines[i];
  if (/^\s*$/.test(l)) { i++; continue; }

  if (isFence(l)) {
    const lang = l.slice(3).trim(); i++;
    const buf = [];
    while (i < lines.length && !isFence(lines[i])) buf.push(lines[i++]);
    i++;
    out.push('<pre data-lang="' + esc(lang) + '">' + esc(buf.join("\n")) + "</pre>");
    continue;
  }
  const h = l.match(/^(#{1,6})\s+(.*)$/);
  if (h) { out.push("<h" + h[1].length + ">" + inline(h[2]) + "</h" + h[1].length + ">"); i++; continue; }
  if (/^(-{3,}|\*{3,}|_{3,})\s*$/.test(l)) { out.push("<hr>"); i++; continue; }
  if (l.trim().startsWith("|") && i + 1 < lines.length && isSep(lines[i + 1])) {
    const head = splitRow(l); i += 2;
    const rows = [];
    while (i < lines.length && lines[i].trim().startsWith("|")) rows.push(splitRow(lines[i++]));
    out.push("<table><thead><tr>" + head.map(c => "<th>" + inline(c) + "</th>").join("") + "</tr></thead><tbody>" +
      rows.map(r => "<tr>" + r.map(c => "<td>" + inline(c) + "</td>").join("") + "</tr>").join("") + "</tbody></table>");
    continue;
  }
  if (/^>\s?/.test(l)) {
    const buf = [];
    while (i < lines.length && /^>\s?/.test(lines[i])) buf.push(lines[i++].replace(/^>\s?/, ""));
    out.push("<blockquote>" + buf.map(b => inline(b)).join("<br>") + "</blockquote>");
    continue;
  }
  if (isList(l)) {
    const items = [];
    let kind = "ul";
    while (i < lines.length && isList(lines[i])) {
      const raw = lines[i].replace(/^\s+/, "");
      const t = raw.match(/^-\s+\[([ xX])\]\s+(.*)$/);
      if (t) { items.push('<li class="task"><span class="cb">' + (t[1].toLowerCase() === "x" ? "☑" : "☐") + "</span>" + inline(t[2]) + "</li>"); }
      else if (/^[-*]\s+/.test(raw)) items.push("<li>" + inline(raw.replace(/^[-*]\s+/, "")) + "</li>");
      else { kind = "ol"; items.push("<li>" + inline(raw.replace(/^\d+\.\s+/, "")) + "</li>"); }
      i++;
    }
    out.push("<" + kind + ">" + items.join("") + "</" + kind + ">");
    continue;
  }
  const buf = [];
  while (i < lines.length && !/^\s*$/.test(lines[i]) && !/^(#{1,6}\s|>|\s*[-*]\s|\s*\d+\.\s|\|)/.test(lines[i]) && !isFence(lines[i])) buf.push(lines[i++]);
  if (buf.length) out.push("<p>" + inline(buf.join(" ")) + "</p>"); else i++;
}

const title = path.basename(inp).replace(/\.md$/, "");
const cssHref = path.relative(path.dirname(outp), cssArg).replace(/\\/g, "/");
const html = '<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><title>' + esc(title) +
  '</title><link rel="stylesheet" href="' + cssHref + '"></head><body class="cols' + cols + '">' +
  out.join("\n") + "</body></html>";
fs.writeFileSync(outp, html, "utf8");
console.log("OK " + path.basename(inp) + " -> " + path.basename(outp) + " (" + out.length + " blocks, cols=" + cols + ")");
