const CACHE_NAME = CACHE_PREFIX + "-v." + EXPORT_VERSION;

const cacheList = [
    'index.html',
    PRODUCT_NAME + '.js',
    PRODUCT_NAME + '.png',
    PRODUCT_NAME + '_bg.png',
    PRODUCT_NAME + '.pck.gz',
    PRODUCT_NAME + '.wasm.gz',
    "sw.js",
    "pako_inflate.min.js",
    "favicon.png",
    "yandex-metrika.js",
    "yandex-games-godot.js",
    "app-specific.js",
    "godot-loader.js"    
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
