const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

test("package.json defines required runtime dependencies and entry point", () => {
  const pkgPath = path.join(__dirname, "..", "package.json");
  const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
  assert.equal(pkg.main, "server.js");
  assert.ok(pkg.dependencies.express, "express dependency is required");
  assert.ok(pkg.dependencies.mysql2, "mysql2 dependency is required");
});

test("server.js exposes /health and /ready probes for Kubernetes liveness/readiness", () => {
  const serverPath = path.join(__dirname, "..", "server.js");
  const src = fs.readFileSync(serverPath, "utf8");
  assert.match(src, /app\.get\(\s*["']\/health["']/);
  assert.match(src, /app\.get\(\s*["']\/ready["']/);
});

test("static frontend assets exist", () => {
  const frontendIndex = path.join(__dirname, "..", "frontend", "index.html");
  assert.ok(fs.existsSync(frontendIndex), "frontend/index.html must exist");
});
