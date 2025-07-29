// test-proxy.js - IP Address Testing with Proxy Support
import '../socks5-agent-injector.js';
import https from 'https';
import http from 'http';

// ANSI color codes
const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const BLUE = '\x1b[34m';
const CYAN = '\x1b[36m';
const NC = '\x1b[0m'; // No Color (resets the color)

// Test using HTTP module
async function getIPviaHTTP() {
    console.log(`${BLUE}Testing IP via HTTP module...${NC}`);

    return new Promise((resolve, reject) => {
        http.get('http://api.ipify.org?format=json', (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                try {
                    const result = JSON.parse(data);
                    const ip = result.ip;
                    console.log(`${GREEN}IP via HTTP: ${ip}${NC}`);
                    resolve(ip);
                } catch (e) {
                    reject(new Error('Failed to parse HTTP response'));
                }
            });

        }).on('error', (err) => {
            console.error(`${RED}HTTP test failed: ${err.message}${NC}`);
            reject(err);
        });
    });
}

// Test using HTTPS module
async function getIPviaHTTPS() {
    console.log(`${BLUE}Testing IP via HTTPS module...${NC}`);

    return new Promise((resolve, reject) => {
        https.get('https://api.ipify.org?format=json', (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                try {
                    const result = JSON.parse(data);
                    const ip = result.ip;
                    console.log(`${GREEN}IP via HTTPS: ${ip}${NC}`);
                    resolve(ip);
                } catch (e) {
                    reject(new Error('Failed to parse HTTPS response'));
                }
            });

        }).on('error', (err) => {
            console.error(`${RED}HTTPS test failed: ${err.message}${NC}`);
            reject(err);
        });
    });
}

// Test using Fetch API
async function getIPviaFetch() {
    console.log(`${BLUE}Testing IP via Fetch API...${NC}`);

    try {
        const response = await fetch('https://httpbin.org/ip');
        const data = await response.json();
        const ip = data.origin;
        console.log(`${GREEN}IP via Fetch: ${ip}${NC}`);
        return ip;
    } catch (error) {
        console.error(`${RED}Fetch test failed: ${error.message}${NC}`);
        throw error;
    }
}

// Test location information
async function getLocationInfo() {
    console.log(`${BLUE}Testing location information...${NC}`);

    try {
        const response = await fetch('https://ipapi.co/json/');
        const data = await response.json();

        console.log(`${CYAN}Location Info:${NC}`);
        console.log(`  IP: ${data.ip}`);
        console.log(`  Country: ${data.country_name}`);
        console.log(`  City: ${data.city}`);
        console.log(`  Region: ${data.region}`);

        return data;
    } catch (error) {
        console.error(`${RED}Location test failed: ${error.message}${NC}`);
        throw error;
    }
}

// Main test function
async function runAllTests() {
    console.log(`${YELLOW}=== IP Address and Proxy Testing ===${NC}\n`);

    const results = {};

    try {
        // Test 1: HTTP module
        results.http = await getIPviaHTTP();

        console.log(''); // Empty line for spacing

        // Test 2: HTTPS module
        results.https = await getIPviaHTTPS();

        console.log(''); // Empty line for spacing

        // Test 3: Fetch API
        results.fetch = await getIPviaFetch();

        console.log(''); // Empty line for spacing

        // Test 4: Location information
        await getLocationInfo();

        console.log(''); // Empty line for spacing

        // Compare results
        const ips = [results.http, results.https, results.fetch.split(',')[0].trim()];
        const uniqueIPs = [...new Set(ips)];

        if (uniqueIPs.length === 1) {
            console.log(`${GREEN}✅ All methods returned the same IP: ${uniqueIPs[0]}${NC}`);
        } else {
            console.log(`${YELLOW}⚠️  Different IPs detected:${NC}`);
            console.log(`   HTTP:  ${results.http}`);
            console.log(`   HTTPS: ${results.https}`);
            console.log(`   Fetch: ${results.fetch}`);
        }

        // Check if proxy is working
        const proxyEnv = process.env.NODEJS_GLOBAL_SOCKS5_PROXY;
        if (proxyEnv) {
            console.log(`${GREEN}✅ Proxy configured: ${proxyEnv}${NC}`);
        } else {
            console.log(`${YELLOW}⚠️  No proxy configured${NC}`);
        }

        console.log(`\n${GREEN}All tests completed successfully!${NC}`);

    } catch (error) {
        console.error(`${RED}Test failed: ${error.message}${NC}`);
    }
}

// Run all tests
runAllTests();