/* Bhadram — Service Worker (permite instalar como app e carregar rápido) */
const CACHE = 'bhadram-v1';
const ASSETS = [
  './vendedor.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png'
];
 
self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});
 
self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});
 
self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  // Chamadas externas (Supabase, biblioteca via CDN) sempre pela rede — nunca do cache.
  if (url.origin !== location.origin) return;
  if (e.request.method !== 'GET') return;
  // App shell: tenta cache primeiro, cai para a rede.
  e.respondWith(
    caches.match(e.request).then((r) => r || fetch(e.request).then((resp) => {
      const copy = resp.clone();
      caches.open(CACHE).then((c) => c.put(e.request, copy)).catch(() => {});
      return resp;
    }).catch(() => caches.match('./vendedor.html')))
  );
});
 
