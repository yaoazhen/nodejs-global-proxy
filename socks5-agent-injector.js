// ~/node-global-proxy/socks5-agent-injector.js
import http from 'http';
import https from 'https';
import { SocksProxyAgent } from 'socks-proxy-agent';

console.log('[GLOBAL_PROXY_DEBUG] Injector script started.');

const SOCKS5_PROXY_URI = process.env.NODEJS_GLOBAL_SOCKS5_PROXY;

// Function to patch fetch API
function patchFetch(agent) {
    // Replace global fetch with node-fetch that supports SOCKS proxy
    import('node-fetch').then(nodeFetch => {
        const fetch = nodeFetch.default || nodeFetch;

        globalThis.fetch = function (url, options = {}) {
            console.log(`[GLOBAL_PROXY_DEBUG] Fetch request intercepted: ${url}`);

            // Force agent for fetch
            options.agent = agent;

            return fetch(url, options);
        };

        console.log('[GLOBAL_PROXY_DEBUG] Global fetch replaced with node-fetch + SOCKS5 proxy.');
    }).catch(() => {
        console.log('[GLOBAL_PROXY_DEBUG] node-fetch not available, using fallback');

        // Fallback to original fetch with agent
        if (typeof globalThis.fetch !== 'undefined') {
            const originalFetch = globalThis.fetch;

            globalThis.fetch = function (url, options = {}) {
                console.log(`[GLOBAL_PROXY_DEBUG] Fetch request intercepted (fallback): ${url}`);

                // Force agent for fetch
                options.agent = agent;

                return originalFetch.call(this, url, options);
            };

            console.log('[GLOBAL_PROXY_DEBUG] Global fetch API patched for SOCKS5 proxy (fallback).');
        }
    });
}

// Function to patch HTTP/HTTPS methods
function patchHttpMethods(agent) {
    // Store original methods
    const originalHttpRequest = http.request;
    const originalHttpsRequest = https.request;
    const originalHttpGet = http.get;
    const originalHttpsGet = https.get;

    // Patch http.request
    http.request = function (options, callback) {
        if (typeof options === 'string') {
            options = new URL(options);
        }
        if (!options.agent) {
            options.agent = agent;
        }
        console.log(`[GLOBAL_PROXY_DEBUG] HTTP request forced through proxy: ${options.hostname || options.host}`);
        return originalHttpRequest.call(this, options, callback);
    };

    // Patch https.request
    https.request = function (options, callback) {
        if (typeof options === 'string') {
            options = new URL(options);
        }
        if (!options.agent) {
            options.agent = agent;
        }
        console.log(`[GLOBAL_PROXY_DEBUG] HTTPS request forced through proxy: ${options.hostname || options.host}`);
        return originalHttpsRequest.call(this, options, callback);
    };

    // Patch http.get
    http.get = function (options, callback) {
        if (typeof options === 'string') {
            options = new URL(options);
        }
        if (!options.agent) {
            options.agent = agent;
        }
        console.log(`[GLOBAL_PROXY_DEBUG] HTTP GET forced through proxy: ${options.hostname || options.host}`);
        return originalHttpGet.call(this, options, callback);
    };

    // Patch https.get
    https.get = function (options, callback) {
        if (typeof options === 'string') {
            options = new URL(options);
        }
        if (!options.agent) {
            options.agent = agent;
        }
        console.log(`[GLOBAL_PROXY_DEBUG] HTTPS GET forced through proxy: ${options.hostname || options.host}`);
        return originalHttpsGet.call(this, options, callback);
    };

    console.log('[GLOBAL_PROXY_DEBUG] HTTP/HTTPS methods patched for SOCKS5 proxy.');
}

async function initializeProxy() {
    if (SOCKS5_PROXY_URI) {
        console.log(`[GLOBAL_PROXY_DEBUG] NODEJS_GLOBAL_SOCKS5_PROXY found: ${SOCKS5_PROXY_URI}`);
        try {
            const agent = new SocksProxyAgent(SOCKS5_PROXY_URI);
            console.log('[GLOBAL_PROXY_DEBUG] SocksProxyAgent instance created successfully.');

            // Set global agents
            http.globalAgent = agent;
            https.globalAgent = agent;
            console.log('[GLOBAL_PROXY_DEBUG] http.globalAgent and https.globalAgent patched successfully.');

            // Patch HTTP/HTTPS methods
            patchHttpMethods(agent);

            // Patch Fetch API
            patchFetch(agent);
            console.log('[GLOBAL_PROXY_DEBUG] Fetch API patched for SOCKS5 proxy.');

            console.log('[Node.js Global Proxy] All HTTP/HTTPS/Fetch requests are now routed through SOCKS5 proxy.');

        } catch (e) {
            console.error(`[Node.js Global Proxy] CRITICAL ERROR during proxy setup: ${e.message}`);
            console.error('[Node.js Global Proxy] Stack Trace:', e.stack);
        }
    } else {
        console.log('[Node.js Global Proxy] NODEJS_GLOBAL_SOCKS5_PROXY environment variable not set. No proxy applied globally.');
    }
    console.log('[GLOBAL_PROXY_DEBUG] Injector script finished execution.');
}

// Initialize the proxy
initializeProxy().catch(console.error);