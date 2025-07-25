// test-proxy-direct.js
import https from 'https';
import { SocksProxyAgent } from 'socks-proxy-agent';

// --- YOUR PROXY CONFIGURATION ---
const SOCKS5_PROXY_URI = "socks5://127.0.0.1:1086"; // <<-- Confirm this matches your proxy's exact address and port!

console.log(`[DIRECT_TEST] Using SOCKS5 Proxy: ${SOCKS5_PROXY_URI}`);

async function getPublicIPv4ThroughProxy() {
    return new Promise((resolve, reject) => {
        try {
            // Create the SocksProxyAgent directly
            const agent = new SocksProxyAgent(SOCKS5_PROXY_URI);
            console.log('[DIRECT_TEST] SocksProxyAgent created successfully for direct test.');

            // Options for the HTTPS request
            const options = {
                hostname: 'ipv4.icanhazip.com',
                port: 443,
                path: '/',
                method: 'GET',
                agent: agent // <<-- Explicitly assign the agent here
            };

            console.log('[DIRECT_TEST] Sending HTTPS request with explicit agent...');

            const req = https.request(options, (res) => {
                let data = '';
                res.on('data', (chunk) => { data += chunk; });
                res.on('end', () => {
                    const publicIp = data.trim();
                    if (publicIp) {
                        console.log(`[DIRECT_TEST] Public IPv4 via Proxy: ${publicIp}`);
                        resolve(publicIp);
                    } else {
                        reject(new Error('Failed to get IPv4 address from response.'));
                    }
                });
            });

            req.on('error', (err) => {
                console.error('[DIRECT_TEST] Error fetching public IPv4 through proxy:', err.message);
                reject(err);
            });

            req.end(); // End the request
        } catch (e) {
            console.error('[DIRECT_TEST] Critical error in direct test setup:', e.message);
            reject(e);
        }
    });
}

// Call the function
getPublicIPv4ThroughProxy()
    .then(() => console.log('[DIRECT_TEST] Direct proxy test complete.'))
    .catch((error) => console.error('[DIRECT_TEST] Direct proxy test failed:', error.message));