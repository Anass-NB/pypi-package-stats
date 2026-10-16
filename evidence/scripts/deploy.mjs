/**
 * Deterministic GitHub Pages deploy for this Evidence project.
 *
 * Publishes the static build (`./build`) to the `gh-pages` branch as a single
 * fresh commit and force-pushes it, so the branch always mirrors the build
 * exactly (no stale files, no gh-pages-package cache surprises).
 *
 * Usage: npm run deploy
 */
import { cpSync, existsSync, mkdtempSync, rmSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';

const BRANCH = 'gh-pages';
const BUILD_DIR = path.resolve('build');

if (!existsSync(path.join(BUILD_DIR, 'index.html'))) {
	console.error(`No build found at ${BUILD_DIR}. Run "npm run build:strict" first.`);
	process.exit(1);
}

const remote = execSync('git remote get-url origin', { encoding: 'utf8' }).trim();
console.log(`Deploying ${BUILD_DIR} to ${remote} (${BRANCH})`);

const work = mkdtempSync(path.join(tmpdir(), 'evidence-gh-pages-'));
const run = (cmd) => execSync(cmd, { cwd: work, stdio: 'inherit' });

try {
	run('git init -q');
	run(`git checkout -q -b ${BRANCH}`);
	run(`git remote add origin "${remote}"`);

	cpSync(BUILD_DIR, work, { recursive: true });

	run('git add -A');
	run('git commit -q -m "Deploy Evidence dashboard"');
	run(`git push -q -f origin ${BRANCH}`);
	console.log(`Published to ${BRANCH}.`);
} finally {
	rmSync(work, { recursive: true, force: true });
}
