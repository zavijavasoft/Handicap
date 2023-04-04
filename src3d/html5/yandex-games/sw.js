const CACHE_NAME = CACHE_PREFIX + "-v." + EXPORT_VERSION;

const cacheList = [
    "index.html",
    "yandex-games-godot.js",
    "yandex-metrika.js",
    "yandex_manifest.js",
    "app-specific.js",
    "sw.js",
    "handicap.wasm",
    "handicap.pck",
    "handicap.png",
    "handicap.background_icon.png",
    "handicap.icon.png",
    "handicap.apple_touch_icon.png"
];

this.addEventListener('install', function (event) {
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            return cache.addAll(cacheList);
        })
    );
});


this.addEventListener('activate', function (event) {
    event.waitUntil(
        caches.keys().then(keyList => {
            return Promise.all(keyList.map(key => {
                if (key.indexOf(CACHE_PREFIX) === 0 && key !== CACHE_NAME) {
                    return caches.delete(key);
                }
            }));
        })
    );
});

this.addEventListener('fetch', function (event) {
 if (
        event.request.method !== 'GET' ||
        event.request.url.indexOf('http://') === 0 ||
        event.request.url.indexOf('an.yandex.ru') !== -1
    ) {
        return;
    }
    event.respondWith(
        caches.match(event.request).then(function(response) {
            return response || fetch(event.request);
        })
    );
});
