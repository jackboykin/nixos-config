import { readdirSync, readFileSync, statSync } from "fs";

const [src, outfile] = process.argv.slice(2);
const list = (dir: string) => readdirSync(dir, { recursive: true }).filter((n) => statSync(`${dir}/${n}`).isFile());
const modules = list(`${src}/modules`);
const text = new Map(modules.filter((n) => /\.(md|txt)$/.test(n)).map((n) => [n, readFileSync(`${src}/modules/${n}`, "utf8")]));
const code = ["cli", ...modules.filter((n) => n !== "cli" && !text.has(n))];

const rewrite = (js: string) =>
  js
    .replace(/[\w$.]+\("\/\$bunfs\/root\/([^"]+\.(?:md|txt))"\)/g, (call, n) => (text.has(n) ? JSON.stringify(text.get(n)) : call))
    .replace(/(\/\$bunfs\/root\/[^"]+)\.mjs"/g, '$1.js"');

const result = await Bun.build({
  entrypoints: code.map((n) => `${src}/modules/${n}`),
  root: `${src}/modules`,
  target: "bun",
  format: "esm",
  splitting: true,
  naming: { entry: "[dir]/[name].[ext]" },
  plugins: [{
    name: "bunfs",
    setup(build) {
      build.onResolve({ filter: /^\/\$bunfs\/root\// }, (a) => ({ path: `${src}/modules/${a.path.slice(13)}` }));
      build.onLoad({ filter: /\/modules\/(cli|.*\.m?js)$/ }, (a) => ({ contents: rewrite(readFileSync(a.path, "utf8")), loader: "js" }));
    },
  }],
  compile: {
    outfile,
    executablePath: process.env.BASE,
    execArgv: JSON.parse(readFileSync(`${src}/exec-argv.json`, "utf8")),
    assets: list(`${src}/assets`).map((n) => `${src}/assets/${n}`),
    autoloadDotenv: false,
    autoloadBunfig: false,
    allowCodeFromDisk: true,
    aot: true,
  },
});
if (!result.success) {
  console.error(...result.logs);
  process.exit(1);
}
