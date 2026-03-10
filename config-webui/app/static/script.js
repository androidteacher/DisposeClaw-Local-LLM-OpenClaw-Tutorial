async function saveToken() {
    const tokenInput = document.getElementById('bot-token');
    const saveBtn = document.getElementById('save-btn');
    const statusMsg = document.getElementById('save-status');
    const token = tokenInput.value.trim();

    if (!token) {
        showStatus('Please enter a valid token.', 'error');
        return;
    }

    saveBtn.disabled = true;
    saveBtn.textContent = 'Saving...';

    try {
        const response = await fetch('/api/save-token', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ token: token })
        });

        const data = await response.json();

        if (response.ok) {
            showStatus(data.message, 'success');
        } else {
            showStatus(data.detail || 'Failed to save token.', 'error');
        }
    } catch (error) {
        showStatus('Network error while saving token.', 'error');
    } finally {
        saveBtn.disabled = false;
        saveBtn.textContent = 'Save Token';
    }
}

function showStatus(message, type) {
    const statusMsg = document.getElementById('save-status');
    statusMsg.textContent = message;
    statusMsg.className = `status-msg ${type}`;
}

async function scanPairings() {
    const scanBtn = document.getElementById('scan-btn');
    const resultsBox = document.getElementById('pairing-results');
    
    scanBtn.disabled = true;
    scanBtn.textContent = 'Scanning...';

    try {
        const response = await fetch('/api/pairings');
        const data = await response.json();

        resultsBox.style.display = 'block';
        resultsBox.innerHTML = `
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <p><strong>OpenClaw Dashboard Action Required</strong></p>
                <p>${data.message}</p>
                <a href="http://localhost:8080" target="_blank" style="display: inline-block; background: #3b82f6; color: white; padding: 10px 20px; text-decoration: none; border-radius: 6px; text-align: center; font-weight: bold; margin-top: 8px;">Open Dashboard</a>
            </div>
        `;
    } catch (error) {
        resultsBox.style.display = 'block';
        resultsBox.innerHTML = `<p style="color: #ef4444;">Error fetching pairing instructions.</p>`;
    } finally {
        scanBtn.disabled = false;
        scanBtn.textContent = 'How to Approve Pairing ➡️';
    }
}
