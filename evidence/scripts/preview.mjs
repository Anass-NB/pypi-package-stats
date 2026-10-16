/**
 * Local preview of the production build under the GitHub Pages base path,
 * exactly like the deployed site: http://localhost:4173/pypi-package-stats/
 *
 * (`evidence preview` runs `npx serve build`, which serves at "/" and breaks
 * when a deployment.basePath is configured — hence this small server.)
 *
 * Usage: npm run preview   (optional: PORT=xxxx)
 */
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import path from 'node:path';

const BASE_PATH = '/pypi-package-stats';
const BUILD_DIR = path.resolve('build');
const PORT = Number(process.env.PORT ?? 4173);

const MIME_TYPES = {
	'.html': 'text/html; charset=utf-8',
	'.js': 'text/javascript; charset=utf-8',
	'.mjs': 'text/javascript; charset=utf-8',
	'.css': 'text/css; charset=utf-8',
	'.json': 'application/json; charset=utf-8',
	'.webmanifest': 'application/manifest+json; charset=utf-8',
	'.parquet': 'application/octet-stream',
	'.arrow': 'application/vnd.apache.arrow.file',
	'.wasm': 'application/wasm',
	'.svg': 'image/svg+xml',
	'.png': 'image/png',
	'.ico': 'image/x-icon',
	'.map': 'application/json; charset=utf-8',
	'.txt': 'text/plain; charset=utf-8'
};

function notFound(res, message) {
	res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
	res.end(message);
}

const server = createServer(async (req, res) => {
	try {
		const { pathname } = new URL(req.url ?? '/', `http://localhost:${PORT}`);
		const decoded = decodeURIComponent(pathname);

		if (decoded === '/' || decoded === BASE_PATH) {
			res.writeHead(302, { Location: `${BASE_PATH}/` });
			return res.end();
		}
		if (!decoded.startsWith(`${BASE_PATH}/`)) {
			return notFound(res, `404 — the site is served under ${BASE_PATH}/`);
		}

		const relative = decoded.slice(BASE_PATH.length).replace(/^\/+/, '');
		const root = path.resolve(BUILD_DIR, relative);
		if (root !== BUILD_DIR && !root.startsWith(BUILD_DIR + path.sep)) {
			return notFound(res, '404 — not found');
		}

		const candidates = [root, path.join(root, 'index.html')];
		let file;
		let body;
		for (const candidate of candidates) {
			try {
				body = await readFile(candidate);
				file = candidate;
				break;
			} catch {
				// try the next candidate
			}
		}
		if (!body) {
			return notFound(res, '404 — not found');
		}

		const headers = {
			'Content-Type': MIME_TYPES[path.extname(file).toLowerCase()] ?? 'application/octet-stream',
			'Cache-Control': 'no-store',
			'Accept-Ranges': 'bytes'
		};

		const range = /^bytes=(\d*)-(\d*)$/.exec(req.headers.range ?? '');
		if (range) {
			const start = range[1] ? Number(range[1]) : 0;
			const end = range[2] ? Number(range[2]) : body.length - 1;
			if (start <= end && end < body.length) {
				const slice = body.subarray(start, end + 1);
				res.writeHead(206, {
					...headers,
					'Content-Range': `bytes ${start}-${end}/${body.length}`,
					'Content-Length': slice.length
				});
				return res.end(req.method === 'HEAD' ? undefined : slice);
			}
			res.writeHead(416, { ...headers, 'Content-Range': `bytes */${body.length}` });
			return res.end();
		}

		res.writeHead(200, { ...headers, 'Content-Length': body.length });
		res.end(req.method === 'HEAD' ? undefined : body);
	} catch (error) {
		console.error(error);
		res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
		res.end('500 — internal error');
	}
});

server.listen(PORT, () => {
	console.log(`\n  Preview (production build): http://localhost:${PORT}${BASE_PATH}/`);
	console.log(`  Serving: ${BUILD_DIR}\n`);
});
