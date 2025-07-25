// ~/node-global-proxy/socks5-agent-injector.js
import http from 'http';
import https from 'https';
import { SocksProxyAgent } from 'socks-proxy-agent';

console.log('[GLOBAL_PROXY_DEBUG] Injector script started. (Using globalAgent Patching)'); // Updated debug message

const SOCKS5_PROXY_URI = process.env.NODEJS_GLOBAL_SOCKS5_PROXY;

if (SOCKS5_PROXY_URI) {
    console.log(`[GLOBAL_PROXY_DEBUG] NODEJS_GLOBAL_SOCKS5_PROXY found: ${SOCKS5_PROXY_URI}`);
    try {
        const agent = new SocksProxyAgent(SOCKS5_PROXY_URI);
        console.log('[GLOBAL_PROXY_DEBUG] SocksProxyAgent instance created successfully.');

        // --- NEW PATCHING LOGIC: Assign SocksProxyAgent to globalAgent ---
        http.globalAgent = agent;
        https.globalAgent = agent;
        console.log('[GLOBAL_PROXY_DEBUG] http.globalAgent and https.globalAgent patched successfully.');
        // -----------------------------------------------------------------

        console.log('[Node.js Global Proxy] HTTP/HTTPS requests are now routed through SOCKS5 proxy via globalAgent.');

    } catch (e) {
        console.error(`[Node.js Global Proxy] CRITICAL ERROR during proxy setup: ${e.message}`);
        console.error('[Node.js Global Proxy] Stack Trace:', e.stack);
    }
} else {
    console.log('[Node.js Global Proxy] NODEJS_GLOBAL_SOCKS5_PROXY environment variable not set. No proxy applied globally.');
}
console.log('[GLOBAL_PROXY_DEBUG] Injector script finished execution.');