const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const { app, BrowserWindow, shell } = require('electron');

let mainWindow;
let localServer;
let appOrigin;

const SUPPORTED_LANGUAGES = new Set(['ar','de','en']);
function languageFilePath() { return path.join(app.getPath('userData'), 'preferred-language.txt'); }
function readPreferredLanguage() {
  try {
    const value = fs.readFileSync(languageFilePath(), 'utf8').trim().toLowerCase();
    if (SUPPORTED_LANGUAGES.has(value)) return value;
  } catch {}
  const locale = String(app.getLocale() || '').toLowerCase();
  if (locale.startsWith('ar')) return 'ar';
  if (locale.startsWith('de')) return 'de';
  return 'en';
}
function writePreferredLanguage(lang) {
  if (!SUPPORTED_LANGUAGES.has(lang)) return false;
  try {
    fs.mkdirSync(path.dirname(languageFilePath()), { recursive: true });
    fs.writeFileSync(languageFilePath(), lang, 'utf8');
    return true;
  } catch { return false; }
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.txt': 'text/plain; charset=utf-8',
  '.json': 'application/json; charset=utf-8'
};

function startLocalServer() {
  return new Promise((resolve, reject) => {
    localServer = http.createServer((request, response) => {
      try {
        const requestUrl = new URL(request.url, 'http://127.0.0.1');
        const rawPath = requestUrl.pathname;

        if (rawPath === '/__set_language' && request.method === 'POST') {
          const lang = String(requestUrl.searchParams.get('lang') || '').toLowerCase();
          const ok = writePreferredLanguage(lang);
          response.writeHead(ok ? 204 : 400, { 'Cache-Control': 'no-store' });
          response.end();
          return;
        }

        const relativePath = rawPath === '/' ? 'index.html' : decodeURIComponent(rawPath.slice(1));
        const safePath = path.normalize(relativePath).replace(/^(\.\.(\/|\\|$))+/, '');
        const filePath = path.join(__dirname, safePath);

        if (!filePath.startsWith(__dirname) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
          response.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
          response.end('Not found');
          return;
        }

        const extension = path.extname(filePath).toLowerCase();
        response.writeHead(200, {
          'Content-Type': MIME_TYPES[extension] || 'application/octet-stream',
          'Cache-Control': 'no-store'
        });
        fs.createReadStream(filePath).pipe(response);
      } catch (error) {
        response.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
        response.end('Internal error');
      }
    });

    localServer.once('error', reject);
    localServer.listen(0, '127.0.0.1', () => {
      const address = localServer.address();
      appOrigin = `http://127.0.0.1:${address.port}`;
      resolve(appOrigin);
    });
  });
}

function createWindow(origin) {
  mainWindow = new BrowserWindow({
    width: 1180,
    height: 800,
    minWidth: 760,
    minHeight: 600,
    backgroundColor: '#10251f',
    autoHideMenuBar: true,
    title: 'صدقة — Sadaqah Path',
    icon: path.join(__dirname, 'assets', 'icon.png'),
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      backgroundThrottling: false
    }
  });

  mainWindow.setMenuBarVisibility(false);
  const preferredLanguage = readPreferredLanguage();
  mainWindow.loadURL(`${origin}/?lang=${encodeURIComponent(preferredLanguage)}`);

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('https://')) shell.openExternal(url);
    return { action: 'deny' };
  });

  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (!url.startsWith(appOrigin)) event.preventDefault();
  });

  mainWindow.webContents.on('before-input-event', (event, input) => {
    if (input.type !== 'keyDown') return;
    if (input.key === 'F11') {
      mainWindow.setFullScreen(!mainWindow.isFullScreen());
      event.preventDefault();
    } else if (input.key === 'Escape' && mainWindow.isFullScreen()) {
      mainWindow.setFullScreen(false);
      event.preventDefault();
    }
  });
}

app.commandLine.appendSwitch('autoplay-policy', 'no-user-gesture-required');

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (!mainWindow) return;
    if (mainWindow.isMinimized()) mainWindow.restore();
    mainWindow.focus();
  });

  app.whenReady().then(async () => {
    app.setAppUserModelId('com.ettech.sadaqahpath');
    const origin = await startLocalServer();
    createWindow(origin);
    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) createWindow(origin);
    });
  }).catch(error => {
    console.error(error);
    app.quit();
  });
}

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('before-quit', () => {
  if (localServer) localServer.close();
});
