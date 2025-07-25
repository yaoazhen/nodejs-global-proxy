// get-ip.js
import https from 'https';

// ANSI color codes
const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const BLUE = '\x1b[34m';
const NC = '\x1b[0m'; // No Color (resets the color)

async function getPublicIPv4() {
    console.log('Attempting to get your public IPv4 address...');

    return new Promise((resolve, reject) => {
        https.get('https://ipv4.icanhazip.com', (res) => {
            let data = '';

            // Receiving data chunks
            res.on('data', (chunk) => {
                data += chunk;
            });

            // Complete response received
            res.on('end', () => {
                const publicIp = data.trim(); // Remove possible newlines or spaces
                if (publicIp) {
                    // Display IP address line in red
                    console.log(`${RED}Your public IPv4 address is: ${publicIp}${NC}`);
                    resolve(publicIp);
                } else {
                    reject(new Error('Failed to get IPv4 address from response.'));
                }
            });

        }).on('error', (err) => {
            console.error('Error occurred while getting public IPv4:', err.message);
            reject(err);
        });
    });
}

// Call the function
getPublicIPv4()
    .then(() => console.log('Public IPv4 retrieval process completed.'))
    .catch((error) => console.error('Failed to get IPv4:', error.message));