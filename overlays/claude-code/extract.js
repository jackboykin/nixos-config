const fs = require("fs"), path = require("path");
const root = "/$bunfs/root", out = process.env.OUT;
const assets = new Set(Bun.embeddedFiles.map((b) => b.name));
for (const n of fs.readdirSync(root, { recursive: true })) {
  if (fs.statSync(`${root}/${n}`).isDirectory()) continue;
  const dst = `${out}/${assets.has(n) ? "assets" : "modules"}/${n}`;
  fs.mkdirSync(path.dirname(dst), { recursive: true });
  fs.writeFileSync(dst, fs.readFileSync(`${root}/${n}`));
}
const argv = process.execArgv.filter((a, i, all) => a !== "--preload" && all[i - 1] !== "--preload");
fs.writeFileSync(`${out}/exec-argv.json`, JSON.stringify(argv));
process.exit(0);
