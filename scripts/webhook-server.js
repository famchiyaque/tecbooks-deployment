/**
 * Simple webhook server to receive GitHub push events
 * Runs on port 9000 and triggers deployment script
 */

import http from 'http';
import crypto from 'crypto';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const PORT = 9000;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || 'your-webhook-secret-change-this';
const DEPLOY_SCRIPT = '/home/ubuntu/tecbooks/deployment/scripts/deploy-dev.sh';

// Verify GitHub webhook signature
function verifySignature(payload, signature) {
  if (!signature) return false;
  
  const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
  const digest = 'sha256=' + hmac.update(payload).digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(digest)
  );
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'POST' && req.url === '/webhook') {
    let body = '';
    
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', async () => {
      try {
        const signature = req.headers['x-hub-signature-256'];
        
        // Verify signature
        if (!verifySignature(body, signature)) {
          console.log('❌ Invalid signature');
          res.writeHead(401);
          res.end('Unauthorized');
          return;
        }
        
        const payload = JSON.parse(body);
        
        // Check if it's a push to develop branch
        if (payload.ref === 'refs/heads/develop') {
          console.log(`\n🚀 Push detected to develop branch`);
          console.log(`Repository: ${payload.repository.name}`);
          console.log(`Pusher: ${payload.pusher.name}`);
          console.log(`Commits: ${payload.commits.length}`);
          
          // Run deployment script
          console.log('Running deployment script...');
          const { stdout, stderr } = await execAsync(`bash ${DEPLOY_SCRIPT}`);
          
          console.log('STDOUT:', stdout);
          if (stderr) console.log('STDERR:', stderr);
          
          console.log('✅ Deployment complete\n');
          
          res.writeHead(200);
          res.end('Deployment triggered');
        } else {
          console.log(`ℹ️  Push to ${payload.ref} - ignoring`);
          res.writeHead(200);
          res.end('Ignored - not develop branch');
        }
      } catch (error) {
        console.error('❌ Error:', error);
        res.writeHead(500);
        res.end('Internal Server Error');
      }
    });
  } else if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200);
    res.end('Webhook server is running');
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

server.listen(PORT, () => {
  console.log(`🎣 Webhook server listening on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
